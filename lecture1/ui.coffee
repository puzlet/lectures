#!no-math-sugar

components = $blab.components

input = new components.Slider
  container: $("#input")
  prompt: "Frequency"
  unit: "Hz"
  init: 10
  min: 0
  max: 40

plot = new components.Plot
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

angle = new components.Slider
  container: $("#angle")
  prompt: "Angle"
  unit: "$\\pi/48$ radians"
  init: 0
  min: 0
  max: 96
  

processMathJax = (element, callback) ->
  #console.log "processMathJax", MathJax?
  return unless MathJax?
  Hub = MathJax.Hub
  queue = (x) -> Hub.Queue x
  queue ['PreProcess', Hub, element[0]]
  queue ['Process', Hub, element[0]]
  queue -> $('.math>span').css("border-left-color", "transparent")
  queue(callback) if callback

width = 400
height = 400
overlay = d3.select "#math-surface"
overlay.selectAll("svg").remove()
svg = overlay.append("svg")
  .attr('width', width)
  .attr('height', height)

surface = svg.append("g")
  .attr("width", width)
  .attr("height", height)

x1 = width/2
y1 = height/2
x2 = x1
y2 = y1
line = surface.append("line")
  .attr("x1", x1)
  .attr("y1", y1)
  .attr("x2", x2)
  .attr("y2", y2)
  .attr("class", "grid-line")

x0 = width/2
y0 = height/2

math = $("#math")

angle.change -> computeVector()

v =
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
  

#!math-sugar
foo = (r, theta) ->
  z = r*exp(j*theta)

#!no-math-sugar
computeVector = ->
  
  a = parseInt(angle.getVal())

  radius = 120  # temp
  #a = 0  # temp

  theta = pi*a/48

  z = foo(radius, theta)
  #z = radius*exp(j*theta)
  x = z.x
  y = -z.y
  y = 0 unless y

  #console.log "z", z, x, y

  # $("#math-dot").css
  #   left: x0+x
  #   top: y0+y

  line.attr "x2", x0+x
  line.attr "y2", y0+y

  #chars = ["\\Psi", "x", "y"]
  #char = chars[c]

  pirad = Math.round(100*theta/pi)/100
  #console.log "***** v", v, a
  
  if v[a]
  #if a<v.length and v[a].length
    c = "$"+v[a]+"$"
    math.css
      fontSize: '20pt'
      color: 'black'
      #background: 'yellow'
  else
    c = "$"+pirad+"\\pi$"
    math.css
      fontSize: '12pt'
      color: '#aaa'
      #background: 'none'
    
  
  #char = v[a] # "\\frac{#{pirad}\\pi}{48}"

  # temp
  math.html c # "$#{char}$"
  
  processMathJax math, -> doSize(x, y, radius)
  

doSize = (x, y, radius) ->
  w = math[0].offsetWidth
  h = math[0].offsetHeight
  #$("#math-dot").css
  #  width: w
  #  height: h
  math.css
    left: x0 + x - w/2*(1 - 1.2*x/radius)
    top: y0 + y - h/2*(1 - 1.2*y/radius)
    #left: x0 + x - w/2 + x/50*w/2
    #top: y0 + y - h/2 + y/50*h/2
  #console.log "math", w, h

$(document).on "mathjaxPreConfig", ->
  console.log "MATHJAX"
  computeVector()
  
  
#setTimeout (->
#  compute()), 5000

 