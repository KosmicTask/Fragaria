// SMLTextView delegate

/*

 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/
#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

// class extension
@interface SMLSyntaxColouring()

@property (copy) NSString *functionDefinition;
@property (copy) NSString *removeFromFunction;
@property (retain) NSString *secondString;
@property (retain) NSString *firstString;
@property (retain) NSString *beginCommand;
@property (retain) NSString *endCommand;
@property (retain) NSSet *keywords;
@property (retain) NSSet *autocompleteWords;
@property (retain) NSArray *keywordsAndAutocompleteWords;
@property (retain) NSString *beginInstruction;
@property (retain) NSString *endInstruction;
@property (retain) NSCharacterSet *beginVariable;
@property (retain) NSCharacterSet *endVariable;
@property (retain) NSString *firstSingleLineComment;
@property (retain) NSString *secondSingleLineComment;
@property (retain) NSMutableArray *singleLineComments;
@property (retain) NSMutableArray *multiLineComments;
@property (retain) NSString *beginFirstMultiLineComment;
@property (retain) NSString*endFirstMultiLineComment;
@property (retain) NSString*beginSecondMultiLineComment;
@property (retain) NSString*endSecondMultiLineComment;
@property (retain) NSCharacterSet *keywordStartCharacterSet;
@property (retain) NSCharacterSet *keywordEndCharacterSet;
@property (retain) NSCharacterSet *attributesCharacterSet;
@property (retain) NSCharacterSet *letterCharacterSet;

- (void)parseSyntaxDictionary:(NSDictionary *)syntaxDictionary;
- (void)applySyntaxDefinition;
- (NSString *)assignSyntaxDefinition;
- (void)performDocumentDelegateSelector:(SEL)selector withObject:(id)object;
- (void)autocompleteWordsTimerSelector:(NSTimer *)theTimer;
- (NSString *)completeString;
- (void)prepareRegularExpressions;
- (void)applyColourDefaults;
- (void)recolourRange:(NSRange)range;
- (void)removeAllColours;
- (void)removeColoursFromRange:(NSRange)range;
- (NSString *)guessSyntaxDefinitionExtensionFromFirstLine:(NSString *)firstLine;
- (void)pageRecolour;
- (void)setColour:(NSDictionary *)colour range:(NSRange)range;
- (void)highlightLineRange:(NSRange)lineRange;
- (void)undoManagerDidUndo:(NSNotification *)aNote;
@end

@implementation SMLSyntaxColouring

@synthesize reactToChanges, functionDefinition, removeFromFunction, undoManager, secondString, firstString, keywords, autocompleteWords, keywordsAndAutocompleteWords, beginCommand, endCommand, beginInstruction, endInstruction, beginVariable, endVariable, firstSingleLineComment, secondSingleLineComment, singleLineComments, multiLineComments, beginFirstMultiLineComment, endFirstMultiLineComment, beginSecondMultiLineComment, endSecondMultiLineComment, keywordStartCharacterSet, keywordEndCharacterSet, attributesCharacterSet, letterCharacterSet;

#pragma mark -
#pragma mark Instance methods
/*
 
 - init
 
 */
- (id)init
{
	self = [self initWithDocument:nil];
	
	return self;
}

/*
 
 - initWithDocument:
 
 */
- (id)initWithDocument:(id)theDocument
{
	if ((self = [super init])) {

		NSAssert(theDocument, @"bad document");
		
		// retain the document
		document = theDocument;
		
		undoManager = [[NSUndoManager alloc] init];

		// configure the document text view
		NSTextView *textView = [document valueForKey:@"firstTextView"];
		NSAssert([textView isKindOfClass:[NSTextView class]], @"bad textview");
		[textView setDelegate:self];
		[[textView textStorage] setDelegate:self];

		// configure ivars
		lastCursorLocation = 0;
		lastLineHighlightRange = NSMakeRange(0, 0);
		reactToChanges = YES;
		
		// configure layout managers
		firstLayoutManager = (SMLLayoutManager *)[textView layoutManager];
		
		// configure colouring
		[self applyColourDefaults];

		// letter character set
		self.letterCharacterSet = [NSCharacterSet letterCharacterSet];
		
		// keyword start character set
		NSMutableCharacterSet *temporaryCharacterSet = [[[NSCharacterSet letterCharacterSet] mutableCopy] autorelease];
		[temporaryCharacterSet addCharactersInString:@"_:@#"];
		self.keywordStartCharacterSet = [[temporaryCharacterSet copy] autorelease];
		
		// keyword end character set
		temporaryCharacterSet = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
		[temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
		[temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
		[temporaryCharacterSet removeCharactersInString:@"_"];
		self.keywordEndCharacterSet = [[temporaryCharacterSet copy] autorelease];
		
		// attributes character set
		temporaryCharacterSet = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
		[temporaryCharacterSet addCharactersInString:@" -"]; // If there are two spaces before an attribute
		self.attributesCharacterSet = [[temporaryCharacterSet copy] autorelease];
		
		// configure syntax definition
		[self applySyntaxDefinition];
		
		// add undo notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(undoManagerDidUndo:) 
													 name:@"NSUndoManagerDidUndoChangeNotification" 
												   object:undoManager];
		
		// add document KVO observers
		[document addObserver:self forKeyPath:@"syntaxDefinition" options:NSKeyValueObservingOptionNew context:@"syntaxDefinition"];
		
		// add NSUserDefaultsController KVO observers
		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

		[defaultsController addObserver:self forKeyPath:@"values.FragariaCommandsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaCommentsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaInstructionsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaKeywordsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaAutocompleteColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaVariablesColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaStringsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaAttributesColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourCommands" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourComments" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourInstructions" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourKeywords" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourAutocomplete" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourVariables" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourStrings" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourAttributes" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourMultiLineStrings" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaOnlyColourTillTheEndOfLine" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaHighlightCurrentLine" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaHighlightLineColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourMultiLineStrings" options:NSKeyValueObservingOptionNew context:@"MultiLineChanged"];
	}
	
    return self;
}

#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context:
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(NSString *)context isEqualToString:@"ColoursChanged"]) {
		[self applyColourDefaults];
		[self pageRecolour];
		if ([[SMLDefaults valueForKey:MGSFragariaPrefsHighlightCurrentLine] boolValue] == YES) {
			NSRange range = [[self completeString] lineRangeForRange:[[document valueForKey:@"firstTextView"] selectedRange]];
			[self highlightLineRange:range];
			lastLineHighlightRange = range;
		} else {
			[self highlightLineRange:NSMakeRange(0, 0)];
		}
	} else if ([(NSString *)context isEqualToString:@"MultiLineChanged"]) {
		[self prepareRegularExpressions];
		[self pageRecolour];
	} else if ([(NSString *)context isEqualToString:@"syntaxDefinition"]) {
		[self applySyntaxDefinition];
		[self removeAllColours];
		[self pageRecolour];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
}


