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
@interface SMLTextView()
- (void)windowDidBecomeMainOrKey:(NSNotification *)note;
@end

@implementation SMLTextView

@synthesize colouredIBeamCursor, fragaria;

#pragma mark -
#pragma mark Instance methods
/*
 
 - initWithFrame:
 
 */
- (id)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		SMLLayoutManager *layoutManager = [[[SMLLayoutManager alloc] init] autorelease];
		[[self textContainer] replaceLayoutManager:layoutManager];
		
		[self setDefaults];	
	}
	return self;
}


#pragma mark -
#pragma mark Accessors
/*
 
 - lineHeight
 
 */
- (NSInteger)lineHeight
{
    return lineHeight;
}


/*
 
 - setDefaults
 
 */
- (void)setDefaults
{

	[self setTabWidth];
	
	[self setVerticallyResizable:YES];
	[self setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[self setAutoresizingMask:NSViewWidthSizable];
	[self setAllowsUndo:YES];
	[self setUsesFindPanel:YES];
	[self setAllowsDocumentBackgroundColorChange:NO];
	[self setRichText:NO];
	[self setImportsGraphics:NO];
	[self setUsesFontPanel:NO];
	
	[self setContinuousSpellCheckingEnabled:[[SMLDefaults valueForKey:@"AutoSpellCheck"] boolValue]];
	[self setGrammarCheckingEnabled:[[SMLDefaults valueForKey:@"AutoGrammarCheck"] boolValue]];
	
	[self setSmartInsertDeleteEnabled:[[SMLDefaults valueForKey:@"SmartInsertDelete"] boolValue]];
	[self setAutomaticLinkDetectionEnabled:[[SMLDefaults valueForKey:@"AutomaticLinkDetection"] boolValue]];
	[self setAutomaticQuoteSubstitutionEnabled:[[SMLDefaults valueForKey:@"AutomaticQuoteSubstitution"] boolValue]];
	
	[self setTextDefaults];
	
	[self setAutomaticDataDetectionEnabled:YES];
	[self setAutomaticTextReplacementEnabled:YES];
	
	[self setPageGuideValues];
	
	[self updateIBeamCursor];	
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame] options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveWhenFirstResponder) owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	[trackingArea autorelease];
    
	NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	[defaultsController addObserver:self forKeyPath:@"values.TextFont" options:NSKeyValueObservingOptionNew context:@"TextFontChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.TextColourWell" options:NSKeyValueObservingOptionNew context:@"TextColourChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.BackgroundColourWell" options:NSKeyValueObservingOptionNew context:@"BackgroundColourChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.SmartInsertDelete" options:NSKeyValueObservingOptionNew context:@"SmartInsertDeleteChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.TabWidth" options:NSKeyValueObservingOptionNew context:@"TabWidthChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.ShowPageGuide" options:NSKeyValueObservingOptionNew context:@"PageGuideChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.ShowPageGuideAtColumn" options:NSKeyValueObservingOptionNew context:@"PageGuideChanged"];
	[defaultsController addObserver:self forKeyPath:@"values.SmartInsertDelete" options:NSKeyValueObservingOptionNew context:@"SmartInsertDeleteChanged"];
	
	lineHeight = [[[self textContainer] layoutManager] defaultLineHeightForFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
}

/*
 
 - setTextDefaults
 
 */
- (void)setTextDefaults
{
	[self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
	[self setTextColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]]];
	[self setInsertionPointColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]]];
	[self setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"BackgroundColourWell"]]];
}

/*
 
 - setFrame:
 
 */
- (void)setFrame:(NSRect)rect
{
	[super setFrame:rect];
	[[fragaria objectForKey:ro_MGSFOLineNumbers] updateLineNumbersForClipView:[[self enclosingScrollView] contentView] checkWidth:NO recolour:YES];
	
}

/*
 - setString:
 */
