<?php

function figureComplexPlane($class) {
?>
<div id='figure-complex-plane' class='<?=$class?>'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
  </div>
  <div class='magnitude'></div>
</div>
<?php
}

function figureComplexAddition($class) {
?>
<div id='figure-complex-addition' class='<?=$class?>'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
    <div class='slider-2'></div>
  </div>
  <div class='magnitude'></div>
</div>
<?php
}

function figureComplexUnit($class) {
?>
<div id='figure-complex-unit' class='<?=$class?>'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='equation'></div>
  </div>
</div>
<?php
}

function figureComplexUnitMultiply($class) {
?>
<div id='figure-complex-unit-multiply' class='<?=$class?>'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
    <!--div class='equation'>$ $</div-->
  </div>
</div>
<?php
}

function figureComplexScaling($class) {
?>
<div id='figure-complex-scaling' class='<?=$class?>'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
  </div>
  <div class='slider-scale-factor'></div>
  <div class='magnitude'></div>
</div>
<?php
}

function figureComplexMultiplication($class) {
?>
<div id='figure-complex-multiplication' class='<?=$class?>'>
  <div class='figure-outer loading'>
    <div class='figure-surface'></div>
    <div class='slider'></div>
  </div>
</div>
<?php
}

function figureComplexEuler($class) {
?>
<div id='figure-euler-formula' class='<?=$class?>'>
  <div class='figure-outer figure-outer-large loading'>
    <div class='figure-surface'></div>
    <div id='math' class='angle-text'></div>
  </div>
  <div id='slider-theta'></div>
  <div id='slider-n'></div>
</div>
<?php
}