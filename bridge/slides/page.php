<?php
# php page.php > index.html
# fswatch -o *.php | xargs -n1 ./build
require("../../lib/php/templates.php");
require('../../complex/figures.php');
head('Complex Numbers', 'slides');
?>

<section id='section-title'>
<h1>Complex Numbers</h1>
<h2 class='subtitle'>An Illustrative Example</h2>
</section>


<?php #pageFooter(); ?>

<?php foot(); ?>
