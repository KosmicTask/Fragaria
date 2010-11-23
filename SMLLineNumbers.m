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

#import "SMLStandardHeader.h"

#import "SMLLineNumbers.h"
#import "SMLSyntaxColouring.h"

@implementation SMLLineNumbers

#pragma mark -
#pragma mark Instance methods
/*
 
 - init
 
 */
- (id)init
{
	[self initWithDocument:nil];
	
	return self;
}


/*
 
 - initWithDocument:
 
 */
- (id)initWithDocument:(id)theDocument
{
	if ((self = [super init])) {
		
		document = theDocument;
		zeroPoint = NSMakePoint(0, 0);
		
		attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]], NSFontAttributeName, nil];
		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
		[defaultsController addObserver:self forKeyPath:@"values.TextFont" options:NSKeyValueObservingOptionNew context:@"TextFontChanged"];
	}
	
    return self;
}

#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(NSString *)context isEqualToString:@"TextFontChanged"]) {
		attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]], NSFontAttributeName, nil];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark -
#pragma mark View updating
/*
 
 - viewBoundsDidChange:
 
 */
- (void)viewBoundsDidChange:(NSNotification *)notification
{
	if (notification != nil && [notification object] != nil && [[notification object] isKindOfClass:[NSClipView class]]) {
		[self updateLineNumbersForClipView:[notification object] checkWidth:YES recolour:YES];
	}
}

/*
 
 - updateLineNumbersCheckWidth:recolour:
 
 */
- (void)updateLineNumbersCheckWidth:(BOOL)checkWidth recolour:(BOOL)recolour
{
	[self updateLineNumbersForClipView:[[document valueForKey:@"firstTextScrollView"] contentView] checkWidth:checkWidth recolour:recolour];

	if ([document valueForKey:@"secondTextScrollView"] != nil) {
		[self updateLineNumbersForClipView:[[document valueForKey:@"secondTextScrollView"] contentView] checkWidth:checkWidth recolour:recolour];
	}
	
	if ([document valueForKey:@"singleDocumentWindow"] != nil) {
		[self updateLineNumbersForClipView:[[document valueForKey:@"thirdTextScrollView"] contentView] checkWidth:checkWidth recolour:recolour];
	}
	
	if ([document valueForKey:@"fourthTextScrollView"] != nil) {
		[self updateLineNumbersForClipView:[[document valueForKey:@"fourthTextScrollView"] contentView] checkWidth:checkWidth recolour:recolour];
	}
}

/*
 
 - updateLineNumbersForClipView:checkWidth:recolour:
 
 */
