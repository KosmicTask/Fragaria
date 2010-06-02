//
//  MGSPreferencesController.m
//  KosmicEditor
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "MGSFragariaFramework.h"

// colour prefs
// [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
NSString * const MGSPrefsCommandsColourWell = @"CommandsColourWell";
NSString * const MGSPrefsCommentsColourWell = @"CommentsColourWell";
NSString * const MGSPrefsInstructionsColourWell = @"InstructionsColourWell";
NSString * const MGSPrefsKeywordsColourWell = @"KeywordsColourWell";
NSString * const MGSPrefsAutocompleteColourWell = @"AutocompleteColourWell";
NSString * const MGSPrefsVariablesColourWell = @"VariablesColourWell";
NSString * const MGSPrefsStringsColourWell = @"StringsColourWell";
NSString * const MGSPrefsAttributesColourWell = @"AttributesColourWell";
NSString * const MGSPrefsBackgroundColourWell = @"BackgroundColourWell";
NSString * const MGSPrefsTextColourWell = @"TextColourWell";
NSString * const MGSPrefsGutterTextColourWell = @"GutterTextColourWell";
NSString * const MGSPrefsInvisibleCharactersColourWell = @"InvisibleCharactersColourWell";
NSString * const MGSPrefsHighlightLineColourWell = @"HighlightLineColourWell";

// bool
NSString * const MGSPrefsColourCommands = @"ColourCommands";
NSString * const MGSPrefsColourComments = @"ColourComments";
NSString * const MGSPrefsColourInstructions = @"ColourInstructions";
NSString * const MGSPrefsColourKeywords = @"ColourKeywords";
NSString * const MGSPrefsColourAutocomplete = @"ColourAutocomplete";
NSString * const MGSPrefsColourVariables = @"ColourVariables";
NSString * const MGSPrefsColourStrings = @"ColourStrings";	
NSString * const MGSPrefsColourAttributes = @"ColourAttributes";	
NSString * const MGSPrefsLiveUpdatePreview = @"LiveUpdatePreview";
NSString * const MGSPrefsShowFullPathInWindowTitle = @"ShowFullPathInWindowTitle";
NSString * const MGSPrefsShowLineNumberGutter = @"ShowLineNumberGutter";
NSString * const MGSPrefsSyntaxColourNewDocuments = @"SyntaxColourNewDocuments";
NSString * const MGSPrefsLineWrapNewDocuments = @"LineWrapNewDocuments";
NSString * const MGSPrefsIndentNewLinesAutomatically = @"IndentNewLinesAutomatically";
NSString * const MGSPrefsOnlyColourTillTheEndOfLine = @"OnlyColourTillTheEndOfLine";
NSString * const MGSPrefsShowMatchingBraces = @"ShowMatchingBraces";
NSString * const MGSPrefsShowInvisibleCharacters = @"ShowInvisibleCharacters";
NSString * const MGSPrefsIndentWithSpaces = @"IndentWithSpaces";
NSString * const MGSPrefsColourMultiLineStrings = @"ColourMultiLineStrings";
NSString * const MGSPrefsAutocompleteSuggestAutomatically = @"AutocompleteSuggestAutomatically";
NSString * const MGSPrefsAutocompleteIncludeStandardWords = @"AutocompleteIncludeStandardWords";
NSString * const MGSPrefsAutoSpellCheck = @"AutoSpellCheck";
NSString * const MGSPrefsAutoGrammarCheck = @"AutoGrammarCheck";
NSString * const MGSPrefsSmartInsertDelete = @"SmartInsertDelete";
NSString * const MGSPrefsAutomaticLinkDetection = @"AutomaticLinkDetection";
NSString * const MGSPrefsAutomaticQuoteSubstitution = @"AutomaticQuoteSubstitution";
NSString * const MGSPrefsUseTabStops = @"UseTabStops";
NSString * const MGSPrefsHighlightCurrentLine = @"HighlightCurrentLine";
NSString * const MGSPrefsAutomaticallyIndentBraces = @"AutomaticallyIndentBraces";
NSString * const MGSPrefsAutoInsertAClosingParenthesis = @"AutoInsertAClosingParenthesis";
NSString * const MGSPrefsAutoInsertAClosingBrace = @"AutoInsertAClosingBrace";

