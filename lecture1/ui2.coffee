#!no-math-sugar

# TODO:
# process mathjax only once loaded.

#--- Base class ---#

class ComplexPlane
  
  # Override in subclass
  margin: {top: 10, right: 10, bottom: 10, left: 10}
  xDomain: [-1, 1]
  yDomain: [-1, 1]
    
  constructor: (@spec) ->
    {@container} = @spec
    @width = @container.width()
    @height = @container.height()
    @createCanvas()
    
  createCanvas: ->
    @canvas = new Canvas {@container, @width, @height, @margin, @xDomain, @yDomain}
    @gridLines = new GridLines {@canvas}


#--- Figures ---#

class FigureComplexPlane extends ComplexPlane
  
  # TODO: use VectorSliderPair
  
  id: "#figure-complex-plane"
  
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
      label: "$\\theta$"
      change: (angle) =>
        z = Complex.polarToComplex @magnitude, angle
        @draw z
    
    @magnitudeText = $ "<span>"
    (@figure.find ".magnitude").append("Magnitude: A=").append(@magnitudeText)
    
    @setVector(x: 1, y: 1)
  
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


class FigureComplexAddition extends ComplexPlane
  
  # TODO: show x+jy and a+jb below, and sum.
  # TODO: different colors for vectors and xy lines
  # BUG?: slider wrong if move and z clips.  or clipping shortens vector when clips?
  
  id: "#figure-complex-addition"
  
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
      angleLabel: "$\\theta_1$"
      getZ: (z) => @getZ(z, @vector2.z())
      set: =>
        @setOrigin2()
        @setMagnitude()
      
    @vector2 = new VectorSliderPair
      figure: @figure
      canvas: @canvas
      xyLabels: true
      sliderClass: ".slider-2"
      angleLabel: "$\\theta_2$"
      getZ: (z) => @getZ(z, @vector1.z())
      set: => @setMagnitude()
    
    @magnitudeText = $ "<span>"
    (@figure.find ".magnitude").append("Magnitude: A=").append(@magnitudeText)
    
    @vector1.set complex(1, 0.5)
    @setOrigin2()
    @vector2.set complex(0.5, 0.5)
  
  setMagnitude: ->
    A = Complex.magnitudeSum(@vector1.z(), @vector2.z())
    @magnitudeText.html round(A, 2)
  
  setOrigin2: (v, z) -> @vector2.setOrigin @vector1.z()
  
  getZ: (z, other) ->
    total = Complex.add(z, other)
    clip = Complex.clipMagnitude(total, 2)
    snap = Complex.snap(clip, 1)
    Complex.diff snap, other


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
      label: "$\\theta$"
      change: (angle) =>
        @z = Complex.polarToComplex abs(@z), angle
        @draw()
    
    @sliderScaleFactor = new HorizontalSlider
      container: $(".slider-scale-factor")
      label: "$a$"
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
  

class FigureEulerFormula extends ComplexPlane
    
    xDomain: [-3, 3]
    yDomain: [-3, 3]
    
    constructor: ->
      
      super container: $("#figure-euler-formula .figure-surface")
      
      #@container = $("#math-surface")
      
      theta = pi
      N = 4
      
      Slider = $blab.components.Slider
      
      @sliderTheta = new Slider
        container: $("#slider-theta")
        prompt: "$\\theta$"
        unit: "$\\pi$ radians"
        init: theta/pi
        min: 0
        max: 2
        step: 0.125
      
      @sliderN = new Slider
        container: $("#slider-n")
        prompt: "N"
        unit: ""
        init: N
        min: 1
        max: 200
      
      @sliderTheta.change =>
        theta = @sliderTheta.getVal() * pi
        @build(theta, N)
      
      @sliderN.change =>
        N = @sliderN.getVal()
        @build(theta, N)
      
      @build(theta, N)
      
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
      step = Computation2.angleStep(theta, N)
      @doSteps @triangles1, "triangle", points, N, step
      
      points = z: z0
      step = Computation2.orthoStep(theta, N)
      @doSteps @triangles2, "triangle fill-blue", points, N, step
       
    doSteps: (triangles, c, points, N, step) ->
      for n in [1..N]
        z = new VectorWithTriangle(canvas: @canvas, class: c)
        triangles.push z
        points = Computation2.step(points.z, step)
        @draw z, points
    
    draw: (t, points) ->
      {z1, z2, z, az1} = points
      t.set z.x, z.y, az1.x, az1.y


#--- Sliders ---#

class VectorSliderPair
  
  constructor: (@spec) ->
    
    {@figure, @canvas, @xyLines, @xyLabels, @sliderClass, @angleLabel, @getZ} = @spec
    
    @vector = new VectorWithCircle
      canvas: @canvas
      xyLines: @xyLines ? true
      xyLabels: @xyLabels
      arc: false
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
    @prompt.html @label
    
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
    {mathjax, special} = angleText(@angleToN(@angle))  # ZZZ dup comp?
    @text.toggleClass('angle-text-special', special)
    @text.toggleClass('angle-text-negative', @angle<0)
    @text.html mathjax
    processed = processMathJax @text, => @setTextPos()
    @setTextPos() unless processed
  
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
    @prompt.html @label
    
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


