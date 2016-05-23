#!no-math-sugar

# TODO:
# complex plane rendering - load indicator
# katex render - perhaps show loading...
# process mathjax only once loaded.
# Exercises button same color as exercises box.
# *** Run button with title showing shoft-enter tip
# Bug: scaling slider - label doesn't bounce back.
# Vector addition: show resultant vector in plot.
# Close (x) button for exercises window.
# Need a way to precompile complex.coffee - command line sci-coffee compiler.
# Show "correct" status in each exercise, at top of execrcise set (n boxes), and top of lecture.

# Math/numeric dependencies
abs = numeric.abs
complex = numeric.complex
linspace = numeric.linspace
j = complex 0, 1
pi = Math.PI

# complex.coffee dependencies - see Figures constructor
Complex = {}
EulerComputation = {}

#------------------------------------------------------#
# Exercises server
#------------------------------------------------------#

class Server
  
  @lectureId: "complex-numbers"  # TODO: settable in some other place
  
  @local: "//puzlet.mvclark.dev"
  @public: "//puzlet.mvclark.com"
  
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
# Figures
#------------------------------------------------------#

class Figures
  
  # Exercises are instantiated within figure classes.
  
  aceUrl: "/puzlet/ace/ace.js"
  
  constructor: ->
    
    #$(document).tooltip
    #  content: -> $(this).prop('title')
    
    Complex = $blab.Complex
    EulerComputation = $blab.EulerComputation
    
    new FigureComplexPlane
    new FigureComplexUnit
    new FigureComplexUnitMultiply
    new FigureComplexAddition
    new FigureComplexScaling
    new FigureComplexMultiplication
    new FigureEulerFormula
    
    Server.ready = true
    Server.fetch (data) => @loadAce(data)
#    Server.getAll (data) => @loadAce(data)
    
    # Old exercise
    new ExerciseRotation
    
    new $blab.Slides #if $(document.body).hasClass "slides"
    
  loadAce: (exercisesData)->
    # Ace after all figures rendered.
    if exercisesData
      $(document).on "aceFilesLoaded", =>
        $.event.trigger "exercisesDataLoaded", {exercises: exercisesData}
    @resources = $blab.resources
    @resources.add url: @aceUrl
    @resources.loadUnloaded => $Ace?.load(@resources)
    

# Base class
class ComplexPlane
  
  # Override in subclass
  margin: {top: 10, right: 10, bottom: 10, left: 10}
  xDomain: [-1, 1]
  yDomain: [-1, 1]
    
  constructor: (@spec) ->
    {@container} = @spec
    @width = @container.width()
    @height = @container.height()
    @figure?.find(".figure-outer").removeClass("loading")
    @createCanvas()
    
  createCanvas: ->
    @canvas = new Canvas {@container, @width, @height, @margin, @xDomain, @yDomain}
    @gridLines = new GridLines {@canvas}


class FigureComplexPlane extends ComplexPlane
  
  # TODO: use VectorSliderPair
  
  id: "#figure-complex-plane"
  sectionId: "#section-complex-plane"
  exercises: "exercises-complex-plane"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]
  yDomain: [-2, 2]
  
  constructor: ->
    
    @figure = $ "#{@id}"
    super container: @figure.find(".figure-surface")
    
    @vector = new VectorWithCircle
      canvas: @canvas
      xyLines: true
      compute: (p) => @setVector(p)
    
    @slider = new VerticalAngleSlider
      container: @figure.find ".slider"
      label: "\\theta"
      change: (angle) =>
        z = Complex.polarToComplex @magnitude, angle
        @draw z
    
    @magnitudeText = $ "<span>"
    (@figure.find ".magnitude").append("Magnitude: A=").append(@magnitudeText)
    
    @setVector(x: 1, y: 1)
    
    @initButtons()
    
    new Exercises(@exercises, this)
    
  initButtons: ->
    draw = (x, y) => @animate(complex(x, y))
    new ButtonSet @sectionId, [
      {id: "complex-12-plus-09i", method: (cb) -> draw(1.2, 0.9)}
      {id: "complex-neg1-plus-i", method: (cb) -> draw(-1, 1)}
      {id: "complex-neg1-plus-negi", method: (cb) => draw(-1, -1)}
      {id: "complex-negi", method: (cb) => draw(0, -1)}
    ]
  
  setVector: (p) ->
    # Set cartesian coords of vector.  Snap to grid.
    # Make rounding part of clip function?
    x = round(p.x, 1)
    y = round(p.y, 1)
    @z = Complex.clipMagnitude complex(x, y), 2
    setSlider = true
    @draw @z, setSlider
    
  draw: (@z, setSlider=false) ->
    @vector.set @z
    {@magnitude, @angle} = Complex.toPolar(@z)
    @slider.set(@angle) if setSlider
    @magnitudeText.html round(@magnitude, 2)
  
  animate: (z, callback) ->
    @vector.showXYLines false
    @vector.animate @z, z, =>
      @z = z
      @draw @z, true  # No clipping
      @vector.showXYLines true
      callback?()
      
  step: (spec, callback) =>
    @vector.setCircleClass spec.fill
    next = (t=1000) ->
      setTimeout(callback, t) if callback?
    if spec.t?
      @z = spec.z
      @draw @z, true  # No clipping
      next()
    else
      @animate spec.z, next


