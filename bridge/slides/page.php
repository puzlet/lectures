<?php
# php page.php > index.html
# fswatch -o *.php | xargs -n1 ./build
require("../../lib/php/templates.php");
head('Complex Numbers', 'slides');
?>

<section id='section-title'>
<h1>Complex Numbers</h1>
<h2 class='subtitle'>An Illustrative Example</h2>
</section>

<?= section('Introduction', 'section-introduction') ?>


<div class='box-2-1'>
    
    <div id='lecture-intro'>
	Complex numbers often appear in engineering; the suspension of
	a car, the electronics in a phone, skyscrapers and bridges all
	use complex numbers in their design. However, the most
	important (and interesting) examples are advanced&mdash;so,
	when you <i>start</i>
	learning about complex numbers it can appear that they have
	little practical use.
    </div>

</div>

<div class='box-2-2'>

    <iframe width="420" height="315" src="https://www.youtube.com/embed/XggxeuFDaDU" frameborder="0" allowfullscreen></iframe>

</div>

<?= sectionEnd(); ?>


<?php #pageFooter(); ?>

<?php foot(); ?>
