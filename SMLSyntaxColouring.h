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
	
	SMLLayoutManager *firstLayoutManager, *secondLayoutManager, *thirdLayoutManager, *fourthLayoutManager;
	
	NSInteger lastCursorLocation;
	
	NSDictionary *commandsColour, *commentsColour, *instructionsColour, *keywordsColour, *autocompleteWordsColour, 
					*stringsColour, *variablesColour, *attributesColour, *lineHighlightColour, *numbersColour, * constantsColour, *classColour;
	
    
	unichar firstStringUnichar;
	unichar secondStringUnichar;

	BOOL reactToChanges;
	BOOL keywordsCaseSensitive;
	BOOL recolourKeywordIfAlreadyColoured;
	BOOL syntaxErrorsAreDirty;
	
	ICUPattern *firstStringPattern;
	ICUPattern *secondStringPattern;	
	ICUMatcher *firstStringMatcher;
	ICUMatcher *secondStringMatcher;
	
	NSTimer *liveUpdatePreviewTimer;
	NSTimer *autocompleteWordsTimer;

	NSRange lastLineHighlightRange;
}

@property BOOL reactToChanges;
@property (retain) NSUndoManager *undoManager;


@property (retain) SMLLayoutManager *secondLayoutManager;
@property (retain) SMLLayoutManager *thirdLayoutManager;
@property (retain) SMLLayoutManager *fourthLayoutManager;

@property (retain) 	NSCharacterSet *attributesCharacterSet;
@property (retain) 	NSCharacterSet *beginVariable;
@property (retain) 	NSCharacterSet *endVariable;
@property (retain) 	NSCharacterSet *letterCharacterSet;
@property (retain) 	NSCharacterSet *keywordStartCharacterSet;
@property (retain) 	NSCharacterSet *keywordEndCharacterSet;
@property (retain) 	NSCharacterSet *numberCharacterStartSet;
@property (retain) 	NSCharacterSet *numberCharacterEndSet;

@property (copy) NSString *beginCommand;
@property (copy) NSString *endCommand;
@property (copy) NSString *beginInstruction;
@property (copy) NSString *endInstruction;
@property (copy) NSString *firstString;
@property (copy) NSString *secondString;
@property (copy) NSString *firstSingleLineComment;
@property (copy) NSString *secondSingleLineComment;
@property (copy) NSString *beginFirstMultiLineComment;
@property (copy) NSString *endFirstMultiLineComment;
@property (copy) NSString *beginSecondMultiLineComment;
@property (copy) NSString *endSecondMultiLineComment;
@property (copy) NSString *functionDefinition;
@property (copy) NSString *removeFromFunction;
@property (copy) NSString *searchString;

@property (retain) NSMutableArray *singleLineComments;
@property (retain) NSMutableArray *multiLineComments;

@property (retain) NSArray* keywordsAndAutocompleteWords;
@property (retain) NSSet *keywords;
@property (retain) NSSet *autocompleteWords;
@property (retain) NSArray* syntaxErrors;

- (id)initWithDocument:(id)document;
- (void)pageRecolourTextView:(SMLTextView *)textView;
- (void)pageRecolour;
- (void)applySyntaxDefinition;
- (void)pageRecolourTextView:(SMLTextView *)textView options:(NSDictionary *)options;

@end
