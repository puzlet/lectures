k = slider()
offset = 0 #menu()
#showText "lecture-offset-text", offset

x = linspace 0, 10, 100 #;
y = k*x*x + offset #;
plot x, y

z = table [], [-> z*z]