- (void)setString:(NSString *)aString
{
	[super setString:aString];
	[[fragaria objectForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
}

/*
 - appendString:
 */
- (void)appendString:(NSString *)aString
{
    NSMutableString * string = [NSMutableString stringWithString:[super string]];
    [string appendString:aString];
    [self setString:string];
}

#pragma mark -
#pragma mark KVO

/*
 
 - observeValueForKeyPath:ofObject:change:context:
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(NSString *)context isEqualToString:@"TextFontChanged"]) {
		[self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
		lineHeight = [[[self textContainer] layoutManager] defaultLineHeightForFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
		[[fragaria objectForKey:ro_MGSFOLineNumbers] updateLineNumbersForClipView:[[self enclosingScrollView] contentView] checkWidth:NO recolour:YES];
		[self setPageGuideValues];
	} else if ([(NSString *)context isEqualToString:@"TextColourChanged"]) {
		[self setTextColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]]];
		[self setInsertionPointColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]]];
		[self setPageGuideValues];
		[self updateIBeamCursor];
	} else if ([(NSString *)context isEqualToString:@"BackgroundColourChanged"]) {
		[self setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"BackgroundColourWell"]]];
	} else if ([(NSString *)context isEqualToString:@"SmartInsertDeleteChanged"]) {
		[self setSmartInsertDeleteEnabled:[[SMLDefaults valueForKey:@"SmartInsertDelete"] boolValue]];
	} else if ([(NSString *)context isEqualToString:@"TabWidthChanged"]) {
		[self setTabWidth];
	} else if ([(NSString *)context isEqualToString:@"PageGuideChanged"]) {
		[self setPageGuideValues];
	} else if ([(NSString *)context isEqualToString:@"SmartInsertDeleteChanged"]) {
		[self setSmartInsertDeleteEnabled:[[SMLDefaults valueForKey:@"SmartInsertDelete"] boolValue]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark -
#pragma mark Drawing
/*
 
 - isOpaque
 
 */
- (BOOL)isOpaque
{
	return YES;
}

/*
 
 - drawRect:
 
 */
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if (showPageGuide == YES) {
		NSRect bounds = [self bounds]; 
		if ([self needsToDrawRect:NSMakeRect(pageGuideX, 0, 1, bounds.size.height)] == YES) { // So that it doesn't draw the line if only e.g. the cursor updates
			[pageGuideColour set];
			[NSBezierPath strokeRect:NSMakeRect(pageGuideX, 0, 0, bounds.size.height)];
		}
	}
}

#pragma mark -
#pragma mark Mouse event handling
/*
 
 - mouseDown:
 
 */
- (void)mouseDown:(NSEvent *)theEvent
{
	if (([theEvent modifierFlags] & NSAlternateKeyMask) && ([theEvent modifierFlags] & NSCommandKeyMask)) { // If the option and command keys are pressed, change the cursor to grab-cursor
		startPoint = [theEvent locationInWindow];
		startOrigin = [[[self enclosingScrollView] contentView] documentVisibleRect].origin;
		[[self enclosingScrollView] setDocumentCursor:[NSCursor openHandCursor]];
	} else {
		[super mouseDown:theEvent];
	}
}


/*
 
 - mouseDragged:
 
 */
- (void)mouseDragged:(NSEvent *)theEvent
{
    if ([[NSCursor currentCursor] isEqual:[NSCursor openHandCursor]]) {
		[self scrollPoint:NSMakePoint(startOrigin.x - ([theEvent locationInWindow].x - startPoint.x) * 3, startOrigin.y + ([theEvent locationInWindow].y - startPoint.y) * 3)];
	} else {
		[super mouseDragged:theEvent];
	}
}

/*
 
 - mouseUp:
 
 */
- (void)mouseUp:(NSEvent *)theEvent
{
#pragma unused(theEvent)
	[[self enclosingScrollView] setDocumentCursor:[NSCursor IBeamCursor]];
}

/*
 
 - mouseMoved:
 
 */
- (void)mouseMoved:(NSEvent *)theEvent
{
#pragma unused(theEvent)
	if ([NSCursor currentCursor] == [NSCursor IBeamCursor]) {
		[colouredIBeamCursor set];
	}
}

/*
 
 - menuForEvent:
 
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	
	NSMenu *menu = [super menuForEvent:theEvent];
	
	return menu;
	
	// TODO: consider what menu behaviour is appropriate
	/*
	 NSArray *array = [menu itemArray];
	 for (id oldMenuItem in array) {
	 if ([oldMenuItem tag] == -123457) {
	 [menu removeItem:oldMenuItem];
	 }		
	 }
	 
	 [menu insertItem:[NSMenuItem separatorItem] atIndex:0];
	 
	 NSEnumerator *collectionEnumerator = [[SMLBasic fetchAll:@"SnippetCollectionSortKeyName"] reverseObjectEnumerator];
	 for (id collection in collectionEnumerator) {
	 if ([collection valueForKey:@"name"] == nil) {
	 continue;
	 }
	 NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[collection valueForKey:@"name"] action:nil keyEquivalent:@""];
	 [menuItem setTag:-123457];
	 NSMenu *subMenu = [[NSMenu alloc] init];
	 
	 NSMutableArray *array = [NSMutableArray arrayWithArray:[[collection mutableSetValueForKey:@"snippets"] allObjects]];
	 [array sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	 for (id snippet in array) {
	 if ([snippet valueForKey:@"name"] == nil) {
	 continue;
	 }
	 NSString *keyString;
	 if ([snippet valueForKey:@"shortcutMenuItemKeyString"] != nil) {
	 keyString = [snippet valueForKey:@"shortcutMenuItemKeyString"];
	 } else {
	 keyString = @"";
	 }
	 NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:[snippet valueForKey:@"name"] action:@selector(snippetShortcutFired:) keyEquivalent:@""];
	 [subMenuItem setTarget:[SMLToolsMenuController sharedInstance]];			
	 [subMenuItem setRepresentedObject:snippet];
	 [subMenu insertItem:subMenuItem atIndex:0];
	 }
	 
	 [menuItem setSubmenu:subMenu];
	 [menu insertItem:menuItem atIndex:0];
	 }
	 
	 return menu;
	 */
}

