class Server
  
  #@lectureId: "complex-numbers"  # TODO: settable in some other place
  
  @local: "//puzlet.mvclark.dev"
  @public: "//puzlet.mvclark.com"
  
  #@ready: false
  #@groupId: "my-group"
  #@userId: null
  
  @isLocal: window.location.hostname is "localhost"
    
  @url: if @isLocal then @local else @public
  
  # To delete/change.
  @getAll: (callback) ->
    $.get "#{@url}", (@data) ->
      console.log "All exercises from server", @data
      callback?(@data)

class Admin
  
  constructor: ->
    Server.getAll (@data) =>
      @model()
      console.log "SERVER"
      @view()
      
  model: ->
    @report = {} 
    for record in @data
      rec = @report[record.userId] ?= {}
      rec[record.exerciseId] =
        correct: record.correct
        code: record.code
    console.log "report", @report
  
  view: ->
    @container = $ "#report"
    for user, userExercises  of @report
      userContainer = @div "user", null, @container
      @div "user-id", user, userContainer
      for exerciseId, exercise of userExercises
        console.log "user/exId/correct/code", user, exerciseId, exercise.correct, exercise.code
        exerciseContainer = @div "exercise", null, userContainer
        exerciseContainer.addClass(if exercise.correct then "correct" else "incorrect")
        id = @div "exercise-id", exerciseId
        code = @div "exercise-code", "<pre>"+exercise.code+"</pre>"
        exerciseContainer.append(id).append(code)
        
  div: (cls, content, container) ->
    console.log "div", cls, content, container
    div = $ "<div>", class: cls
    div.append(content) if content
    console.log "C", container
    container.append(div) if container
    div
    
  append: (element) -> @container.append element
    
      
      
new Admin

  