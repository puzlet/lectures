<?php

function head($title) {
ob_start("process");
?><!DOCTYPE html>
<html lang='en'>

<head>
<meta charset='utf-8'>
<title><?=$title;?></title>
<link rel='icon' href='//puzlet.org/puzlet/images/favicon.ico'>
<link rel='stylesheet' href='//puzlet.org/puzlet/css/vendor.css'>
<link rel='stylesheet' href='../css/style.css?v=1'>
<link rel='stylesheet' href='style.css?v=1'>
<!-- Preload KaTeX to improve math rendering speed -->
<script src='//puzlet.org/puzlet/js/katex.js'></script>
<base target="_blank">
</head>

<body>

<div id='outer-container'>
<div id='container'>
<?php
}

function foot() {
?>
</div>  <!--#container-->
</div>  <!--#outer-container-->

<!--script>
$mathRendering = ["katex", "mathjax"];
</script-->
<script src="//puzlet.org/puzlet/js/render-math.js"></script>
<script src='//puzlet.org/puzlet/js/vendor.js'></script>
<script src='//puzlet.org/puzlet.js' data-puzlet data-resources='resources.coffee'></script>
  
</body>

</html>
<?php
ob_flush();
}

function section($title, $id) {
  ?>
  <section id='<?=$id?>'>
    
  <h2><?=$title?></h2>
  <?php
}

function sectionEnd() {
  ?>
  <div class='clear'></div>

  </section>
  <?php
}

function exercises($id) {
  ?>
  <div id='<?=$id?>' class='exercises-wrapper'>
    
    <div class='exercises-button'>Exercises</div>
    
    <div class='exercises hide'>
      
      <div class='exercise-navigation'>
        <div class='previous button'>Prev</div> | <div class='next button'>Next</div>
      </div>
  <?php
}

function exercisesEnd() {
  ?>
    
    </div> <!-- .exercises -->
  
  </div> <!-- .exercises-wrapper-->
  <?php  
}

function exercise($heading, $id, $coffee) {
?>
<div class='exercise' id='<?=$id?>'>
  <h2><?=$heading?></h2>
  <div class='code-buttons'></div>
  <div data-file='exercises/<?=$coffee?>'></div>
  <div data-eval='exercises/<?=$coffee?>' class='hide'></div>
  <div class='exercise-footer'>
<?php
}

function exerciseEnd() {
  ?>
  </div>
</div>
<?php
}

function button($id, $text) {
  ?><span id='<?=$id?>' class='text-button'><?=$text?></span><?php
}

function userCredentials() {
  ?>
  <div id='user-credentials'>
    <input
      class='group-id'
      type='text' 
      placeholder='Group key'
      title='Enter ID for your user group.'>
    </input>
    <br>
    <input
      class='user-id hide'
      type='text' 
      placeholder='Your email address'
      title='Enter your email address (user ID).'>
    </input>
  </div>
  <?php
}

function pageFooter() {
  $updated = date('j F Y');
  ?>
  <div class='page-footer' class='box-1-1'>
  
    <hr>
  
    <p>
      <span class='last-update'>Last updated <?=$updated;?></span>
      <!--TODO: Auto fetch date from github-->
      | <a href='//github.com/puzlet/lectures' title='View source code for this web page.'>Source Code</a>
      | <a href='//github.com/puzlet/lectures/issues' title='Comment on this web page.'>Comments</a>
    </p>
  
    <p>
      Developed by
      <a href="//github.com/mvclark">Martin Clark</a> and
      <a href="//github.com/garyballantyne">Gary Ballantyne</a>
      (Haulashore Limited)
      as part of the <a href='//puzlet.org'>Puzlet</a> project.
    </p>
  
    <p class='credits'>
      Thanks to:
      <a href='//ace.c9.io'>Ace</a>,
      <a href='//coffeescript.org'>CoffeeScript</a>,
      <!--a href='//mathjax.org'>MathJax</a>, -->
      <a href='//khan.github.io/KaTeX/'>KaTeX</a>,
      <a href='//numericjs.com'>numericjs</a>,
      <a href='//d3js.org'>d3</a>,
      <a href='//paperjs.org/reference/paperscript'>PaperScript</a>,
      <a href='//jquery.com'>jQuery</a>,
      <a href='//github.com'>GitHub</a>.
    </p>
  
    <p>
      <a href='//blabr.org'>
      <img src='//puzlet.org/blab/img/blabr-logo.png' height='20'/>Blabr</a> &mdash;
      Create your own interactive computation directly in the browser.
      <a href="//twitter.com/blabrnet"><img src="//puzlet.org/blab/img/TwitterLogo.png" 
        height=24 style="vertical-align: middle"/>Follow us on Twitter</a>.<br>
    </p>
  
  </div>
  <?php
}

function process($buffer) {
  $buffer = paragraphs($buffer);
  $buffer =  str_replace("---", "&mdash;", $buffer);
  return $buffer;
}

function paragraphs($buffer) {
  
  # Trim whitespace
  $lines = explode("\n", $buffer);
  foreach ($lines as $idx => $line) {
    $lines[$idx] = trim($line);
  }
  $text = implode("\n", $lines);
  
  # Text blocks
  $blocks = explode("\n\n", $text);
  
  # Paragraphs
  $pattern = '/^[A-Z]/';
  foreach ($blocks as $idx => $block) {
    preg_match($pattern, $block, $matches);
    if (count($matches)) {
      $blocks[$idx] = "<p>$block</p>";
    }
  }
  
  # Add newlines between blocks.
  $buffer = implode("\n\n", $blocks);
  
  return $buffer;
}

?>