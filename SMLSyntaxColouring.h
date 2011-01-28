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

#import <Cocoa/Cocoa.h>

@class SMLTextView;
@class SMLLayoutManager;
@class ICUPattern;
@class ICUMatcher;

@interface SMLSyntaxColouring : NSObject <NSTextStorageDelegate, NSTextViewDelegate> {
	
	id document;
	NSUndoManager *undoManager;
	
	SMLLayoutManager *firstLayoutManager, *secondLayoutManager, *thirdLayoutManager, *fourthLayoutManager;
	
	NSInteger lastCursorLocation;
	
	NSDictionary *commandsColour, *commentsColour, *instructionsColour, *keywordsColour, *autocompleteWordsColour, 
					*stringsColour, *variablesColour, *attributesColour, *lineHighlightColour;
	
	NSSet *keywords;
	NSSet *autocompleteWords;
	NSArray *keywordsAndAutocompleteWords;

	NSString *beginCommand;
	NSString *endCommand;
	NSString *beginInstruction;
	NSString *endInstruction;
	NSString *firstString;
	NSString *secondString;
	NSString *firstSingleLineComment, *secondSingleLineComment, *beginFirstMultiLineComment, *endFirstMultiLineComment, 
			*beginSecondMultiLineComment, *endSecondMultiLineComment, *functionDefinition, *removeFromFunction;
	NSString *searchString;

	unichar firstStringUnichar;
	unichar secondStringUnichar;

	BOOL reactToChanges;
	BOOL keywordsCaseSensitive;
	BOOL recolourKeywordIfAlreadyColoured;
	
	NSCharacterSet *attributesCharacterSet;
	NSCharacterSet *beginVariable;
	NSCharacterSet *endVariable;
	NSCharacterSet *letterCharacterSet, *keywordStartCharacterSet, *keywordEndCharacterSet;
	
	ICUPattern *firstStringPattern;
	ICUPattern *secondStringPattern;	
	ICUMatcher *firstStringMatcher;
	ICUMatcher *secondStringMatcher;
	
	NSTimer *liveUpdatePreviewTimer;
	NSTimer *autocompleteWordsTimer;

	NSRange lastLineHighlightRange;
}

@property BOOL reactToChanges;
@property (readonly) NSUndoManager *undoManager;

@property (copy) NSString *functionDefinition;
@property (copy) NSString *removeFromFunction;

@property (assign) SMLLayoutManager *secondLayoutManager;
@property (assign) SMLLayoutManager *thirdLayoutManager;
@property (assign) SMLLayoutManager *fourthLayoutManager;

- (id)initWithDocument:(id)document;
- (void)pageRecolourTextView:(SMLTextView *)textView;
- (void)pageRecolour;
- (void)applySyntaxDefinition;
- (void)pageRecolourTextView:(SMLTextView *)textView options:(NSDictionary *)options;

@end
