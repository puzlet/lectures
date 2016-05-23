#------------------------------------------------------#
# Slides
#------------------------------------------------------#

class Slides
  
  constructor: ->
    
    return unless $(document.body).hasClass("slides")
    
    @sections = $ "section"
    @sections.hide()
    @sections.css visibility: "visible"
    
    @current = 0
    $(@sections[@current]).show()
    
    @lecture =
      doStep: => @navigate(1)
      back: => @navigate(-1)
      reset: =>
    
    KeyHandler.init @lecture
    
    @number = $ ".slide-navigation .slide-number"
    @next = $ ".slide-navigation .next"
    @prev = $ ".slide-navigation .prev"
      
    @setNavButtons()
    
    @next.click => @lecture.doStep()
    @prev.click => @lecture.back()
    
  setNavButtons: ->
    @number.html "#{@current+1} of #{@sections.length}"
    enable = (b, e=true) =>
      b.toggleClass "nav-button-enable", e
      b.toggleClass "nav-button-disable", not(e)
    enable @next, (@current < @sections.length-1)
    enable @prev, @current > 0
    
  navigate: (d) =>
    $(@sections[@current]).hide()
    @current++ if d>0 and @current<@sections.length-1
    @current-- if d<0 and @current>0
    $(@sections[@current]).show()
    @setNavButtons()


class KeyHandler
  
  @lecture: null
  
  @init: (lecture) ->
    KeyHandler.lecture = lecture
    handler = (evt) => KeyHandler.keyDown(evt)
    $("body").unbind "keydown", handler
    $("body").bind "keydown", handler
  
  @keyDown: (evt) ->
    lecture = KeyHandler.lecture
    return unless evt.target.tagName is "BODY"
    return unless lecture
    if evt.keyCode is 37
      lecture?.back()
    else if evt.keyCode is 39
      lecture?.doStep()
    #else if evt.keyCode is 27  # Escape
    #  lecture?.reset()
    #  lecture = null  # ZZZ better way?



#------------------------------------------------------#
# Exercises server
#------------------------------------------------------#

class Server
  
  @lectureId: null #"complex-numbers"  # TODO: settable in some other place
  
  @local: "//puzlet.mvclark.dev"
  @public: "//puzlet.mvclark.com"
  
  @aceUrl: "/puzlet/ace/ace.js"  # For loading Ace after exercises data.
  
  @ready: false
  @groupId: null
  @userId: null
  
  @isLocal: window.location.hostname is "localhost"
    
  @url: if @isLocal then @local else @public
  
  # To delete/change.
  @getAll: (callback) ->
    $.get "#{@url}", (@data) ->
      console.log "All exercises from server", @data
      callback?(@data)
  
  # Fetch records for group/user/lecture.
  @fetch: (callback) ->
    unless @ready and @groupId and @userId
      callback?()
      return
    ids =
      groupId: @groupId
      userId: @userId
      lectureId: @lectureId
    $.get "#{@url}/exercise/fetch", ids, (@data) =>
      console.log "Exercises from server", ids, @data
      callback?(@data)
  
  @put: (exerciseId, content, correct) ->
    console.log "Exercises record", exerciseId, content, correct
    return unless @ready and @groupId and @userId
    record =
      groupId: @groupId
      userId: @userId
      lectureId: @lectureId
      exerciseId: exerciseId
      code: content
      correct: if correct then 1 else 0
    console.log "PUT data", record
    $.ajax
      type: "POST"
      url: "#{@url}/exercise/create"
      data: record
      dataType: 'json'
      success: (data) ->
        console.log "POST", data
        return if data.ok
        alert "Code not saved to server"
        
  @checkUser: (userId, callback) ->
    ids =
      groupId: @groupId
      userId: userId
      lectureId: @lectureId
    $.get "#{@url}/checkuser", ids, (data) =>
      console.log "User exists", ids, data
      callback?(data.userExists)
      
  @loadExercises: (@lectureId) ->
    @ready = true
    @fetch (exercisesData) =>
      # Ace after all figures rendered.
      if exercisesData
        $(document).on "aceFilesLoaded", =>
          $.event.trigger "exercisesDataLoaded", {exercises: exercisesData}
      @resources = $blab.resources
      @resources.add url: @aceUrl
      @resources.loadUnloaded => $Ace?.load(@resources)


