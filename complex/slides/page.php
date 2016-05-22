<?php
# php page.php > index.html
# fswatch -o *.php | xargs -n1 ./build
require('../templates.php');
require('../figures.php');
head('Complex Numbers', 'slides');
?>

<section id='section-title'>
<h1>Complex Numbers</h1>
<h2 class='subtitle'>An Interactive Guide</h2>
</section>

<?= section('Vectors in a Plane', 'section-complex-plane') ?>

<div class='box-2-1'>
  
  <p>
  <table>
    <tr><td>Cartesian<td>$z = (x, y)$
    <tr><td>Polar<td>$z = A \angle \theta$
    <tr><td>Complex<td>$z = x+iy$
  </table>
  </p>
  
  <div class='text-block'>
    
    Examples:
    <ul class='buttons'>
      <li><span id='complex-12-plus-09i' class='text-button'> $1.2+0.9i$ </span>
      <li><span id='complex-neg1-plus-i' class='text-button'>$-1+i$</span>
      <li><span id='complex-neg1-plus-negi' class='text-button'>$-1-i$</span>
      <li><span id='complex-negi' class='text-button'>$-i$</span>
    </ul>
    
  </div>
  
</div>

<?= figureComplexPlane('box-2-2') ?>

<?= sectionEnd(); ?>


<?= section('Addition', 'section-complex-addition') ?>

<div class='box-2-1'>
  
  $$z_1 = x + iy$$
  $$z_2 = a + ib$$
  
  <br>
  
  $$
  \begin{aligned}
  z_1 + z_2 & = (x + iy) + (a + ib) \\[2ex] & = (x+a) + i(y+b)
  \end{aligned}
  $$
  
</div>

<?= figureComplexAddition('box-2-2') ?>

<?= sectionEnd(); ?>


<?= section('The Imaginary Unit', 'section-complex-unit') ?>

<div class='box-2-1'>
  
  <p>
    <table id='table-complex-unit'>
      <tr><th>$z$<th>$(x,y)$<th>$\theta$
      <tr><td>$1$<td>$(1,0)$<td>$0$
      <tr><td>$i$<td>$(0,1)$<td>$\frac{\pi}{2}$
      <tr><td>$-1$<td>$(-1,0)$<td>$\pi$
      <tr><td>$-i$<td>$(0,-1)$<td>$-\frac{\pi}{2}$
    </table>
  </p>
  
  <div class='text-block'>
  
    <span id="show-vectors" class='text-button'>Cycle through vectors</span>
  
    <h3>180° rotation</h3>
  
    <ul class='buttons'>
      <li><span id='multiply-by-negative-1' class='text-button'>Multiply $z$ by $-1$</span>
    </ul>
  
    <h3>90° rotation</h3>

    <ul class='buttons'>
      <li><span id='z1' class='text-button'>$z=1$</span>
      <li><span id='multiply-1-by-i' class='text-button'>Multiply by $z=1$ by $i$ </span>
      <li><span id='multiply-i-by-i' class='text-button'>Multiply $z=i$ by $i$</span> 
      <li><span id='multiply-by-i' class='text-button'>Multiply by $i$</span> 
      <li><span id='multiply-by-negative-i' class='text-button'>Multiply by $-i$</span> 
    </ul>
  
  </div>
  
</div>

<?= figureComplexUnit('box-2-2') ?>

<?= sectionEnd(); ?>


<?= section('The Imaginary Unit', 'section-complex-unit-multiply') ?>

<div class='box-2-1'>
  
  $$z = 1+i$$
  $$z = z_1 + z_2$$
  $$z_1 = 1$$
  $$z_2 = i$$
    
  <div class='text-block'>
    <ul class='buttons'>
      <li><span id='multiply-by-i' class='text-button'>Multiply by $i$</span>
      <li><span id='multiply-by-negative-i' class='text-button'>Multiply by $-i$ </span>
    </ul>
  </div>
  
</div>

<?= figureComplexUnitMultiply('box-2-2') ?>

<?= sectionEnd(); ?>


<?= section('Scaling', 'section-complex-scaling') ?>

<div class='box-2-1'>
  
  $$az = a(x+iy) = ax + iay$$
  
  <div class='text-block'>
  <ul>
    <li>$a>0$: scaling in direction of vector
    <li>$a < 0$: vector rotated 180°</sup>
  </ul>
  
</div>

</div>

<?= figureComplexScaling('box-2-2') ?>

<?= sectionEnd(); ?>


<?= section('Multiplication', 'section-complex-multiplication') ?>

<div class='box-2-1'>
  
  $$z=x+iy$$
  $$z_2 = a+ib$$
  $$ z z_2 = z(a+ib) = az + ibz$$
  
  Add two vectors:
  <ol>
    <li>$z$ scaled by $a$
    <li>$z$ scaled by $b$, rotated by 90°</sup>
  </ol>
  Assume $|z|=1$.
  Vectors form right-angle triangle
  stacked on top of vector $z$.
  <ul>
  <li>base = $a$
  <li>height = $b$
  <li>angle = angle of $a+ib$
  </ul>
  Angle of result = angle of $z$ + angle of $z_2$
  
  <p>
    <b>Multiply complex numbers:<br>add their angles</b>
  </p>

</div>

<?= figureComplexMultiplication('box-2-2') ?>

<?= sectionEnd(); ?>


<?= section("Power and Euler's Formula", 'section-complex-power') ?>

<div class='box-2-1'>
  
  <span style='color:red'>Red</span> triangles:
  $$\begin{aligned} z^n 
    & =(\cos(\theta/n) + i\sin(\theta/n))^n\\ 
    & = \cos(\theta) + i\sin(\theta) \end{aligned} $$
  <ul>
    <li>Starting vector: $z^0=1$
    <li>First triangle: $z^1=z$
    <li>Second triangle: $z^2$
  </ul>
  For large $n$:
  $$ \left(\cos(\theta/n) + i\sin(\theta/n)\right)^n \approx \left( 1 + \frac{i\theta}{n} \right)^n $$
  
  <span style='color:blue'>Blue</span> triangles:
  $$ \left( 1 + \frac{i\theta}{n} \right)^n $$
  <ul>
    <li>Starting vector: $z^0=1$
    <li>First triangle: $1+i\theta/n$
    <li>Second triangle: $(1+i\theta/n)^2$
  </ul>
  $$ e^{i\theta} = \lim_{n \to \infty} \left( 1 + \frac{i\theta}{n} \right)^n = \cos(\theta) + i\sin(\theta) $$

</div>

<?= figureComplexEuler('box-2-2') ?>

<?= sectionEnd(); ?>


<?php #pageFooter(); ?>

<?php foot(); ?>
