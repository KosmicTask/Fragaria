//
//  FragariaAppDelegate.m
//  Fragaria
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "FragariaAppDelegate.h"
#import "MGSFragaria.h"


@implementation FragariaAppDelegate

@synthesize window;

/*
 
 - applicationDidFinishLaunching:
 
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	// create an instance
	fragaria = [[MGSFragaria alloc] init];

	//
	// assign user defaults.
	// a number of properties are derived from the user defaults system rather than the doc spec.
	//
	// see MGSFragariaPreferences.h for details
	//
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSPrefsAutocompleteSuggestAutomatically];	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSPrefsLineWrapNewDocuments];	
	
	// define initial object configuration
	//
	// see MGSFragaria.h for details
	//
	[fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
	[fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
	[fragaria setObject:self forKey:MGSFODelegate];
	
	// define our syntax definition
	[self setSyntaxDefinition:@"Objective-C"];
	
	// embed editor in editView
	[fragaria embedInView:editView];

	// get initial text
	NSString *path = [[NSBundle mainBundle] pathForResource:@"SMLSyntaxColouring" ofType:@"m"];
	NSString *fileText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	// set text
	[fragaria setString:fileText];
	
	// access the NSTextView
	NSTextView *textView = [fragaria objectForKey:ro_MGSFOTextView];
	
#pragma unused(textView)
	
}

/*
 
 copyToPasteBoard
 
 */
- (IBAction)copyToPasteBoard:(id)sender
{
	NSAttributedString *attString = [fragaria attributedString];
	NSData *data = [attString RTFFromRange:NSMakeRange(0, [attString length]) documentAttributes:nil];
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard clearContents];
	[pasteboard setData:data forType:NSRTFPboardType];
}
/*
 
 - applicationShouldTerminateAfterLastWindowClosed:
 
 */
 - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
 {
	 return YES;
 }

/*
 
 - setSyntaxDefinition:
 
 */
 
- (void)setSyntaxDefinition:(NSString *)name
{
	[fragaria setObject:name forKey:MGSFOSyntaxDefinitionName];
}

/*
 
 - syntaxDefinition
 
 */
- (NSString *)syntaxDefinition
{
	return [fragaria objectForKey:MGSFOSyntaxDefinitionName];

}
/*
 
 - textDidChange:
 
 fragaria delegate method
 
 */
- (void)textDidChange:(NSNotification *)notification
{
	[window setDocumentEdited:YES];
}
@end