// integer
NSString * const MGSPrefsGutterWidth = @"GutterWidth";
NSString * const MGSPrefsTabWidth = @"TabWidth";
NSString * const MGSPrefsIndentWidth = @"IndentWidth";
NSString * const MGSPrefsShowPageGuideAtColumn = @"ShowPageGuideAtColumn";	

// float
NSString * const MGSPrefsAutocompleteAfterDelay = @"AutocompleteAfterDelay";	
NSString * const MGSPrefsLiveUpdatePreviewDelay = @"LiveUpdatePreviewDelay";

// font
// [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
NSString * const MGSPrefsTextFont = @"TextFont";

// string
NSString * const MGSPrefsSyntaxColouringPopUpString = @"SyntaxColouringPopUpString";


static BOOL MGS_preferencesInitialized = NO;

@implementation MGSPreferencesController


/*
 
 - initializeValues
 
 */
+ (void)initializeValues
{	
	if (MGS_preferencesInitialized) {
		return;
	}
		
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.031 green:0.0 blue:0.855 alpha:1.0]] forKey:@"CommandsColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0 green:0.45 blue:0.0 alpha:1.0]] forKey:@"CommentsColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.45 green:0.45 blue:0.45 alpha:1.0]] forKey:@"InstructionsColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.737 green:0.0 blue:0.647 alpha:1.0]] forKey:@"KeywordsColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.84 green:0.41 blue:0.006 alpha:1.0]] forKey:@"AutocompleteColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.73 green:0.0 blue:0.74 alpha:1.0]] forKey:@"VariablesColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.804 green:0.071 blue:0.153 alpha:1.0]] forKey:@"StringsColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.50 green:0.5 blue:0.2 alpha:1.0]] forKey:@"AttributesColourWell"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourCommands"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourComments"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourInstructions"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourKeywords"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"ColourAutocomplete"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourVariables"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourStrings"];	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ColourAttributes"];	
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:@"BackgroundColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor textColor]] forKey:@"TextColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.42f alpha:1.0f]] forKey:@"GutterTextColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:@"InvisibleCharactersColourWell"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.96 green:0.96 blue:0.71 alpha:1.0]] forKey:@"HighlightLineColourWell"];
	
	[dictionary setValue:[NSNumber numberWithInteger:40] forKey:@"GutterWidth"];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:@"TabWidth"];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:@"IndentWidth"];
	[dictionary setValue:[NSNumber numberWithInteger:80] forKey:@"ShowPageGuideAtColumn"];	
	[dictionary setValue:[NSNumber numberWithFloat:1.0] forKey:@"AutocompleteAfterDelay"];	
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]] forKey:@"TextFont"];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ShowFullPathInWindowTitle"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ShowLineNumberGutter"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"SyntaxColourNewDocuments"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"LineWrapNewDocuments"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"IndentNewLinesAutomatically"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"OnlyColourTillTheEndOfLine"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ShowMatchingBraces"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"ShowInvisibleCharacters"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IndentWithSpaces"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"ColourMultiLineStrings"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutocompleteSuggestAutomatically"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutocompleteIncludeStandardWords"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutoSpellCheck"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutoGrammarCheck"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"SmartInsertDelete"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"AutomaticLinkDetection"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutomaticQuoteSubstitution"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"UseTabStops"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"HighlightCurrentLine"];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"AutomaticallyIndentBraces"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutoInsertAClosingParenthesis"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"AutoInsertAClosingBrace"];
	[dictionary setValue:@"Standard" forKey:@"SyntaxColouringPopUpString"];
	
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"LiveUpdatePreview"];
	[dictionary setValue:[NSNumber numberWithFloat:1.0] forKey:@"LiveUpdatePreviewDelay"];
	
	NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	[defaultsController setInitialValues:dictionary];
	
	MGS_preferencesInitialized = YES;
}

@end