class FigureComplexAddition extends ComplexPlane
  
  # TODO: show x+jy and a+jb below, and sum.
  # TODO: different colors for vectors and xy lines
  # BUG?: slider wrong if move and z clips.  or clipping shortens vector when clips?
  
  id: "#figure-complex-addition"
  exercises: "exercises-complex-addition"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]
  yDomain: [-2, 2]
  
  constructor: ->
    
    @figure = $ "#{@id}"
    super container: @figure.find(".figure-surface")
      
    @vector1 = new VectorSliderPair
      figure: @figure
      canvas: @canvas
      xyLines: false
      xyLabels: false
      sliderClass: ".slider"
      angleLabel: "\\theta_1"
      getZ: (z) => @getZ(z, @vector2.z())
      set: =>
        @setOrigin2()
        @setMagnitude()
      
    @vector2 = new VectorSliderPair
      figure: @figure
      canvas: @canvas
      xyLabels: true
      sliderClass: ".slider-2"
      angleLabel: "\\theta_2"
      getZ: (z) => @getZ(z, @vector1.z())
      set: => @setMagnitude()
    
    @magnitudeText = $ "<span>"
    (@figure.find ".magnitude").append("Magnitude: A=").append(@magnitudeText)
    
    @vector1.set complex(1, 0.5)
    @setOrigin2()
    @vector2.set complex(0.5, 0.5)
    
    new Exercises(@exercises, this)
    
  setMagnitude: ->
    A = Complex.magnitudeSum(@vector1.z(), @vector2.z())
    @magnitudeText.html round(A, 2)
  
  setOrigin2: (v, z) -> @vector2.setOrigin @vector1.z()
  
  getZ: (z, other) ->
    total = Complex.add(z, other)
    clip = Complex.clipMagnitude(total, 2)
    snap = Complex.snap(clip, 1)
    Complex.diff snap, other


class FigureComplexUnit extends ComplexPlane
  
  id: "#figure-complex-unit"
  sectionId: "#section-complex-unit"
  tableId: "#table-complex-unit"
  exercises: "exercises-complex-unit"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]
  yDomain: [-2, 2]
  
  constructor: ->
    
    @figure = $ @id
    super container: @figure.find(".figure-surface")
    
    @zValues = [
      {value: complex(1,0), r180: "1 \\times -1 = -1", f90: "1 \\times i = i", b90: "1 \\times -i = -i"}
      {value: complex(0,1), r180: "i \\times -1 = -i", f90: "i \\times i = i^2 = -1", b90: "i \\times -i = -i^2 = 1"}
      {value: complex(-1,0), r180: "-1 \\times -1 = 1", f90: "-1 \\times i = -i", b90: "-1 \\times -i = i"}
      {value: complex(0,-1), r180: "-i \\times -1 = i", f90: "-i \\times i = -i^2 = 1", b90: "-i \\times -i = i^2 = -1"}
    ]
    
    click = (idx) => =>
      @setEquation ""
      @setVector idx
    
    for z, idx in @zValues
      vector = new VectorWithCircle
        canvas: @canvas
        class: "circle-no-drag"
        xyLines: false
        arc: false
        click: click(idx)
      vector.set z.value
    
    @vector = new VectorWithCircle
      canvas: @canvas
      xyLines: false
      zLabel: true
      #compute: (z) =>
        
    @table = $ @tableId
    @rows = @table.find "tr"
    
    @setVector 0
    
    @initButtons()
    
    new Exercises(@exercises, this)
    
  initButtons: ->
    
    new ButtonSet @sectionId, [
      {id: "show-vectors", method: (cb) => @animateAll(cb)}
      {id: "multiply-by-negative-1", method: (cb) => @negate(cb)}
      {id: "z1", method: (cb) => @setVectorInstantly(0, cb)}
      {id: "multiply-1-by-i", method: (cb) => @multiplyzi(0, cb)}
      {id: "multiply-i-by-i", method: (cb) => @multiplyzi(1, cb)}
      {id: "multiply-by-i", method: (cb) => @multiply(j, cb)}
      {id: "multiply-by-negative-i", method: (cb) => @multiply(complex(0, -1), cb)}
    ]
  
  setVector: (@idx, callback) ->
    zStart = @z
    @z = @zValues[@idx].value
    @animate zStart, =>
      @highlightRow()
      callback?()
      
  setVectorInstantly: (@idx, callback) ->
    @setEquation ""
    @z = @zValues[@idx].value
    @vector.set @z
    @highlightRow()
    callback?()
  
  # Interface for exercises.
  setToZ: (z, callback) ->
    zStart = @z
    @z = z
    console.log "zStart, z", zStart, z
    @animate zStart, =>
      #@highlightRow()  # highlight only if z corresponds to row
      callback?()
      
  # Interface for exercises.  Similar to animateAll.
  animateSet: (zValues, callback) ->
    idx = 0
    next = =>
      idx++
      if idx<zValues.length
        set()  # Recursion
      else
        callback?()
    set = =>
      @setToZ zValues[idx], =>
        delay = if idx is 0 then 500 else 1000
        setTimeout (-> next()), delay
    set()
  
  animateAll: (callback) ->
    @setEquation ""
    idx = 0
    next = =>
      idx++
      if idx<@zValues.length
        set()  # Recursion
      else
        @setVector 0, callback  # Back to start
    set = =>
      @setVector idx, =>
        delay = if idx is 0 then 500 else 1000
        setTimeout (-> next()), delay
    set()
      
  animate: (zStart, callback) =>
    
    unless zStart
      @vector.set @z
      callback?()
      return
    
    @vector.animate zStart, @z, =>
      @z = @vector.z
      callback?()
    
  negate: (callback) ->
    @setEquation @zValues[@idx].r180
    zStart = @z
    @z = Complex.mul -1, zStart
    @showOperation zStart, callback
    
  multiplyzi: (startIdx, callback) ->
    @setVectorInstantly(startIdx)
    @multiply j, callback
    
  multiply: (z2, callback) ->
    @setEquation ""
    if z2.x is 0
      if z2.y is 1
        @setEquation @zValues[@idx].f90
      else if z2.y is -1
        @setEquation @zValues[@idx].b90
    zStart = @z
    @z = Complex.mul z2, zStart
    @showOperation zStart, callback
  
  showOperation: (zStart, callback) ->
    idx = @getIdx @z
    if idx<0
      callback?()
      return
    @idx = idx
    @animate zStart, =>
      @highlightRow()
      callback?()
      
  setEquation: (equation) ->
    container = $("#figure-complex-unit .equation")
    katex.render(equation, container[0]);
    #container.html equation
    #processMathJax container  # No callback
  
  getIdx: (v) ->
    for z, idx in @zValues
      return idx if abs(Complex.diff(z.value, v))<0.000001
    return -1
  
  highlightRow: ->
    for row0, rowIdx in @rows
      row = $ row0
      row.toggleClass "row-highlight", rowIdx is @idx+1


