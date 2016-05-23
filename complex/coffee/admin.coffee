class Server
  
  #@lectureId: "complex-numbers"  # TODO: settable in some other place
  
  @local: "//puzlet.mvclark.dev"
  @public: "//puzlet.mvclark.com"
  
  #@ready: false
  #@groupId: "public"  # Not used yet
  #@userId: null
  
  @isLocal: window.location.hostname is "localhost"
    
  @url: if @isLocal then @local else @public
  
  # To delete/change.
  @getAll: (callback) ->
    $.get "#{@url}", (@data) ->
      console.log "All exercises from server", @data
      callback?(@data)

class Admin
  
  # TODO: Get from coffee file in /complex?
  exerciseIds: {
    '1.1': 'complex-plane-1'
    '1.2': 'complex-plane-2'
    '2.1': 'complex-addition-1'
    '2.2': 'complex-addition-2'
    '2.3': 'complex-addition-3'
    '3.1': 'complex-unit-1'
    '3.2': 'complex-unit-2'
    '3.3': 'complex-unit-3'
    '3.4': 'complex-unit-4'
    '3.5': 'complex-unit-5'
  }
  
  constructor: ->
    
    $(document).tooltip
      content: -> $(this).prop('title')
    
    Server.getAll (@data) =>
      @model()
      console.log "report", @report
      @viewSummary()
      @viewDetail()
      
  model: ->
    @report = {} 
    for record in @data
      rec = @report[record.userId] ?= {}
      @blankExerciseRecords(rec)
      rec[@trimExerciseId(record.exerciseId)] =
        correct: record.correct
        code: record.code
        
  blankExerciseRecords: (rec) ->
    return if rec[@exerciseIds['1.1']]
    rec[id] = {} for ex, id of @exerciseIds
  
  viewSummary: ->
    @container = $ "#report"
    summaryContainer = @div "summary", null, @container
    
    # Heading
    userContainer = @div "user-summary", null, summaryContainer
    #a = $ "<a>", href: "##{user}", target: "_self", text: "USER"
    @div "user-id-summary", null, userContainer
    for ex, id of @exerciseIds
      e = @div "exercise-heading", ex, userContainer
      e.attr title: id
      
    for user, userExercises  of @report
      userContainer = @div "user-summary", null, summaryContainer
      a = $ "<a>", href: "##{user}", target: "_self", text: user
      @div "user-id-summary", a, userContainer
      for exerciseId, exercise of userExercises
        e = @div "exercise-summary", null, userContainer
        @answer e, exercise.correct
        text = @summaryTextTemplate exerciseId, (exercise.code ? "No answer")
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
        correct = exercise.correct
        continue unless correct?
        exerciseContainer = @div "exercise", null, userContainer
        @answer exerciseContainer, correct
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
    
  answer: (element, correct) ->
    element.addClass(if correct? then (if correct then "correct" else "incorrect") else "not-done")
    
  append: (element) -> @container.append element
  


new Admin
  