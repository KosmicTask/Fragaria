//
//  MGSFragaria.m
//  Fragaria
//
//  Created by Jonathan on 05/05/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//
#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"
#import "FRAFontTransformer.h"

// valid keys for 
// - (void)setObject:(id)object forKey:(id)key;
// - (id)objectForKey:(id)key;

// BOOL
NSString * const MGSFOIsSyntaxColoured = @"isSyntaxColoured";
NSString * const MGSFOShowLineNumberGutter = @"showLineNumberGutter";
NSString * const MGSFOIsEdited = @"isEdited";

// string
NSString * const MGSFOSyntaxDefinitionName = @"syntaxDefinition";
NSString * const MGSFODocumentName = @"name";

// integer
NSString * const MGSFOGutterWidth = @"gutterWidth";

// NSView *
NSString * const ro_MGSFOTextView = @"firstTextView"; // readonly
NSString * const ro_MGSFOScrollView = @"firstTextScrollView"; // readonly
NSString * const ro_MGSFOGutterScrollView = @"firstGutterScrollView"; // readonly

// NSObject
NSString * const MGSFODelegate = @"delegate";
NSString * const ro_MGSFOLineNumbers = @"lineNumbers"; // readonly
NSString * const ro_MGSFOSyntaxColouring = @"syntaxColouring"; // readonly

static NSSet *objectGetterKeys;
static NSSet *objectSetterKeys;
static MGSFragaria *_currentInstance;

// KVO context constants
char kcGutterWidthPrefChanged;
char kcSyntaxColourPrefChanged;
char kcSpellCheckPrefChanged;
char kcLineNumberPrefChanged;
char kcLineWrapPrefChanged;

// class extension
@interface MGSFragaria()
@property (nonatomic, readwrite, assign) MGSExtraInterfaceController *extraInterfaceController;

- (void)updateGutterView;

@end

@implementation MGSFragaria

@synthesize extraInterfaceController;

#pragma mark -
#pragma mark Class methods

/*
 
 + currentInstance;
 
 */
+ (id)currentInstance
{
	/*
	 
	 We need to have access to the current instance.
	 This is used by the various singleton controllers to provide a target for their actions.
	 
	 The instance in the key window will automatically be assigned as the current instance.
	 
	 */
	return _currentInstance;
}

/*
 
 + currentInstance;
 
 */
+ (void)setCurrentInstance:(MGSFragaria *)anInstance
{
	NSAssert([anInstance isKindOfClass:[self class]], @"bad class");
	_currentInstance = anInstance;
}


/*
 
 + initialize
 
 */
+ (void)initialize
{
	[MGSFragariaPreferences initializeValues];
	
	objectSetterKeys = [[NSSet setWithObjects:MGSFOIsSyntaxColoured, MGSFOShowLineNumberGutter, MGSFOIsEdited,
						MGSFOSyntaxDefinitionName, MGSFODelegate,
						nil] retain];
	
	objectGetterKeys = [[NSMutableSet setWithObjects:ro_MGSFOTextView, ro_MGSFOScrollView, ro_MGSFOGutterScrollView,
						ro_MGSFOLineNumbers, ro_MGSFOLineNumbers, 
						nil] retain];
	[(NSMutableSet *)objectGetterKeys unionSet:objectSetterKeys];
}

/*
 
 + initializeFramework
 
 */
+ (void)initializeFramework
{
	// + initialize does the work
}

/*
 
 + createDocSpec
 
 */
+ (id)createDocSpec
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // initialise document spec from user defaults
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[defaults objectForKey:MGSFragariaPrefsSyntaxColourNewDocuments], MGSFOIsSyntaxColoured,
            [defaults objectForKey:MGSFragariaPrefsShowLineNumberGutter], MGSFOShowLineNumberGutter,
            [defaults objectForKey:MGSFragariaPrefsGutterWidth], MGSFOGutterWidth,
			@"Standard", MGSFOSyntaxDefinitionName,
			nil];
}

/*
 
 + docSpec:setString:
 
 */
+ (void)docSpec:(id)docSpec setString:(NSString *)string
{
	// set text view string
	[[docSpec valueForKey:ro_MGSFOTextView] setString:string];
}

/*
 
 + docSpec:setString:options:
 
 */
