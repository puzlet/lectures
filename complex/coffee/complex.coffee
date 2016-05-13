# Complex Number Computation

#!math-sugar

class Complex
  
  @toPolar: (z) ->
    magnitude = abs(z)
    angle = z.arg()
    {magnitude, angle}
  
  @polarToComplex: (magnitude, angle) ->
    z = complex(magnitude*cos(angle), magnitude*sin(angle))
    
  @clipMagnitude: (z, maxA) ->
    a = abs(z)
    return z if a<maxA
    (maxA/a)*z
    
  @snap: (z, n) -> complex(round(z.x, n), round(z.y, n))
    
  @add: (z1, z2) -> z1 + z2
  
  @diff: (z1, z2) ->
    d = z1 - z2
    d.y ?= 0 # TODO: Fix in math module
    d
    
  @isEqual: (z1, z2) ->
    abs(@diff(z1, z2)) < 1e-6
  
  @magnitudeSum: (z1, z2) -> abs(z1 + z2)
  
  @scale: (z, a) -> a * z
  
  @mul: (z1, z2) -> z1 * z2
  
  @div: (z1, z2) -> z1/z2
  
  @rotate: (z, theta) -> z*exp(j*theta)


class EulerComputation
  
  @angleStep: (theta, N) ->
    cos(theta/N) + j*sin(theta/N)
  
  @orthoStep: (theta, N) ->
    1 + j*theta/N
  
  @step: (z1, z2) ->
    # Diff vector
    z = z1*z2
    az1 = z2.x*z1
    {z1, z2, z, az1}


# Unused
complexPolar = (r, theta) -> r*exp(j*theta)

#!no-math-sugar

round = (x, n) ->
  f = Math.pow(10, n)
  Math.round(x * f)/f

$blab.Complex = Complex
$blab.EulerComputation = EulerComputation