#--- d3 elememts ---#

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
    
    {@canvas, @data, @draggable, @class} = @spec
    
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


#--- Complex plane elements ---#

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
    
    {@canvas, @class, @radius, @xyLines, @xyLabels, @arc, @compute} = @spec
      
    @class ?= "circle fill-green"
    @radius ?= 10
    @xyLabels ?= @xyLines
    @arc ?= true
    
    @vector = new Vector {@canvas}
    
    @circle = new Circle
      canvas: @canvas
      class: @class
      draggable: @compute?
      callback: (p) =>
        zp = complex p.x, p.y
        origin = @origin ? complex(0, 0)
        z = Complex.diff zp, origin
        @compute?(z)
    
    @showXYLines() if @xyLines
    @showXYLabels() if @xyLabels
    @showArc() if @arc
  
  showXYLines: ->
    
    @xLine = new Line
      canvas: @canvas
      class: "line-dashed"
        
    @yLine = new Line
      canvas: @canvas
      class: "line-dashed"
  
  showXYLabels: ->
    
    @xText = new Text
      canvas: @canvas
      # class
    
    @yText = new Text
      canvas: @canvas
      # class
        
    @xText.text
      .attr "text-anchor", "middle"
      
    @yText.text
      .attr "dy", "0.4em"
      
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
  
  set: (@z) ->
    
    @z ?= complex 0, 0
    x = @z.x
    y = @z.y
    {@magnitude, @angle} = Complex.toPolar(@z)
    
    x0 = @origin?.x ? 0
    y0 = @origin?.y ? 0
    
    @vector.set(x, y)
    @circle.set(x: x0+x, y: y0+y, r: @radius)
    
    xMargin = "0.3em"
    yMargin = "0.3em"
    
    xl = x0+x
    yl = y0+y
    
    @xLine?.set(x1: xl, y1: 0, x2: xl, y2: yl)
    @xText?.set(x: xl, y: 0, text: "x="+round(xl, 1))
    @xText?.text
      .attr "fill", (if xl>=0 then "black" else "red")
      .attr "dy", (if yl>=0 then "1.1em" else "-#{xMargin}")
    
    @yLine?.set(x1: 0, y1: yl, x2: xl, y2: yl)
    @yText?.set(x: 0, y: yl, text: "y="+round(yl, 1))
    @yText?.text
      .attr "fill", (if yl>=0 then "black" else "red")
      .attr "text-anchor", (if xl>=0 then "end" else "start")
      .attr "dx", (if xl>=0 then "-#{yMargin}" else yMargin)
    
    # ZZZ arc won't work if @origin
    
    show = @magnitude>0.4
    @angleArc?.set
      innerRadius: if show then 20 else 0
      outerRadius: if show then 22 else 0
      endAngle: pi/2-@angle
      
    @angleArc?.path.attr "fill", (if @angle>=0 then "black" else "red")


#------------------#

class VectorAngle
  
  constructor: (@container, @x0, @y0) ->
  
  set: (x, y, mathjax, special) ->
    @container.toggleClass('angle-text-special', special)
    @container.html mathjax
    processMathJax @container, => @pos(x, y)
  
  pos: (x, y) ->
    
    w = @container.width()
    h = @container.height()
    
    r = Math.sqrt(x*x + y*y)
    f = (x) -> 0.5*(1 - 1.2*x/r)
    
    @container.css
      left: @x0 + x - w*f(x)
      top: @y0 + y - h*f(y)
    


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


class Z
  
  constructor: (@spec) ->
    
    {@canvas, @compute} = @spec
    
    @circle = new Circle
      canvas: @canvas
      class: "circle"
      draggable: true
      callback: (p) => @compute(p)
      
    @smallCircle = new Circle
      canvas: @canvas
      class: "circle fill-black"
      draggable: false
      
    @triangle = new Polygon {@canvas, class: "triangle"}
    
  set: (x, y, xb, yb) ->
    @circle.set(x: x, y: y, r: 10)
    @smallCircle.set(x: xb, y: yb, r: 3)
    @triangle.set [
      {x: 0, y: 0}
      {x: xb, y: yb}
      {x: x, y: y}
    ]


# Multiply two complex vectors - to rename.
class Main1
  
  # ZZZ get from container?
  width: 600
  height: 600
  margin: {top: 30, right: 30, bottom: 50, left: 25}
  xDomain: [-1.5, 1.5]
  yDomain: [-1.5, 1.5]
  
  constructor: ->
    
    @container = $("#math-surface")
    @canvas = new Canvas {@container, @width, @height, @margin, @xDomain, @yDomain}
    @gridLines = new GridLines {@canvas} 
    
    # First vector, z1
    @z1 = new Z1
      canvas: @canvas
      compute: (p) => @computation.setZ1(p)
    
    # Result vector, z = z1*z2
    @z = new Z
      canvas: @canvas
      compute: (p) => @computation.setZ(p)
    
    @computation = new Computation1(draw: (points) => @draw(points))
    
