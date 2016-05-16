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
    
    $(document).tooltip
      content: -> $(this).prop('title');
    
    Server.getAll (@data) =>
      @model()
      @viewSummary()
      @viewDetail()
      
  model: ->
    @report = {} 
    for record in @data
      rec = @report[record.userId] ?= {}
      rec[@trimExerciseId(record.exerciseId)] =
        correct: record.correct
        code: record.code
  
  viewSummary: ->
    @container = $ "#report"
    summaryContainer = @div "summary", null, @container
    for user, userExercises  of @report
      userContainer = @div "user-summary", null, summaryContainer
      a = $ "<a>", href: "##{user}", target: "_self"
      userContainer.append a
      @div "user-id-summary", user, a
      for exerciseId, exercise of userExercises
        e = @div "exercise-summary", null, userContainer
        e.addClass(if exercise.correct then "correct" else "incorrect")  # ZZZ helper function
        text = @summaryTextTemplate exerciseId, exercise.code
        e.attr title: text
        
  summaryTextTemplate: (id, code) ->
    text = """
      <div class='text-summary'>
        <b>#{id}</b>
        <pre>#{code}</pre>
      </div>
    """
  
  viewDetail: ->
    @container = $ "#report"
    for user, userExercises  of @report
      userContainer = @div "user", null, @container
      userContainer.attr id: user
      @div "user-id", user, userContainer
      for exerciseId, exercise of userExercises
        #console.log "user/exId/correct/code", user, exerciseId, exercise.correct, exercise.code
        exerciseContainer = @div "exercise", null, userContainer
        exerciseContainer.addClass(if exercise.correct then "correct" else "incorrect")
        id = @div "exercise-id", exerciseId
        code = @div "exercise-code", "<pre>"+exercise.code+"</pre>"
        exerciseContainer.append(id).append(code)
        
  div: (cls, content, container) ->
    div = $ "<div>", class: cls
    div.append(content) if content
    container.append(div) if container
    div
    
  trimExerciseId: (id) ->
    prefix = "exercise-"
    if id.indexOf(prefix) is 0
      id = id.substr(prefix.length)
    id
    
  append: (element) -> @container.append element
    
      
      
new Admin

  