# TODO

# Disable keys if lecture hasn't started.

# step function:  option to pass array/obj for first arg.  then can do multiple transitions.

# lecture button should appear only once all audio loaded.
# load audio in defs section?  search for data-audio attributes?  do via lecture.coffee?
# way to have math builds - elements that don't show in initital presentation.

# * yellow popup text boxes - placed anywhere.
# * similarly, balloon pointer boxes.  point at text/widget etc., and explain it.
# * a generic pointer (scripted) for audio/voiceovers.

# Audio should be tied to transitions, rather than ion html.  But then how will load all?
# Answer: once layout done, run lecture constructor.  Will not run init method (or whatever it's called).
# This will find all audio.

class $blab.Lecture
  
  constructor: ->
    
    KeyHandler.init(null)
    
    @startButton = new StartButton(this)
    @guide = new Guide()
    @progress = new Progress()
    @pointer = new Pointer()
    
    @steps = []
    @stepIdx = -1
    @content()
    
  start: ->
    @startButton.hide()
    KeyHandler.lecture = this
    @steps = []
    @stepIdx = -1
    @init()
    @content()
    setTimeout (=> @kickoff()), 100
    
  kickoff: ->
    @init()
    @doStep()
    
  init: ->
    # Can override in lecture blab.
    @hideElements()
    @guide.init()
    
  content: ->
    # Override in subclass.
  
  reset: ->
    KeyHandler.lecture = null
    @guide.hide()
    @progress.clear()
    @pointer.hide()
    @showElements()
    @startButton.show()
    @stepIdx = -1
    
  step: (obj, spec={}) ->
    
    obj = $("#"+obj) if typeof obj is "string"
    
    # Specified action
    action = spec.action
    
    # Default action
    action ?= (o) ->
      f: -> o.show()
      b: -> o.hide()
    
    # Fade action
    if action is "fade"
      action = (o) ->
        f: -> o.fadeIn()
        b: -> o.fadeOut()
    
    # Replace action
    # ZZZ options for replace
    if spec.replace
      rObj = spec.replace
      action = (o) ->
        f: -> rObj.fadeOut(300, -> o.fadeIn())
        b: -> o.hide(0, -> rObj.show())
    
    # Audio element
    audio = spec.audio
    @appendAudio audio
      
    # Lecture pointer
    pointer = spec.pointer
      
    @steps = @steps.concat {obj, action, audio, pointer}
    
    obj
    
  doStep: ->
     
    @stepIdx++ if @stepIdx<@steps.length
     
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
      @guide.hide()
    
    console.log "stepIdx", @stepIdx
    
  back: ->
    
    console.log "Back step"
    
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
      
  # Component action
  action: (spec) ->
    (o) =>
      component = o.data("blab-component")
      component?.lectureAction?(spec)
  
  appendAudio: (audio) ->
    # Audio element
    if audio and not $("audio#{audio}").length
      $(document.body).append "<audio id='#{audio}' src='#{@audioServer}/#{audio}.mp3'></audio>\n"
  
  hideElements: ->
    $("[id|=lecture]").hide()
    
  showElements: ->
    $("[id|=lecture]").show()
    $(".hide[id|=lecture]").hide()
  

class StartButton
  
  id: "start-lecture-button"
  
  constructor: (@lecture) ->
    
    @button = $ "##{@id}"
    return if @button.length
    
    @button = $ "<button>",
      id: @id
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
      #console.log evt.keyCode
      lecture?.doStep() #and evt.keyCode is 32


class Guide
  
  id: "lecture-guide"
  
  constructor: ->
    
    @container = $ document.body
    
    @guide = $ "<div>", id: @id
    @container.append @guide
    
    @guide.draggable()
    @guide.css left: ($("body").width() - 200)
    
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
    
    setTimeout (-> show()), 1000
  
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


# Computation helper function
$blab.computation = (computeFile, components) ->
  
  compute = $blab.resources.find computeFile
  
  ui = {}
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


# Dynamic styles
$blab.style = (id, css) ->
  s = $ "style##{id}"
  unless s.length
    s = $ "<style>", id: id
    s.appendTo "head"
  s.html "\n#{css}\n"