#pragma mark -
#pragma mark Tab and page guide handling
/*
 
 - insertTab:
 
 */
- (void)insertTab:(id)sender
{	
	BOOL shouldShiftText = NO;
	
	if ([self selectedRange].length > 0) { // Check to see if the selection is in the text or if it's at the beginning of a line or in whitespace; if one doesn't do this one shifts the line if there's only one suggestion in the auto-complete
		NSRange rangeOfFirstLine = [[self string] lineRangeForRange:NSMakeRange([self selectedRange].location, 0)];
		NSUInteger firstCharacterOfFirstLine = rangeOfFirstLine.location;
		while ([[self string] characterAtIndex:firstCharacterOfFirstLine] == ' ' || [[self string] characterAtIndex:firstCharacterOfFirstLine] == '\t') {
			firstCharacterOfFirstLine++;
		}
		if ([self selectedRange].location <= firstCharacterOfFirstLine) {
			shouldShiftText = YES;
		}
	}
	
	if (shouldShiftText) {
		[[MGSTextMenuController sharedInstance] shiftRightAction:nil];
	} else if ([[SMLDefaults valueForKey:@"IndentWithSpaces"] boolValue] == YES) {
		NSMutableString *spacesString = [NSMutableString string];
		NSInteger numberOfSpacesPerTab = [[SMLDefaults valueForKey:@"TabWidth"] integerValue];
		if ([[SMLDefaults valueForKey:@"UseTabStops"] boolValue] == YES) {
			NSInteger locationOnLine = [self selectedRange].location - [[self string] lineRangeForRange:[self selectedRange]].location;
			if (numberOfSpacesPerTab != 0) {
				NSInteger numberOfSpacesLess = locationOnLine % numberOfSpacesPerTab;
				numberOfSpacesPerTab = numberOfSpacesPerTab - numberOfSpacesLess;
			}
		}
		while (numberOfSpacesPerTab--) {
			[spacesString appendString:@" "];
		}
		
		[self insertText:spacesString];
	} else if ([self selectedRange].length > 0) { // If there's only one word matching in auto-complete there's no list but just the rest of the word inserted and selected; and if you do a normal tab then the text is removed so this will put the cursor at the end of that word
		[self setSelectedRange:NSMakeRange(NSMaxRange([self selectedRange]), 0)];
	} else {
		[super insertTab:sender];
	}
}