#pragma mark -
#pragma mark Syntax definition handling
/*
 
 - applySyntaxDefinition
 
 */
- (void)applySyntaxDefinition
{	
	NSString *definitionName = [document valueForKey:@"syntaxDefinition"];
	
	// if document has no syntax definition name then assign one
	if (!definitionName) {
		definitionName = [self assignSyntaxDefinition];
	}
	
	// get syntax dictionary
	NSDictionary *syntaxDictionary = [[MGSSyntaxController sharedInstance] syntaxDictionaryWithName:definitionName];
		
	// parse
	[self parseSyntaxDictionary:syntaxDictionary];	
}

/*
 
 - assignSyntaxDefinition
 
 */
- (NSString *)assignSyntaxDefinition
{
	NSString *definitionName = [document valueForKey:@"syntaxDefinition"];
	if (definitionName) return definitionName;

	NSString *defaultDefinitionName  = [SMLDefaults valueForKey:MGSFragariaPrefsSyntaxColouringPopUpString];
	NSString *documentExtension = [[document valueForKey:@"name"] pathExtension];
	
	if ([[SMLDefaults valueForKey:@"SyntaxColouringMatrix"] integerValue] == 1) { // Always use...
		definitionName = defaultDefinitionName;
	} else {
		NSString *lowercaseExtension = nil;
		
		// If there is no extension try to guess definition from first line
		if ([documentExtension isEqualToString:@""]) { 
			
			NSString *string = [[[document valueForKey:@"firstTextScrollView"] documentView] string];
			NSString *firstLine = [string substringWithRange:[string lineRangeForRange:NSMakeRange(0,0)]];
			if ([firstLine hasPrefix:@"#!"] || [firstLine hasPrefix:@"%"] || [firstLine hasPrefix:@"<?"]) {
				lowercaseExtension = [self guessSyntaxDefinitionExtensionFromFirstLine:firstLine];
			} 
		} else {
			lowercaseExtension = [documentExtension lowercaseString];
		}
		
		if (lowercaseExtension) {
			definitionName = [[MGSSyntaxController sharedInstance] syntaxDefinitionNameWithExtension:lowercaseExtension];
		}
	}
	
	if (!definitionName) {
		definitionName = [MGSSyntaxController standardSyntaxDefinitionName];
	}
	
	// update document definition
	[document setValue:definitionName forKey:@"syntaxDefinition"];
	
	return definitionName;
}

/*
 
 - parseSyntaxDictionary
 
 */