class FigureComplexUnitMultiply extends ComplexPlane
  
  id: "#figure-complex-unit-multiply"
  sectionId: "#section-complex-unit-multiply"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]
  yDomain: [-2, 2]
  
  constructor: ->
    
    @figure = $ @id
    super container: @figure.find(".figure-surface")
    
    @vector = new VectorSliderPair
      figure: @figure
      canvas: @canvas
      xyLines: true
      xyLabels: true
      xyComponents: true
      sliderClass: ".slider"
      angleLabel: "\\theta"
      getZ: (z) => @getZ(z)
    
    new ButtonSet @sectionId, [
      {id: "multiply-by-i", method: (cb) => @multiply(j, cb)}
      {id: "multiply-by-negative-i", method: (cb) => @multiply(complex(0, -1), cb)}
    ]
    
    @vector.set complex(1, 1)
  
  multiply: (a, callback) ->
    v = @vector.vector
    @vector.animate v.z, Complex.mul(a, v.z), callback
    
  getZ: (z) ->
    clip = Complex.clipMagnitude(z, 2)
    snap = Complex.snap(clip, 1)


class FigureComplexScaling extends ComplexPlane
  
  id: "#figure-complex-scaling"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]  # ZZZ larger?
  yDomain: [-2, 2]
  
  constructor: ->
    
    @figure = $ "#{@id}"
    super container: @figure.find(".figure-surface")
    
    @vector = new VectorWithCircle
      canvas: @canvas
      xyLines: false
      arc: true
      compute: (@z) => @draw()
      
    @scaledVector = new VectorWithCircle
      canvas: @canvas
      xyLines: true
      arc: false
      compute: (@az) =>
        # ZZZ preserve sign of z?
        @z = Complex.polarToComplex(abs(@z), @az.arg())
        sf = abs(@az)/abs(@z)
        @sliderScaleFactor.set sf
        @draw()
      
    @sliderAngle = new VerticalAngleSlider
      container: @figure.find ".slider"
      label: "\\theta"
      change: (angle) =>
        @z = Complex.polarToComplex abs(@z), angle
        @draw()
    
    @sliderScaleFactor = new HorizontalSlider
      container: $(".slider-scale-factor")
      label: "a"
      unit: ""
      init: 1.5
      min: -5
      max: 5
      step: 0.1
      change: => @draw()
      done: => @draw()  # To constrain slider
      
    @magnitudeText = $ "<span>"
    (@figure.find ".magnitude").append("Magnitude: A=").append(@magnitudeText)
    
    @z = complex 1, 1
    @sliderScaleFactor.set 1.2
    
    @draw()
  
  draw: ->
    # Compute scaled vector, and constrain scale factor
    sf = round(@sliderScaleFactor.val(), 2)
    @az = Complex.scale @z, sf
    @az = Complex.clipMagnitude @az, 2
    sf = @sign(sf)*round(abs(@az)/abs(@z), 2)
    
    # Set vectors, sliders, and magnitude
    @vector.set @z
    @scaledVector.set(@az)
    @sliderAngle.set(@z.arg())
    @sliderScaleFactor.set sf  # ZZZ Issue with slider if too large - need to clip val
    @magnitudeText.html round(abs(@az), 2)
    
  sign: (x) -> if x<0 then -1 else 1
  


class FigureComplexMultiplication extends ComplexPlane
  
  id: "#figure-complex-multiplication"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]  # ZZZ larger?
  yDomain: [-2, 2]
  
  constructor: ->
    
    @figure = $ "#{@id}"
    super container: @figure.find(".figure-surface")
    
    # Result z=z1*z2
    @z2 = complex 0.5, 0.5
    
    @vector = new VectorSliderPair
      figure: @figure
      canvas: @canvas
      xyLines: false
      #xyLabels: true
      arc: false
      sliderClass: ".slider"
      angleLabel: "\\theta"
      getZ: (z) => @getZ(z)
      set: =>
        @z = Complex.mul @vector.z(), @z2
        @compute()
      
    @vectorResult = new VectorWithTriangle
      canvas: @canvas
      class: "triangle"
      compute: (z) =>
        @z = @getZ z
        @z2 = Complex.div @z, @vector.z()
        @compute()
    
    @vector.set complex(1, 0.5)
    #@vector2.set @z2.x, @z2.y, 1, 0
    
    @compute()
      
  getZ: (z) ->
    clip = Complex.clipMagnitude(z, 2)
    snap = Complex.snap(clip, 1)
    
  compute: ->