/*
 
 - setTabWidth
 
 */
- (void)setTabWidth
{
	// Set the width of every tab by first checking the size of the tab in spaces in the current font and then remove all tabs that sets automatically and then set the default tab stop distance
	NSMutableString *sizeString = [NSMutableString string];
	NSInteger numberOfSpaces = [[SMLDefaults valueForKey:@"TabWidth"] integerValue];
	while (numberOfSpaces--) {
		[sizeString appendString:@" "];
	}
	NSDictionary *sizeAttribute = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]], NSFontAttributeName, nil] autorelease];
	CGFloat sizeOfTab = [sizeString sizeWithAttributes:sizeAttribute].width;
	
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	
	NSArray *array = [style tabStops];
	for (id item in array) {
		[style removeTabStop:item];
	}
	[style setDefaultTabInterval:sizeOfTab];
	NSDictionary *attributes = [[[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil] autorelease];
	[self setTypingAttributes:attributes];
}

/*
 
 - setPageGuideValues
 
 */
- (void)setPageGuideValues
{
	NSDictionary *sizeAttribute = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]], NSFontAttributeName, nil] autorelease];
	NSString *sizeString = @" ";
	CGFloat sizeOfCharacter = [sizeString sizeWithAttributes:sizeAttribute].width;
	pageGuideX = (sizeOfCharacter * ([[SMLDefaults valueForKey:@"ShowPageGuideAtColumn"] integerValue] + 1)) - 1.5f; // -1.5 to put it between the two characters and draw only on one pixel and not two (as the system draws it in a special way), and that's also why the width above is set to zero 
	
	NSColor *color = [NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]];
	pageGuideColour = [color colorWithAlphaComponent:([color alphaComponent] / 4)]; // Use the same colour as the text but with more transparency
	
	showPageGuide = [[SMLDefaults valueForKey:@"ShowPageGuide"] boolValue];
	
	[self display]; // To reflect the new values in the view
}

#pragma mark -
#pragma mark Text handling
/*
 
 - insertText:
 
 */
