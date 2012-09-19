//
//  MGSPreferencesController.m
//  KosmicEditor
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "MGSFragariaFramework.h"

typedef enum {
    kTextEditingPrefTabIndex = 0,
    kFontsAndColoursPrefTabIndex = 1
} MGSPrefTabIndex;

static BOOL MGS_preferencesInitialized = NO;
static id sharedInstance = nil;

@implementation MGSFragariaPreferencesController

@synthesize fontsAndColoursPrefsViewController, textEditingPrefsViewController;

/*
 
 - initializeValues
 
 */
+ (void)initializeValues
{	
	if (MGS_preferencesInitialized) {
		return;
	}
		
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.031f green:0.0f blue:0.855f alpha:1.0f]] forKey:MGSFragariaPrefsCommandsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0f green:0.45f blue:0.0f alpha:1.0f]] forKey:MGSFragariaPrefsCommentsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.45f green:0.45f blue:0.45f alpha:1.0f]] forKey:MGSFragariaPrefsInstructionsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.737f green:0.0f blue:0.647f alpha:1.0f]] forKey:MGSFragariaPrefsKeywordsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.84f green:0.41f blue:0.006f alpha:1.0f]] forKey:MGSFragariaPrefsAutocompleteColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.73f green:0.0f blue:0.74f alpha:1.0f]] forKey:MGSFragariaPrefsVariablesColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.804f green:0.071f blue:0.153f alpha:1.0f]] forKey:MGSFragariaPrefsStringsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.50f green:0.5f blue:0.2f alpha:1.0f]] forKey:MGSFragariaPrefsAttributesColourWell];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourCommands];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourCommands];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourInstructions];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourKeywords];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsColourAutocomplete];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourVariables];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourStrings];	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourAttributes];	
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MGSFragariaPrefsBackgroundColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor textColor]] forKey:MGSFragariaPrefsTextColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.42f alpha:1.0f]] forKey:MGSFragariaPrefsGutterTextColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:MGSFragariaPrefsInvisibleCharactersColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.96f green:0.96f blue:0.71f alpha:1.0f]] forKey:MGSFragariaPrefsHighlightLineColourWell];
	
	[dictionary setValue:[NSNumber numberWithInteger:40] forKey:MGSFragariaPrefsGutterWidth];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:MGSFragariaPrefsTabWidth];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:MGSFragariaPrefsIndentWidth];
	[dictionary setValue:[NSNumber numberWithInteger:80] forKey:MGSFragariaPrefsShowPageGuideAtColumn];	
	[dictionary setValue:[NSNumber numberWithFloat:1.0f] forKey:MGSFragariaPrefsAutocompleteAfterDelay];	
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]] forKey:MGSFragariaPrefsTextFont];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsShowFullPathInWindowTitle];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsShowLineNumberGutter];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsSyntaxColourNewDocuments];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsLineWrapNewDocuments];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsIndentNewLinesAutomatically];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsOnlyColourTillTheEndOfLine];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsShowMatchingBraces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsShowInvisibleCharacters];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsIndentWithSpaces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsColourMultiLineStrings];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutocompleteIncludeStandardWords];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoSpellCheck];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoGrammarCheck];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsSmartInsertDelete];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutomaticLinkDetection];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutomaticQuoteSubstitution];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsUseTabStops];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsHighlightCurrentLine];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:MGSFragariaPrefsSpacesPerTabEntabDetab];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutomaticallyIndentBraces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoInsertAClosingParenthesis];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoInsertAClosingBrace];
	[dictionary setValue:@"Standard" forKey:MGSFragariaPrefsSyntaxColouringPopUpString];
	
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsLiveUpdatePreview];
	[dictionary setValue:[NSNumber numberWithFloat:1.0f] forKey:MGSFragariaPrefsLiveUpdatePreviewDelay];
	
	NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	[defaultsController setInitialValues:dictionary];
	
	MGS_preferencesInitialized = YES;
}

/*
 
 + sharedInstance
 
 */
+ (MGSFragariaPreferencesController *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

/*
 
 + allocWithZone:
 
 alloc with zone for singleton
 
 */
+ (id)allocWithZone:(NSZone *)zone
{
#pragma unused(zone)
	return [[self sharedInstance] retain];
}

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init
{
    if (sharedInstance) return sharedInstance;
    self = [super initWithWindowNibName:@"MGSPreferences" owner:self];
    if (self) {
        
    }
    sharedInstance = self;
    return self;
}

/*
 
 - windowDidLoad
 
 */
- (void)windowDidLoad
{
    // load view controllers
    textEditingPrefsViewController = [[MGSFragariaTextEditingPrefsViewController alloc] init];
    [[tabView tabViewItemAtIndex:kTextEditingPrefTabIndex] setView:[textEditingPrefsViewController view]];

    fontsAndColoursPrefsViewController = [[MGSFragariaFontsAndColoursPrefsViewController alloc] init];
    [[tabView tabViewItemAtIndex:kFontsAndColoursPrefTabIndex] setView:[fontsAndColoursPrefsViewController view]];
    
}

@end