#    @z1 = @vector.z()
    # @z is result vector
#    @z2 = Complex.div @z, @z1
    @az1 = Complex.mul @z2.x, @vector.z()
    @vectorResult.set @z.x, @z.y, @az1.x, @az1.y
    
  # Zcompute: ->
  #   @z = @z1*@z2
  #   @az1 = @z2.x*@z1
  #
  #   @draw {@z1, @z2, @z, @az1}
  #
  # setZ1: (p) ->
  #   @z1 = complex p.x, p.y
  #
  #   # Constrain
  #   @z1 = @z1 / abs(@z1)
  #
  #   @compute()
  #
  # setZ: (p) ->
  #   z = complex p.x, p.y
  #
  #   # Constrain
  #   z = z / abs(z)
  #
  #   @z2 = z / @z1
  #
  #   @compute()
    
    
  


class FigureEulerFormula extends ComplexPlane
    
    id: "#figure-euler-formula"
    xDomain: [-3, 3]
    yDomain: [-3, 3]
    
    constructor: ->
      
      @figure = $ "#{@id}"
      super container: @figure.find(".figure-surface")
      
      #@container = $("#math-surface")
      
      theta = pi
      N = 4
      
      Slider = $blab.components.Slider
      
      @sliderTheta = new Slider
        container: $("#slider-theta")
        prompt: "$\\theta$"
        unit: "$\\pi$"
        init: theta/pi
        min: 0
        max: 2
        step: 0.125
        
      @sliderN = new Slider
        container: $("#slider-n")
        prompt: "$n$"
        unit: ""
        init: N
        min: 1
        max: 200
        
      @renderSliderMath @sliderTheta
      @renderSliderMath @sliderN
      
      @sliderTheta.change =>
        theta = @sliderTheta.getVal() * pi
        @build(theta, N)
      
      @sliderN.change =>
        N = @sliderN.getVal()
        @build(theta, N)
      
      @build(theta, N)
      
    renderSliderMath: (slider) ->
      renderMathInElement slider.container[0], delimiters: [
        left: "$", right: "$", display: false
      ]
      
    build: (theta, N) ->
      
      @createCanvas()
        
      #@slider.change => @compute()
      
      # First vector, z0
      @z0 = new Z1 canvas: @canvas
      z0 = complex(1, 0)
      @z0.set z0.x, z0.y
      
      @triangles1 = []
      @triangles2 = []
      
      points = z: z0
      step = EulerComputation.angleStep(theta, N)
      @doSteps @triangles1, "triangle", points, N, step
      
      points = z: z0
      step = EulerComputation.orthoStep(theta, N)
      @doSteps @triangles2, "triangle fill-blue", points, N, step
       
    doSteps: (triangles, c, points, N, step) ->
      for n in [1..N]
        z = new VectorWithTriangle(canvas: @canvas, class: c)
        triangles.push z
        points = EulerComputation.step(points.z, step)
        @draw z, points
    
    draw: (t, points) ->
      {z1, z2, z, az1} = points
      t.set z.x, z.y, az1.x, az1.y


#------------------------------------------------------#
# Exercises and solutions
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
      E = Exercise[id]
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
    


#----------Exercise subclasses-------------#

Exercise = {}

class Exercise['exercise-complex-plane-1'] extends ExerciseBase
  
  processArgs: "{z, x, y, A, θ}"
  
  process: (data) ->
    
    {z, x, y, A, θ} = data
    return unless x?  # May replace this with process detector.
    
    z1 = z
    z2 = complex(x, y)
    z3 = Complex.polarToComplex(A, θ)
    
    @figure.step {z: z1, fill: "fill-green", t: 0}, =>
      ok1 = Complex.isEqual(z1, z2)
      @ok ok1
      @figure.step {z: z2, fill: "fill-red"}, =>
        @figure.step {z: z3, fill: "fill-blue"}
        ok2 = Complex.isEqual(z1, z3)
        @ok ok2
        @correct = ok1 and ok2
        @saveToServer()
        
    # Perhaps just have a "done" method.  pass correct flag.


class Exercise['exercise-complex-plane-2'] extends ExerciseBase
  
  postProcess: (evals) ->
    
    return unless evals.length
    f = evals[0]
    return unless f(0, 0)?
    
    A = (z) -> f(z.x, z.y)
    
    z1 = complex 0.6, 0.8
    z2 = complex -1, 1.5
    z3 = complex -1.8, -0.6
    
    step = (spec, next) =>
      z = spec.z
      @text "Your A = "+round(A(z), 2)
      ok = Complex.isEqual(A(z), abs(z))
      @ok ok
      notOk = true unless ok
      @figure.step {z: z, fill: "fill-green", t: spec.t}, => next?()
    
    @correct = not(notOk?)
        
    step {z: z1, t: 0}, => step {z: z2}, => step {z: z3}, => @saveToServer()