- (void)parseSyntaxDictionary:(NSDictionary *)syntaxDictionary
{
	
	NSMutableArray *keywordsAndAutocompleteWordsTemporary = [NSMutableArray array];
	
	// If the plist file is malformed be sure to set the values to something
	if ([syntaxDictionary valueForKey:@"keywords"]) {
		self.keywords = [[[NSSet alloc] initWithArray:[syntaxDictionary valueForKey:@"keywords"]] autorelease];
		[keywordsAndAutocompleteWordsTemporary addObjectsFromArray:[syntaxDictionary valueForKey:@"keywords"]];
	}
	
	if ([syntaxDictionary valueForKey:@"autocompleteWords"]) {
		self.autocompleteWords = [[[NSSet alloc] initWithArray:[syntaxDictionary valueForKey:@"autocompleteWords"]] autorelease];
		[keywordsAndAutocompleteWordsTemporary addObjectsFromArray:[syntaxDictionary valueForKey:@"autocompleteWords"]];
	}
	
	if ([[SMLDefaults valueForKey:@"ColourAutocompleteWordsAsKeywords"] boolValue] == YES) {
		self.keywords = [NSSet setWithArray:keywordsAndAutocompleteWordsTemporary];
	}
	
	self.keywordsAndAutocompleteWords = [keywordsAndAutocompleteWordsTemporary sortedArrayUsingSelector:@selector(compare:)];
	
	if ([syntaxDictionary valueForKey:@"recolourKeywordIfAlreadyColoured"]) {
		recolourKeywordIfAlreadyColoured = [[syntaxDictionary valueForKey:@"recolourKeywordIfAlreadyColoured"] boolValue];
	}
	
	if ([syntaxDictionary valueForKey:@"keywordsCaseSensitive"]) {
		keywordsCaseSensitive = [[syntaxDictionary valueForKey:@"keywordsCaseSensitive"] boolValue];
	}
	
	if (keywordsCaseSensitive == NO) {
		NSMutableArray *lowerCaseKeywords = [[[NSMutableArray alloc] init] autorelease];
		for (id item in keywords) {
			[lowerCaseKeywords addObject:[item lowercaseString]];
		}
		
		NSSet *lowerCaseKeywordsSet = [[[NSSet alloc] initWithArray:lowerCaseKeywords] autorelease];
		self.keywords = lowerCaseKeywordsSet;
	}
	
	if ([syntaxDictionary valueForKey:@"beginCommand"]) {
		self.beginCommand = [syntaxDictionary valueForKey:@"beginCommand"];
	} else { 
		self.beginCommand = @"";
	}
    
	if ([syntaxDictionary valueForKey:@"endCommand"]) {
		self.endCommand = [syntaxDictionary valueForKey:@"endCommand"];
	} else { 
		self.endCommand = @"";
	}
    
	if ([syntaxDictionary valueForKey:@"beginInstruction"]) {
		self.beginInstruction = [syntaxDictionary valueForKey:@"beginInstruction"];
	} else {
		self.beginInstruction = @"";
	}

	if ([syntaxDictionary valueForKey:@"endInstruction"]) {
		self.endInstruction = [syntaxDictionary valueForKey:@"endInstruction"];
	} else {
		self.endInstruction = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"beginVariable"]) {
		self.beginVariable = [NSCharacterSet characterSetWithCharactersInString:[syntaxDictionary valueForKey:@"beginVariable"]];
	} else {
        self.beginVariable = [NSCharacterSet characterSetWithCharactersInString:@""];
    }
	

	if ([syntaxDictionary valueForKey:@"endVariable"]) {
		self.endVariable = [NSCharacterSet characterSetWithCharactersInString:[syntaxDictionary valueForKey:@"endVariable"]];
	} else {
		self.endVariable = [NSCharacterSet characterSetWithCharactersInString:@""];
	}

	if ([syntaxDictionary valueForKey:@"firstString"]) {
		self.firstString = [syntaxDictionary valueForKey:@"firstString"];
		if (![[syntaxDictionary valueForKey:@"firstString"] isEqualToString:@""]) {
			firstStringUnichar = [[syntaxDictionary valueForKey:@"firstString"] characterAtIndex:0];
		}
	} else {
		self.firstString = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"secondString"]) {
		self.secondString = [syntaxDictionary valueForKey:@"secondString"];
		if (![[syntaxDictionary valueForKey:@"secondString"] isEqualToString:@""]) {
			secondStringUnichar = [[syntaxDictionary valueForKey:@"secondString"] characterAtIndex:0];
		}
	} else { 
		self.secondString = @"";
	}
	
    // single line comment definitions
	if ([syntaxDictionary valueForKey:@"firstSingleLineComment"]) {
		self.firstSingleLineComment = [syntaxDictionary valueForKey:@"firstSingleLineComment"];
	} else {
		self.firstSingleLineComment = @"";
	}
    
    self.singleLineComments = [NSMutableArray arrayWithCapacity:2];
    [self.singleLineComments addObject:firstSingleLineComment];
	
	if ([syntaxDictionary valueForKey:@"secondSingleLineComment"]) {
		self.secondSingleLineComment = [syntaxDictionary valueForKey:@"secondSingleLineComment"];
	} else {
		self.secondSingleLineComment = @"";
	}
    [self.singleLineComments addObject:secondSingleLineComment];
	
    // multi line comment definitions
	if ([syntaxDictionary valueForKey:@"beginFirstMultiLineComment"]) {
		self.beginFirstMultiLineComment = [syntaxDictionary valueForKey:@"beginFirstMultiLineComment"];
	} else {
		self.beginFirstMultiLineComment = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"endFirstMultiLineComment"]) {
		self.endFirstMultiLineComment = [syntaxDictionary valueForKey:@"endFirstMultiLineComment"];
	} else {
		self.endFirstMultiLineComment = @"";
	}

    self.multiLineComments = [NSMutableArray arrayWithCapacity:2];
	[self.multiLineComments addObject:[NSArray arrayWithObjects:self.beginFirstMultiLineComment, self.endFirstMultiLineComment, nil]];
	
	if ([syntaxDictionary valueForKey:@"beginSecondMultiLineComment"]) {
		self.beginSecondMultiLineComment = [syntaxDictionary valueForKey:@"beginSecondMultiLineComment"];
	} else {
		self.beginSecondMultiLineComment = @"";
	}
     
	if ([syntaxDictionary valueForKey:@"endSecondMultiLineComment"]) {
		self.endSecondMultiLineComment = [syntaxDictionary valueForKey:@"endSecondMultiLineComment"];
	} else {
		self.endSecondMultiLineComment = @"";
	}
	[self.multiLineComments addObject:[NSArray arrayWithObjects:self.beginSecondMultiLineComment, self.endSecondMultiLineComment, nil]];

	
	if ([syntaxDictionary valueForKey:@"functionDefinition"]) {
		self.functionDefinition = [syntaxDictionary valueForKey:@"functionDefinition"];
	} else {
		self.functionDefinition = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"removeFromFunction"]) {
		self.removeFromFunction = [syntaxDictionary valueForKey:@"removeFromFunction"];
	} else {
		self.removeFromFunction = @"";
	}
	
	if ([syntaxDictionary valueForKey:@"excludeFromKeywordStartCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [[keywordStartCharacterSet mutableCopy] autorelease];
		[temporaryCharacterSet removeCharactersInString:[syntaxDictionary valueForKey:@"excludeFromKeywordStartCharacterSet"]];
		self.keywordStartCharacterSet = [[temporaryCharacterSet copy] autorelease];
	}
	
	if ([syntaxDictionary valueForKey:@"excludeFromKeywordEndCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [[keywordEndCharacterSet mutableCopy] autorelease];
		[temporaryCharacterSet removeCharactersInString:[syntaxDictionary valueForKey:@"excludeFromKeywordEndCharacterSet"]];
		self.keywordEndCharacterSet = [[temporaryCharacterSet copy] autorelease];
	}
	
	if ([syntaxDictionary valueForKey:@"includeInKeywordStartCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [[keywordStartCharacterSet mutableCopy] autorelease];
		[temporaryCharacterSet addCharactersInString:[syntaxDictionary valueForKey:@"includeInKeywordStartCharacterSet"]];
		self.keywordStartCharacterSet = [[temporaryCharacterSet copy] autorelease];
	}
	
	if ([syntaxDictionary valueForKey:@"includeInKeywordEndCharacterSet"]) {
		NSMutableCharacterSet *temporaryCharacterSet = [[keywordEndCharacterSet mutableCopy] autorelease];
		[temporaryCharacterSet addCharactersInString:[syntaxDictionary valueForKey:@"includeInKeywordEndCharacterSet"]];
		self.keywordEndCharacterSet = [[temporaryCharacterSet copy] autorelease];
	}

	[self prepareRegularExpressions];
}

/*
 
 - guessSyntaxDefinitionExtensionFromFirstLine:
 
 */
- (NSString *)guessSyntaxDefinitionExtensionFromFirstLine:(NSString *)firstLine
{
	NSString *returnString = nil;
	NSRange firstLineRange = NSMakeRange(0, [firstLine length]);
	if ([firstLine rangeOfString:@"perl" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"pl";
	} else if ([firstLine rangeOfString:@"wish" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"tcl";
	} else if ([firstLine rangeOfString:@"sh" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"sh";
	} else if ([firstLine rangeOfString:@"php" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"php";
	} else if ([firstLine rangeOfString:@"python" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"py";
	} else if ([firstLine rangeOfString:@"awk" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"awk";
	} else if ([firstLine rangeOfString:@"xml" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"xml";
	} else if ([firstLine rangeOfString:@"ruby" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"rb";
	} else if ([firstLine rangeOfString:@"%!ps" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"ps";
	} else if ([firstLine rangeOfString:@"%pdf" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"pdf";
	}
	
	return returnString;
}


#pragma mark -
#pragma mark Regex handling
/*
 
 - prepareRegularExpressions
 
 */
- (void)prepareRegularExpressions
{
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsColourMultiLineStrings] boolValue] == NO) {
		firstStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\\\r\\n]*+(?:\\\\(?:.|$)[^%@\\\\\\r\\n]*+)*+%@", self.firstString, self.firstString, self.firstString, self.firstString]];
		
		secondStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\\\r\\n]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", self.secondString, self.secondString, self.secondString, self.secondString]];

	} else {
		firstStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", self.firstString, self.firstString, self.firstString, self.firstString]];
		
		secondStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", self.secondString, self.secondString, self.secondString, self.secondString]];
	}
}


#pragma mark -
#pragma mark Accessors

/*
 
 - completeString
 
 */
- (NSString *)completeString
{
	return [[document valueForKey:@"firstTextView"] string];
}

#pragma mark -
#pragma mark Colouring

/*
 
 - removeAllColours
 
 */
- (void)removeAllColours
{
	NSRange wholeRange = NSMakeRange(0, [[self completeString] length]);
	[firstLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:wholeRange];
}

/*
 
 - removeColoursFromRange
 
 */
- (void)removeColoursFromRange:(NSRange)range
{
	[firstLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
}

/*
 
 - pageRecolour
 
 */
- (void)pageRecolour
{
	[self pageRecolourTextView:[document valueForKey:@"firstTextView"]];
}

/*
 
 - pageRecolourTextView:
 
 */
- (void)pageRecolourTextView:(SMLTextView *)textView
{
	if ([[document valueForKey:@"isSyntaxColoured"] boolValue] == NO) {
		return;
	}
	
	if (textView == nil) {
		return;
	}
	NSRect visibleRect = [[[textView enclosingScrollView] contentView] documentVisibleRect];
	NSRange visibleRange = [[textView layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
	NSInteger beginningOfFirstVisibleLine = [[textView string] lineRangeForRange:NSMakeRange(visibleRange.location, 0)].location;
	NSInteger endOfLastVisibleLine = NSMaxRange([[self completeString] lineRangeForRange:NSMakeRange(NSMaxRange(visibleRange), 0)]);
	
	[self recolourRange:NSMakeRange(beginningOfFirstVisibleLine, endOfLastVisibleLine - beginningOfFirstVisibleLine)];
}

/*
 
 - pageRecolourTextView:options:
 
 */
- (void)pageRecolourTextView:(SMLTextView *)textView options:(NSDictionary *)options
{
	if (!textView) {
		return;
	}

	if ([[document valueForKey:@"isSyntaxColoured"] boolValue] == NO) {
		return;
	}
	
	// colourAll option
	NSNumber *colourAll = [options objectForKey:@"colourAll"];
	if (!colourAll || ![colourAll boolValue]) {
		[self pageRecolourTextView:textView];
		return;
	}
	
	
	[self recolourRange:NSMakeRange(0, [[textView string] length])];
}

/*
 
 - recolourRange:
 
 */
- (void)recolourRange:(NSRange)range
{
	if (reactToChanges == NO) {
		return;
	}
	
	BOOL shouldOnlyColourTillTheEndOfLine = [[SMLDefaults valueForKey:MGSFragariaPrefsOnlyColourTillTheEndOfLine] boolValue];
	BOOL shouldColourMultiLineStrings = [[SMLDefaults valueForKey:MGSFragariaPrefsColourMultiLineStrings] boolValue];
	NSString *completeString = [self completeString];
	
	NSRange effectiveRange = range;
	NSRange rangeOfLine = NSMakeRange(0, 0);
	NSRange foundRange = NSMakeRange(0, 0);
	NSRange searchRange = NSMakeRange(0, 0);
	NSUInteger searchSyntaxLength = 0;
	NSUInteger beginning = 0, end = 0, endOfLine = 0, length = 0;

	if (shouldColourMultiLineStrings) { // When multiline strings are coloured it needs to go backwards to find where the string might have started if it's "above" the top of the screen
		NSInteger beginFirstStringInMultiLine = [completeString rangeOfString:self.firstString options:NSBackwardsSearch range:NSMakeRange(0, effectiveRange.location)].location;
		if (beginFirstStringInMultiLine != NSNotFound && [[firstLayoutManager temporaryAttributesAtCharacterIndex:beginFirstStringInMultiLine effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
			NSInteger startOfLine = [completeString lineRangeForRange:NSMakeRange(beginFirstStringInMultiLine, 0)].location;
			effectiveRange = NSMakeRange(startOfLine, range.length + (range.location - startOfLine));
		}
	}
	
	NSUInteger rangeLocation = effectiveRange.location;
	NSUInteger maxRange = NSMaxRange(effectiveRange);
	searchString = [completeString substringWithRange:effectiveRange];
	NSUInteger searchStringLength = [searchString length];
	if (searchStringLength == 0) {
		return;
	}
	NSScanner *scanner = [[[NSScanner alloc] initWithString:searchString] autorelease];
	[scanner setCharactersToBeSkipped:nil];
	NSScanner *completeDocumentScanner = [[[NSScanner alloc] initWithString:completeString] autorelease];
	[completeDocumentScanner setCharactersToBeSkipped:nil];
	
	NSUInteger completeStringLength = [completeString length];
	
	NSUInteger endLocationInMultiLine = 0;
	NSUInteger beginLocationInMultiLine = 0;
	
    // uncolour the range
	[self removeColoursFromRange:range];		
	
	
	@try {	
		
        //
		// Commands
        //
		if (![self.beginCommand isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourCommands] boolValue] == YES) {
			searchSyntaxLength = [self.endCommand length];
			unichar beginCommandCharacter = [self.beginCommand characterAtIndex:0];
			unichar endCommandCharacter = [self.endCommand characterAtIndex:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToString:self.beginCommand intoString:nil];
				beginning = [scanner scanLocation];
				endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
				if (![scanner scanUpToString:self.endCommand intoString:nil] || [scanner scanLocation] >= endOfLine) {
					[scanner mgs_setScanLocation:endOfLine];
					continue; // Don't colour it if it hasn't got a closing tag
				} else {
					// To avoid problems with strings like <yada <%=yada%> yada> we need to balance the number of begin- and end-tags
					// If ever there's a beginCommand or endCommand with more than one character then do a check first
					NSUInteger commandLocation = beginning + 1;
					NSUInteger skipEndCommand = 0;
					
					while (commandLocation < endOfLine) {
						unichar commandCharacterTest = [searchString characterAtIndex:commandLocation];
						if (commandCharacterTest == endCommandCharacter) {
							if (!skipEndCommand) {
								break;
							} else {
								skipEndCommand--;
							}
						}
						if (commandCharacterTest == beginCommandCharacter) {
							skipEndCommand++;
						}
						commandLocation++;
					}
					if (commandLocation < endOfLine) {
						[scanner mgs_setScanLocation:commandLocation + searchSyntaxLength];
					} else {
						[scanner mgs_setScanLocation:endOfLine];
					}
				}
				
				[self setColour:commandsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
			}
		}
		

        //
		// Instructions
        //
		if (![self.beginInstruction isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourInstructions] boolValue] == YES) {
			// It takes too long to scan the whole document if it's large, so for instructions, first multi-line comment and second multi-line comment search backwards and begin at the start of the first beginInstruction etc. that it finds from the present position and, below, break the loop if it has passed the scanned range (i.e. after the end instruction)
			
			beginLocationInMultiLine = [completeString rangeOfString:self.beginInstruction options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
			endLocationInMultiLine = [completeString rangeOfString:self.endInstruction options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
			if (beginLocationInMultiLine == NSNotFound || (endLocationInMultiLine != NSNotFound && beginLocationInMultiLine < endLocationInMultiLine)) {
				beginLocationInMultiLine = rangeLocation;
			}			

			searchSyntaxLength = [self.endInstruction length];
			while (![completeDocumentScanner isAtEnd]) {
				searchRange = NSMakeRange(beginLocationInMultiLine, range.length);
				if (NSMaxRange(searchRange) > completeStringLength) {
					searchRange = NSMakeRange(beginLocationInMultiLine, completeStringLength - beginLocationInMultiLine);
				}
				
				beginning = [completeString rangeOfString:self.beginInstruction options:NSLiteralSearch range:searchRange].location;
				if (beginning == NSNotFound) {
					break;
				}
				[completeDocumentScanner mgs_setScanLocation:beginning];
				if (![completeDocumentScanner scanUpToString:self.endInstruction intoString:nil] || [completeDocumentScanner scanLocation] >= completeStringLength) {
					if (shouldOnlyColourTillTheEndOfLine) {
						[completeDocumentScanner mgs_setScanLocation:NSMaxRange([completeString lineRangeForRange:NSMakeRange(beginning, 0)])];
					} else {
						[completeDocumentScanner mgs_setScanLocation:completeStringLength];
					}
				} else {
					if ([completeDocumentScanner scanLocation] + searchSyntaxLength <= completeStringLength) {
						[completeDocumentScanner mgs_setScanLocation:[completeDocumentScanner scanLocation] + searchSyntaxLength];
					}
				}
				
				[self setColour:instructionsColour range:NSMakeRange(beginning, [completeDocumentScanner scanLocation] - beginning)];
				if ([completeDocumentScanner scanLocation] > maxRange) {
					break;
				}
				beginLocationInMultiLine = [completeDocumentScanner scanLocation];
			}
		}
		
		//
		// Keywords
        //
		if ([keywords count] != 0 && [[SMLDefaults valueForKey:MGSFragariaPrefsColourKeywords] boolValue] == YES) {
			[scanner mgs_setScanLocation:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToCharactersFromSet:self.keywordStartCharacterSet intoString:nil];
				beginning = [scanner scanLocation];
				if ((beginning + 1) < searchStringLength) {
					[scanner mgs_setScanLocation:(beginning + 1)];
				}
				[scanner scanUpToCharactersFromSet:self.keywordEndCharacterSet intoString:nil];
				
				end = [scanner scanLocation];
				if (end > searchStringLength || beginning == end) {
					break;
				}
				
				NSString *keywordTestString = nil;
				if (!keywordsCaseSensitive) {
					keywordTestString = [[completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)] lowercaseString];
				} else {
					keywordTestString = [completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)];
				}
				if ([keywords containsObject:keywordTestString]) {
					if (!recolourKeywordIfAlreadyColoured) {
						if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
							continue;
						}
					}	
					[self setColour:keywordsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
				}
			}
		}
			
		//
		// Autocomplete
        //
		if ([self.autocompleteWords count] != 0 && [[SMLDefaults valueForKey:MGSFragariaPrefsColourAutocomplete] boolValue] == YES) {
			[scanner mgs_setScanLocation:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToCharactersFromSet:self.keywordStartCharacterSet intoString:nil];
				beginning = [scanner scanLocation];
				if ((beginning + 1) < searchStringLength) {
					[scanner mgs_setScanLocation:(beginning + 1)];
				}
				[scanner scanUpToCharactersFromSet:self.keywordEndCharacterSet intoString:nil];
				
				end = [scanner scanLocation];
				if (end > searchStringLength || beginning == end) {
					break;
				}
				
				NSString *autocompleteTestString = nil;
				if (!keywordsCaseSensitive) {
					autocompleteTestString = [[completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)] lowercaseString];
				} else {
					autocompleteTestString = [completeString substringWithRange:NSMakeRange(beginning + rangeLocation, end - beginning)];
				}
				if ([self.autocompleteWords containsObject:autocompleteTestString]) {
					if (!recolourKeywordIfAlreadyColoured) {
						if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
							continue;
						}
					}	
					
					[self setColour:autocompleteWordsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
				}
			}
		}
		
		//
		// Variables
        //
		if (self.beginVariable != nil && [[SMLDefaults valueForKey:MGSFragariaPrefsColourVariables] boolValue] == YES) {
			[scanner mgs_setScanLocation:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToCharactersFromSet:self.beginVariable intoString:nil];
				beginning = [scanner scanLocation];
				if (beginning + 1 < searchStringLength) {
					if ([self.firstSingleLineComment isEqualToString:@"%"] && [searchString characterAtIndex:beginning + 1] == '%') { // To avoid a problem in LaTex with \%
						if ([scanner scanLocation] < searchStringLength) {
							[scanner mgs_setScanLocation:beginning + 1];
						}
						continue;
					}
				}
				endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
				if (![scanner scanUpToCharactersFromSet:self.endVariable intoString:nil] || [scanner scanLocation] >= endOfLine) {
					[scanner mgs_setScanLocation:endOfLine];
					length = [scanner scanLocation] - beginning;
				} else {
					length = [scanner scanLocation] - beginning;
					if ([scanner scanLocation] < searchStringLength) {
						[scanner mgs_setScanLocation:[scanner scanLocation] + 1];
					}
				}
				
				[self setColour:variablesColour range:NSMakeRange(beginning + rangeLocation, length)];
			}
		}	

		//
		// Second string, first pass
        //
		if (![self.secondString isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourStrings] boolValue] == YES) {
			@try {
				secondStringMatcher = [[ICUMatcher alloc] initWithPattern:secondStringPattern overString:searchString];
			}
			@catch (NSException *exception) {
				return;
			}

			while ([secondStringMatcher findNext]) {
				foundRange = [secondStringMatcher rangeOfMatch];
				[self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
			}
		}
		
		//
		// First string
        //
		if (![self.firstString isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourStrings] boolValue] == YES) {
			@try {
				firstStringMatcher = [[ICUMatcher alloc] initWithPattern:firstStringPattern overString:searchString];
			}
			@catch (NSException *exception) {
				return;
			}
			
			while ([firstStringMatcher findNext]) {
				foundRange = [firstStringMatcher rangeOfMatch];
				if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
					continue;
				}
				[self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
			}
		}
		
		//
		// Attributes
        //
		if ([[SMLDefaults valueForKey:MGSFragariaPrefsColourAttributes] boolValue] == YES) {
			[scanner mgs_setScanLocation:0];
			while (![scanner isAtEnd]) {
				[scanner scanUpToString:@" " intoString:nil];
				beginning = [scanner scanLocation];
				if (beginning + 1 < searchStringLength) {
					[scanner mgs_setScanLocation:beginning + 1];
				} else {
					break;
				}
				if (![[firstLayoutManager temporaryAttributesAtCharacterIndex:(beginning + rangeLocation) effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
					continue;
				}
				
				[scanner scanCharactersFromSet:self.attributesCharacterSet intoString:nil];
				end = [scanner scanLocation];
				
				if (end + 1 < searchStringLength) {
					[scanner mgs_setScanLocation:[scanner scanLocation] + 1];
				}
				
				if ([completeString characterAtIndex:end + rangeLocation] == '=') {
					[self setColour:attributesColour range:NSMakeRange(beginning + rangeLocation, end - beginning)];
				}
			}
		}
		
		//
		// Colour single-line comments
        //
        for (NSString *singleLineComment in self.singleLineComments) {
            if (![singleLineComment isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourComments] boolValue] == YES) {
                
                // reset scanner
                [scanner mgs_setScanLocation:0];
                searchSyntaxLength = [singleLineComment length];
                
                // scan
                while (![scanner isAtEnd]) {
                    
                    // scan for comment
                    [scanner scanUpToString:singleLineComment intoString:nil];
                    beginning = [scanner scanLocation];
                    
                    // common case handling
                    if ([singleLineComment isEqualToString:@"//"]) {
                        if (beginning > 0 && [searchString characterAtIndex:beginning - 1] == ':') {
                            [scanner mgs_setScanLocation:beginning + 1];
                            continue; // To avoid http:// ftp:// file:// etc.
                        }
                    } else if ([singleLineComment isEqualToString:@"#"]) {
                        if (searchStringLength > 1) {
                            rangeOfLine = [searchString lineRangeForRange:NSMakeRange(beginning, 0)];
                            if ([searchString rangeOfString:@"#!" options:NSLiteralSearch range:rangeOfLine].location != NSNotFound) {
                                [scanner mgs_setScanLocation:NSMaxRange(rangeOfLine)];
                                continue; // Don't treat the line as a comment if it begins with #!
                            } else if (beginning > 0 && [searchString characterAtIndex:beginning - 1] == '$') {
                                [scanner mgs_setScanLocation:beginning + 1];
                                continue; // To avoid $#
                            } else if (beginning > 0 && [searchString characterAtIndex:beginning - 1] == '&') {
                                [scanner mgs_setScanLocation:beginning + 1];
                                continue; // To avoid &#
                            }
                        }
                    } else if ([singleLineComment isEqualToString:@"%"]) {
                        if (searchStringLength > 1) {
                            if (beginning > 0 && [searchString characterAtIndex:beginning - 1] == '\\') {
                                [scanner mgs_setScanLocation:beginning + 1];
                                continue; // To avoid \% in LaTex
                            }
                        }
                    } 
                    
                    // If the comment is within an already coloured string then disregard it
                    if (beginning + rangeLocation + searchSyntaxLength < completeStringLength) {
                        if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:beginning + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
                            [scanner mgs_setScanLocation:beginning + 1];
                            continue; 
                        }
                    }
                    
                    // this is a single line comment so we can scan to the end of the line
                    endOfLine = NSMaxRange([searchString lineRangeForRange:NSMakeRange(beginning, 0)]);
                    [scanner mgs_setScanLocation:endOfLine];
                    
                    // colour the comment
                    [self setColour:commentsColour range:NSMakeRange(beginning + rangeLocation, [scanner scanLocation] - beginning)];
                }
            }
		}
        
		//
		// Multi-line comments
        //
        for (NSArray *multiLineComment in self.multiLineComments) {
            
            NSString *beginMultiLineComment = [multiLineComment objectAtIndex:0];
            NSString *endMultiLineComment = [multiLineComment objectAtIndex:1];
            
            if (![beginMultiLineComment isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourComments] boolValue] == YES) {
            
                beginLocationInMultiLine = [completeString rangeOfString:beginMultiLineComment options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
                endLocationInMultiLine = [completeString rangeOfString:endMultiLineComment options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
                if (beginLocationInMultiLine == NSNotFound || (endLocationInMultiLine != NSNotFound && beginLocationInMultiLine < endLocationInMultiLine)) {
                    beginLocationInMultiLine = rangeLocation;
                }			
                [completeDocumentScanner mgs_setScanLocation:beginLocationInMultiLine];
                searchSyntaxLength = [endMultiLineComment length];
                
                while (![completeDocumentScanner isAtEnd]) {
                    searchRange = NSMakeRange(beginLocationInMultiLine, range.length);
                    if (NSMaxRange(searchRange) > completeStringLength) {
                        searchRange = NSMakeRange(beginLocationInMultiLine, completeStringLength - beginLocationInMultiLine);
                    }
                    beginning = [completeString rangeOfString:beginMultiLineComment options:NSLiteralSearch range:searchRange].location;
                    if (beginning == NSNotFound) {
                        break;
                    }
                    [completeDocumentScanner mgs_setScanLocation:beginning];
                    if (beginning + 1 < completeStringLength) {
                        if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:beginning effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
                            [completeDocumentScanner mgs_setScanLocation:beginning + 1];
                            beginLocationInMultiLine++;
                            continue; // If the comment is within a string disregard it
                        }
                    }
                    if (![completeDocumentScanner scanUpToString:endMultiLineComment intoString:nil] || [completeDocumentScanner scanLocation] >= completeStringLength) {
                        if (shouldOnlyColourTillTheEndOfLine) {
                            [completeDocumentScanner mgs_setScanLocation:NSMaxRange([completeString lineRangeForRange:NSMakeRange(beginning, 0)])];
                        } else {
                            [completeDocumentScanner mgs_setScanLocation:completeStringLength];
                        }
                        length = [completeDocumentScanner scanLocation] - beginning;
                    } else {
                        if ([completeDocumentScanner scanLocation] < completeStringLength)
                            [completeDocumentScanner mgs_setScanLocation:[completeDocumentScanner scanLocation] + searchSyntaxLength];
                        length = [completeDocumentScanner scanLocation] - beginning;
                        if ([endMultiLineComment isEqualToString:@"-->"]) {
                            [completeDocumentScanner scanUpToCharactersFromSet:self.letterCharacterSet intoString:nil]; // Search for the first letter after -->
                            if ([completeDocumentScanner scanLocation] + 6 < completeStringLength) {// Check if there's actually room for a </script>
                                if ([completeString rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:NSMakeRange([completeDocumentScanner scanLocation] - 2, 9)].location != NSNotFound || [completeString rangeOfString:@"</style>" options:NSCaseInsensitiveSearch range:NSMakeRange([completeDocumentScanner scanLocation] - 2, 8)].location != NSNotFound) {
                                    beginLocationInMultiLine = [completeDocumentScanner scanLocation];
                                    continue; // If the comment --> is followed by </script> or </style> it is probably not a real comment
                                }
                            }
                            [completeDocumentScanner mgs_setScanLocation:beginning + length]; // Reset the scanner position
                        }
                    }

                    [self setColour:commentsColour range:NSMakeRange(beginning, length)];

                    if ([completeDocumentScanner scanLocation] > maxRange) {
                        break;
                    }
                    beginLocationInMultiLine = [completeDocumentScanner scanLocation];
                }
            }
		}
        
		//
		// Second string, second pass
        //
		if (![self.secondString isEqualToString:@""] && [[SMLDefaults valueForKey:MGSFragariaPrefsColourStrings] boolValue] == YES) {
			@try {
				[secondStringMatcher reset];
			}
			@catch (NSException *exception) {
				return;
			}
			
			while ([secondStringMatcher findNext]) {
				foundRange = [secondStringMatcher rangeOfMatch];
				if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour] || [[firstLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:commentsColour]) {
					continue;
				}
				[self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
			}
		}

	}
	@catch (NSException *exception) {
		NSLog(@"Syntax colouring exception: %@", exception);
	}
	
}

/*
 
 - setColour:range:
 
 */
- (void)setColour:(NSDictionary *)colourDictionary range:(NSRange)range
{
	[firstLayoutManager setTemporaryAttributes:colourDictionary forCharacterRange:range];
}

/*
 
 - applyColourDefaults
 
 */
- (void)applyColourDefaults
{
	commandsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsCommandsColourWell]], NSForegroundColorAttributeName, nil];
	
	commentsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsCommentsColourWell]], NSForegroundColorAttributeName, nil];
	
	instructionsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsInstructionsColourWell]], NSForegroundColorAttributeName, nil];
	
	keywordsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsKeywordsColourWell]], NSForegroundColorAttributeName, nil];
	
	autocompleteWordsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteColourWell]], NSForegroundColorAttributeName, nil];
	
	stringsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsStringsColourWell]], NSForegroundColorAttributeName, nil];
	
	variablesColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsVariablesColourWell]], NSForegroundColorAttributeName, nil];
	
	attributesColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsAttributesColourWell]], NSForegroundColorAttributeName, nil];
	
	lineHighlightColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsHighlightLineColourWell]], NSBackgroundColorAttributeName, nil];
}

