console.log "**** lecture.js"

$(document).tooltip
  content: -> $(this).prop('title')

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


window.$blab ?= {}
$blab.Slides = Slides
