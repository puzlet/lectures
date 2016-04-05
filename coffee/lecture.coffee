# TODO

# TUE 5 APRIL, 2016
# Disable keys if lecture hasn't started.
#-------------------------------------

# lecture button should appear only once all audio loaded.
# load audio in defs section?  search for data-audio attributes?  do via lecture.coffee?
# way to have math builds - elements that don't show in initital presentation.

# * yellow popup text boxes - placed anywhere.
# * similarly, balloon pointer boxes.  point at text/widget etc., and explain it.
# * a generic pointer (scripted) for audio/voiceovers.

# Audio should be tied to transitions, rather than ion html.  But then how will load all?
# Answer: once layout done, run lecture constructor.  Will not run init method (or whatever it's called).
# This will find all audio.

Widgets = null
Widgets = $blab.Widgets  # Does not exist

$blab.computation = (computeFile, components) ->
  
  ui = {}
  
  compute = $blab.resources.find computeFile
  
  for name, component of components
    ui[name] = component.ui?()
    component.change?(-> compute.compile())  # Does not compile if code unchanged
  $blab.ui = ui
  
  $blab.postProcessing = ->
    # Currently only for tables
    component.setFunctions?() for name, component of components
    
  $(document).on "preCompileCoffee", (evt, data) =>
    return unless data.resource?.url is computeFile
    names = (name for name of components)
    list = names.join ", "
    precompile = {}
    precompile[computeFile] =
      preamble: "{#{list}} = $blab.ui\n"
      postamble: "$blab.postProcessing()\n"
    $blab.precompile(precompile)

class $blab.Lecture
  
  constructor: ->
    @startButton = new StartButton(this)
    @guide = new Guide()
    @progress = new Progress()
    @pointer = new Pointer()
    
    @steps = []
    @stepIdx = -1
    @content()
    
  start: ->
    @startButton.hide()
    KeyHandler.init(this)
    @steps = []
    @stepIdx = -1
    @init()
    @content()
    setTimeout (=> @kickoff()), 100
    
  kickoff: ->
    @init()
    @doStep()
    
  init: ->
    console.log "******** OBJECTS", $("[id|=lecture]").css("display")
    # Can override in lecture blab.
    @hideElements()
    @guide.init()
    
  content: ->
    # Override in subclass.
  
  reset: ->
    KeyHandler.init(null)
    @guide.hide()
    @progress.clear()
    @pointer.hide()
    @showElements()
    @startButton.show()
    @stepIdx = -1
    
  step: (obj, spec={}) ->
    
    # option to pass array/obj for first arg.  then can do multiple transitions.
    
    if typeof obj is "string"
      obj = $("#"+obj)
    
    # Use parent object for specified widgets
    #if obj.hasClass("blab-input") or obj.hasClass("blab-menu") or obj.hasClass("puzlet-plot") #or obj.hasClass("widget")
      # ZZZ do for table, plot2, etc.  way to detect any widget?
    #  origObj = obj
    #  obj = obj.parent()
    
    #console.log "OBJ", obj.data(), obj
    
    action = spec.action
    
    action ?= (o) ->
      f: -> o.show()
      b: -> o.hide()
    
    if action is "fade"
      action = (o) ->
        f: -> o.fadeIn()
        b: -> o.fadeOut()
    
    # ZZZ options for replace
    if spec.replace
      rObj = spec.replace
      action = (o) ->
        f: -> rObj.fadeOut(300, -> o.fadeIn())
        b: -> o.hide(0, -> rObj.show())
    
    if action is "menu"
      # ZZZ DUP code
      domId = origObj.attr "id"
      origVal = Widgets.widgets[domId].getVal()
      action = (o) =>
        console.log "origVal", origVal
        f: => @setMenu origObj, spec.val
        b: => @setMenu origObj, origVal  # ZZZ should be original val?
          
    if action is "table"
      #domId = obj.attr "id"
      action = (o) =>
        f: => @tablePopulate obj, spec.col, spec.vals, ->
        b: => #no reverse action yet
          
    audio = spec.audio
    if audio and not $("audio#{audio}").length
      $(document.body).append "<audio id='#{audio}' src='#{@audioServer}/#{audio}.mp3'></audio>\n"
      
    pointer = spec.pointer
      
    @steps = @steps.concat {obj, action, audio, pointer}
    
    obj
    
  doStep: ->
    if @stepIdx<@steps.length
      @stepIdx++
      
    @progress.draw @stepIdx+1, @steps.length
    
    if @stepIdx>=0 and @stepIdx<@steps.length
      step = @steps[@stepIdx]
      obj = step.obj
      action = step.action
      action(obj).f()
      audioId = step.audio
      if audioId and @enableAudio
        audio = document.getElementById(audioId)
        audio.play()
      pointer = step.pointer
      if pointer
        @pointer.setPosition pointer
      else
        @pointer.hide()
      
    if @stepIdx>=@steps.length
      @guide.end()
      @guide.show()
      @pointer.hide()
    else
      @guide.hide() #if @guide.guide.is(":visible")
    
    console.log "stepIdx", @stepIdx
    
  back: ->
    console.log "BACK STEP"
    
    if @stepIdx>=0 and @stepIdx<@steps.length
      step = @steps[@stepIdx]
      obj = step.obj
      action = step.action
      action(obj).b()
    
    @stepIdx-- if @stepIdx>=0
    
    @progress.draw @stepIdx+1, @steps.length
    
    @pointer.hide()
    
    console.log "stepIdx", @stepIdx
    if @stepIdx<0
      @guide.start()
      @guide.show()
    else
      @guide.hide()
      
  action: (spec) ->
    (o) =>
      component = o.data("blab-component")
      component?.lectureAction?(spec)
  
  setMenu: (obj, val, cb) ->
    console.log "**** SET MENU", obj, val
    domId = obj.attr "id"
    #obj.slider 'option', 'value', v  # ZZZ
    Widgets.widgets[domId].setVal val
    Widgets.widgets[domId].menu.val(val).trigger "change"
    Widgets.compute()
    cb?()
        
  tablePopulate: (obj, col, vals, cb) ->
    delay = 1000
    idx = 0
    domId = obj.attr "id"
    setTable = (cb) =>
      v = vals[idx]
      t = Widgets.widgets[domId]
      console.log "***t/col/vals/idx", t, col, vals, idx
      cell = t.editableCells[col][idx]  # 0 needs to be arg.
      dir = if idx<vals.length-1 then 1 else 0
      cell.div.text v
      bg = cell.div.parent().css "background"
      cell.div.parent().css background: "#ccc"
      setTimeout (->
        cell.div.parent().css background: bg
        cell.done()
      ), 200
      idx++
      if idx < vals.length
        setTimeout (-> setTable(cb)), delay
      else
        console.log("cells", $('.editable-table-cell'))
        cells = $('.editable-table-cell')
        setTimeout (->
          $(cells[2]).blur()
          $("#container").click()
        ), 1000
        cb?()
        
    setTable(cb)
  
  
  table: (obj, spec) ->
    spec.action = "table"
    @step obj, spec
    
  menu: (obj, spec) ->
    spec.action = "menu"
    @step obj, spec
    
  hideElements: ->
    $("[id|=lecture]").hide()
    #$(".widget").hide()  # Needed?
    
  showElements: ->
    $("[id|=lecture]").show()
    $(".hide[id|=lecture]").hide()
    #$(".widget").show()  # Needed?
  

