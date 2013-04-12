//
//  MGSFragaria.m
//  Fragaria
//
//  Created by Jonathan on 05/05/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//
#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

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
NSString * const MGSFOBreakpointDelegate = @"breakpointDelegate";
NSString * const MGSFOAutoCompleteDelegate = @"autoCompleteDelegate";
NSString * const ro_MGSFOLineNumbers = @"lineNumbers"; // readonly
NSString * const ro_MGSFOSyntaxColouring = @"syntaxColouring"; // readonly

static MGSFragaria *_currentInstance;

// class extension
@interface MGSFragaria()
@property (nonatomic, readwrite, assign) MGSExtraInterfaceController *extraInterfaceController;
@property (nonatomic,retain) NSSet* objectGetterKeys;
@property (nonatomic,retain) NSSet* objectSetterKeys;

@end

@implementation MGSFragaria

@synthesize extraInterfaceController;
@synthesize docSpec;
@synthesize objectSetterKeys;
@synthesize objectGetterKeys;

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
	[MGSPreferencesController initializeValues];
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
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], MGSFOIsSyntaxColoured,
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
			self.docSpec = object;
		} else {
			self.docSpec = [[self class] createDocSpec];
		}
        
        
        // Create the Sets containing the valid setter/getter combinations for the Docspec
        
        self.objectSetterKeys = [NSSet setWithObjects:MGSFOIsSyntaxColoured, MGSFOShowLineNumberGutter, MGSFOIsEdited,
                            MGSFOSyntaxDefinitionName, MGSFODelegate, MGSFOBreakpointDelegate, MGSFOAutoCompleteDelegate,
                            nil];
        
        self.objectGetterKeys = [NSMutableSet setWithObjects:ro_MGSFOTextView, ro_MGSFOScrollView, ro_MGSFOGutterScrollView,
                            ro_MGSFOLineNumbers, ro_MGSFOLineNumbers, MGSFOAutoCompleteDelegate,
                            nil];
        [(NSMutableSet *)self.objectGetterKeys unionSet:self.objectSetterKeys];
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
	NSInteger gutterWidth = [[SMLDefaults valueForKey:MGSPrefsGutterWidth] integerValue];
	
	// create text scrollview
	NSScrollView *textScrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(gutterWidth, 0, [contentView bounds].size.width - gutterWidth, [contentView bounds].size.height)] autorelease];
	NSSize contentSize = [textScrollView contentSize];
	[textScrollView setBorderType:NSNoBorder];
	[textScrollView setHasVerticalScroller:YES];
	[textScrollView setAutohidesScrollers:YES];
	[textScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[textScrollView contentView] setAutoresizesSubviews:YES];
	[textScrollView setPostsFrameChangedNotifications:YES];
    [textScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
	
	// create line numbers
	SMLLineNumbers *lineNumbers = [[[SMLLineNumbers alloc] initWithDocument:self.docSpec] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[textScrollView contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewFrameDidChangeNotification object:[textScrollView contentView]];
	
	[self.docSpec setValue:lineNumbers forKey:ro_MGSFOLineNumbers];
	
	// create textview
	SMLTextView *textView = nil;
	if ([[SMLDefaults valueForKey:MGSPrefsLineWrapNewDocuments] boolValue] == YES) {
		textView = [[[SMLTextView alloc] initWithFrame:NSMakeRect(gutterWidth, 0, contentSize.width, contentSize.height)] autorelease];
		[textView setMinSize:contentSize];
		[textScrollView setHasHorizontalScroller:NO];
		[textView setHorizontallyResizable:YES];
		[[textView textContainer] setWidthTracksTextView:YES];
		[[textView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];		 
	} else {
		textView = [[[SMLTextView alloc] initWithFrame:NSMakeRect(gutterWidth, 0, contentSize.width, contentSize.height)] autorelease];
		[textView setMinSize:contentSize];
		[textScrollView setHasHorizontalScroller:YES];
		[textView setHorizontallyResizable:YES];
		[[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
		[[textView textContainer] setWidthTracksTextView:NO];
	}
	[textView setFragaria:self];
	[textScrollView setDocumentView:textView];
	
	// create gutter scrollview
	NSScrollView *gutterScrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height)] autorelease];
	[gutterScrollView setBorderType:NSNoBorder];
	[gutterScrollView setHasVerticalScroller:NO];
	[gutterScrollView setHasHorizontalScroller:NO];
	[gutterScrollView setAutoresizingMask:NSViewHeightSizable];
	[[gutterScrollView contentView] setAutoresizesSubviews:YES];
    [gutterScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
	
	// create gutter textview
	SMLGutterTextView *gutterTextView = [[[SMLGutterTextView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height - 50)] autorelease];
	[gutterScrollView setDocumentView:gutterTextView];
	
	// update the docSpec
	[self.docSpec setValue:textView forKey:ro_MGSFOTextView];
	[self.docSpec setValue:textScrollView forKey:ro_MGSFOScrollView];
	[self.docSpec setValue:gutterScrollView forKey:ro_MGSFOGutterScrollView];
	
	// add syntax colouring
	SMLSyntaxColouring *syntaxColouring = [[[SMLSyntaxColouring alloc] initWithDocument:self.docSpec] autorelease];
	[self.docSpec setValue:syntaxColouring forKey:ro_MGSFOSyntaxColouring];
	
	// add views to content view
	[contentView addSubview:[self.docSpec valueForKey:ro_MGSFOScrollView]];
	if ([[self.docSpec valueForKey:MGSFOShowLineNumberGutter] boolValue] == YES) {
		[contentView addSubview:[self.docSpec valueForKey:ro_MGSFOGutterScrollView]];
	}
	
	// update line numbers
	[[self.docSpec valueForKey:ro_MGSFOLineNumbers] updateLineNumbersForClipView:[[self.docSpec valueForKey:ro_MGSFOScrollView] contentView] checkWidth:NO recolour:YES];
	
    // issues on 10.8
    // https://github.com/mugginsoft/Fragaria/issues/8#issuecomment-5391009
    [textScrollView setFrame:NSMakeRect(gutterWidth, 0, [contentView bounds].size.width - gutterWidth, [contentView bounds].size.height)];
    [gutterScrollView setFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height)];
}

#pragma mark -
#pragma mark Document specification



/*
 
 - setObject:forKey:
 
 */
- (void)setObject:(id)object forKey:(id)key
{
	if ([self.objectSetterKeys containsObject:key]) {
		[(id)self.docSpec setValue:object forKey:key];
	}
}

/*
 
 - objectForKey:
 
 */
- (id)objectForKey:(id)key
{
	if ([self.objectGetterKeys containsObject:key]) {
		return [self.docSpec valueForKey:key];
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
	[[self class] docSpec:self.docSpec setString:aString];
}

/*
 
 - setString:options:
 
 */
- (void)setString:(NSString *)aString options:(NSDictionary *)options
{
	[[self class] docSpec:self.docSpec setString:aString options:options];
}
/*
 
 - attributedString
 
 */
- (NSAttributedString *)attributedString
{
	return [[self class] attributedStringForDocSpec:self.docSpec];
}

/*
 
 - attributedStringWithTemporaryAttributesApplied
 
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
	return [[self class] attributedStringWithTemporaryAttributesAppliedForDocSpec:self.docSpec];
}

/*
 
 - attributedString
 
 */
- (NSString *)string
{
	return [[self class] stringForDocSpec:self.docSpec];
}

/*
 
 - textView
 
 */
- (NSTextView *)textView
{
	return [self objectForKey:ro_MGSFOTextView];
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
#pragma mark Resource loading

+ (NSImage *) imageNamed:(NSString *)name
{
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *path = [bundle pathForImageResource:name];
    return path != nil ? [[[NSImage alloc]
                           initWithContentsOfFile:path] autorelease] : nil;
}

@end