+ (void)docSpec:(id)docSpec setString:(NSString *)string options:(NSDictionary *)options
{
	// set text view string
	[(SMLTextView *)[docSpec valueForKey:ro_MGSFOTextView] setString:string options:options];
}

/*
 
 + docSpec:setAttributedString
 
 */
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string 
{
	// set text view string
	[(SMLTextView *)[docSpec valueForKey:ro_MGSFOTextView] setAttributedString:string];
}

/*
 
 + docSpec:setAttributedString:options:
 
 */
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string options:(NSDictionary *)options
{
	// set text view string
	[(SMLTextView *)[docSpec valueForKey:ro_MGSFOTextView] setAttributedString:string options:options];
}

/*
 
 + stringForDocSpec:
 
 */
+ (NSString *)stringForDocSpec:(id)docSpec
{
	return [[docSpec valueForKey:ro_MGSFOTextView] string];
}

/*
 
 + attributedStringForDocSpec:
 
 */
+ (NSAttributedString *)attributedStringForDocSpec:(id)docSpec
{
	return [[[docSpec valueForKey:ro_MGSFOTextView] layoutManager] attributedString];
}

/*
 
 + attributedStringWithTemporaryAttributesAppliedForDocSpec:
 
 */
+ (NSAttributedString *)attributedStringWithTemporaryAttributesAppliedForDocSpec:(id)docSpec
{
	// recolour the entire textview content
	SMLTextView *textView = [docSpec valueForKey:ro_MGSFOTextView];
	SMLSyntaxColouring *syntaxColouring = [docSpec valueForKey:ro_MGSFOSyntaxColouring];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"colourAll", nil];
	[syntaxColouring pageRecolourTextView:textView options: options];
	
	// get content with layout manager temporary attributes persisted
	SMLLayoutManager *layoutManager = (SMLLayoutManager *)[textView layoutManager];
	return [layoutManager attributedStringWithTemporaryAttributesApplied];
}

#pragma mark -
#pragma mark Instance methods
/*
 
 - initWithObject
 
 Designated initializer
 
 Calling this method enables us to use a predefined object
 for our doc spec.
 eg: Smultron used a CoreData object.
 
 */
- (id)initWithObject:(id)object
{
	if ((self = [super init])) {
		_currentInstance = self;
		
		if (object) {
			_docSpec = [object retain];
		} else {
			_docSpec = [[[self class] createDocSpec] retain];
		}
        
        // register the font transformer
        FRAFontTransformer *fontTransformer = [[[FRAFontTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:fontTransformer forName:@"FontTransformer"];
        
        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaGutterWidth" options:NSKeyValueObservingOptionNew context:&kcGutterWidthPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaSyntaxColourNewDocuments" options:NSKeyValueObservingOptionNew context:&kcSyntaxColourPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaAutoSpellCheck" options:NSKeyValueObservingOptionNew context:&kcSpellCheckPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaShowLineNumberGutter" options:NSKeyValueObservingOptionNew context:&kcLineNumberPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaLineWrapNewDocuments" options:NSKeyValueObservingOptionNew context:&kcLineWrapPrefChanged];
        
        
	}

	return self;
}

/*
 
 - init
 
 */
- (id)init
{
	return [self initWithObject:nil];
}


#pragma mark View handling
/*
 
 - embedInView:
 
 */
- (void)embedInView:(NSView *)contentView
{
    NSAssert(contentView != nil, @"A content view must be provided.");
    
	NSInteger gutterWidth = [[SMLDefaults valueForKey:MGSFragariaPrefsGutterWidth] integerValue];
    
	// create text scrollview
	NSScrollView *textScrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, [contentView bounds].size.width, [contentView bounds].size.height)] autorelease];
	NSSize contentSize = [textScrollView contentSize];
	[textScrollView setBorderType:NSNoBorder];
	[textScrollView setHasVerticalScroller:YES];
	[textScrollView setAutohidesScrollers:YES];
	[textScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[textScrollView contentView] setAutoresizesSubviews:YES];
	[textScrollView setPostsFrameChangedNotifications:YES];
		
	// create textview
	SMLTextView *textView = [[[SMLTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)] autorelease];
    [textView setFragaria:self];
	[textScrollView setDocumentView:textView];

    // create line numbers
	SMLLineNumbers *lineNumbers = [[[SMLLineNumbers alloc] initWithDocument:_docSpec] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[textScrollView contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewFrameDidChangeNotification object:[textScrollView contentView]];	
	[_docSpec setValue:lineNumbers forKey:ro_MGSFOLineNumbers];

	// create gutter scrollview
	NSScrollView *gutterScrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height)] autorelease];
	[gutterScrollView setBorderType:NSNoBorder];
	[gutterScrollView setHasVerticalScroller:NO];
	[gutterScrollView setHasHorizontalScroller:NO];
	[gutterScrollView setAutoresizingMask:NSViewHeightSizable];
	[[gutterScrollView contentView] setAutoresizesSubviews:YES];
	
	// create gutter textview
	SMLGutterTextView *gutterTextView = [[[SMLGutterTextView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height - 50)] autorelease];
	[gutterScrollView setDocumentView:gutterTextView];
	
	// update the docSpec
	[_docSpec setValue:textView forKey:ro_MGSFOTextView];
	[_docSpec setValue:textScrollView forKey:ro_MGSFOScrollView];
	[_docSpec setValue:gutterScrollView forKey:ro_MGSFOGutterScrollView];
	
	// add syntax colouring
	SMLSyntaxColouring *syntaxColouring = [[[SMLSyntaxColouring alloc] initWithDocument:_docSpec] autorelease];
	[_docSpec setValue:syntaxColouring forKey:ro_MGSFOSyntaxColouring];
	
	// add scroll view to content view
	[contentView addSubview:[_docSpec valueForKey:ro_MGSFOScrollView]];
	
	// update line numbers
	[[_docSpec valueForKey:ro_MGSFOLineNumbers] updateLineNumbersForClipView:[[_docSpec valueForKey:ro_MGSFOScrollView] contentView] checkWidth:NO recolour:YES];
    
    // update the gutter view
    [self updateGutterView];
    
    // apply default line wrapping
    [textView updateLineWrap];
    [textView setLineWrap:[[SMLDefaults valueForKey:MGSFragariaPrefsLineWrapNewDocuments] boolValue]];

}

