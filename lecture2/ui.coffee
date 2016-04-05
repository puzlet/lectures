#!no-math-sugar

{Slider, Menu, Table, Plot} =  $blab.components

slider = new Slider
  container: $("#lecture-slider-quadratic")
  prompt: "k"
  unit: ""
  init: 5
  min: 0
  max: 10
  step: 0.1

menu = new Menu
  container: $("#lecture-menu-offset")
  init: 0
  prompt: "Offset:"
  options: [
    {text: "None", value: 0}
    {text: "Small", value: 5}
    {text: "Large", value: 20}
  ]
  align: "left"

table = new Table
  container: $("#lecture-table-quadratic")
  id: "my-table"  # Must be consistent with tables.json
  title: "Quadratic"
  headings: ["$x$", "$x^2$"]  # ["Column 1", "Column 2"]
  widths: 100  #[100, 100]
  
plot = new Plot
  container: $("#lecture-plot-quadratic")
  title: "Quadratic"
  width: 400, height: 300
  xlabel: "x", ylabel: "y"
  # xaxis: {min: 0, max: 1}
  yaxis: {min: 0, max: 100}
  series: {lines: lineWidth: 1}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}

# Custom UI element
textOffset = ui: -> (val) ->
  id = "lecture-text-offset"
  $("##{id} > [data-val]").hide()
  $("##{id} > [data-val=#{val}]").show()

$blab.computation "compute.coffee", {slider, menu, table, plot, textOffset}
