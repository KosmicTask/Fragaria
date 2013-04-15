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
	
    // set the syntax colouring delegate
    [fragaria setObject:self forKey:MGSFOSyntaxColouringDelegate];
    
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
	
    // define a syntax error
    SMLSyntaxError *syntaxError = [[SMLSyntaxError new] autorelease];
    syntaxError.description = @"Syntax errors can be defined";
    syntaxError.line = 1;
    syntaxError.character = 1;
    syntaxError.length = 10;
    
    fragaria.syntaxErrors = @[syntaxError];
    
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

/*
 
 reloadString:
 
 */
- (IBAction)reloadString:(id)sender
{
#pragma unused(sender)
    [fragaria reloadString];
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

#pragma mark -
#pragma mark MGSFragariaTextViewDelegate

/*
 
 - mgsTextDidPaste:
 
 */
- (void)mgsTextDidPaste:(NSNotification *)aNotification
{
    /*
     When this notification is received the paste will have been accepted.
     Use this method to query the pasteboard for additional pasteboard content
     that may be relevant to the application: eg: a plist that may contain custom data.
     */
    NSLog(@"notification : %@", [aNotification name]); 
}

#pragma mark -
#pragma mark SMLSyntaxColouringDelegate

/*
 
 For more information on custom colouring see SMLSyntaxColouringDelegate.h
 
 */

/*
 
 - fragariaDocument:willColourWithBlock:string:range:info
 
 */
- (void) fragariaDocument:(id)document willColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
#pragma unused(document, colourWithBlock, string, range, info)
    NSLog(@"Will colour document.");
    
    // we can call colourWithBlock to perform initial colouration
}
/*
 
 - fragariaDocument:willColourTagWithBlock:string:range:info
 
 */
- (BOOL) fragariaDocument:(id)document willColourTagWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
    #pragma unused(document, string)
    BOOL success = NO;
    
    // query info
    NSString *tag = [info objectForKey:SMLSyntaxTag];
    NSInteger tagID = [[info objectForKey:SMLSyntaxTagID] integerValue];
    BOOL willColour = [[info objectForKey:SMLSyntaxWillColour] boolValue];
    NSDictionary *attributes = [info objectForKey:SMLSyntaxAttributes];
    NSDictionary *syntaxInfo = [info objectForKey:SMLSyntaxInfo];

    // compiler comfort
    (void)syntaxInfo;

    
    NSLog(@"willColourTagWithBlock Colouring tag : %@ id : %li caller will colour : %@", tag, tagID, (willColour ? @"YES" : @"NO"));
    
    // tag
    switch (tagID) {
        case kSMLSyntaxTagNumber:
            
            // we can call colourWithBlock to perform initial tag colouration
            if (NO) {
                
                // colour the whole string with the number tag colour
                colourWithBlock(attributes, range);
                
                success = YES;
            }
            break;
            
        case kSMLSyntaxTagCommand:
            break;
            
        case kSMLSyntaxTagInstruction:
            break;
            
        case kSMLSyntaxTagKeyword:
            break;
            
        case kSMLSyntaxTagAutoComplete:
            break;
            
        case kSMLSyntaxTagVariable:
            break;
            
        case kSMLSyntaxTagFirstString:
            break;
            
        case kSMLSyntaxTagSecondString:
            break;
            
        case kSMLSyntaxTagAttribute:
            break;

        case kSMLSyntaxTagSingleLineComment:
            break;
            
        case kSMLSyntaxTagMultiLineComment:
            
            // we can prevent further colouring by returning YES
            if (NO) {
                success = YES;
            }
            
            break;
            
        case kSMLSyntaxTagSecondStringPass2:
            break;
    }
    

    // return YES if code has been fully coloured and no further colouring of tag is required.
    // return NO if we want the caller to colour the code for the current tag.
    return success;
}

/*
 
 - fragariaDocument:willColourTagWithBlock:string:range:info
 
 */
- (void) fragariaDocument:(id)document didColourTagWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
#pragma unused(document, string)
    
    // query info
    NSString *tag = [info objectForKey:SMLSyntaxTag];
    NSInteger tagID = [[info objectForKey:SMLSyntaxTagID] integerValue];
    BOOL willColour = [[info objectForKey:SMLSyntaxWillColour] boolValue];
    NSDictionary *attributes = [info objectForKey:SMLSyntaxAttributes];
    NSDictionary *syntaxInfo = [info objectForKey:SMLSyntaxInfo];
    
    // compiler comfort
    (void)syntaxInfo;
    
    NSLog(@"didColourTagWithBlock Colouring tag : %@ id : %li caller will colour : %@", tag, tagID, (willColour ? @"YES" : @"NO"));
    
    NSString *subString = [string substringWithRange:range];
    NSScanner *rangeScanner = [NSScanner scannerWithString:subString];
    [rangeScanner setScanLocation:0];
    
    // tag
    switch (tagID) {
        case kSMLSyntaxTagNumber:
            
            break;
            
        case kSMLSyntaxTagCommand:
            break;
            
        case kSMLSyntaxTagInstruction:
            break;
            
        case kSMLSyntaxTagKeyword:
        {
            // normally we iterate over the string using an NSScanner to identiy our substrings.
            // in this simple case we just colour the occurence of a given string as a false keyword.
            NSString *fauxKeyword = @" noodle";
            while (![rangeScanner isAtEnd]) {
                if ([rangeScanner scanUpToString:fauxKeyword intoString:nil]) {
                    NSUInteger location = [rangeScanner scanLocation];
                    NSRange testRange = NSMakeRange(location, [fauxKeyword length]);
                    colourWithBlock(attributes, testRange);
                }
            }
        }
            break;
            
        case kSMLSyntaxTagAutoComplete:
            break;
            
        case kSMLSyntaxTagVariable:
            break;
            
        case kSMLSyntaxTagFirstString:
            break;
            
        case kSMLSyntaxTagSecondString:
            break;
            
        case kSMLSyntaxTagAttribute:
            break;
            
        case kSMLSyntaxTagSingleLineComment:
            break;
            
        case kSMLSyntaxTagMultiLineComment:
            break;
            
        case kSMLSyntaxTagSecondStringPass2:
            break;
    }
}


/*
 
 - fragariaDocument:willColourWithBlock:string:range:info
 
 */
- (void) fragariaDocument:(id)document didColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
    #pragma unused(document, colourWithBlock, string, range, info)
    NSLog(@"Did colour document.");
    
    // we can call colourWithBlock to perform final colouration

}
@end
