

a = slider_real()
b = slider_imag()
s = a + j*b

t = linspace 0, 10, 1000
z = exp(s*t)

console.log "imag", z.y

plot_s  z.x, z.y