#pragma mark -
#pragma mark Document specification
/*
 
 - docSpec
 
 */
- (id)docSpec
{
	return _docSpec;
}

/*
 
 - setObject:forKey:
 
 */
- (void)setObject:(id)object forKey:(id)key
{
	if ([objectSetterKeys containsObject:key]) {
		[(id)_docSpec setValue:object forKey:key];
	}
}

/*
 
 - objectForKey:
 
 */
- (id)objectForKey:(id)key
{
	if ([objectGetterKeys containsObject:key]) {
		return [_docSpec valueForKey:key];
	}
	
	return nil;
}


#pragma mark -
#pragma mark Accessors

/*
 
 - setString:
 
 */
- (void)setString:(NSString *)aString
{
	[[self class] docSpec:_docSpec setString:aString];
}

/*
 
 - setString:options:
 
 */
- (void)setString:(NSString *)aString options:(NSDictionary *)options
{
	[[self class] docSpec:_docSpec setString:aString options:options];
}

/*
 
 - setAttributedString:
 
 */
- (void)setAttributedString:(NSAttributedString *)aString 
{
	[[self class] docSpec:_docSpec setAttributedString:aString];
}

/*
 
 - setAttributedString:options:
 
 */
- (void)setAttributedString:(NSAttributedString *)aString options:(NSDictionary *)options
{
	[[self class] docSpec:_docSpec setAttributedString:aString options:options];
}


/*
 
 - attributedString
 
 */
- (NSAttributedString *)attributedString
{
	return [[self class] attributedStringForDocSpec:_docSpec];
}

/*
 
 - attributedStringWithTemporaryAttributesApplied
 
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
	return [[self class] attributedStringWithTemporaryAttributesAppliedForDocSpec:_docSpec];
}

/*
 
 - attributedString
 
 */
- (NSString *)string
{
	return [[self class] stringForDocSpec:_docSpec];
}

/*
 
 - textView
 
 */
- (NSTextView *)textView
{
	return [self objectForKey:ro_MGSFOTextView];
}

/*
 
 - setShowsLineNumbers:
 
 */
- (void)setShowsLineNumbers:(BOOL)value
{
    [self setObject:[NSNumber numberWithBool:value] forKey:MGSFOShowLineNumberGutter];
    [self updateGutterView];
}
/*
 
 - showsLineNumbers
 
 */