- (void)updateLineNumbersForClipView:(NSClipView *)clipView checkWidth:(BOOL)checkWidth recolour:(BOOL)recolour
{
	SMLTextView *textView;
	NSScrollView *scrollView;
	NSScrollView *gutterScrollView;
	NSLayoutManager *layoutManager;
	NSRect visibleRect;
	NSRange visibleRange;
	NSString *textString;
	NSString *searchString;
	
	NSInteger idx;
	NSInteger lineNumber;
	
	NSInteger indexNonWrap;
	NSInteger maxRangeVisibleRange;
	NSInteger numberOfGlyphsInTextString;
	BOOL oneMoreTime;
	unichar lastGlyph;
	
	NSRange range;
	NSInteger widthOfStringInGutter;
	NSInteger gutterWidth;
	NSRect currentViewBounds;
	
	NSInteger currentLineHeight;
	
	CGFloat addToScrollPoint;
	
	if (updatingLineNumbersForClipView == clipView) {
		return;
	}
	updatingLineNumbersForClipView = clipView;
	
	textView = [clipView documentView];
	
	if ([[document valueForKey:@"showLineNumberGutter"] boolValue] == NO || textView == nil) {
		if (checkWidth == YES && recolour == YES) {
			[[document valueForKey:@"syntaxColouring"] pageRecolourTextView:textView];
		}
		goto allDone;
	}
	
	scrollView = (NSScrollView *)[clipView superview];
	addToScrollPoint = 0;	
	if (scrollView == [document valueForKey:@"firstTextScrollView"]) {
		gutterScrollView = [document valueForKey:@"firstGutterScrollView"];
	} else if (scrollView == [document valueForKey:@"secondTextScrollView"]) {
		gutterScrollView = [document valueForKey:@"secondGutterScrollView"];
		//addToScrollPoint = [[SMLCurrentProject secondContentViewNavigationBar] bounds].size.height;
	} else if (scrollView == [document valueForKey:@"thirdTextScrollView"]) {
		gutterScrollView = [document valueForKey:@"thirdGutterScrollView"];
	} else if (scrollView == [document valueForKey:@"fourthTextScrollView"]) {
		gutterScrollView = [document valueForKey:@"fourthGutterScrollView"];
	} else {
		goto allDone;
	}
	
	layoutManager = [textView layoutManager];
	visibleRect = [[scrollView contentView] documentVisibleRect];
	visibleRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
	textString = [textView string];
	searchString = [textString substringWithRange:NSMakeRange(0,visibleRange.location)];
	
	for (idx = 0, lineNumber = 0; idx < (NSInteger)visibleRange.location; lineNumber++) {
		idx = NSMaxRange([searchString lineRangeForRange:NSMakeRange(idx, 0)]);
	}
	
	indexNonWrap = [searchString lineRangeForRange:NSMakeRange(idx, 0)].location;
	maxRangeVisibleRange = NSMaxRange([textString lineRangeForRange:NSMakeRange(NSMaxRange(visibleRange), 0)]); // Set it to just after the last glyph on the last visible line 
	numberOfGlyphsInTextString = [layoutManager numberOfGlyphs];
	oneMoreTime = NO;
	if (numberOfGlyphsInTextString != 0) {
		lastGlyph = [textString characterAtIndex:numberOfGlyphsInTextString - 1];
		if (lastGlyph == '\n' || lastGlyph == '\r') {
			oneMoreTime = YES; // Continue one more time through the loop if the last glyph isn't newline
		}
	}
	NSMutableString *lineNumbersString = [[NSMutableString alloc] init];
	
	while (indexNonWrap <= maxRangeVisibleRange) {
		if (idx == indexNonWrap) {
			lineNumber++;
			[lineNumbersString appendFormat:@"%i\n", lineNumber];
		} else {
			[lineNumbersString appendFormat:@"%C\n", 0x00B7];
			indexNonWrap = idx;
		}
		
		if (idx < maxRangeVisibleRange) {
			[layoutManager lineFragmentRectForGlyphAtIndex:idx effectiveRange:&range];
			idx = NSMaxRange(range);
			indexNonWrap = NSMaxRange([textString lineRangeForRange:NSMakeRange(indexNonWrap, 0)]);
		} else {
			idx++;
			indexNonWrap ++;
		}
		
		if (idx == numberOfGlyphsInTextString && !oneMoreTime) {
			break;
		}
	}
	
	if (checkWidth == YES) {
		widthOfStringInGutter = [lineNumbersString sizeWithAttributes:attributes].width;
		
		if (widthOfStringInGutter > ([[document valueForKey:@"gutterWidth"] integerValue] - 14)) { // Check if the gutterTextView has to be resized
			[document setValue:[NSNumber numberWithInteger:widthOfStringInGutter + 20] forKey:@"gutterWidth"]; // Make it bigger than need be so it doesn't have to resized soon again
			if ([[document valueForKey:@"showLineNumberGutter"] boolValue] == YES) {
				gutterWidth = [[document valueForKey:@"gutterWidth"] integerValue];
			} else {
				gutterWidth = 0;
			}
			currentViewBounds = [[gutterScrollView superview] bounds];
			[scrollView setFrame:NSMakeRect(gutterWidth, 0, currentViewBounds.size.width - gutterWidth, currentViewBounds.size.height)];
			
			[gutterScrollView setFrame:NSMakeRect(0, 0, [[document valueForKey:@"gutterWidth"] integerValue], currentViewBounds.size.height)];
		}
	}
	
	if (recolour == YES) {
		[[document valueForKey:@"syntaxColouring"] pageRecolourTextView:textView];
	}
	
	[[gutterScrollView documentView] setString:lineNumbersString];
	
	[[gutterScrollView contentView] setBoundsOrigin:zeroPoint]; // To avert an occasional bug which makes the line numbers disappear
	currentLineHeight = (NSInteger)[textView lineHeight];
	if ((NSInteger)visibleRect.origin.y != 0 && currentLineHeight != 0) {
		[[gutterScrollView contentView] scrollToPoint:NSMakePoint(0, ((NSInteger)visibleRect.origin.y % currentLineHeight) + addToScrollPoint)]; // Move currentGutterScrollView so it aligns with the rows in currentTextView
	}
	
allDone:
	
	updatingLineNumbersForClipView = nil;
}
@end