/*
 
 - highlightLineRange:
 
 */
- (void)highlightLineRange:(NSRange)lineRange
{
	if (lineRange.location == lastLineHighlightRange.location && lineRange.length == lastLineHighlightRange.length) {
		return;
	}
	
	[firstLayoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:lastLineHighlightRange];
		
	[self pageRecolour];
	
	[firstLayoutManager addTemporaryAttributes:lineHighlightColour forCharacterRange:lineRange];
	
	lastLineHighlightRange = lineRange;
}

#pragma mark -
#pragma mark Document delegate support

/*
 
 - performDocumentDelegateSelector:withObject:
 
 */
- (void)performDocumentDelegateSelector:(SEL)selector withObject:(id)object
{
	id delegate = [document valueForKey:MGSFODelegate]; 
	if (delegate && [delegate respondsToSelector:selector]) {
		[delegate performSelector:selector withObject:object];
	}
}


#pragma mark -
#pragma mark NSTextDelegate

/*
 
 - textDidChange:
 
 */
- (void)textDidChange:(NSNotification *)notification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:notification];

	if (reactToChanges == NO) {
		return;
	}
	NSString *completeString = [self completeString];
	
	if ([completeString length] < 2) {
		// MGS[SMLInterface updateStatusBar]; // One needs to call this from here as well because otherwise it won't update the status bar if one writes one character and deletes it in an empty document, because the textViewDidChangeSelection delegate method won't be called.
	}
	
	SMLTextView *textView = (SMLTextView *)[notification object];
	
	if ([[document valueForKey:MGSFOIsEdited] boolValue] == NO) {
		[document setValue:[NSNumber numberWithBool:YES] forKey:MGSFOIsEdited];
	}
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsHighlightCurrentLine] boolValue] == YES) {
		[self highlightLineRange:[completeString lineRangeForRange:[textView selectedRange]]];
	} else if ([[document valueForKey:@"isSyntaxColoured"] boolValue] == YES) {
		[self pageRecolourTextView:textView];
	}
	
	if (autocompleteWordsTimer != nil) {
		[autocompleteWordsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:[[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteAfterDelay] floatValue]]];
	} else if ([[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteSuggestAutomatically] boolValue] == YES) {
		autocompleteWordsTimer = [NSTimer scheduledTimerWithTimeInterval:[[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteAfterDelay] floatValue] target:self selector:@selector(autocompleteWordsTimerSelector:) userInfo:textView repeats:NO];
	}
	
	[[document valueForKey:@"lineNumbers"] updateLineNumbersCheckWidth:NO recolour:NO];
	
}
/*
 
 - textDidBeginEditing:
 
 */
