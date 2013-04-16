#Todo

1. Line  numbering alignment has issues when scrolling to the end of long documents. The vlidholt repo seemed to offer an improvement (see SMLGUtterTextView) but I am not sure if it addresses the real root of the problem.

1. Syntax definitions conflate language keywords and function, class method names. Adding additional recolouring is not difficult but the syntax definitions would have to be carefully filtered for all languages.

1. Scrolling causes a lot of recolouring. Something seems amiss here.

1. Number colouring is not quite robust enough. In particular variables such as temp_1 have the _1 coloured as a number.

1. Unit tests. Define strings. Colour them and validate the coring.

1. Define source files in the bundle for each supported language type. These can be loaded in the example app to validate colouring. An NSStepper might be useful too.

1. Delegate colouring seems useful. Perhaps it can be extended.

1. Would SMLTextView subclassing be beneficial? The client could pass in the required subclass name in the docspec.

9. Pull in syntax colouring changes from https://github.com/faceleg/Fragaria. This adds additional regex based colouring and support for Markdown.