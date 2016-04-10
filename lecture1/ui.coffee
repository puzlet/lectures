#!no-math-sugar

class AngleSlider
  
  constructor: (@container, @setMethod)->
    
    @slider = new $blab.components.Slider
      container: @container
      prompt: "Angle"
      unit: "radians"
      init: 0
      min: 0
      max: 96
      
    @textOuter = @slider.textDiv
    @textOuter.empty()
    @textInner = $ "<div>", class: "angle-inner angle-text"
    @textOuter.append @textInner
    
    @slider.set = (v) => @setMethod(v)
    
  set: (v, mathjax, special) ->
    @slider.value = v
    @textInner.toggleClass('angle-text-special', special)
    #unit = $ "<span>",
    #  class: "angle-slider-unit"
    #  text: " radians"
    @textInner.html(mathjax)
    #@textInner.append unit
    processMathJax @textInner


class Vector
  
  # TODO:
  # use coord mapping
  
  # ZZZ constructor args?
  width: 400
  height: 400
  
  constructor: (@container) ->
    
    @overlay = d3.select @container[0]
    @overlay.selectAll("svg").remove()
    @svg = @overlay.append("svg")
      .attr('width', @width)
      .attr('height', @height)
      
    @surface = @svg.append("g")
      .attr("width", @width)
      .attr("height", @height)
      
    x1 = @width/2
    y1 = @height/2
    @x = 0
    @y = 0
    # ZZZ DUP?
    @x2 = x1 + @x
    @y2 = y1 + @y
    
    @line = @surface.append("line")
      .attr("x1", x1)
      .attr("y1", y1)
      .attr("x2", @x2)
      .attr("y2", @y2)
      .attr("class", "grid-line")  # rename class
    
    @x0 = x1
    @y0 = y1
    
  set: (@x, @y) ->
    @line
      .attr "x2", @x0+x
      .attr "y2", @y0+y


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
    


class Main
  
  radius: 120
  
  constructor: ->
    
    @angleSlider = new AngleSlider($("#angle"), (v) => @compute(v))
    @vector = new Vector $("#math-surface")
    @vectorAngle = new VectorAngle($("#math"), @vector.x0, @vector.y0)
    
    $(document).on "mathjaxPreConfig", => @compute(0)
  
  compute: (v) ->
    
    a = parseInt(v)
    theta = pi*a/48
    
    z = complexPolar(@radius, theta)
    x = z.x
    y = -z.y
    y = 0 unless y
    
    {mathjax, special} = angleText(a)
    
    @angleSlider.set v, mathjax, special
    @vector.set(x, y)
    @vectorAngle.set x, y, mathjax, special


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


#new Main

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

