## index.html
* Define page elements here.
* Use box-1-1, box-2-1 etc. for layout.
* Lecture elements: id should begin with "lecture-"

## style.css
* Styling for page elements and interactive components.

## ui.coffee
* Define interactive components here.
* Container ids specified in index.html.
* Component parameters similar to Blabr widgets.
* $blab.computation(...) defines what components are available to compute.coffee.

## compute.coffee
* Similar to compute.coffee in Blabr.
* Available components are defined in ui.coffee.  Similar to Blabr widgets, but no string ids.
* Coffee math (predefined functions, overloaded operators etc.) supported here.

## lecture.coffee
* Define lecture steps here.
* Use page element ids specified in index.html.
* @action can be used for custom actions for interactive components.  To be enhanced.

## tables.json
* Initialization data for interative table widget.

## resources.coffee
* Defines filenames for key resources -- Puzlet libraries and files listed above.