class Exercise['exercise-complex-addition-1'] extends ExerciseBase
  
  processArgs: "{z, z1, z2}"
  
  process: (data) ->
    
    {z, z1, z2} = data
    return unless z1?  # May replace this with process detector.
    
    c = (z) => complex(z.x ? z, z.y ? 0)
    
    z1 = c(z1)
    z2 = c(z2)
    
    @figure.vector1.set z1
    @figure.setOrigin2()
    @figure.vector2.set z2
    @figure.setMagnitude()
    ok = z1.x is z.x and z1.y is 0 and z2.x is 0 and z2.y is z.y
    @ok(ok)
    @correct = ok
    @saveToServer()


class Exercise['exercise-complex-addition-2'] extends ExerciseBase
  
  processArgs: "{z, z1, z2}"
  
  process: (data) ->
    
    {z, z1, z2} = data
    return unless z1?  # May replace this with process detector.
    
    c = (z) => complex(z.x ? z, z.y ? 0)
    
    z2 = c(z2)
    
    @figure.vector1.set z1
    @figure.setOrigin2()
    @figure.vector2.set z2
    @figure.setMagnitude()
    zb = Complex.add(z1, z2)
    ok = Complex.isEqual z, zb
    @ok(ok)
    @correct = ok
    @saveToServer()


class Exercise['exercise-complex-addition-3'] extends ExerciseBase
  
  postamble: -> "\n  null\n  A\n"
  
  postProcess: (evals) ->
    
    return unless evals.length
    f = evals[0]
    z = complex(0, 0)
    #console.log "f", f, f(z, z)
    return unless f(z, z)?
    
    A = (z1, z2) -> f(z1, z2)
    
    z1 = complex(0.5, 0.2)
    z2 = complex(0.5, 0.5)
    
    console.log "Result", A(z1, z2)
    
    step = (spec, next) =>
      {z1, z2, t} = spec
      z = Complex.add(z1, z2)
      m = A(z1, z2)
      @text "Your A = "+round(m, 2)
      ok = Complex.isEqual(m, abs(z))
      @ok ok
      notOk = true unless ok
      # TODO: create method on figure.  Dup code.  Need to do without clipping.
      @figure.vector1.set z1
      @figure.setOrigin2()
      @figure.vector2.set z2
      @figure.setMagnitude()
      #@figure.step {z: z, fill: "fill-green", t: t}, => next?()
    
    step {z1: z1, z2: z2, t: 0}, =>
      @correct = not(notOk?)
      @saveToServer()
       #, => step {z: z2}, => step {z: z3}


# Base class for complex unit exercises
class ExerciseComplexUnit extends ExerciseBase
  
  postamble: -> ""
  
  forwardVals: (A=1) ->
    i = j
    negi = Complex.diff(0, i)
    (Complex.mul(A, z) for z in [1, i, -1, negi, 1])
    
  reverseVals: ->
    i = j
    negi = Complex.diff(0, i)
    [1, negi, -1, i, 1]
  
  complexVector: (vals) ->
    vector = []
    for v in vals
      continue unless v
      z = Complex.complex(v)
      vector.push complex(round(z.x, 5), round(z.y, 5))
    vector
  
  run: (userValues, correctValues) ->
    
    # User values
    zValues = @complexVector userValues
    
    # Correct values
    correctZ = @complexVector correctValues
    
    # Compare values
    if zValues.length is correctValues.length
      for z1, idx in zValues
        z2 = correctZ[idx] ? null
        ok = Complex.isEqual(z1, z2)
        notOk = true unless ok
      @correct = not(notOk?)
    else
      @correct = false
    
    # Animation
    console.log "zValues", zValues
    @figure.animateSet zValues, =>
      @ok(@correct)
      @saveToServer()
  


class Exercise['exercise-complex-unit-1'] extends ExerciseComplexUnit
  
  postProcess: (evals) ->
    return unless evals.length>3
    @run evals, @forwardVals()


class Exercise['exercise-complex-unit-2'] extends ExerciseComplexUnit
  
  postProcess: (evals) ->
    return unless evals.length
    angle = evals[0]
    return unless angle(0)?
    zValues = (Complex.polarToComplex(1, angle(n)) for n in [0..4])
    @run zValues, @forwardVals()


class Exercise['exercise-complex-unit-3'] extends ExerciseComplexUnit
  
  postProcess: (evals) ->
    return unless evals.length>1
    @run evals, @reverseVals()


class Exercise['exercise-complex-unit-4'] extends ExerciseComplexUnit
  
  postProcess: (evals) ->
    console.log "**** evals", evals
    angle = evals[0]
    return if angle is ""
    zValues = [1, Complex.polarToComplex(1, angle)]
    @run zValues, [1, complex(0, -1)]


class Exercise['exercise-complex-unit-5'] extends ExerciseComplexUnit
  
  postProcess: (evals) ->
    return unless evals.length>3
    A = evals[0]
    @run evals, @forwardVals(A)


class ExerciseRotation
  
  url: "exercises/rotation.coffee"
  
  constructor: ->
    
    $(document).on "preCompileCoffee", (evt, data) =>
      return unless data.resource?.url is @url
      precompile = {}
      precompile[@url] =
        preamble: "i = j\n"
        postamble: "\n"
      $blab.precompile(precompile)
    
    $(document).on "compiledCoffeeScript", (evt, data) =>
      return unless data.url is @url
      @resource = $blab.resources.find @url
      @process()
      @report()
      
  process: ->
    @numbers = []
    for result in @resource.resultArray
      x = @complex(result)
      @numbers.push(x) if x
      
  report: ->
    container = $ "#exercise-rotation-result"
    container.css
      marginTop: "20px"
      fontFamily: "courier"
    container.empty()
    container.append "RESULTS<br>"
    for z in @numbers
      container.append("z = #{z.x} + #{z.y}i<br>")
    #console.log "NUMBERS", numbers
    
  complex: (x) ->
    type = typeof x
    return x if type is "object" and x.constructor.name is "T"
    return complex(x, 0) if type is "number"
    null


