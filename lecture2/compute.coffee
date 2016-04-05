k = slider()
offset = menu()

textOffset offset

x = linspace 0, 10, 100 #;
y = k*x*x + offset #;
plot x, y

z = table [], [-> z*z]
