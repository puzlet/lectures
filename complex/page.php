<?php
# php page.php > index.html
# fswatch -o *.php | xargs -n1 ./build
require('templates.php');
head('Complex Numbers');
?>

<?= userCredentials(); ?>

<h1>Complex Numbers</h1>
<h2 class='subtitle'>An Interactive Guide</h2>
<h2 class='subtitle'><a href='./slides'>Go to slides version<a></h2>

<p class='heading highlight'>[This web page is currently under development.]</p>


<?= section('Vectors in a Plane', 'section-complex-plane') ?>

<div class='box-2-1'>
  
  Many applications in science and engineering model phenomena as a 
  two-dimensional (2D) vector in a plane.
  
  We can express a vector $z$ in a couple of ways:
  <table>
  <tr><td>Cartesian<td>$z = (x, y)$
  <tr><td>Polar<td>$z = A \angle \theta$
  </table>
  where
  $$x = A \cos(\theta)$$
  $$y = A \sin(\theta)$$
  
  Another way to express the vector $z$ is as a <i><b>complex number</b></i>:
  $$z = x+iy$$
  
  Here, $i$ represents the vertical-axis in the plane.
  Click the following buttons to see examples of vector $z$ in the plot:
  <?= button('complex-12-plus-09i', ' $1.2+0.9i$'); ?>,
  <?= button('complex-neg1-plus-i', '$-1+i$'); ?>,
  <?= button('complex-neg1-plus-negi', '$-1-i$'); ?>,
  <?= button('complex-negi', '$-i$'); ?>.
  Or set vector $z$ by dragging the green circle or the angle slider.
  Click the Excerises button on the right for more.
  
  So $i$ represents the vertical axis, but does $i$ itself have a value?
  We'll see below that assigning a special (and somewhat weird) value to $i$ 
  enables useful mathematical properties of complex numbers.
  In particular, we'll see that complex number <b><i>multiplication</i></b> 
  is equivalent to vector <b><i>rotation</i></b> in the plane.
  The mathematics of rotating vectors is important in
  electrical circuits, telecommunication signals, mechanical oscillation,
  and many other areas.

</div>

<div id='figure-complex-plane' class='box-2-2'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
  </div>
  <div class='magnitude'></div>
</div>

<div class='box-2-2'>
  
<?= exercises('exercises-complex-plane'); ?>

<?= exercise('Exercise 1.1', 'exercise-complex-plane-1', 'complex-plane-1.coffee'); ?>
  For the complex vector $z$ in the editor above,
  fill in the related values ($x$ and $y$ coordinates, magnitude $A$, and angle $\theta$).
  See the values plotted above ---
  <span style='color:green'>green for $z$</span>,
  <span style='color:red'>red for ($x$, $y$)</span>,
  and <span style='color:blue'>blue for $A \angle \theta$</span>.
<?= exerciseEnd(); ?>

<?= exercise('Exercise 1.2', 'exercise-complex-plane-2', 'complex-plane-2.coffee'); ?>
  Fill in the function to compute the magnitude $A$ given $x$ and $y$.
  See your function's result for a few vectors plotted above. 
  <i>Hint: use square and square root buttons above.</i>
<?= exerciseEnd(); ?>

<?= exercisesEnd(); ?>

</div>

<?= sectionEnd() ?>


<?= section('Addition', 'section-complex-addition') ?>

<div class='box-2-1'>
  
  Before we get into complex number multiplication, or even defining the value of $i$,
  let's look at simple <i>addition</i> of vectors in the plane. 
  
  To add vectors---and thus add complex numbers---just 
  add the $x$ coordinates to get the new $x$-coordinate; and add the $y$ coordinates to get the new $y$-coordinate:
    $$z_1 = x + iy$$
    $$z_2 = a + ib$$
    $$z_1 + z_2 = (x + iy) + (a + ib) = (x+a) + i(y+b)$$
    
  The plot represents a vector sum by stacking two vectors end-to-end:
  $z_1$ starts at the plot's origin; and $z_2$ starts at the end of $z_1$.
  The vector sum $z_1+z_2$ is the resultant vector from the origin of $z_1$ to the end of $z_2$.
  The plot shows $x$ and $y$ values, and magnitude $A$, of the vector sum.
  Try adjusting $z_1$ and $z_2$ by dragging the green circles or angle sliders.