- (void)insertText:(NSString *)aString
{
	if ([aString isEqualToString:@"}"] && [[SMLDefaults valueForKey:@"IndentNewLinesAutomatically"] boolValue] == YES && [[SMLDefaults valueForKey:@"AutomaticallyIndentBraces"] boolValue] == YES) {
		unichar characterToCheck;
		NSInteger location = [self selectedRange].location;
		NSString *completeString = [self string];
		NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
		NSRange currentLineRange = [completeString lineRangeForRange:NSMakeRange([self selectedRange].location, 0)];
		NSInteger lineLocation = location;
		NSInteger lineStart = currentLineRange.location;
		while (--lineLocation >= lineStart) { // If there are any characters before } on the line skip indenting
			if ([whitespaceCharacterSet characterIsMember:[completeString characterAtIndex:lineLocation]]) {
				continue;
			}
			[super insertText:aString];
			return;
		}
		
		BOOL hasInsertedBrace = NO;
		NSUInteger skipMatchingBrace = 0;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '{') {
				if (skipMatchingBrace == 0) { // If we have found the opening brace check first how much space is in front of that line so the same amount can be inserted in front of the new line
					NSString *openingBraceLineWhitespaceString;
					NSScanner *openingLineScanner = [[[NSScanner alloc] initWithString:[completeString substringWithRange:[completeString lineRangeForRange:NSMakeRange(location, 0)]]] autorelease];
					[openingLineScanner setCharactersToBeSkipped:nil];
					BOOL foundOpeningBraceWhitespace = [openingLineScanner scanCharactersFromSet:whitespaceCharacterSet intoString:&openingBraceLineWhitespaceString];
					
					if (foundOpeningBraceWhitespace == YES) {
						NSMutableString *newLineString = [NSMutableString stringWithString:openingBraceLineWhitespaceString];
						[newLineString appendString:@"}"];
						[newLineString appendString:[completeString substringWithRange:NSMakeRange([self selectedRange].location, NSMaxRange(currentLineRange) - [self selectedRange].location)]];
						if ([self shouldChangeTextInRange:currentLineRange replacementString:newLineString]) {
							[self replaceCharactersInRange:currentLineRange withString:newLineString];
							[self didChangeText];
						}
						hasInsertedBrace = YES;
						[self setSelectedRange:NSMakeRange(currentLineRange.location + [openingBraceLineWhitespaceString length] + 1, 0)]; // +1 because we have inserted a character
					} else {
						NSString *restOfLineString = [completeString substringWithRange:NSMakeRange([self selectedRange].location, NSMaxRange(currentLineRange) - [self selectedRange].location)];
						if ([restOfLineString length] != 0) { // To fix a bug where text after the } can be deleted
							NSMutableString *replaceString = [NSMutableString stringWithString:@"}"];
							[replaceString appendString:restOfLineString];
							hasInsertedBrace = YES;
							NSInteger lengthOfWhiteSpace = 0;
							if (foundOpeningBraceWhitespace == YES) {
								lengthOfWhiteSpace = [openingBraceLineWhitespaceString length];
							}
							if ([self shouldChangeTextInRange:currentLineRange replacementString:replaceString]) {
								[self replaceCharactersInRange:[completeString lineRangeForRange:currentLineRange] withString:replaceString];
								[self didChangeText];
							}
							[self setSelectedRange:NSMakeRange(currentLineRange.location + lengthOfWhiteSpace + 1, 0)]; // +1 because we have inserted a character
						} else {
							[self replaceCharactersInRange:[completeString lineRangeForRange:currentLineRange] withString:@""]; // Remove whitespace before }
						}
				
					}
					break;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '}') {
				skipMatchingBrace++;
			}
		}
		if (hasInsertedBrace == NO) {
			[super insertText:aString];
		}
	} else if ([aString isEqualToString:@"("] && [[SMLDefaults valueForKey:@"AutoInsertAClosingParenthesis"] boolValue] == YES) {
		[super insertText:aString];
		NSRange selectedRange = [self selectedRange];
		if ([self shouldChangeTextInRange:selectedRange replacementString:@")"]) {
			[self replaceCharactersInRange:selectedRange withString:@")"];
			[self didChangeText];
			[self setSelectedRange:NSMakeRange(selectedRange.location - 0, 0)];
		}
	} else if ([aString isEqualToString:@"{"] && [[SMLDefaults valueForKey:@"AutoInsertAClosingBrace"] boolValue] == YES) {
		[super insertText:aString];
		NSRange selectedRange = [self selectedRange];
		if ([self shouldChangeTextInRange:selectedRange replacementString:@"}"]) {
			[self replaceCharactersInRange:selectedRange withString:@"}"];
			[self didChangeText];
			[self setSelectedRange:NSMakeRange(selectedRange.location - 0, 0)];
		}
	} else {
		[super insertText:aString];
	}
}

/*
 
 - insertNewline:
 
 */