$(".solution-button").click (evt) ->
  button = $(evt.target)
  solution = button.parent().find(".solution")
  button.hide()
  solution.show()


#------------Exercise tools-------------#

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
# Complex Plane and Slider Elements
#------------------------------------------------------#

class Vector
  
  constructor: (@spec) ->
    
    {@canvas} = @spec
    
    @x0 = 0
    @y0 = 0
    @x = 0
    @y = 0
    
    @line = new Line {@canvas, class: "line"} 
    @set(@x, @y)
  
  setOrigin: (@x0, @y0) -> @set(@x, @y)
  
  set: (@x, @y) ->
    @line.set {x1: @x0, y1: @y0, x2: @x0+@x, y2: @y0+@y}


class VectorWithCircle
  
  # TODO:
  # txet rounding should be a parameter
  
  constructor: (@spec) ->
    
    {@canvas, @class, @radius, @xyLines, @xyLabels, @xyComponents, @zLabel, @arc, @compute, @click} = @spec
    
    @class ?= "circle fill-green"
    @radius ?= 10
    @xyLabels ?= @xyLines
    @arc ?= true
    
    @vector = new Vector {@canvas}
    
    @circle = new Circle
      canvas: @canvas
      class: @class
      draggable: @compute?
      click: @click
      callback: (p) =>
        zp = complex p.x, p.y
        origin = @origin ? complex(0, 0)
        z = Complex.diff zp, origin
        @compute?(z)
    
    @showXYLines() if @xyLines
    @showXYLabels() if @xyLabels
    @showXYComponents() if @xyComponents
    @showZLabel() if @zLabel
    @showArc() if @arc
    
  setCircleClass: (c) ->
    @circle.setClass "circle "+c
  
  showXYLines: (show=true) ->
    
    setClass = (line) ->
      l = line.line
      c = if show then "line-dashed" else "line-invisible"
      l.attr "class", c
    
    @xLine ?= new Line
      canvas: @canvas
      #class: "line-dashed" 
        
    @yLine ?= new Line
      canvas: @canvas
      #class: "line-dashed"
    
    setClass @xLine
    setClass @yLine
  
  showXYLabels: ->
    
    @xText = new Text
      canvas: @canvas
    
    @yText = new Text
      canvas: @canvas
      # class
        
    @xText.text
      .attr "text-anchor", "middle"
      
    @yText.text
      .attr "dy", "0.4em"
      
  showXYComponents: ->
    
    @xComponent = new Line
      canvas: @canvas
      class: "component"
      
    @yComponent = new Line
      canvas: @canvas
      class: "component"
  
  showZLabel: ->
    
    @zText = new Text
      canvas: @canvas
  
  showArc: ->
    @angleArc = new Arc
      canvas: @canvas
      data:
        x: 0
        y: 0
        innerRadius: 20
        outerRadius: 22
        startAngle: pi/2
        endAngle: pi/2
  
  setOrigin: (@origin) ->
    # @origin is complex
    @vector.setOrigin @origin.x, @origin.y
    @set(@z)
  
  set: (@z, angleRotate=0) ->
    
    @z ?= complex 0, 0
    x = @z.x
    y = @z.y
    {@magnitude, @angle} = Complex.toPolar(@z)
    
    zOriginal = Complex.rotate(@z, -angleRotate)
    
    x0 = @origin?.x ? 0
    y0 = @origin?.y ? 0
    
    @vector.set(x, y)
    @circle.set(x: x0+x, y: y0+y, r: @radius)
    
    xMargin = "0.3em"
    yMargin = "0.6em"
    
    xo = zOriginal.x
    yo = zOriginal.y
    
    xl = x0+x
    yl = y0+y
    
    ca = Math.cos(angleRotate)
    sa = Math.sin(angleRotate)
    
    if angleRotate
      @xLine?.set(x1: x0+xo*ca, y1: xo*sa, x2: xl, y2: yl)
    else
      @xLine?.set(x1: xl, y1: 0, x2: xl, y2: yl)
    @xComponent?.set(x1: 0, y1: 0, x2: xo*ca, y2: xo*sa)
    
    if angleRotate
      @yLine?.set(x1: -yo*sa, y1: y0+yo*ca, x2: xl, y2: yl)
    else
      @yLine?.set(x1: 0, y1: yl, x2: xl, y2: yl)
    @yComponent?.set(x1: 0, y1: 0, x2: -yo*sa, y2: yo*ca)
    
    @xText?.set(x: xl, y: 0, text: if angleRotate then "" else "x="+round(xl, 1))
    @xText?.text
      .attr "fill", (if xl>=0 then "black" else "red")
      .attr "dy", (if yl>=0 then "1.1em" else "-#{xMargin}")
    
    @yText?.set(x: 0, y: yl, text: if angleRotate then "" else "y="+round(yl, 1))
    @yText?.text
      .attr "fill", (if yl>=0 then "black" else "red")
      .attr "text-anchor", (if xl>=0 then "end" else "start")
      .attr "dx", (if xl>=0 then "-#{yMargin}" else yMargin)
    
    isUnit = (x) -> abs(abs(x)-1)<0.000001
    real = y is 0 and isUnit(x)
    imag = x is 0 and isUnit(y)
    @zText?.set
      x: (if real then xl else 0)
      y: (if imag then yl else 0)
      text: (if real or imag then "z="+(if real and x<0 or imag and y<0 then "-" else "")+(if real then "1" else "i") else "")  # ZZZ fix
    @zText?.text
      .attr "fill", (if real and x>=0 or imag and y>=0 then "black" else "red")
      .attr "text-anchor", "middle"
      .attr "dy", (if real or y<0 then "1.5em" else "-0.8em")
    
    # ZZZ arc won't work if @origin
    
    show = @magnitude>0.4
    @angleArc?.set
      innerRadius: if show then 20 else 0
      outerRadius: if show then 22 else 0
      endAngle: pi/2-@angle
      
    @angleArc?.path.attr "fill", (if @angle>=0 then "black" else "red")
  
  animate: (zStart, zEnd, callback) =>
    
    stepDelay = 8
    
    m1 = abs(zStart)
    m2 = abs(zEnd)
    
    a1 = zStart.arg()
    a2 = zEnd.arg()
    
    wrap = (a) -> if a<0 then a+2*pi else a
    d = abs(a1-a2)
    if d>pi
      a1 = wrap(a1)
      a2 = wrap(a2)
    a1 -= 2*pi if abs(a1-a2-pi)<0.00001
    
    d = abs(a1-a2)
    nSteps = if d>pi/8 then Math.round(30*d) else 10
    
    magnitudes = linspace(m1, m2, nSteps)
    angles = linspace(a1, a2, nSteps)
    zValues = (Complex.polarToComplex(magnitudes[idx], angle) for angle, idx in angles)
    zValues[-1..] = zEnd  # End value
    
    step = 1
    aStep = angles[1]-angles[0]
    doStep = =>
      z = zValues[step]
      @set z, (if step+1 is zValues.length then 0 else step*aStep)
      step++
      if step<zValues.length
        setTimeout (-> doStep()), stepDelay # Recursion
      else
        callback?()
    doStep()


