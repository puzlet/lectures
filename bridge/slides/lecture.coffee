class myLecture extends $blab.Lecture

  audioServer: "http://haulashore.com/audio"
  enableAudio: false

  content: ->
    
    flash = (o) ->
      f: ->
        o.show 1000, ->
          o.addClass("flash-background")
          setTimeout (->
            o.removeClass("flash-background")
          ), 1000
      b: ->
        
    heading = (o) ->
      f: ->
        o.show 0, ->
          o.textillate({in:{effect:"swing"}})
      b: ->

    entrance = (o) ->
      f: ->
        o.show 0, ->
          o.addClass('animated flipInX')
      b: ->
        o.hide()
        
    flash2 = (o, p) ->
      f: ->
        animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend'
        p.addClass("animated flipOutX").one animationEnd, ->
          p.hide()
          o.show 0, ->
            o.addClass("animated flipInX")
      b: ->
        o.hide()
       
    #@step "lecture-heading",
    #  action: "fade"

    o = @step "lecture-text-first",
      action: entrance

    o = @step "lecture-plot-quad",
      action: entrance

    o = @step "lecture-text-roots",
      action: entrance


    ###
    o = @step "lecture-text-1",
      action: entrance

    o = @step "lecture-text-2",
      action: entrance
    ###


    ###
    respect = @step "lecture-text-respect",
      action: (o) -> flash2(o, many)

    decimal = @step "lecture-table-decimal",
      action: (o) -> flash2(o, space)

    rarely = @step "lecture-text-rarely",
      action: (u) -> flash2(u, respect)

    instead = @step "lecture-text-instead",
      action: (u) -> flash2(u, rarely)

    sn = @step "lecture-table-sn",
      action: (u) -> flash2(u, instead)

    roughly = @step "lecture-text-roughly",
      action: entrance

    step1 = @step "lecture-text-step1",
      action: (u) -> flash2(u, roughly)

    table_product = @step "lecture-table-product",
      action: entrance

    shift = @step "lecture-text-shift",
      action: (u) -> flash2(u, step1)

    @step "lecture-slider-shift",
      action: (u) -> flash2(u, shift)

    @step "lecture-slider-shift",
      action: @action(vals: [1..3])

    expo = @step "lecture-text-exp",
      action: entrance

    @step "lecture-table-exp",
      action: entrance

    one = @step "lecture-text-one",
      action: (u) -> flash2(u, expo)

    @step "lecture-slider-shift",
      action: @action(vals: [4..26])

    question = @step "lecture-text-question",
      action: (u) -> flash2(u, one)

    choose = @step "lecture-text-choose",
      action: (u) -> flash2(u, question)

    @step "lecture-menu-examples",
      action: (u) -> flash2(u, choose)
    ###

new myLecture