- (void)insertNewline:(id)sender
{
	[super insertNewline:sender];
	
	// If we should indent automatically, check the previous line and scan all the whitespace at the beginning of the line into a string and insert that string into the new line
	NSString *lastLineString = [[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]];
	if ([[SMLDefaults valueForKey:@"IndentNewLinesAutomatically"] boolValue] == YES) {
		NSString *previousLineWhitespaceString;
		NSScanner *previousLineScanner = [[[NSScanner alloc] initWithString:[[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]]] autorelease];
		[previousLineScanner setCharactersToBeSkipped:nil];		
		if ([previousLineScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&previousLineWhitespaceString]) {
			[self insertText:previousLineWhitespaceString];
		}
		
		if ([[SMLDefaults valueForKey:@"AutomaticallyIndentBraces"] boolValue] == YES) {
			NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			NSInteger idx = [lastLineString length];
			while (idx--) {
				if ([characterSet characterIsMember:[lastLineString characterAtIndex:idx]]) {
					continue;
				}
				if ([lastLineString characterAtIndex:idx] == '{') {
					[self insertTab:nil];
				}
				break;
			}
		}
	}
}

/*
 
 - setString:options:
 
 */
- (void)setString:(NSString *)text options:(NSDictionary *)options
{
	BOOL undo = [[options objectForKey:@"undo"] boolValue];
	
	if ([self isEditable] && undo) {
		
		/*
		 
		 see http://www.cocoabuilder.com/archive/cocoa/179875-exponent-action-in-nstextview-subclass.html
		 entitled: Re: "exponent" action in NSTextView subclass (SOLVED)
		 
		 This details how to make programatic changes to the textStorage object.
		 
		 */
		NSTextStorage *textStorage = [self textStorage];
		NSRange all = NSMakeRange(0, [textStorage length]);
        BOOL textIsEmpty = ([textStorage length] == 0 ? YES : NO);

		if ([self shouldChangeTextInRange:all replacementString:text]) {
			[textStorage beginEditing];
			[textStorage replaceCharactersInRange:all withString:text];
			[textStorage endEditing];
            
            // reset the default font if text was empty as the font gets reset to system default.
            if (textIsEmpty) {
                [self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
            }

			[self didChangeText];
            
			NSUndoManager *undoManager = [self undoManager];
			
			// TODO: this doesn't seem to be having the desired effect
			[undoManager setActionName:NSLocalizedString(@"Content Change", @"undo content change")];
			
		}
	} else {
		[self setString:text];
	}
	
}

#pragma mark -
#pragma mark Selection handling
/*
 
 - selectionRangeForProposedRange:granularity:
 
 */
- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity
{
	// If it's not a mouse event return unchanged
	NSEventType eventType = [[NSApp currentEvent] type];
	if (eventType != NSLeftMouseDown && eventType != NSLeftMouseUp) {
		return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
	}
	
	if (granularity != NSSelectByWord || [[self string] length] == proposedSelRange.location || [[NSApp currentEvent] clickCount] != 2) { // If it's not a double-click return unchanged
		return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
	}
	
	NSUInteger location = [super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByCharacter].location;
	NSInteger originalLocation = location;
	
	NSString *completeString = [self string];
	unichar characterToCheck = [completeString characterAtIndex:location];
	NSInteger skipMatchingBrace = 0;
	NSUInteger lengthOfString = [completeString length];
	if (lengthOfString == proposedSelRange.location) { // To avoid crash if a double-click occurs after any text
		return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
	}
	
	BOOL triedToMatchBrace = NO;
	
	if (characterToCheck == ')') {
		triedToMatchBrace = YES;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '(') {
				if (!skipMatchingBrace) {
					return NSMakeRange(location, originalLocation - location + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ')') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '}') {
		triedToMatchBrace = YES;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '{') {
				if (!skipMatchingBrace) {
					return NSMakeRange(location, originalLocation - location + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '}') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == ']') {
		triedToMatchBrace = YES;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '[') {
				if (!skipMatchingBrace) {
					return NSMakeRange(location, originalLocation - location + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ']') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '>') {
		triedToMatchBrace = YES;
		while (location--) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '<') {
				if (!skipMatchingBrace) {
					return NSMakeRange(location, originalLocation - location + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '>') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '(') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == ')') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '(') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '{') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '}') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '{') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '[') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == ']') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '[') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '<') {
		triedToMatchBrace = YES;
		while (++location < lengthOfString) {
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '>') {
				if (!skipMatchingBrace) {
					return NSMakeRange(originalLocation, location - originalLocation + 1);
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '<') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	}
	
	// If it has a found a "starting" brace but not found a match, a double-click should only select the "starting" brace and not what it usually would select at a double-click
	if (triedToMatchBrace) {
		return [super selectionRangeForProposedRange:NSMakeRange(proposedSelRange.location, 1) granularity:NSSelectByCharacter];
	} else {
		
		NSInteger startLocation = originalLocation;
		NSInteger stopLocation = originalLocation;
		NSInteger minLocation = [super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByWord].location;
		NSInteger maxLocation = NSMaxRange([super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByWord]);
		
		BOOL hasFoundSomething = NO;
		while (--startLocation >= minLocation) {
			if ([completeString characterAtIndex:startLocation] == '.' || [completeString characterAtIndex:startLocation] == ':') {
				hasFoundSomething = YES;
				break;
			}
		}
		
		while (++stopLocation < maxLocation) {
			if ([completeString characterAtIndex:stopLocation] == '.' || [completeString characterAtIndex:stopLocation] == ':') {
				hasFoundSomething = YES;
				break;
			}
		}
		
		if (hasFoundSomething == YES) {
			return NSMakeRange(startLocation + 1, stopLocation - startLocation - 1);
		} else {
			return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
		}
	}
}


