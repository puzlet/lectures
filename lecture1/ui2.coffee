#!no-math-sugar

# TODO:
# Coord mapping

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
      draggable: true
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
    #@triangle2 = new Polygon {@canvas, class: "triangle"}
    #@triangle3 = new Polygon {@canvas, class: "triangle"}
      
    #@triangleZ2 = new Polygon {@canvas, class: "triangle"}
    
  set: (x, y, xb, yb) ->
    #console.log "circle", x, y, xb, yb
    @circle.set(x: x, y: y, r: 10)
    @smallCircle.set(x: xb, y: yb, r: 3)
    @triangle.set [
      {x: 0, y: 0}
      {x: xb, y: yb}
      {x: x, y: y}
    ]
    # @triangle2.set [
    #   {x: 0, y: 0}
    #   {x: xb, y: 0}
    #   {x: xb, y: yb}
    # ]
    # @triangle3.set [
    #   {x: xb, y: yb}
    #   {x: xb, y: y}
    #   {x: x, y: y}
    # ]
    # @triangleZ2.set [
    #   {x: 0, y: 0}
    #   {x: xb/2, y: yb/2}
    #   {x: x/2, y: y/2}
    # ]
    

class Main
  
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
    
    @computation = new Computation(draw: (points) => @draw(points))
    
#    $(document).on "mathjaxPreConfig", => @compute(0)
    
  draw: (points) ->
    {z1, z2, z, az1} = points
    @z1.set z1.x, z1.y
    #console.log "zset", z, az1
    @z.set z.x, z.y, az1.x, az1.y  #, z2.z, z2.y


#!math-sugar
class Computation
  
  constructor: (@spec) ->
    {@draw} = @spec
    @z1 = 1/sqrt(2) * complex(1, 1)
    @z2 = complex 0.5, 0.5
    @compute()
    
  compute: ->
    @z = @z1*@z2  # BUG?
    @z.y ?= 0  # Set imaginary to zero if undefined.
    #@z = @mul(@z1, @z2) #@z1*@z2  # BUG?
    #console.log "MUL", @z, @z1*@z2
    
    @az1 = @z2.x*@z1
    @az1.y ?= 0  # Set imaginary to zero if undefined.
    
    #@az1 = complex(@z2.x*@z1.x, @z2.x*@z1.y) # # Bug - real * complex
    @draw {@z1, @z2, @z, @az1}
    
  setZ1: (p) ->
    @z1 = complex p.x, p.y
    
    # Constrain
    @z1 = @z1 / abs(@z1)
    @z1.y ?= 0
    
    @compute()
    
  setZ: (p) ->
    z = complex p.x, p.y
    @z2 = z / @z1
    @z2.y ?= 0  # Set imaginary to zero if undefined.
    #@z2 = @div z, @z1
    #@z2 = z / @z1  # Bug with zero imaginary values
    @compute()
    
#   div: (z1, z2) ->
#     # Fixes bug with complex division.
#     zz = @mul(z1, @conj(z2))
# #    zz = @mul(z1, z2.conj())
#     #z1*z2.conj()  # Bug here, too
#     #zz = complex(z1.x*z2.x - z1.y*z2.y, z1.x*z2.y + z1.y*z2.x)  #z1*z2.conj()  # Bug here, too
#     a = 1/(z2.x * z2.x + z2.y * z2.y)
#     #console.log z1, z2, zz, a
#     complex(a*zz.x, a*zz.y)
#
#   mul: (z1, z2) ->
#     x = z1.x*z2.x - z1.y*z2.y
#     y = z1.x*z2.y + z1.y*z2.x
#     #console.log "z1/z2/x/y", z1, z2, x, y
#     complex(x, y)
#
#   conj: (z) ->
#     complex(z.x, -z.y)
    

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


new Main

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