- (void)textDidBeginEditing:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];
}

/*
 
 - textDidEndEditing:
 
 */
- (void)textDidEndEditing:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];
}

/*
 
 - textShouldBeginEditing:
 
 */
- (BOOL)textShouldBeginEditing:(NSText *)aTextObject
{
	id delegate = [document valueForKey:MGSFODelegate]; 
	if (delegate && [delegate respondsToSelector:@selector(textShouldBeginEditing:)]) {
		return [delegate textShouldBeginEditing:aTextObject];
	}
	
	return YES;
}

/*
 
 - textShouldEndEditing:
 
 */
- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
	id delegate = [document valueForKey:MGSFODelegate]; 
	if (delegate && [delegate respondsToSelector:@selector(textShouldEndEditing:)]) {
		return [delegate textShouldEndEditing:aTextObject];
	}
	
	return YES;
}

#pragma mark -
#pragma mark NSTextViewDelegate

/*
 
 It would cumbersome to route all NSTextViewDelegate messages to our delegate.
 
 A better solution would be to permit subclasses of this class to be made the text view delegate.
 
 */
/*
 
 - textViewDidChangeTypingAttributes:
 
 */
- (void)textViewDidChangeTypingAttributes:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];

}

/*
 
 - textViewDidChangeSelection:
 
 */
- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];

	if (reactToChanges == NO) {
		return;
	}
	
	NSString *completeString = [self completeString];

	NSUInteger completeStringLength = [completeString length];
	if (completeStringLength == 0) {
		return;
	}
	
	SMLTextView *textView = [aNotification object];
		
	NSRange editedRange = [textView selectedRange];
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsHighlightCurrentLine] boolValue] == YES) {
		[self highlightLineRange:[completeString lineRangeForRange:editedRange]];
	}
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsShowMatchingBraces] boolValue] == NO) {
		return;
	}

	
	NSUInteger cursorLocation = editedRange.location;
	NSInteger differenceBetweenLastAndPresent = cursorLocation - lastCursorLocation;
	lastCursorLocation = cursorLocation;
	if (differenceBetweenLastAndPresent != 1 && differenceBetweenLastAndPresent != -1) {
		return; // If the difference is more than one, they've moved the cursor with the mouse or it has been moved by resetSelectedRange below and we shouldn't check for matching braces then
	}
	
	if (differenceBetweenLastAndPresent == 1) { // Check if the cursor has moved forward
		cursorLocation--;
	}
	
	if (cursorLocation == completeStringLength) {
		return;
	}
	
	unichar characterToCheck = [completeString characterAtIndex:cursorLocation];
	NSInteger skipMatchingBrace = 0;
	
	if (characterToCheck == ')') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '(') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ')') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == ']') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '[') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ']') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '}') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '{') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '}') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '>') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '<') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '>') {
				skipMatchingBrace++;
			}
		}
	}
	
}