#pragma mark -
#pragma mark Persistence
/*
 
 - save:
 
 */
- (IBAction)save:(id)sender
{
#pragma unused(sender)
	// no implicit save functionality
}

#pragma mark -
#pragma mark Cursor handling
/*
 
 - updateIBeamCursor:
 
 */
- (void)updateIBeamCursor
{
	NSColor *textColour = [[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]] colorUsingColorSpaceName:NSCalibratedWhiteColorSpace];
	
	if (textColour != nil && [textColour whiteComponent] < 0.01 && [textColour alphaComponent] > 0.990) { // Keep the original cursor if it's black
		[self setColouredIBeamCursor:[NSCursor IBeamCursor]];
	} else {
		NSImage *cursorImage = [[NSCursor IBeamCursor] image];
		[cursorImage lockFocus];
		[(NSColor *)[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]] set];
		NSRectFillUsingOperation(NSMakeRect(0, 0, [cursorImage size].width, [cursorImage size].height), NSCompositeSourceAtop);
		[cursorImage unlockFocus];
        NSCursor *cursor = [[[NSCursor alloc] initWithImage:cursorImage hotSpot:[[NSCursor IBeamCursor] hotSpot]] autorelease];
		[self setColouredIBeamCursor:cursor];
	}
}

/*
 
 - cursorUpdate:
 
 */
- (void)cursorUpdate:(NSEvent *)event
{
#pragma unused(event)
	[colouredIBeamCursor set];
}
	
#pragma mark -
#pragma mark Find
/*
 
 - performFindPanelAction:
 
 */
- (void)performFindPanelAction:(id)sender
{
	[super performFindPanelAction:sender];
}


#pragma mark -
#pragma mark NSView

/*
 
 - viewWillMoveToWindow:
 
 */
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	[super viewWillMoveToWindow:newWindow];
}

/*
 
 - viewDidMoveToWindow
 
 */
- (void)viewDidMoveToWindow
{
	if ([self window]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMainOrKey:) name:NSWindowDidBecomeKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMainOrKey:) name:NSWindowDidBecomeMainNotification object:[self window]];
	}
	
	[super viewDidMoveToWindow];
}

/*
 
 - becomeFirstResponder
 
 */
- (BOOL)becomeFirstResponder
{
	[MGSFragaria setCurrentInstance:self.fragaria];
	
	return [super becomeFirstResponder];
}

#pragma mark -
#pragma mark Notification methods

/*
 
 - windowDidBecomeMainOrKey:
 
 */
- (void)windowDidBecomeMainOrKey:(NSNotification *)note
{
	#pragma unused(note)
	
	[MGSFragaria setCurrentInstance:self.fragaria];
}

@end
