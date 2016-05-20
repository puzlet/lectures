

t = linspace 0, 20, 1000

# sigma = Re(s)
sigma = slider_a()
plot_a t, exp(sigma*t)

# omega = Im(s)
wt = slider_t()+0.01
s1 = exp(j*wt)
plot_w [s1.x], [s1.y]

# e^{st}
a = slider_real()
b = slider_imag()
s = a + j*b
s2 = exp(s*t)
plot_s  s2.x, s2.y

# y
zeta = slider_z()
sigma = -zeta
omega = sqrt(1-zeta**2)
plot_z t, exp(sigma*t)*cos(omega*t)
console.log "??", zeta, sigma, omega
table_z [sigma], [omega]