class VectorWithTriangle
  
  constructor: (@spec) ->
    
    {@canvas, @class, @compute} = @spec
      
    @class ?= "triangle"
    
    @radius = if @compute? then 10 else 3
    
    @circle = new Circle
      canvas: @canvas
      class: if @compute? then "circle fill-green" else "circle"
      
      draggable: @compute?
      callback: (p) =>
        z = complex p.x, p.y
        @compute?(z)
    
    @smallCircle = new Circle
      canvas: @canvas
      class: "circle fill-black"
      draggable: false
    
    @triangle = new Polygon {@canvas, class: @class}
  
  set: (x, y, xb, yb) ->
    @circle.set(x: x, y: y, r: @radius)
    @smallCircle.set(x: xb, y: yb, r: 3)
    @triangle.set [
      {x: 0, y: 0}
      {x: xb, y: yb}
      {x: x, y: y}
    ]


class VectorSliderPair
  
  constructor: (@spec) ->
    
    {@figure, @canvas, @xyLines, @xyLabels, @xyComponents, @arc, @sliderClass, @angleLabel, @getZ} = @spec
    
    @vector = new VectorWithCircle
      canvas: @canvas
      xyLines: @xyLines ? true
      xyLabels: @xyLabels ? false
      xyComponents: @xyComponents ? false
      arc: @arc ? false
      compute: (z) => @set(z)
      
    @slider = new VerticalAngleSlider
      container: @figure.find @sliderClass
      label: @angleLabel
      change: (angle) =>
        z = Complex.polarToComplex @vector.magnitude, angle
        setSlider = false
        @set z, setSlider
        
  set: (z, setSlider=true) ->
    z = @getZ z
    @vector.set z
    @spec.set?(z)
    @slider.set(@vector.angle) if setSlider
    
  z: -> @vector.z ? complex(0, 0)
  
  origin: -> @vector.origin ? complex(0, 0)
  
  setOrigin: (z) -> @vector.setOrigin z
  
  animate: (zStart, zEnd, callback) ->
    @vector.animate zStart, zEnd, =>
      #@set zEnd
      @spec.set?(z)
      setTimeout (=> @slider.set(@vector.angle)), 10
      callback?()


class VerticalAngleSlider
  
  # Slider for -pi..pi.
  
  nAngle: 48  # Number of slider angles from 0+ to pi
  
  constructor: (@spec) ->
    
    {@container, @label, @change} = @spec
    
    @container.append @template()
    
    @sliderContainer = @container.find(".slider-angle")
    
    @slider = new Slider
      container: @sliderContainer
      orientation: "vertical"
      init: 0
      min: -@nAngle
      max: @nAngle
      step: 1
      change: (v) =>
        @angle = @nToAngle(v)
        @setText()
        @change(@angle)
    
    @height = @sliderContainer.height()
        
    @prompt = @container.find(".slider-angle-prompt")
    katex.render @label, @prompt[0]
    #@prompt.html @label
    
    @text = @container.find(".slider-angle-text")
  
  template: -> """
    <div class='slider-angle'></div>
    <div class='slider-angle-prompt'></div>
    <div class='slider-angle-text angle-text'></div>
  """
    
  set: (@angle) ->
    v = round(@angleToN(@angle), 2)
    @slider.set(v)
    @setText()
  
  setText: ->
    {math, mathjax, special} = angleText(@angleToN(@angle))  # ZZZ dup comp?
    @text.toggleClass('angle-text-special', special)
    @text.toggleClass('angle-text-negative', @angle<0)
    katex.render math, @text[0]
    @setTextPos()
    #@text.html mathjax
    #processed = processMathJax @text, => @setTextPos()
    #@setTextPos() unless processed
  
  setTextPos: ->
    y = @height * 0.5*(1 - @angle/pi) - 15
    @text.css top: "#{y}px"
    
  angleToN: (angle) ->
    n = @nAngle*angle/pi
    n = 0 if abs(n)<0.0000001
    n
  
  nToAngle: (n) -> n*pi/@nAngle