#    $(document).on "mathjaxPreConfig", => @compute(0)
    
  draw: (points) ->
    {z1, z2, z, az1} = points
    @z1.set z1.x, z1.y
    @z.set z.x, z.y, az1.x, az1.y  #, z2.z, z2.y


class VectorWithTriangle
  
  constructor: (@spec) ->
    
    {@canvas, @class} = @spec
      
    @class ?= "triangle"
    
    @circle = new Circle
      canvas: @canvas
      class: "circle"
      draggable: false
    
    @smallCircle = new Circle
      canvas: @canvas
      class: "circle fill-black"
      draggable: false
    
    @triangle = new Polygon {@canvas, class: @class}
  
  set: (x, y, xb, yb) ->
    @circle.set(x: x, y: y, r: 3)
    @smallCircle.set(x: xb, y: yb, r: 3)
    @triangle.set [
      {x: 0, y: 0}
      {x: xb, y: yb}
      {x: x, y: y}
    ]


#!math-sugar

# Complex number computation
# TODO - put in separate file - visible in Ace editor in document?
class Complex
  
  @toPolar: (z) ->
    magnitude = abs(z)
    angle = z.arg()
    {magnitude, angle}
  
  @polarToComplex: (magnitude, angle) ->
    z = complex(magnitude*cos(angle), magnitude*sin(angle))
    
  @clipMagnitude: (z, maxA) ->
    a = abs(z)
    return z if a<maxA
    (maxA/a)*z
    
  @snap: (z, n) -> complex(round(z.x, n), round(z.y, n))
    
  @add: (z1, z2) -> z1 + z2
  
  @diff: (z1, z2) ->
    d = z1 - z2
    d.y ?= 0 # TODO: Fix in math module
    d
  
  @magnitudeSum: (z1, z2) -> abs(z1 + z2)
  
  @scale: (z, a) -> a * z
  
  @div: (z1, z2) -> z1/z2


class Computation2
  
  @angleStep: (theta, N) ->
    cos(theta/N) + j*sin(theta/N)
  
  @orthoStep: (theta, N) ->
    1 + j*theta/N
  
  @step: (z1, z2) ->
    # Diff vector
    z = z1*z2
    az1 = z2.x*z1
    {z1, z2, z, az1}


#step = (z1) ->

class Computation1
  
  constructor: (@spec) ->
    
    {@draw} = @spec
    
    @z1 = complex(1, 0)
    @z2 = 1/sqrt(2) * complex(1, 1)
    
    @setZ1(complex(1,0))
    @setZ(1/sqrt(2) * complex(1, 1))
    
    # ZZZ should do a setZ1, setZ here, to get constraints.
    @compute()
    
  compute: ->
    @z = @z1*@z2
    @az1 = @z2.x*@z1
    
    @draw {@z1, @z2, @z, @az1}
    
  setZ1: (p) ->
    @z1 = complex p.x, p.y
    
    # Constrain
    @z1 = @z1 / abs(@z1)
    
    @compute()
    
  setZ: (p) ->
    z = complex p.x, p.y
    
    # Constrain
    z = z / abs(z)
    
    @z2 = z / @z1
    
    @compute()


#!no-math-sugar

#------- Functions -----------#

round = (x, n) ->
  f = Math.pow(10, n)
  Math.round(x * f)/f


#!math-sugar
complexPolar = (r, theta) -> r*exp(j*theta)
#!no-math-sugar

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
  mathjax = "$#{mj}$"
  
  {mathjax, special}


processMathJax = (element, callback) ->
  return false unless MathJax?
  Hub = MathJax.Hub
  queue = (x) -> Hub.Queue x
  queue ['PreProcess', Hub, element[0]]
  queue ['Process', Hub, element[0]]
  queue -> $('.math>span').css("border-left-color", "transparent")
  queue(callback) if callback
  true


#------------------------------------------------------#
# Figures
#------------------------------------------------------#

new FigureComplexPlane
new FigureComplexAddition
new FigureComplexScaling
new FigureEulerFormula

#------------------------------------------------------#

extraStuff = ->
  
  input = new $blab.components.Slider
    container: $("#input")
    prompt: "Frequency"
    unit: "Hz"
    init: 10
    min: 0
    max: 40
    
  plot = new $blab.components.Plot
    container: $("#plot")
    title: "TEST PLOT, $f(x)$"
    width: 500, height: 300
    xlabel: "x", ylabel: "y"
    # xaxis: {min: 0, max: 1}
    # yaxis: {min: 0, max: 1}
    series: {lines: lineWidth: 2}
    colors: ["red", "blue"]
    grid: {backgroundColor: "white"}
    
  compute = $blab.resources.find "compute.coffee"
  input.change -> compute.compile()  # Does not compile if code unchanged
  
  $blab.ui =
    input: -> parseFloat(input.getVal())
    result: (f) -> $("#result").html("Frequency " + f + " Hz")
    plot: (x, y) -> plot.setVal([x, y])

