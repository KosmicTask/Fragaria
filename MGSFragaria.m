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
NSString * const ro_MGSFOLineNumbers = @"lineNumbers"; // readonly
NSString * const ro_MGSFOSyntaxColouring = @"syntaxColouring"; // readonly

static NSSet *objectGetterKeys;
static NSSet *objectSetterKeys;

@implementation MGSFragaria

#pragma mark -
#pragma mark Class methods

/*
 
 + initialize
 
 */
+ (void)initialize
{
	[MGSPreferencesController initializeValues];
	
	objectSetterKeys = [NSSet setWithObjects:MGSFOIsSyntaxColoured, MGSFOShowLineNumberGutter, MGSFOIsEdited,
						MGSFOSyntaxDefinitionName, MGSFODelegate,
						nil];
	
	objectGetterKeys = [NSMutableSet setWithObjects:ro_MGSFOTextView, ro_MGSFOScrollView, ro_MGSFOGutterScrollView, 
						ro_MGSFOLineNumbers, ro_MGSFOLineNumbers, 
						nil];
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
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], MGSFOIsSyntaxColoured,
			@"Standard", MGSFOSyntaxDefinitionName,
			nil];
}

/*
 
 + editDocSpec:inView:
 
 */
+ (void)createDocSpec:(id)docSpec inView:(NSView *)contentView
{
	NSInteger gutterWidth = [[SMLDefaults valueForKey:MGSPrefsGutterWidth] integerValue];
	
	// create text scrollview
	NSScrollView *textScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(gutterWidth, 0, [contentView bounds].size.width - gutterWidth, [contentView bounds].size.height)];
	NSSize contentSize = [textScrollView contentSize];
	[textScrollView setBorderType:NSNoBorder];
	[textScrollView setHasVerticalScroller:YES];
	[textScrollView setAutohidesScrollers:YES];
	[textScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[textScrollView contentView] setAutoresizesSubviews:YES];
	
	// create line numbers
	SMLLineNumbers *lineNumbers = [[SMLLineNumbers alloc] initWithDocument:docSpec];
	[[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[textScrollView contentView]];
	[docSpec setValue:lineNumbers forKey:ro_MGSFOLineNumbers];
	
	// create textview
	SMLTextView *textView = nil;
	if ([[SMLDefaults valueForKey:MGSPrefsLineWrapNewDocuments] boolValue] == YES) {
		textView = [[SMLTextView alloc] initWithFrame:NSMakeRect(gutterWidth, 0, contentSize.width, contentSize.height)];
		[textView setMinSize:contentSize];
		[textScrollView setHasHorizontalScroller:NO];
		[textView setHorizontallyResizable:YES];
		[[textView textContainer] setWidthTracksTextView:YES];
		[[textView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];		 
	} else {
		textView = [[SMLTextView alloc] initWithFrame:NSMakeRect(gutterWidth, 0, contentSize.width, contentSize.height)];
		[textView setMinSize:contentSize];
		[textScrollView setHasHorizontalScroller:YES];
		[textView setHorizontallyResizable:YES];
		[[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
		[[textView textContainer] setWidthTracksTextView:NO];
	}
	[textView setDocSpec:docSpec];
	[textScrollView setDocumentView:textView];
	
	// create gutter scrollview
	NSScrollView *gutterScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height)];
	[gutterScrollView setBorderType:NSNoBorder];
	[gutterScrollView setHasVerticalScroller:NO];
	[gutterScrollView setHasHorizontalScroller:NO];
	[gutterScrollView setAutoresizingMask:NSViewHeightSizable];
	[[gutterScrollView contentView] setAutoresizesSubviews:YES];
	
	// create gutter textview
	SMLGutterTextView *gutterTextView = [[SMLGutterTextView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height - 50)];
	[gutterScrollView setDocumentView:gutterTextView];
	
	// update the docSpec
	[docSpec setValue:textView forKey:ro_MGSFOTextView];
	[docSpec setValue:textScrollView forKey:ro_MGSFOScrollView];
	[docSpec setValue:gutterScrollView forKey:ro_MGSFOGutterScrollView];
	
	// add syntax colouring
	SMLSyntaxColouring *syntaxColouring = [[SMLSyntaxColouring alloc] initWithDocument:docSpec];
	[docSpec setValue:syntaxColouring forKey:ro_MGSFOSyntaxColouring];

	// add views to content view
	[contentView addSubview:[docSpec valueForKey:ro_MGSFOScrollView]];
	if ([[docSpec valueForKey:MGSFOShowLineNumberGutter] boolValue] == YES) {
		[contentView addSubview:[docSpec valueForKey:ro_MGSFOGutterScrollView]];
	}
	
	// update line numbers
	[[docSpec valueForKey:ro_MGSFOLineNumbers] updateLineNumbersForClipView:[[docSpec valueForKey:ro_MGSFOScrollView] contentView] checkWidth:NO recolour:YES];

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
		if (object) {
			_docSpec = object;
		} else {
			_docSpec = [[self class] createDocSpec];
		}
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

/*
 
 - setObject:forKey:
 
 */
- (void)setObject:(id)object forKey:(id)key
{
	if ([objectSetterKeys containsObject:key]) {
		[(id)_docSpec setObject:object forKey:key];
	}
}

/*
 
 - objectForKey:
 
 */
- (id)objectForKey:(id)key
{
	if ([objectGetterKeys containsObject:key]) {
		return [_docSpec objectForKey:key];
	}
	
	return nil;
}

/*
 
 - embedInView:
 
 */
- (void)embedInView:(NSView *)view
{
	[[self class] createDocSpec:_docSpec inView:view];
}

/*
 
 - setString:
 
 */
- (void)setString:(NSString *)aString
{
	[[self class] docSpec:_docSpec setString:aString];
}

/*
 
 - attributedString
 
 */
- (NSAttributedString *)attributedString
{
	return [[self class] attributedStringForDocSpec:_docSpec];
}

/*
 
 - attributedString
 
 */
- (NSString *)string
{
	return [[self class] stringForDocSpec:_docSpec];
}

@end
