#--------------Old, Extra, Unused--------------------#

class OLD_Figure_Multiply
  
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
    @z = new OLD_Figure_Multiply_Z
      canvas: @canvas
      compute: (p) => @computation.setZ(p)
    
    @computation = new OLD_Figure_Multiply_Computation1(draw: (points) => @draw(points))
    
#    $(document).on "mathjaxPreConfig", => @compute(0)
    
  draw: (points) ->
    {z1, z2, z, az1} = points
    @z1.set z1.x, z1.y
    @z.set z.x, z.y, az1.x, az1.y  #, z2.z, z2.y


class OLD_Figure_Multiply_Computation1
  
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


class OLD_Figure_Multiply_Z
  
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


class OLD_VectorAngle
  
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