class User
  
  # TODO: if user changes, need to revert to default inputs first.  reload page?
  # TODO: need a way to logout and reset editors.
  # TODO: check valid group id - when first set.
  
  groupCookie: "group-id"
  userCookie: "user-id"
  
  constructor: ->
    
    @groupInput = $(".group-id")
    @userInput = $(".user-id")
    
    @groupId = $.cookie(@groupCookie) ? 'public'
    if @groupId
      @groupInput.val @groupId
      @showUser()
    
    @userId = $.cookie(@userCookie)
    if @userId
      @userInput.val @userId
      @showUser()
    
    if @groupId and @userId
      @load()
    
    @groupInput.change (evt) =>
      @groupId = evt.target.value
      $.cookie(@groupCookie, @groupId, {expires: 100}) 
      if @userId
        #@load()
        window.location.reload()
      else
        @showUser()
        @userInput.focus()
      
    @userInput.change (evt) =>
      
      userId = evt.target.value
      
      Server.checkUser userId, (exists) =>
        
        if exists and window.location.hash isnt "#reset-user"
          
          # hash = reset-user is a temporary feature to reset user id.
          
          # Does not agree with cookie
          alert("Username not authenticated")
          @userInput.val @userId  # Revert value
          
          #window.location.reload()
          
        else
          # New user - set up cookie.
          @userId = userId
          $.cookie(@userCookie, @userId, {expires: 100}) 
          #@load()
          window.location.href = window.location.href.split('#')[0]
      
  showUser: ->
    #@groupInput.addClass "hide"
    @userInput.removeClass "hide"
  
  load: ->
    Server.groupId = @groupId
    Server.userId = @userId
    Server.fetch (data) =>
      $.event.trigger "exercisesDataLoaded", {exercises: data}


new User


#------------------------------------------------------#
# Exercises
#------------------------------------------------------#

$mathCoffee.preProcessor = (code) ->
  chars =
    "×":      "*"
    "⋅":      "*"
    "÷":      "/"
    "√":      "sqrt"
    "²":      "**2"
    "³":      "**3"
    "⁴":      "**4"
    "\u211C": "Re"
    "ℑ":      "Im"
    "₁":      "1"
    "₂":      "2"
  
  code = code.replace /√([a-zA-Z0-9]+)/g, 'sqrt($1)' # Special case: √val
  code = code.replace /([a-zA-Z0-9]+)π/g, '$1*π'  # nπ
  code = code.replace /\^/g, "**"
  code = code.replace /f\((.+)\) =/g, '($1) ->'  # function f(...) = [becomes anon function]
  code = code.replace /[^\x00-\x80]/g, (c) ->
    chars[c] ? c
  #console.log code
  #code


class Exercises
  
  constructor: (@id, @figure) ->
    
    sel = "#"+@id
    @mainButton = $("#{sel} .exercises-button")
    @container = $("#{sel} .exercises")
    @exercises = $("#{sel} .exercise")
    @next = $("#{sel} .next")
    @previous = $("#{sel} .previous")
    
    # Exercise process functions need to be accessible to exercise coffee.
    $blab.exercises ?= {}
    
    # Instantiate Exercise objects.
    for exercise in @exercises
      id = $(exercise).attr "id"
      E = $blab.Exercise[id]
      unless E
        console.log "!!!!!!!! NOT IMPLEMENTED: Exercise #{id}"
        E = ExerciseBase
      new E(id, @figure) if E
    
    @exercises.hide()
    @current = 0
    $(@exercises[@current]).show()
    
    @mainButton.click =>
      @mainButton.hide 500
      @container.hide()
      @container.toggleClass "hide"
      @container.slideDown()
    
    @next.click => @navigate(1)
    @previous.click => @navigate(-1)
    
    @setNavButtons()
    
  navigate: (dir) ->
    $(@exercises[@current]).hide()
    @current += dir
    $(@exercises[@current]).show()
    @setNavButtons()
    
  setNavButtons: ->
    @previous.toggleClass("disable", @current is 0)
    @next.toggleClass("disable", @current is @exercises.length-1)


