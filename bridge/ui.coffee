#!no-math-sugar

{Slider, Menu, Table, Plot} =  $blab.components

###
menu_examples = new Menu
  container: $("#lecture-menu-examples")
  init: 1
  prompt: null
  options: [
    {text: "choose example", value: 0}
    {text: "diameter of visible universe", value: 1}
    {text: "power output of sun", value: 2}
    {text: "mass of the earth", value: 3}
  ]
  align: "center"

table_decimal = new Table
  container: $("#lecture-table-decimal")
  id: "decimal"
  title: null
  headings: null
  widths: 500

table_product = new Table
  container: $("#lecture-table-product")
  id: "product"
  title: null
  headings: null
  widths: 500

table_exp = new Table
  container: $("#lecture-table-exp")
  id: "exp"
  title: null
  headings: null
  widths: 500

table_sn = new Table
  container: $("#lecture-table-sn")
  id: "sn"
  title: null
  headings: null
  widths: 500

slider_count = new Slider
  container: $("#lecture-slider-count")
  prompt: "length"
  unit: "digits"
  init: 0
  min: 1
  max: 50
  step: 1
###


slider_real = new Slider
  container: $("#lecture-slider-real")
  prompt: "a"
  unit: null
  init: -0.1
  min: -0.5
  max: 0.5
  step: 0.05

slider_imag = new Slider
  container: $("#lecture-slider-imag")
  prompt: "b"
  unit: null
  init: 5
  min: 1
  max: 10
  step: 1

#plot_s = new $blab.components.Plot
plot_s = new Plot
  container: $("#lecture-plot-s")
  title: "complex exponential: $e^{st}$"
  width: 300, height: 300
  xlabel: "$\Re{s} = e^{at}\cos bt$"
  ylabel: "$\Im{s} = e^{at}\sin bt$"
  xaxis: {min: -2, max: 2}
  yaxis: {min: -2, max: 2}
  series: {lines: lineWidth: 2}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}


  
$blab.computation "compute.coffee", {slider_real, slider_imag, plot_s}


