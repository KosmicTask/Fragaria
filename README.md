#What is it?
Fragaria is an OS X Cocoa syntax colouring NSTextView implemented within a framework named MGSFragaria. It supports a wide range of programming languages and includes preference panel support.

The MGSFragaria framework now properly supports both traditional reference counting memory management and garbage collection.

#Where can I see it in use

You can see Fragaria used in the following products:

* [KosmicTask](http://www.mugginsoft.com) : a multi (20+) language  scripting environment for OS X that features script editing, network sharing, remote execution, and file processing.

If you use MGSFragaria in your app and want it added to the list raise it as an issue.

#Features

Most features are accessed via the framework preferences.

* Configurable syntax colouring
* Configurable font type, size and colour.
* Invisible character display
* Line numbering
* Brace matching and auto insertion
* Page guide
* Simple word auto complete
* Tab and indent control
* Line wrapping


##How do I use it?

The best way to learn how to use the framework is to look at the sample apps.

* __Fragaria__ : a simple editor window that features language selection, a wired up text menu and a preferences panel.

* __Fragaria GC__ : a GC version of the above.

* __Fragaria Doc__ : a simple NSDocument based editor.

##Show me code

A Fragaria view is embedded in a content view.


```objective-c
#import "MGSFragaria/MGSFragaria.h"

// we need a container view to host Fragaria in
NSView *containerView = nil; // loaded from nib or otherwise created

// create our instance
MGSFragaria *fragaria = [[MGSFragaria alloc] init];

// we want to be the delegate
[fragaria setObject:self forKey:MGSFODelegate];

// Objective-C is the place to be
[self setSyntaxDefinition:@"Objective-C"];

// embed in our container - exception thrown if containerView is nil
[fragaria embedInView:containerView];

// set initial text
[fragaria setString:@"// We don't need the future."];
```


The initial appearance of a Fragaria view is determined by the framework preferences controller. The MGSFragaria framework supplies two preference view controllers whose views can be embedded in your preference panel.


```objective-c
MGSFragariaTextEditingPrefsViewController * textEditingPrefsViewController = [MGSFragariaPreferences sharedInstance].textEditingPrefsViewController;

MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController = [MGSFragariaPreferences sharedInstance].fontsAndColoursPrefsViewController;
```


##Setting preferences

Preference strings are defined in MGSFragaria/MGSFragariaPreferences.h. Each preference name is prefixed with Fragaria for easy identification within the application preferences file.

```objective-c
// default to line wrap off
[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsLineWrapNewDocuments];
```


All preferences are observed and instances of Fragaria views update immediately to reflect the new preference.


##Breakpoint Highlighting

Use the `MGSFOBreakpointDelegate` key to define a breakpoint delegate that responds to conforms to `MGSBreakpointDelegate`

```objective-c
[fragaria setObject:self forKey:MGSFODelegate];
```

The breakpoint delegate returns an `NSSet` of breakpoint line numbers.

## Syntax Error Highlighting

To add clickable syntax error highlights define an `NSArray` of SMLSyntaxErrors.

```objective-c
// define a syntax error
SMLSyntaxError *syntaxError = [[SMLSyntaxError new] autorelease];
syntaxError.description = @"Syntax errors can be defined";
syntaxError.line = 1;
syntaxError.character = 1;
syntaxError.length = 10;
    
fragaria.syntaxErrors = @[syntaxError];
```

##Supported languages
Fragaria supports syntax colouring for a wide range of programming languages and configuration file formats:

###A
actionscript, 
actionscript3, 
active4d, 
ada, 
ampl, 
apache (config), 
applescript, 
asm-mips, 
asm-x86, 
asp-js, 
asp-vb, 
aspdotnet-cs, 
aspdotnet-vb, 
awk

###B
batch (shell)

###C
C, 
cobol, 
coffeescript, 
coldfusion, 
cpp, 
csharp, 
csound, 
css

###D
D, 
dylan

###E
eiffel, erl, eztpl

###F
F-script,
fortran,
freefem

###G
gedcom,
gnuassembler,
graphviz

###H
haskell,
header,
html

###I
idl

###J
java,
javafx,
javascript,
jsp

###L
latex,
lilypond,
lisp,
logtalk,
lsl,
lua

###M
matlab,
mel,
metapost,
metaslang,
mysql,
nemerle,

###N
nrnhoc


###O
objectivec,
objectivecaml,
ox

###P
pascal,
pdf,
perl,
php,
plist,
postscript,
prolog,
python

###R
r,
rhtml,
ruby

###S
scala,
sgml,
shell,
sml,
sql,
stata,
supercollider

###T
tcltk,
torquescript

###U
udo

###V
vb,
verilog,
vhdl

###X
xml

##Defining a new language syntax

To define a new syntax definition:

1. Generate a plist that defines the language syntax. The plist structure is simple and browsing the [existing definitions](Syntax%20Definitions) should provide plenty of enlightenment.
2. Insert a reference to the new plist into [SyntaxDefinitions.plist](SyntaxDefinitions.plist)

##Where did it come from?
Fragaria started out as the vital pulp of Smultron, now called Fraise. If you want to add additional features to Fragaria then looking at the [Fraise](https://github.com/jfmoy/Fraise) and other forked sources is a good place to start. Fraise is a GC only app so you will need to consider memory management issues when importing code into Fragaria.



 
