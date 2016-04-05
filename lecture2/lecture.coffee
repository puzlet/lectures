class myLecture extends $blab.Lecture

  audioServer: "http://haulashore.com/audio"
  enableAudio: false

  content: ->
    
    @step "lecture-heading"

    @step "lecture-text-1",
      action: "fade"
    
    @step "lecture-text-2",
      audio: "x-squared"
      pointer: [233, 211]
      action: (o) ->
        f: -> o.fadeIn(1000)  # perhaps specify f/b directly? omit action?
        b: -> o.fadeOut()
    
    @step "lecture-math-1",
      audio: "x-cubed"
      pointer: [55, 361]
      action: (o) ->
        f: -> o.slideDown()
        b: -> o.slideUp()
    
    @step "lecture-slider-1"
    
    #@step "menu-Offset"
    @step "lecture-offset-text"
    
    @step "lecture-plot-1"
    
    @step "lecture-slider-1",
      audio: "x-squared"  # Not correct audio - just a test.
      pointer: [229, 420]
      action: @action(vals: [1..9])
    
    #@menu "menu-Offset",
    #  pointer: [327, 457]
    #  val: 20
    
    o = @step "lecture-text-3"
    
    @step "lecture-text-4",
      replace: o
    
    @step "lecture-table-1"
    
    @step "lecture-table-1",
      pointer: [183, 675]
      action: @action(col: 0, vals: [4, 5, 6])
    
    #@table "table-Quadratic",
    #  pointer: [183, 675]
    #  col: 0
    #  vals: [1, 2, 3]

showText = (id, val) ->
  $("##{id} > [data-val]").hide()
  $("##{id} > [data-val=#{val}]").show()

new myLecture
