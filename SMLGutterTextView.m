/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
 Based on:
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "SMLStandardHeader.h"

#import "SMLGutterTextView.h"

@implementation SMLGutterTextView

#pragma mark -
#pragma mark Instance methods
/*
 
 - initWithFrame:
 
 */
- (id)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {

		[self setContinuousSpellCheckingEnabled:NO];
		[self setAllowsUndo:NO];
		[self setAllowsDocumentBackgroundColorChange:NO];
		[self setRichText:NO];
		[self setUsesFindPanel:NO];
		[self setUsesFontPanel:NO];
		[self setAlignment:NSRightTextAlignment];
		[self setEditable:NO];
		[self setSelectable:NO];
		[[self textContainer] setContainerSize:NSMakeSize([[SMLDefaults valueForKey:@"GutterWidth"] integerValue], FLT_MAX)];
		[self setVerticallyResizable:YES];
		[self setHorizontallyResizable:YES];
		[self setAutoresizingMask:NSViewHeightSizable];
		
		[self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
		[self setTextColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"GutterTextColourWell"]]];
		[self setInsertionPointColor:[NSColor textColor]];
		//[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextColourWell"]]];
		[self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.94f alpha:1.0f]];

		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
		[defaultsController addObserver:self forKeyPath:@"values.TextFont" options:NSKeyValueObservingOptionNew context:@"TextFontChanged"];
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
	if ([(NSString *)context isEqualToString:@"TextFontChanged"]) {
		[self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:@"TextFont"]]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark -
#pragma mark Drawing

/*
 
 - drawRect:
 
 */
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	NSRect bounds = [self bounds]; 
	if ([self needsToDrawRect:NSMakeRect(bounds.size.width - 1, 0, 1, bounds.size.height)] == YES) {
		[[NSColor lightGrayColor] set];
		NSBezierPath *dottedLine = [NSBezierPath bezierPathWithRect:NSMakeRect(bounds.size.width, 0, 0, bounds.size.height)];
		CGFloat dash[2];
		dash[0] = 1.0f;
		dash[1] = 2.0f;
		[dottedLine setLineDash:dash count:2 phase:1.0f];
		[dottedLine stroke];
	}
	
}

/*
 
 - isOpaque
 
 */
- (BOOL)isOpaque
{
	return YES;
}

@end
