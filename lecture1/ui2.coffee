#!no-math-sugar

Slider = 

round = (x, n) ->
  f = Math.pow(10, n)
  Math.round(x * f)/f

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


class FigureComplexPlane extends ComplexPlane
  
  id: "#figure-complex-plane"
  
  margin: {top: 40, right: 40, bottom: 40, left: 40}
  xDomain: [-2, 2]
  yDomain: [-2, 2]
  
  constructor: ->
    
    super container: $("#{@id} .figure-surface")
    
    @vector = new VectorWithCircle
      canvas: @canvas
      xyLines: true
      compute: (p) => @draw(p)
    
    Slider = $blab.components.Slider
    
    @sliderAngle = new Slider
      container: $("#{@id} #slider-angle")
      prompt: "$\\theta$"
      unit: "$\\pi$ radians"
      init: 0
      min: -1
      max: 1
      step: 1/48 #0.125/2
    
    # TODO: make vertcial slider on right side of plot.
    #@sliderAngle.slider.slider orientation: "vertical"
    
    @draw(x: 1, y: 1)
    
    @sliderAngle.change =>
      angle = @sliderAngle.getVal() * pi
      z = ComputationComplexPlane.setPolar @magnitude, angle
      @draw2 z
      #console.log angle, z
      #@build(theta, N)
  
  draw: (p) ->
    
    x = p.x
    y = p.y
    
    # Snap to grid
    x = round(x, 1)
    y = round(y, 1)
    
    @z = complex x, y
    
    {@magnitude, @angle} = ComputationComplexPlane.set(@z)
    @sliderAngle.move round(@angle/pi, 2)  # OK here?
    
    @draw2(@z)
    
  draw2: (@z) ->
    
    {@magnitude, @angle} = ComputationComplexPlane.set(@z)
    
    @vector.set @z.x, @z.y, @magnitude, @angle
    
    $("#{@id} #magnitude").html round(@magnitude, 2)
    #$("#{@id} #angle").html round(@angle/pi, 2) 
    
  #round: (x) ->
  #  Math.round(x * 100)/100


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
    
  set: (@x, @y) ->
    @line.set {x1: @x0, y1: @y0, x2: @x0+@x, y2: @y0+@y}


class VectorWithCircle
  
  # TODO:
  # txet rounding should be a parameter
  
  constructor: (@spec) ->
    
    {@canvas, @class, @radius, @xyLines, @compute} = @spec
      
    @class ?= "circle fill-green"
    @radius ?= 10
    
    @vector = new Vector {@canvas}
    
    @circle = new Circle
      canvas: @canvas
      class: @class
      draggable: @compute?
      callback: (p) => @compute?(p)
      
    @arc = new Arc
      canvas: @canvas
      data:
        x: 0
        y: 0
        innerRadius: 20
        outerRadius: 22
        startAngle: pi/2
        endAngle: pi/2
      
    @showXYLines() if @xyLines
  
  showXYLines: ->
    
    @xLine = new Line
      canvas: @canvas
      class: "line-dashed"
        
    @yLine = new Line
      canvas: @canvas
      class: "line-dashed"
        
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
    
  set: (x, y, magnitude=0, angle=0) ->
    
    @vector.set(x, y)
    @circle.set(x: x, y: y, r: @radius)
    
    xMargin = "0.3em"
    yMargin = "0.3em"
    
    @xLine?.set(x1: x, y1: 0, x2: x, y2: y)
    @xText?.set(x: x, y: 0, text: "x="+round(x, 1))
    @xText?.text
      .attr "fill", (if x>=0 then "black" else "red")
      .attr "dy", (if y>=0 then "1.1em" else "-#{xMargin}")
    
    @yLine?.set(x1: 0, y1: y, x2: x, y2: y)
    @yText?.set(x: 0, y: y, text: "y="+round(y, 1))
    @yText?.text
      .attr "fill", (if y>=0 then "black" else "red")
      .attr "text-anchor", (if x>=0 then "end" else "start")
      .attr "dx", (if x>=0 then "-#{yMargin}" else yMargin)
    
    show = magnitude>0.4
    @arc?.set
      innerRadius: if show then 20 else 0
      outerRadius: if show then 22 else 0
      endAngle: pi/2-angle
      
    @arc?.path.attr "fill", (if angle>=0 then "black" else "red")


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

# Computation for FigureComplexPlane
# TODO - put in separate file - visible in Ace editor in document
class ComputationComplexPlane
  
  @set: (z) ->
    magnitude = abs(z)
    angle = z.arg()
    {magnitude, angle}
    
  @setPolar: (magnitude, angle) ->
    z = complex(magnitude*cos(angle), magnitude*sin(angle))


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
  piRad = Math.round(100*theta/pi)/100
  
  special = specialAngles[a]?
  mj = if special then specialAngles[a] else piRad+"\\pi"
  mathjax = "$#{mj}$"
  
  {mathjax, special}


processMathJax = (element, callback) ->
  return unless MathJax?
  Hub = MathJax.Hub
  queue = (x) -> Hub.Queue x
  queue ['PreProcess', Hub, element[0]]
  queue ['Process', Hub, element[0]]
  queue -> $('.math>span').css("border-left-color", "transparent")
  queue(callback) if callback


new FigureComplexPlane
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