</div>

<div id='figure-complex-addition' class='box-2-2'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
    <div class='slider-2'></div>
  </div>
  <div class='magnitude'></div>
</div>

<div class='box-2-2'>
  
  <?= exercises('exercises-complex-addition'); ?>
  
  <?= exercise('Exercise 2.1', 'exercise-complex-addition-1', 'complex-addition-1.coffee'); ?>
    You have two vectors: $z_1$ lies along the $x$-axis; and $z_2$ lies along the $y$-axis. 
    What vectors $z_1$ and $z_2$ add up to the vector $z$ in the editor above?
  <?= exerciseEnd(); ?>
  
  <?= exercise('Exercise 2.2', 'exercise-complex-addition-2', 'complex-addition-2.coffee'); ?>
    <b>Complex subtraction.</b>
    Find vector $z_2$ so that $z = z_1 + z_2$.
  <?= exerciseEnd(); ?>
  
  <?= exercise('Exercise 2.3', 'exercise-complex-addition-3', 'complex-addition-3.coffee'); ?>
    The editor contains an incomplete function for computing the magnitude of the vector sum $z_1+z_2$.
    Fill in the last line.
    <!--Expression for magnitude of sum: $\sqrt{(x+a)^2 + (y+b)^2}$-->
  <?= exerciseEnd(); ?>
  
  <?= exercisesEnd(); ?>

</div>

<?= sectionEnd() ?>


<?= section('The Imaginary Unit', 'section-complex-unit') ?>

<div class='box-2-1'>
  
  Consider the following four cases for $z$:
  <table id='table-complex-unit'>
  <tr><th>$z$<th>$(x,y)$<th>$\theta$
  <tr><td>$1$<td>$(1,0)$<td>$0$
  <tr><td>$i$<td>$(0,1)$<td>$\frac{\pi}{2}$
  <tr><td>$-1$<td>$(-1,0)$<td>$\pi$
  <tr><td>$-i$<td>$(0,-1)$<td>$-\frac{\pi}{2}$
  </table>
    
  The figure shows <?= button('show-vectors', 'each vector $z$') ?>.
  (Click this green button to see the vectors, or click any white circle in the figure.)
  Each vector lies along an axis and has a unit magnitude $A=1$.
  
  If we <?= button('multiply-by-negative-1', 'multiply a vector $z$ by $-1$') ?>,
  we get a 180° rotation ($\pi$ radians).
  Try with any vector $z$ as the starting point (click white circle in figure).
  Multiplying <i>twice</i> by $-1$ returns to the original vector.
  
  What about a 90° rotation?
  Can it be accomplished by multiplying $z$ by some value?
  Well, consider the starting point <?= button('z1', '$z=1$') ?>.
  If we <?= button('multiply-1-by-i', 'multiply by $i$') ?>,
  we get a 90° rotation to $z=i$ (because $1 \times i = i$).
  
  If we multiply <i>again</i> by $i$, we get $z=i \times i$.
  We know we want the result to be
  <?= button('multiply-i-by-i', '$z=-1$') ?>
  (90° from $z=i$).  And so for this operation to work, we need
  
  $$i \times i = i^2 = -1$$
  
  The solution to this equation is $i=\sqrt{-1}$.
  There's no real number solution!
  (The square of any real number is always positive, or zero.)
  For this reason, $i$
  is called an <i><b>imaginary</b></i> number.
  
</div>

<div id='figure-complex-unit' class='box-2-2'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='equation'></div>
  </div>
</div>

