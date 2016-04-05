#!no-math-sugar

{Slider, Table, Plot} =  $blab.components

slider = new Slider
  container: $("#lecture-slider-1")
  prompt: "k"
  unit: ""
  init: 5
  min: 0
  max: 10
  step: 0.1

# Menu not implemented yet.
# @menu = new $blab.components.Menu
#   init: 0
#   prompt: "Offset:"
#   options: [
#     {text: "None", value: 0}
#     {text: "Small", value: 5}
#     {text: "Large", value: 20}
#   ],
#   align: "left"

table = new Table
  container: $("#lecture-table-1")
  id: "my-table"  # Must be consistent with tables.json
  title: "Quadratic"
  headings: ["$x$", "$x^2$"]  # ["Column 1", "Column 2"]
  widths: 100  #[100, 100]
  
plot = new Plot
  container: $("#lecture-plot-1")
  title: "Quadratic"
  width: 400, height: 300
  xlabel: "x", ylabel: "y"
  # xaxis: {min: 0, max: 1}
  yaxis: {min: 0, max: 100}
  series: {lines: lineWidth: 1}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}
  

$blab.computation "compute.coffee", {slider, table, plot}  # @menu


#---- MathJax -----#

# $(document).on "mathjaxPreConfig", => #@compute(0)
  
# processMathJax = (element, callback) ->
#   return unless MathJax?
#   Hub = MathJax.Hub
#   queue = (x) -> Hub.Queue x
#   queue ['PreProcess', Hub, element[0]]
#   queue ['Process', Hub, element[0]]
#   queue -> $('.math>span').css("border-left-color", "transparent")
#   queue(callback) if callback