/*
 
 - textView:completions:forPartialWordRange:indexOfSelectedItem
 
 */
- (NSArray *)textView:theTextView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)idx
{
#pragma unused(idx)
	if ([self.keywordsAndAutocompleteWords count] == 0) {
		if ([[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteIncludeStandardWords] boolValue] == NO) {
			return [NSArray array];
		} else {
			return words;
		}
	}
	
	NSString *matchString = [[theTextView string] substringWithRange:charRange];
	NSMutableArray *finalWordsArray = [NSMutableArray arrayWithArray:self.keywordsAndAutocompleteWords];
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteIncludeStandardWords] boolValue]) {
		[finalWordsArray addObjectsFromArray:words];
	}
	
	NSMutableArray *matchArray = [NSMutableArray array];
	NSString *item;
	for (item in finalWordsArray) {
		if ([item rangeOfString:matchString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [item length])].location == 0) {
			[matchArray addObject:item];
		}
	}
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteIncludeStandardWords] boolValue]) { // If no standard words are added there's no need to sort it again as it has already been sorted
		return [matchArray sortedArrayUsingSelector:@selector(compare:)];
	} else {
		return matchArray;
	}
}

/*
 
 - undoManagerForTextView:
 
 */
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView
{
#pragma unused(aTextView)
	return undoManager;
}