<div class='box-2-2'>
  
  <?= exercises('exercises-complex-unit'); ?>
  
  <?= exercise('Exercise 3.1', 'exercise-complex-unit-1', 'complex-unit-1.coffee'); ?>
    The editor above shows values for $z=i^0$ and $z=i^1$.
    Append three more lines for the results of $i^2$, $i^3$, and $i^4$.
    See the values plotted above.
  <?= exerciseEnd(); ?>
  
  <?= exercise('Exercise 3.2', 'eexercise-complex-unit-2', 'complex-unit-2.coffee'); ?>
    What is the angle (in radians) of $i^n$ as a function of $n$?
    <i>Hint: use × and π buttons above.</i> 
  <?= exerciseEnd(); ?>
  
  <?= exercise('Exercise 3.3', 'exercise-complex-unit-3', 'complex-unit-3.coffee'); ?>
    What happens if you multiply by $-i$?
    Enter five lines in the editor for the results of
    $(-i)^0$, $(-i)^1$, $(-i)^2$, $(-i)^3$, $(-i)^4$.
  <?= exerciseEnd(); ?>
  
  <?= exercise('Exercise 3.4', 'exercise-complex-unit-4', 'complex-unit-4.coffee'); ?>
    If you multiply vector $z$ by $-i$, what is the angle of rotation (in radians)?
    Enter the result above.
  <?= exerciseEnd(); ?>
  
  <?= exercise('Exercise 3.5', 'exercise-complex-unit-5', 'complex-unit-5.coffee'); ?>
    
    In the examples so far, each vector had a unit magnitude $A=1$.
    What happens for other vector magnitudes?
    
    Say we start with vector $z=A$. Then we multiply by $i$.
    The result is $Ai$, as shown in the editor.
    If we multiply by $i$ three more times, what is the result at each step?
    Append the results above.
    
  <?= exerciseEnd(); ?>
  
  <?= exercisesEnd(); ?>
  
  With this definition for $i$ in  mind, we can
  <?= button('multiply-by-i', 'multiply by $i$&nbsp;') ?> 
  to rotate any of our four vectors by 90°.
  We'll see soon how this also works for vectors of <i>any</i> magnitude and angle.
  So, while $i$ doesn't have a real value,
  it does have useful mathematical properties for rotating a vector in a plane.
  
  In general, an imaginary number is $iy$ where $y$ is any real value and $i$ is the 
  <b>imaginary unit</b> $\sqrt{-1}$.
  For example, $2i$ is an imaginary number with magnitude 2.  
  
  What about rotating the vector by -90° (clockwise)?
  Complete the exercises above to explore this and other cases.
    
</div>

<?= sectionEnd() ?>

<hr>

<?= section('', 'section-complex-unit-multiply') ?>

<div class='box-2-1'>
  
  So, we see that multiplying a vector $z$ by the imaginary unit $i$ rotates $z$ by 90°.
  But we demonstrated this for only four vector angles (vectors lying along an axis).
  In general, a complex number has the form
  $$z = x + iy$$
  We refer to $x$ as the <em><strong>real part </strong></em> and
  $y$ as the <em><strong>imaginary part</strong></em>.
  
  Consider the case where the real part is 1 ($x=1$) and the imaginary part is also 1 ($y=1$):
  $$z = 1+i$$
  We can think of this vector as the sum of two component vectors:
  $$z = z_1 + z_2$$
  $$z_1 = 1$$
  $$z_2 = i$$
  The figure shows these two component vectors as blue lines.
  Each component lies along an axis and has a unit magnitude,
  just like the vectors in the previous section.
  
  <p>
  <?= button('multiply-by-i', 'Multiplying $z$ by $i$') ?>
  is equivalent to multiplying each component ($z_1$ and $z_2$) by $i$,
  and summing the results.
  From the previous section, 
  we know that this is equivalent to <b>rotating</b> each component by 90°.
  And so multiplying $z$ by $i$ must also rotate it by 90°.
  </p>

</div>

<div id='figure-complex-unit-multiply' class='box-2-2'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
    <!--div class='equation'>$ $</div-->
  </div>
</div>

<div class='box-2-2'>
  
  What happens for other values of $x$ and $y$?
  Try adjusting the vector $z=x+iy$ in the figure, and then<br>
  <?= button('multiply-by-i', 'multiply by $i$') ?>
  What happens if you
  <?= button('multiply-by-negative-i', 'multiply by $-i$') ?>?
  
  <div class='todo'>
    <h3>Exercises to implement</h3>
    <ul>
      <li>
        Write expression for multiplying $z=x+iy$ by $i$.
        Answer:
        $$i(x+iy) = ix + i^2y = -y + ix$$
      </li>
    </ul>
  </div>
  
