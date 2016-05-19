

a = slider_real()
b = slider_imag()
s = a + j*b

t = linspace 0, 10, 1000
z = exp(s*t)


tt = slider_t()+0.01
zz = exp(j*tt)

aa= slider_a()

plot_a t, exp(aa*t)

plot_w [zz.x], [zz.y]

plot_s  z.x, z.y