class ExerciseBase
  
  codeButtons:
    "×": "⋅"
    "÷": "/"
    "x²": "²"
    "xʸ": "^"
    "√": "√"
    "π": "π"
    "θ": "θ"
    "eˣ": "exp()"
    "sin": "sin()"
    "cos": "cos()"
    #"Re": "Re "
    #"Im": "Im "
    
  preamble: """
    i = j
    π = pi
    Re = (z) -> z.x
    Im = (z) -> z.y
    
  """
  
  # Override in subclass
  processArgs: "{}"
  
  postamble: (process) -> """
    
    null
    #{process} #{@processArgs}
    
  """
  
  runCode: false
  
  constructor: (@id, @figure) ->
    @container = $("#"+@id)
    @url = @container.find('div[data-file]').data()?["file"]
    return unless @url
    @initButtons()
    
    $(document).on "exercisesDataLoaded", (evt, data) =>
      exerciseData = data.exercises.find (el) => el.exerciseId is @id
      @setCode(exerciseData.code) if exerciseData 
    
    # Are there compile events associated with this specific resource?
    # Is there a way to process only if shift-enter or swipe?  i.e., so not processed initially.
    $blab.exercises[@id] = (data) => @process(data)
    $(document).on "preCompileCoffee", (evt, data) =>
      @runCode = true  # Potential for bug here?
      @preCompile(data.resource)
    
    $(document).on "compiledCoffeeScript", (evt, data) =>
      return unless data.url is @url
      console.log "*** Compiled", @url
      @resource = $blab.resources.find @url
      @resultArray = @resource?.resultArray
      @postProcess(@resultArray)
      
    $(document).on "runCode", (evt, data) =>
      return unless data.filename is @url
      console.log "*** RUN", @url
      @runCode = true
      #@saveToServer()  # save: will need to save "correct" status after computed
      # ZZZ perhaps set flag - running.
  
  getEditor: ->
    resource = $blab.resources.find @url
    editor = resource.containers.fileNodes[0].editor
  
  saveToServer: ->
    return unless @runCode
    console.log "***** SAVE", @resource, @id, @resource.content, @correct
    Server.put @id, @resource.content, @correct
    @runCode = false
    
  setCode: (code) ->
    @getEditor().set code
    
  process: (data) ->  # Override in subclass
    
  postProcess: (evals) ->  # Override in subclass
  
  preCompile: (@coffee) ->
    
    return unless @coffee?.url is @url
    console.log "+++ Precompile", @url
    
    # Hide syntax checks in margin
    @editor = @getEditor()
    @editor.session().setUseWorker false
    
    # Do only once - after Ace compiled?
    @buttons.css fontFamily: @editor.editorContainer.css("font-family")
    
    precompile = {}
    process = "$blab.exercises['#{@id}']"
    postamble = @postamble(process)
    precompile[@url] = {@preamble, postamble}
    $blab.precompile(precompile)
  
  initButtons: ->
    @buttons = @container.find ".code-buttons"
    @codeButton(label, char) for label, char of @codeButtons
    text = $ "<div>",
      class: "run-instruction"
      html: "Press shift-enter to run"
    @buttons.append text
    
  codeButton: (label, char) ->
    new CodeButton
      container: @buttons
      editor: => @editor?.editor
      label: label
      char: char
      click: (char) =>
  
  text: (text, x=0, y=-1.5) ->
    canvas = @figure.canvas
    data = {x, y, text}
    clearTimeout(@tId) if @tId?
    @ttext?.text.remove()
    @ttext = new Text {canvas, data} #, class: c}
    @ttext.text.attr "text-anchor", "middle"
    @tId = setTimeout (=> @ttext.text.remove()), 2000
  
  ok: (correct) ->
    # Merge with above
    canvas = @figure.canvas
    txt = if correct then "Correct" else "Incorrect - Try again"
    data = {x: 0, y: -2, text: txt}
    c = if correct then "answer-correct" else "answer-incorrect"
    clearTimeout(@oId) if @oId?
    @oText?.text.remove()
    @oText = new Text {canvas, data, class: c}
    @oText.text.attr "text-anchor", "middle"
    @oId = setTimeout (=> @oText.text.remove()), 2000



#------------------------------------------------------#
# Exercise tools
#------------------------------------------------------#

class CodeButton
  
  constructor: (@spec) ->
    
    {@container, @editor, @label, @char, @click} = @spec
    
    @button = $ "<div>",
      class: "code-button"
      html: @label
      click: =>
        @editor?().insert @char
        @editor?().focus()
        if @char.match /\(\)/g
          {row, column} = @editor?().getCursorPosition()
          @editor?().moveCursorTo(row, column-1)
        @click?(this)
    
    if @label.length>2
      @button.css fontSize: "8pt"
    
    @container.append @button


class ButtonSet
  
  constructor: (@sectionId, @buttons)->
    
    @allButtons = $("#{@sectionId} .text-button")
    
    callback = (method) => =>
      @allButtons.addClass "disabled"
      method => @allButtons.removeClass "disabled"
      
    $("#{@sectionId} ##{b.id}").click(callback b.method) for b in @buttons
    



#------------------------------------------------------#
# d3 Elements
#------------------------------------------------------#