#pragma mark -
#pragma mark Undo handling

/*
 
 - undoManagerDidUndo:
 
 */
- (void)undoManagerDidUndo:(NSNotification *)aNote
{
	NSUndoManager *theUndoManager = [aNote object];
	
	NSAssert([theUndoManager isKindOfClass:[NSUndoManager class]], @"bad notification object");
	
	if (![theUndoManager canUndo]) {
		
		// we can undo no more so we must be restored to unedited state
		[document setValue:[NSNumber numberWithBool:NO] forKey:MGSFOIsEdited];
		
		//should data be reloaded?
	}
}


#pragma mark -
#pragma mark NSTimer callbacks
/*
 
 - autocompleteWordsTimerSelector:
 
 */
- (void)autocompleteWordsTimerSelector:(NSTimer *)theTimer
{
	SMLTextView *textView = [theTimer userInfo];
	NSRange selectedRange = [textView selectedRange];
	NSString *completeString = [self completeString];
	NSUInteger stringLength = [completeString length];
	if (selectedRange.location <= stringLength && selectedRange.length == 0 && stringLength != 0) {
		if (selectedRange.location == stringLength) { // If we're at the very end of the document
			[textView complete:nil];
		} else {
			unichar characterAfterSelection = [completeString characterAtIndex:selectedRange.location];
			if ([[NSCharacterSet symbolCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet punctuationCharacterSet] characterIsMember:characterAfterSelection] || selectedRange.location == stringLength) { // Don't autocomplete if we're in the middle of a word
				[textView complete:nil];
			}
		}
	}
	
	if (autocompleteWordsTimer) {
		[autocompleteWordsTimer invalidate];
		autocompleteWordsTimer = nil;
	}
}


@end