</div>

<?= sectionEnd() ?>


<?= section('Scaling', 'section-complex-scaling') ?>

<div class='box-2-1'>

  To scale a complex vector $z = x+iy$,
  multiply the real part $x$ and imaginary part $y$ by the same factor:
  $$az = a(x+iy) = ax + iay$$
  
  When $a$ is a positive number, scaling operates in the direction of the vector.
  
  When $a$ is a <i>negative</i> number, the vector is rotated 180° ($\pi$ radians).
  
  [To implement: buttons in text to set original vector to $1+i$, 
  and scale factor to $-1$, $2$, $-i$, $2i$, $0.5i$, etc.]
  
  What about multiplying a complex number by $ib$?
  This is the same as scaling by $b$ (as above), and then rotating by 90°
  (as in previous section).
  
</div>

<div id='figure-complex-scaling' class='box-2-2'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
  </div>
  <div class='slider-scale-factor'></div>
  <div class='magnitude'></div>
</div>

<?= sectionEnd() ?>


<?= section('Multiplication', 'section-complex-multiplication') ?>

<div class='box-2-1'>
  
  So, we know how to multiply a complex number $z=x+iy$ by $a$ or by $ib$.
  What about multiplying a complex number $z=x+iy$ by another complex number $z_2 = a+ib$?
  This is equivalent to
  $$ z z_2 = z(a+ib) = az + ibz$$
  That is, add two vectors:
  <ul>
    <li>the first vector is $z$ scaled by $a$.
    <li>the second vector is $z$ scaled by $b$ and rotated by 90°.
  </ul>
  You can think of these two vectors as forming a right-angle triangle
  stacked on top of vector $z$ (see figure).
  If $z$ has a unit magnitude ($A=1$):
  <ul>
  <li>the base of the triangle has length $a$ [color?].
  <li>the height of the triangle is $b$.
  <li>the angle of the triangle is the angle of the complex number $a+ib$.
  <li>the angle of the result is the sum of the angle of $z$ and the angle of $z_2$.
  </ul>
  In other words, <b>multiplying complex numbers adds their angles</b>.

</div>

<div id='figure-complex-multiplication' class='box-2-2'>
  
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
  </div>
  
  <div class='todo'>
    <h3>Exercises to implement</h3>
    
    What if the magnitude of $z$ is not 1?  Can we still add the angles?
    What is the magnitude of the result?<br>
    Answer:
    <ul>
      <li>$z$ has magnitude $A=\sqrt{x^2 + y^2}$ and angle $\theta$.
      <li>$z_2$ has magnitude $A_2=\sqrt{a^2 + b^2}$ and angle $\phi$.
      <li>the triangle has base length $aA$ and height $bA$.
      <li>this triangle is similar for any value of $A$, and so it has angle $\phi$.
      <li>the resulting vector $zz_2$ has angle $\theta + \phi$.
      <li>$zz_2$ has a magnitude equal to the hypotenuse of the triangle: $\sqrt{(aA)^2 + (bA)^2} = AA_2$.
    </ul>

  </div>
</div>

<?= sectionEnd() ?>


<?= section('Power', 'section-complex-power') ?>

<div class='box-2-1'>

  Let's summarize multiplication of complex numbers.  Say we have two complex numbers:
  <ul>
    <li>$z_1 = x_1+iy_1 = A_1(\cos(\theta_1) + i\sin(\theta_1))$
    <li>$z_2 = x_2+iy_2 = A_2(\cos(\theta_2) + i\sin(\theta_2))$
  </ul>
  Their product is
  $$z_1 z_2 = A_1 A_2 (\cos(\theta_1 + \theta_2) + i\sin(\theta_1 + \theta_2))$$
  
  Exercise: Prove this using trig identities.
  
  Consider now a complex number $z$ with a unit magnitude $A=1$ and angle $\phi$.
  The <i>square</i> of $z$ is
  $$ z^2 = (\cos(\phi) + i\sin(\phi))^2 = \cos(2\phi) + i\sin(2\phi) $$
  The angle of $z^2$ is thus $\theta = 2\phi$.
  