class Canvas
  
  constructor: (@spec) ->
    
    {@container, @width, @height, @margin, @xDomain, @yDomain} = @spec
    
    @graphics = d3.select @container[0]
    
    @graphics.selectAll("svg").remove()
    @svg = @graphics.append("svg")
      .attr('width', @width)
      .attr('height', @height)
      
    @w = @width - @margin.left - @margin.right
    
    @h = @height - @margin.top - @margin.bottom
    
    @canvas = @svg.append("g")
      .attr("transform", "translate(#{@margin.left}, #{@margin.top})")
      .attr("width", @w)
      .attr("height", @h)
    
    @mx = d3.scale.linear()
      .domain(@xDomain)
      .range([0, @w])
    
    @my = d3.scale.linear()
      .domain(@yDomain)
      .range([@h, 0])
      
  invertX: (x) -> @limit @mx.invert(x), @xDomain
  
  invertY: (y) -> @limit @my.invert(y), @yDomain
    
  limit: (z, d) ->
    return d[1] if z>d[1]
    return d[0] if z<d[0]
    z
  
  append: (obj) ->
    @canvas.append obj


class Line
  
  constructor: (@spec) ->
    
    {@canvas, @points, @class} = @spec
    
    @line = @canvas.append("line").attr("class", @class)
      
    {@mx, @my} = @canvas
    @set(@points) if @points?
    
  set: (@points) ->
    {x1, y1, x2, y2} = @points
    @line
      .attr "x1", @mx(x1)
      .attr "y1", @my(y1)
      .attr "x2", @mx(x2)
      .attr "y2", @my(y2)


class Arc
  
  constructor: (@spec) ->
    
    {@canvas, @data, @class} = @spec
    
    @path = @canvas.append("path").attr("class", @class)
    
    {@mx, @my} = @canvas
    @arc = d3.svg.arc()
      
    @set(@data) if @data?
    
  set: (@data) ->
    @arc.innerRadius(@data.innerRadius) if @data.innerRadius?
    @arc.outerRadius(@data.outerRadius) if @data.outerRadius?
    @arc.startAngle(@data.startAngle) if @data.startAngle?
    @arc.endAngle(@data.endAngle) if @data.endAngle?
    @path.attr "d",  @arc
    @path.attr("transform", "translate(#{@mx(@data.x)},#{@my(@data.y)})") if @data.x? and @data.y?


class Circle
  
  constructor: (@spec) ->
    
    {@canvas, @data, @draggable, @class, @click} = @spec
    
    @circle = @canvas.append("circle").attr("class", @class)
    @setDraggable() if @draggable
    
    {@mx, @my} = @canvas
    @set(@data) if @data?
    
  set: (@data) ->
    {x, y, r} = @data
    @circle
      .attr "cx", @mx(x)
      .attr "cy", @my(y)
      .attr "r", r  # map?
      
    if not @draggable and @click?
      @circle.on "click", => @click()
      
  setDraggable: ->
    @circle.call(d3.behavior
      .drag()
      .on "drag", =>
        x = d3.event.x
        y = d3.event.y
        @data.x = @canvas.invertX(x)
        @data.y = @canvas.invertY(y)
        @spec.callback?(@data)
    )
    
  setClass: (@class) -> @circle.attr "class", @class


class Polygon
  
  constructor: (@spec) ->
    
    {@canvas, @points, @class} = @spec
    @path = @canvas.append("path").attr("class", @class)
    
    {@mx, @my} = @canvas
    @line = d3.svg.line()
      .x((d) => @mx(d.x))
      .y((d) => @my(d.y))
      .interpolate("linear")
    
    @set(@points) if @points?
    
  set: (@points) ->
    # Z closes path
    @path.attr "d",  @line(@points) + "Z"


class GridLines
  
  constructor: (@spec) ->
    
    {@canvas} = @spec
    
    @xDomain = @canvas.xDomain
    @yDomain = @canvas.yDomain
    
    @xAxis = new Line
      canvas: @canvas
      class: "grid-line"
      points:
        x1: @xDomain[0]
        y1: 0
        x2: @xDomain[1]
        y2: 0
        
    @yAxis = new Line
      canvas: @canvas
      class: "grid-line"
      points:
        x1: 0
        y1: @yDomain[0]
        x2: 0
        y2: @yDomain[1]


class Text
  
  constructor: (@spec) ->
    
    {@canvas, @data, @class} = @spec
      
    @text = @canvas.append("text").attr("class", @class)
      
    {@mx, @my} = @canvas
    
    @set(@data) if @data?
    
  set: (@data) ->
    {x, y, text} = @data
    @text
      .attr "x", @mx(x)
      .attr "y", @my(y)
      .text text



#------------------------------------------------------#
# jQuery
#------------------------------------------------------#

$(document).tooltip
  content: -> $(this).prop('title')


#------------------------------------------------------#
# Exports
#------------------------------------------------------#

window.$blab ?= {}

$blab.Slides = Slides
$blab.Exercises = {Server, Exercises, ExerciseBase, ButtonSet}
$blab.d3 = {Canvas, Line, Arc, Circle, Polygon, GridLines, Text}