- (BOOL)showsLineNumbers
{
    NSNumber *value = [self objectForKey:MGSFOShowLineNumberGutter];
    return [value boolValue];
}
/*
 
 - setSyntaxColoured
 
 */
- (void)setSyntaxColoured:(BOOL)value
{
    [self setObject:[NSNumber numberWithBool:value] forKey:MGSFOIsSyntaxColoured]; 
    [self reloadString];
}
/*
 
 - isSyntaxColoured
 
 */
- (BOOL)isSyntaxColoured
{
    NSNumber *value = [self objectForKey:MGSFOIsSyntaxColoured];
    return [value boolValue];
}

/*
 
 - reloadString
 
 */
- (void)reloadString
{
    [self setString:[self string]];
}

#pragma mark -
#pragma mark Controllers

/*
 
 - textMenuController
 
 */
- (MGSTextMenuController *)textMenuController
{
	return [MGSTextMenuController sharedInstance];
}

/*
 
 - extraInterfaceController
 
 */
- (MGSExtraInterfaceController *)extraInterfaceController
{
	if (!extraInterfaceController) {
		extraInterfaceController = [[MGSExtraInterfaceController alloc] init];
	}
	
	return extraInterfaceController;
}

#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context:
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL boolValue = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	if (context == &kcGutterWidthPrefChanged) {

        [self updateGutterView];

    } else if (context == &kcLineNumberPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsShowLineNumberGutter];
        [self setShowsLineNumbers:boolValue];
        
    } else if (context == &kcSyntaxColourPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsSyntaxColourNewDocuments];
        [self setSyntaxColoured:boolValue];
        
    } else if (context == &kcSpellCheckPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsAutoSpellCheck];
        [[self textView] setContinuousSpellCheckingEnabled:boolValue];
        
    } else if (context == &kcLineWrapPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsLineWrapNewDocuments];
        [(SMLTextView *)[self textView] setLineWrap:boolValue];
        [[_docSpec valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
    } else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
}

#pragma mark -
#pragma mark Class extension
/*
 
 - updateGutterView
 
 */
- (void) updateGutterView {
    id document = _docSpec;
    
    BOOL showGutter = [[_docSpec valueForKey:MGSFOShowLineNumberGutter] boolValue];
	NSUInteger gutterWidth = [[SMLDefaults valueForKey:MGSFragariaPrefsGutterWidth] integerValue];
    NSUInteger gutterOffset = (showGutter ? gutterWidth : 0);
	NSRect frame, newFrame;
	
	// Update document value first.
	[document setValue:[NSNumber numberWithUnsignedInteger:gutterWidth] forKey:MGSFOGutterWidth];
	
    // get editor views
    NSScrollView *textScrollView = (NSScrollView *)[document valueForKey:ro_MGSFOScrollView];
    NSScrollView *gutterScrollView = (NSScrollView *) [document valueForKey:ro_MGSFOGutterScrollView];
    NSTextView *textView = (NSTextView *)[document valueForKey:ro_MGSFOTextView];
    
    // get content view
    NSView *contentView = [textScrollView superview];
    CGFloat contentWidth = [contentView bounds].size.width;
    
    // Text Scroll View
    if (textScrollView != nil) {
        frame = [textScrollView frame];
        newFrame = NSMakeRect(gutterOffset, frame.origin.y, contentWidth - gutterOffset, frame.size.height);
        [textScrollView setFrame:newFrame];
        [textScrollView setNeedsDisplay:YES];
    }
    
    // Text View
    else if (textView != nil) {
        frame = [textScrollView frame];
        newFrame = NSMakeRect(gutterOffset, frame.origin.y, contentWidth - gutterOffset, frame.size.height);
        [textView setFrame:newFrame];
        [textView setNeedsDisplay:YES];
    }
    
    // Gutter Scroll View
    if (gutterScrollView != nil) {
        frame = [gutterScrollView frame];
        newFrame = NSMakeRect(frame.origin.x, frame.origin.y, gutterWidth, frame.size.height);
        [gutterScrollView setFrame:newFrame];

        // add or remove the gutter sub view
        if (showGutter) {
            [contentView addSubview:gutterScrollView];
            [gutterScrollView setNeedsDisplay:YES];
        } else {
            [gutterScrollView removeFromSuperview];
        }
    }
    
    // update the line numbers
    [[document valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
}
@end
