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

#import "MGSFragariaFramework.h"
#import "SMLLayoutManager.h"

@implementation SMLLayoutManager

@synthesize showInvisibleCharacters;

#pragma mark -
#pragma mark Instance methods
/*
 
 - init
 
 */
- (id)init
{
	if ((self = [super init])) {
		
		attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]], NSFontAttributeName, [NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsInvisibleCharactersColourWell]], NSForegroundColorAttributeName, nil];
		unichar tabUnichar = 0x00AC;
		tabCharacter = [[NSString alloc] initWithCharacters:&tabUnichar length:1];
		unichar newLineUnichar = 0x00B6;
		newLineCharacter = [[NSString alloc] initWithCharacters:&newLineUnichar length:1];
		spaceCharacter = @".";
        
		[self setShowInvisibleCharacters:[[SMLDefaults valueForKey:MGSFragariaPrefsShowInvisibleCharacters] boolValue]];
		[self setAllowsNonContiguousLayout:YES]; // Setting this to YES sometimes causes "an extra toolbar" and other graphical glitches to sometimes appear in the text view when one sets a temporary attribute, reported as ID #5832329 to Apple
		
		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        
        // text font and colour preferences
		[defaultsController addObserver:self forKeyPath:@"values.FragariaTextFont" options:NSKeyValueObservingOptionNew context:@"FontOrColourValueChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaInvisibleCharactersColourWell" options:NSKeyValueObservingOptionNew context:@"FontOrColourValueChanged"];
        
        // invisible characters preference
        [defaultsController addObserver:self forKeyPath:@"values.FragariaShowInvisibleCharacters" options:NSKeyValueObservingOptionNew context:@"InvisibleCharacterValueChanged"];

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
	if ([(NSString *)context isEqualToString:@"FontOrColourValueChanged"]) {
		attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]], NSFontAttributeName, [NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsInvisibleCharactersColourWell]], NSForegroundColorAttributeName, nil];
		[[self firstTextView] setNeedsDisplay:YES];
    } else if ([(NSString *)context isEqualToString:@"InvisibleCharacterValueChanged"]) {
        [self setShowInvisibleCharacters:[[SMLDefaults valueForKey:MGSFragariaPrefsShowInvisibleCharacters] boolValue]];
		[[self firstTextView] setNeedsDisplay:YES];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark -
#pragma mark Drawing
/*
 
 - drawGlyphsForGlyphRange:atPoint:
 
 */
- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)containerOrigin
{	
    if (showInvisibleCharacters) {
        
		NSPoint pointToDrawAt;
		NSRect glyphFragment;
		NSString *completeString = [[self textStorage] string];
		NSInteger lengthToRedraw = NSMaxRange(glyphRange);	
		
        NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:glyphRange.location effectiveRange:NULL];
        CGFloat padding = [textContainer lineFragmentPadding];
        
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        NSLog(@"Context isFlipped = % d", [context isFlipped]);
        
        NSFont *font = [attributes objectForKey:NSFontAttributeName];
        CGFloat baseLineOffset = [self defaultBaselineOffsetForFont:font];
        CGFloat lineHeight =[self defaultLineHeightForFont:font];
        NSLog(@"baseLineOffset = %f, lineHeight = %f", baseLineOffset, lineHeight);
        
		for (NSInteger idx = glyphRange.location; idx < lengthToRedraw; idx++) {
			unichar characterToCheck = [completeString characterAtIndex:idx];
            NSString *charString = nil;
            
			if (characterToCheck == '\t') {
				charString = tabCharacter;
			} else if (characterToCheck == ' ') {
				charString = spaceCharacter;
			} else if (characterToCheck == '\n' || characterToCheck == '\r') {
                charString = newLineCharacter;
			} else {
                continue;
            }
            
            pointToDrawAt = [self locationForGlyphAtIndex:idx];
            glyphFragment = [self lineFragmentRectForGlyphAtIndex:idx effectiveRange:NULL];
            
           // NSLog(@"pointToDrawAt x = %f, y = %f", pointToDrawAt.x, pointToDrawAt.y);
           // NSLog(@"glyphFragment x = %f, y = %f, width = %f, height = %f", glyphFragment.origin.x, glyphFragment.origin.y, glyphFragment.size.width, glyphFragment.size.height);
            
            pointToDrawAt.x += glyphFragment.origin.x;
            //pointToDrawAt.y = glyphFragment.origin.y - (glyphFragment.size.height - pointToDrawAt.y);
            pointToDrawAt.y = glyphFragment.origin.y;
            [charString drawAtPoint:pointToDrawAt withAttributes:attributes];
		}
    } 
	
    [super drawGlyphsForGlyphRange:glyphRange atPoint:containerOrigin];
}

#pragma mark -
#pragma mark Accessors


/*
 
 - attributedStringWithTemporaryAttributesApplied
 
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
	/*
	 
	 temporary attributes have been applied by the layout manager to
	 syntax colour the text.
	 
	 to retain these we duplicate the text and apply the temporary attributes as normal attributes
	 
	 */
	
	NSMutableAttributedString *attributedString = [[[self attributedString] mutableCopy] autorelease];
	NSInteger lastCharacter = [attributedString length];
	[self removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, lastCharacter)];
	
	NSInteger idx = 0;
	while (idx < lastCharacter) {
		NSRange range = NSMakeRange(0, 0);
		NSDictionary *tempAttributes = [self temporaryAttributesAtCharacterIndex:idx effectiveRange:&range];
		if ([tempAttributes count] != 0) {
			[attributedString setAttributes:tempAttributes range:range];
		}
		NSInteger rangeLength = range.length;
		if (rangeLength != 0) {
			idx = idx + rangeLength;
		} else {
			idx++;
		}
	}
	
	return attributedString;	
}

@end