class StartButton
  
  constructor: (@lecture) ->
    @button = $ "#start-lecture-button"
    
    return if @button.length
    
    @button = $ "<button>",
      id: "start-lecture-button"
      text: "Start lecture"
      css: marginBottom: "10px"
      
    $("#container").after @button  # ZZZ better container
    
    @button.click (evt) =>
      @lecture.start()  # Wait until audio loaded?
      
  show: -> @button.show()
  
  hide: -> @button.hide()


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
    else if evt.keyCode is 27  # Escape
      lecture?.reset()
      lecture = null  # ZZZ better way?
    else
      console.log evt.keyCode
      lecture?.doStep() #and evt.keyCode is 32


class Guide
  
  constructor: ->
    
    @guide = $ "#demo-guide"
    @guide.draggable()
  
    @guide.css
      top: 30
      left: ($("body").width() - 200)
      background: background ? "#ff9"
      textAlign: "center"
      width: 150
    
    @hide()
    
  init: ->
    @guide.html """
      <b>&#8592; &#8594;</b> to navigate<br>
      <b>Esc</b> to exit
    """
    
    show = =>
      @show()
      setTimeout (-> hide()), 5000
      
    hide = =>
      @hide()
      @css textAlign: "center"
    
    setTimeout (-> show()), 1000 #.delay(3000).hide()
  
  start: ->
    @guide.html """
      <b>Start of lecture</b><br>
      <b>&#8592; &#8594;</b> to navigate<br>
      <b>Esc</b> to exit
    """
    
  end: ->
    @guide.html """
      <b>End of lecture</b><br>
      <b>&#8592; &#8594;</b> to navigate<br>
      <b>Esc</b> to exit
    """
    
  show: -> @guide.show()
  
  hide: ->
    @guide.hide() if @guide.is(":visible")
  
  html: (html) -> @guide.html html
  
  css: (css) -> @guide.css css


class Progress
  
  constructor: ->
    
    @container = $ document.body
    
    @wrapper = $ "<div>", class: "progress-outer"
    @container.append @wrapper
    
    @div = $ "<div>", class: "progress-inner"
    @wrapper.append @div
    
  draw: (@currentStep, @numSteps) ->
    @clear()
    for step in [1..@numSteps]
      fill = step is @currentStep
      @circle(fill)
      
  clear: ->
    @div.empty()
  
  circle: (filled = false)->
    circle = $ "<div>", class: "step-circle" + (if filled then " step-circle-filled" else "")
    @div.append circle


class Pointer
  
  constructor: ->
    
    @container = $ "#container"
    
    @pointer = $ "<img>",
      class: "lecture-pointer"
      src: "../img/pointer.png"
    
    @pointer.hide()
    @pointer.css(left: 500, top: 500)
    
    @container.append @pointer
    
    $(document.body).click (evt) =>
      offset = @container.offset()
      console.log "container(x, y)", (evt.clientX - offset.left), (evt.clientY)
      # 267, 166
      # 251, 160
  
  show: ->
    @pointer.show()
    
  hide: ->
    @pointer.hide()
    
  setPosition: (coords) ->
    
    @show()
    
    adjust = {left: 13, top: 45} 
    
    @pointer.animate
      left: coords[0] - adjust.left
      top: coords[1] - adjust.top


# Dynamic styles
$blab.style = (id, css) ->
  s = $ "style##{id}"
  unless s.length
    s = $ "<style>", id: id
    s.appendTo "head"
  s.html "\n#{css}\n"

