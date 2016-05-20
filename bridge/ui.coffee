#!no-math-sugar

{Slider, Menu, Table, Plot} =  $blab.components

slider_t = new Slider
  container: $("#lecture-slider-t")
  prompt: "$\\theta = \\omega t$"
  unit: null
  init: 0
  min: 0
  max: 10
  step: 0.5

slider_a = new Slider
  container: $("#lecture-slider-a")
  prompt: "$\\sigma$"
  unit: null
  init: 0
  min: -0.5
  max: 0.5
  step: 0.1

slider_real = new Slider
  container: $("#lecture-slider-real")
  prompt: "$\\sigma$"
  unit: null
  init: -0.1
  min: -0.5
  max: 0.5
  step: 0.02

slider_imag = new Slider
  container: $("#lecture-slider-imag")
  prompt: "$\\omega$"
  unit: null
  init: 5
  min: 1
  max: 10
  step: 1

slider_z = new Slider
  container: $("#lecture-slider-z")
  prompt: "$\\zeta$"
  unit: null
  init: 0
  min: -1
  max: 1
  step: 0.05

plot_w = new Plot
  container: $("#lecture-plot-w")
  title: null
  width: 300, height: 300
  xlabel: "$\\Re$"
  ylabel: "$\\Im$"
  xaxis: {min: -2, max: 2}
  yaxis: {min: -2, max: 2}
  series: {lines: lineWidth: 2}
  points: {show: true}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}


plot_a = new Plot
  container: $("#lecture-plot-a")
  title: null
  width: 300, height: 300
  xlabel: "$t$"
  ylabel: "$exp(\\sigma t)$"
  xaxis: {min: 0, max: 10}
  yaxis: {min: 0, max: 10}
  series: {lines: lineWidth: 2}
  points: {show: false}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}

plot_s = new Plot
  container: $("#lecture-plot-s")
  title: "complex exponential: $e^{st}$"
  width: 300, height: 300
  xlabel: "$\Re{s} = e^{\\sigma t}\cos \\omega t$"
  ylabel: "$\Im{s} = e^{\\sigma t}\sin \\omega t$"
  xaxis: {min: -2, max: 2}
  yaxis: {min: -2, max: 2}
  series: {lines: lineWidth: 2}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}

plot_z = new Plot
  container: $("#lecture-plot-z")
  title: "$y(t)$"
  width: 300, height: 300
  xlabel: "$t$"
  ylabel: "$y$"
  xaxis: {min: 0, max: 20}
  yaxis: {min: -3, max: 3}
  series: {lines: lineWidth: 2}
  colors: ["red", "blue"]
  grid: {backgroundColor: "white"}

table_z = new Table
  container: $("#lecture-table-z")
  id: "z"
  title: null
  headings: ['$\\sigma$', '$\\omega$']
  widths: 200
 
$blab.computation "compute.coffee", {slider_z, slider_real, slider_imag, slider_t, slider_a, plot_z, plot_s, plot_w, plot_a, table_z}


