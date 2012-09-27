//
//  FragariaAppDelegate.m
//  Fragaria
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "FragariaAppDelegate.h"
#import <MGSFragaria/MGSFragaria.h>
#import "MGSPreferencesController.h"

@implementation FragariaAppDelegate

@synthesize window;


#pragma mark -
#pragma mark NSApplicationDelegate
/*
 
 - applicationDidFinishLaunching:
 
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
#pragma unused(aNotification)
	
	// create an instance
	fragaria = [[MGSFragaria alloc] init];

	// define initial object configuration
	//
	// see MGSFragaria.h for details
	//
	[fragaria setObject:self forKey:MGSFODelegate];
	
	// define our syntax definition
	[self setSyntaxDefinition:@"Objective-C"];
	
	// embed editor in editView
	[fragaria embedInView:editView];

    //
	// assign user defaults.
	// a number of properties are derived from the user defaults system rather than the doc spec.
	//
	// see MGSFragariaPreferences.h for details
	//
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];

	// get initial text - in this case a test file from the bundle
	NSString *path = [[NSBundle mainBundle] pathForResource:@"SMLSyntaxColouring" ofType:@"m"];
	NSString *fileText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	// set text
	//[fragaria performSelector:@selector(setString:) withObject:fileText afterDelay:0];
	[fragaria setString:fileText];
    
	// access the NSTextView directly
	NSTextView *textView = [fragaria objectForKey:ro_MGSFOTextView];
	
#pragma unused(textView)
	
}

/*
 
 - applicationShouldTerminateAfterLastWindowClosed:
 
 */
 - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
 {
	 #pragma unused(theApplication)
	 
	 return YES;
 }

#pragma mark -
#pragma mark Actions

/*
 
 - showPreferencesWindow
 
 */
- (IBAction)showPreferencesWindow:(id)sender
{
    #pragma unused(sender)
    
    [[MGSPreferencesController sharedPrefsWindowController] showWindow:self];
}

#pragma mark -
#pragma mark Pasteboard handling
/*
 
 copyToPasteBoard
 
 */
- (IBAction)copyToPasteBoard:(id)sender
{
	#pragma unused(sender)
	
	NSAttributedString *attString = [fragaria attributedString];
	NSData *data = [attString RTFFromRange:NSMakeRange(0, [attString length]) documentAttributes:nil];
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard clearContents];
	[pasteboard setData:data forType:NSRTFPboardType];
}


#pragma mark -
#pragma mark Syntax definition handling
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
#pragma mark -
#pragma mark NSTextDelegate

/*
 
 - textDidChange:
 
 */
- (void)textDidChange:(NSNotification *)notification
{
	#pragma unused(notification)

	[window setDocumentEdited:YES];
}

/*
 
 - textDidBeginEditing:
 
 */
- (void)textDidBeginEditing:(NSNotification *)aNotification
{
	NSLog(@"notification : %@", [aNotification name]);
}

/*
 
 - textDidEndEditing:
 
 */
- (void)textDidEndEditing:(NSNotification *)aNotification
{
	NSLog(@"notification : %@", [aNotification name]);
}

/*
 
 - textShouldBeginEditing:
 
 */
- (BOOL)textShouldBeginEditing:(NSText *)aTextObject
{
#pragma unused(aTextObject)
	
	return YES;
}

/*
 
 - textShouldEndEditing:
 
 */
- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
#pragma unused(aTextObject)
	
	return YES;
}

@end