class HorizontalSlider
  
  constructor: (@spec) ->
    
    {@container, @label, @init, @min, @max, @step, @change, @done} = @spec
    
    @container.append @template()
    
    @sliderContainer = @container.find(".slider-horiz")
    
    @slider = new Slider
      container: @sliderContainer
      orientation: "horizontal"
      init: @init
      min: @min
      max: @max
      step: @step
      change: (v) =>
        @value = v
        @setText()
        @change(@value)
      done: => @done()
    
    @height = @sliderContainer.height()
        
    @prompt = @container.find(".slider-horiz-prompt")
    katex.render @label, @prompt[0]
    #@prompt.html @label
    
    @text = @container.find(".slider-horiz-text")
  
  template: -> """
    <div class='slider-horiz-prompt'></div>
    <div class='slider-horiz'></div>
    <div class='slider-horiz-text'></div>
  """
    
  set: (@value) ->
    v = @value
    @slider.set(v)
    @setText()
    
  val: -> @slider.val()
  
  setText: ->
    # {mathjax, special} = angleText(@angleToN(@angle))  # ZZZ dup comp?
    #@text.toggleClass('angle-text-special', special)
    #@text.toggleClass('angle-text-negative', @angle<0)
    @text.html @value
    #processed = processMathJax @text, => @setTextPos()
    #@setTextPos() unless processed
  
  


class Slider
  
  constructor: (@spec) ->
    
    {@container, @min, @max, @step, @init, @orientation, @fast, change, @done} = @spec
    
    @orientation ?= "horizontal"
    @fast ?= true
    
    @changeFcn = if change then ((v) -> change(v)) else (->)
    
    @slider = @container.slider
      orientation: @orientation
      range: "min"
      min: @min
      max: @max
      step: @step
      value: @init
      mouseup: (e) ->
      slide: (e, ui) =>
        @changeFcn(ui.value) if @fast
      change: (e, ui) =>
        @done?() if e.originalEvent
        @changeFcn(ui.value) unless @fast
      
  val: -> @slider.slider "option", "value"
  
  set: (v) ->
    # Forces slider to move to value - used for animation.
    @slider.slider 'option', 'value', v


# Still used by Euler - to be replaced by VectorWithTriangle.
class Z1
  
  constructor: (@spec) ->
    
    {@canvas, @compute} = @spec
    
    @vector = new Vector {@canvas}
    @circle = new Circle
      canvas: @canvas
      class: "circle fill-green"
      draggable: @compute?
      callback: (p) => @compute(p)
      #@triangle = new Polygon {@canvas, class: "triangle"}
    
  set: (x, y) ->
    @vector.set(x, y)
    @circle.set(x: x, y: y, r: 10)
      # @triangle.set [
      #   {x: 0, y: 0}
      #   {x: x, y: y}
      #   {x: x, y: 0}
      # ]



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
# Utility functions
#------------------------------------------------------#

round = (x, n) ->
  f = Math.pow(10, n)
  Math.round(x * f)/f


angleText = (a) ->
  
  # a is angle in pi/48 radians.
  
  # Angle in radians.
  theta = pi*a/48
  
  specialAngles =
    
    0: '0'
    
    8: '\\frac{\\pi}{6}'
    12: '\\frac{\\pi}{4}'
    
    16: '\\frac{\\pi}{3}'
    24: '\\frac{\\pi}{2}'
    
    32: '\\frac{2\\pi}{3}'
    36: '\\frac{3\\pi}{4}'
    
    40: '\\frac{5\\pi}{6}'
    48: '\\pi'
    
    56: '\\frac{7\\pi}{6}'
    
    60: '\\frac{5\\pi}{4}'
    64: '\\frac{4\\pi}{3}'
    
    72: '\\frac{3\\pi}{2}'
    80: '\\frac{5\\pi}{3}'
    
    84: '\\frac{7\\pi}{4}'
    88: '\\frac{11\\pi}{6}'
    96: '2\\pi'
  
  # Angle in pi-radians, rounded to two decimal places.
  piRad = Math.round(100*theta/pi)/100  # ZZZ use round above
  
  aa = round(Math.abs(a), 8)
  special = specialAngles[aa]?
  minus = "-\\!"  # \! is negative space
  mj = if special then (if a<0 then minus else "")+specialAngles[aa] else piRad+"\\pi"
  mj = "{#{mj}}"  # Wrap in {} to get shorter unary minus sign.
  mathjax = "$#{mj}$"  # No longer used
  math = mj
  
  {math, mathjax, special}


# To delete
processMathJax = (element, callback) ->
  return false unless MathJax?
  #console.log element
  Hub = MathJax.Hub
  queue = (x) -> Hub.Queue x
  queue ['PreProcess', Hub, element[0]]
  queue ['Process', Hub, element[0]]
  queue -> element.find('.math>span').css("border-left-color", "transparent")
  queue(callback) if callback
  true


$blab.Figures = Figures
