//
//  MGSFragariaPreferences.m
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "MGSFragariaPreferences.h"

// colour prefs
// persisted as [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
NSString * const MGSFragariaPrefsCommandsColourWell = @"FragariaCommandsColourWell";
NSString * const MGSFragariaPrefsCommentsColourWell = @"FragariaCommentsColourWell";
NSString * const MGSFragariaPrefsInstructionsColourWell = @"FragariaInstructionsColourWell";
NSString * const MGSFragariaPrefsKeywordsColourWell = @"FragariaKeywordsColourWell";
NSString * const MGSFragariaPrefsAutocompleteColourWell = @"FragariaAutocompleteColourWell";
NSString * const MGSFragariaPrefsVariablesColourWell = @"FragariaVariablesColourWell";
NSString * const MGSFragariaPrefsStringsColourWell = @"FragariaStringsColourWell";
NSString * const MGSFragariaPrefsAttributesColourWell = @"FragariaAttributesColourWell";
NSString * const MGSFragariaPrefsBackgroundColourWell = @"FragariaBackgroundColourWell";
NSString * const MGSFragariaPrefsTextColourWell = @"FragariaTextColourWell";
NSString * const MGSFragariaPrefsGutterTextColourWell = @"FragariaGutterTextColourWell";
NSString * const MGSFragariaPrefsInvisibleCharactersColourWell = @"FragariaInvisibleCharactersColourWell";
NSString * const MGSFragariaPrefsHighlightLineColourWell = @"FragariaHighlightLineColourWell";

// bool
NSString * const MGSFragariaPrefsColourCommands = @"FragariaColourCommands";
NSString * const MGSFragariaPrefsColourComments = @"FragariaColourComments";
NSString * const MGSFragariaPrefsColourInstructions = @"FragariaColourInstructions";
NSString * const MGSFragariaPrefsColourKeywords = @"FragariaColourKeywords";
NSString * const MGSFragariaPrefsColourAutocomplete = @"FragariaColourAutocomplete";
NSString * const MGSFragariaPrefsColourVariables = @"FragariaColourVariables";
NSString * const MGSFragariaPrefsColourStrings = @"FragariaColourStrings";
NSString * const MGSFragariaPrefsColourAttributes = @"FragariaColourAttributes";
NSString * const MGSFragariaPrefsLiveUpdatePreview = @"FragariaLiveUpdatePreview";
NSString * const MGSFragariaPrefsShowFullPathInWindowTitle = @"FragariaShowFullPathInWindowTitle";
NSString * const MGSFragariaPrefsShowLineNumberGutter = @"FragariaShowLineNumberGutter";
NSString * const MGSFragariaPrefsSyntaxColourNewDocuments = @"FragariaSyntaxColourNewDocuments";
NSString * const MGSFragariaPrefsLineWrapNewDocuments = @"FragariaLineWrapNewDocuments";
NSString * const MGSFragariaPrefsIndentNewLinesAutomatically = @"FragariaIndentNewLinesAutomatically";
NSString * const MGSFragariaPrefsOnlyColourTillTheEndOfLine = @"FragariaOnlyColourTillTheEndOfLine";
NSString * const MGSFragariaPrefsShowMatchingBraces = @"FragariaShowMatchingBraces";
NSString * const MGSFragariaPrefsShowInvisibleCharacters = @"FragariaShowInvisibleCharacters";
NSString * const MGSFragariaPrefsIndentWithSpaces = @"FragariaIndentWithSpaces";
NSString * const MGSFragariaPrefsColourMultiLineStrings = @"FragariaColourMultiLineStrings";
NSString * const MGSFragariaPrefsAutocompleteSuggestAutomatically = @"FragariaAutocompleteSuggestAutomatically";
NSString * const MGSFragariaPrefsAutocompleteIncludeStandardWords = @"FragariaAutocompleteIncludeStandardWords";
NSString * const MGSFragariaPrefsAutoSpellCheck = @"FragariaAutoSpellCheck";
NSString * const MGSFragariaPrefsAutoGrammarCheck = @"FragariaAutoGrammarCheck";
NSString * const MGSFragariaPrefsSmartInsertDelete = @"FragariaSmartInsertDelete";
NSString * const MGSFragariaPrefsAutomaticLinkDetection = @"FragariaAutomaticLinkDetection";
NSString * const MGSFragariaPrefsAutomaticQuoteSubstitution = @"FragariaAutomaticQuoteSubstitution";
NSString * const MGSFragariaPrefsUseTabStops = @"FragariaUseTabStops";
NSString * const MGSFragariaPrefsHighlightCurrentLine = @"FragariaHighlightCurrentLine";
NSString * const MGSFragariaPrefsAutomaticallyIndentBraces = @"FragariaAutomaticallyIndentBraces";
NSString * const MGSFragariaPrefsAutoInsertAClosingParenthesis = @"FragariaAutoInsertAClosingParenthesis";
NSString * const MGSFragariaPrefsAutoInsertAClosingBrace = @"FragariaAutoInsertAClosingBrace";

// integer
NSString * const MGSFragariaPrefsGutterWidth = @"FragariaGutterWidth";
NSString * const MGSFragariaPrefsTabWidth = @"FragariaTabWidth";
NSString * const MGSFragariaPrefsIndentWidth = @"FragariaIndentWidth";
NSString * const MGSFragariaPrefsShowPageGuideAtColumn = @"FragariaShowPageGuideAtColumn";
NSString * const MGSFragariaPrefsSpacesPerTabEntabDetab = @"FragariaSpacesPerTabEntabDetab";

// float
NSString * const MGSFragariaPrefsAutocompleteAfterDelay = @"FragariaAutocompleteAfterDelay";
NSString * const MGSFragariaPrefsLiveUpdatePreviewDelay = @"FragariaLiveUpdatePreviewDelay";

// font
// persisted as [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
NSString * const MGSFragariaPrefsTextFont = @"FragariaTextFont";

// string
NSString * const MGSFragariaPrefsSyntaxColouringPopUpString = @"FragariaSyntaxColouringPopUpString";


