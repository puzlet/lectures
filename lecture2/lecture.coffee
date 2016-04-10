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
        
    #@step "lecture-compute"
    
    @step "lecture-slider-quadratic"
    
    @step "lecture-menu-offset"
    @step "lecture-text-offset"
    
    @step "lecture-plot-quadratic"
    
    @step "lecture-slider-quadratic",
      audio: "x-squared"  # Not correct audio - just a test.
      pointer: [229, 420]
      action: @action(vals: [1..9])
    
    @step "lecture-menu-offset",
      pointer: [327, 457]
      action: @action(val: 20)
    
    o = @step "lecture-text-3"
    
    @step "lecture-text-4",
      replace: o
    
    @step "lecture-table-quadratic"
    
    @step "lecture-table-quadratic",
      pointer: [189, 701]
      action: @action(col: 0, vals: [4, 5, 6])

new myLecture