</div>

<div class='box-2-2'>
  
  Further, the <i>$n$th power</i> of $z$ is
  $$ z^n = (\cos(\phi) + i\sin(\phi))^n = \cos(n\phi) + i\sin(n\phi) $$
  The angle of $z^n$ is thus $\theta = n\phi$.
  
  See red triangles in figure below for specified $\theta$ and $n$ (and $\phi = \theta/n$).
  The starting vector is $z^0=1$.  The first triangle is $z^1=z$.
  The second triangle is for $z^2$, and so on.
  
</div>

<div class='clear'></div>

<div id='figure-euler-formula' class='box-1-1'>
  <div class='figure-outer figure-outer-large loading'>
    <div class='figure-surface'></div>
    <div id='math' class='angle-text'></div>
  </div>
  <div id='slider-theta'></div>
  <div id='slider-n'></div>
</div>

<?= sectionEnd() ?>


<?= section("Euler's Formula", 'section-complex-euler') ?>

<div class='box-2-1'>
    
  From the section above, we can write the relationship
  $$ (\cos(\theta/n) + i\sin(\theta/n))^n = \cos(\theta) + i\sin(\theta)$$
  
  For some value of $\theta$, what happens when $n$ becomes large 
  and thus $\phi=\theta/n$ becomes small?
  For small $\phi$, we have:
  <ul>
    <li>$\cos(\phi) \rightarrow 1$
    <li>$\sin(\phi) \rightarrow \phi$ (for angle in radians)
  </ul>
  And so
  $$ \lim_{n \to \infty} \left( 1 + \frac{i\theta}{n} \right)^n = \cos(\theta) + i\sin(\theta) $$
  
  The blue triangles in the figure above show the left hand side of the equation for specified $\theta$ and $n$.
  As $n$ becomes large, the trajectory of the blue triangles approximates that of the red triangles.

</div>

<div class='box-2-2'>
  
  Note that the definition of the <i>exponential function</i> is
  $$ e^x = \lim_{n \to \infty} \left(1 + \frac{x}{n} \right)^n $$
  And so it follows that (while not a rigorous proof)
  $$ e^{i\theta} = \cos(\theta) + i\sin(\theta)$$
  This is <a href='https://en.wikipedia.org/wiki/Euler%27s_formula'><i>Euler's formula</i></a>, 
  and has been referred to as "the most remarkable formula in mathematics."
  
  [Intuitive explanation of exponential function of imaginary number.
  What does it mean to "grow" in orthogonal direction, rather than same/real direction in usual exponential form?]
  
  Based on Euler's formula, a complex number can be represented as
  $$ z = A e^{i\theta} $$
  The product of two complex numbers $z_1 = A_1 e^{i\theta_1}$  and $z_2 = A_2 e^{i\theta_2}$ is
  $$ z_1 z_2 = A_1 A_2 e^{i\theta_1}e^{i\theta_2} = A_1 A_2 e^{i(\theta_1 + \theta_2)}$$
  That is, Euler's formula is consistent with the notion of adding angles for the product of complex numbers.
    
</div>

<?= sectionEnd() ?>


<?= section("Other Stuff", 'section-complex-other-stuff') ?>

<ul>
  <li>Conjugate.
  <li>Division.
  <li>Quadratic/polynomial solutions.
  <li>Using Euler's form in applications.
</ul>

<h2>References and Further Reading</h2>

<ol>
  <li><a href='//betterexplained.com/articles/a-visual-intuitive-guide-to-imaginary-numbers'>A
    Visual, Intuitive Guide to Imaginary Numbers</a> --- Kalid Azad
  <li><a href='//betterexplained.com/articles/understanding-why-complex-multiplication-works/'>Understanding 
    Why Complex Multiplication Works</a> --- Kalid Azad
  <li><a href='//slesinsky.org/brian/misc/eulers_identity.html'>How To 
    explain Euler's identity using triangles and spirals</a> --- Brian Slesinsky
</ol>

<?php pageFooter(); ?>

<?php foot(); ?>
