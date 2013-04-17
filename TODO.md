#Todo

1. Line  numbering alignment has issues when scrolling to the end of long documents. The vlidholt repo seemed to offer an improvement (see SMLGUtterTextView) but I am not sure if it addresses the real root of the problem.

1. Syntax definitions conflate language keywords and function, class method names. Adding additional recolouring is not difficult but the syntax definitions would have to be carefully filtered for all languages.

1. Autocomplete keyword colouring. Autocomplete keywords can be specified and coloured separately to keywords. To me it seems that keywords should be defined by the language syntax. Autocomplete items should contain a list of available functions, names, constants and methods. At present, for most definitions, these items have been incorporated into the keyword list. Perhaps the name of this group is what has confused people in the past (it has certainly confused me). Another name? Perhaps ?. In my option true keywords should not autocomplete.

1. Scrolling causes a lot of recolouring. Something seems amiss here. Surely we should be able to cache our coloured range and only recolour when required. This seems like a fairly fundamental requirement.

1. Unit tests. Define strings. Colour them and validate the colouring.

1. Define source files in the bundle for each supported language type. These can be loaded in the example app to validate colouring. An NSStepper might be useful too.

1. Delegate colouring protocol seems useful. Perhaps it can be extended.

1. Would SMLTextView subclassing be beneficial? The client could pass in the required subclass name in the document spec.

1. Pull in syntax colouring changes from https://github.com/faceleg/Fragaria. This adds additional regex based colouring and support for Markdown.

1. Syntax definitions are currently loaded from the framework bundle. It would be useful if the client app could supply an externally defined syntax definition dictionary to provide custom language support.
