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
 
 - fragariaDocument:shouldColourWithBlock:string:range:info
 
 */
- (BOOL)fragariaDocument:(id)document shouldColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
#pragma unused(document, colourWithBlock, string, range, info)
    
    // query info
    BOOL willColour = [[info objectForKey:SMLSyntaxWillColour] boolValue];
    NSDictionary *syntaxInfo = [info objectForKey:SMLSyntaxInfo];

    // provide compiler comfort
    (void)syntaxInfo, (void)willColour;
    
    NSLog(@"Should colour document.");
    
    // we can call colourWithBlock to perform initial colouring
    
    // YES: Fragaria should colour document
    // NO: Fragaria should not colour document
    return YES;
}
/*
 
 - fragariaDocument:shouldColourGroupWithBlock:string:range:info
 
 */
- (BOOL)fragariaDocument:(id)document shouldColourGroupWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
    #pragma unused(document, string)
    BOOL fragariaShouldColour = YES;
    
    // query info
    NSString *group = [info objectForKey:SMLSyntaxGroup];
    NSInteger groupID = [[info objectForKey:SMLSyntaxGroupID] integerValue];
    BOOL willColour = [[info objectForKey:SMLSyntaxWillColour] boolValue];
    NSDictionary *attributes = [info objectForKey:SMLSyntaxAttributes];
    
    // for key values see SMLSyntaxDefinition.h
    NSDictionary *syntaxInfo = [info objectForKey:SMLSyntaxInfo];

    // provide compiler comfort
    (void)syntaxInfo;

    // follow the default behaviour. if we don't then colouring occurs even when we turn
    // syntax colouring off in the preferences. this is fine in practice but confusing in a demo app.
    fragariaShouldColour = willColour;
    
    // this amount of logging makes the app sluggish
    NSLog(@"%@ group : %@ id : %li caller will colour : %@", NSStringFromSelector(_cmd), group, groupID, (willColour ? @"YES" : @"NO"));
    
    // group
    switch (groupID) {
        case kSMLSyntaxGroupNumber:
            
            // we can call colourWithBlock to perform initial group colouration
            if (NO) {
                
                // colour the whole string with the number group colour
                colourWithBlock(attributes, range);
                
                fragariaShouldColour = NO;
            }
            break;
            
        case kSMLSyntaxGroupCommand:
            break;
            
        case kSMLSyntaxGroupInstruction:
            break;
            
        case kSMLSyntaxGroupKeyword:
            break;
            
        case kSMLSyntaxGroupAutoComplete:
            break;
            
        case kSMLSyntaxGroupVariable:
            break;
            
        case kSMLSyntaxGroupFirstString:
            break;
            
        case kSMLSyntaxGroupSecondString:
            break;
            
        case kSMLSyntaxGroupAttribute:
            break;

        case kSMLSyntaxGroupSingleLineComment:
            break;
            
        case kSMLSyntaxGroupMultiLineComment:
            
            // we can prevent colouring of this group by returning NO
            if (NO) {
                fragariaShouldColour = NO;
            }
            
            break;
            
        case kSMLSyntaxGroupSecondStringPass2:
            break;
    }

    
    // YES: Fragaria should colour group
    // NO: Fragaria should not colour group
    return fragariaShouldColour;
}

/*
 
 - fragariaDocument:didColourGroupWithBlock:string:range:info
 
 */
- (void)fragariaDocument:(id)document didColourGroupWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
#pragma unused(document, string)
    
    // query info
    NSString *group = [info objectForKey:SMLSyntaxGroup];
    NSInteger groupID = [[info objectForKey:SMLSyntaxGroupID] integerValue];
    BOOL willColour = [[info objectForKey:SMLSyntaxWillColour] boolValue];
    NSDictionary *attributes = [info objectForKey:SMLSyntaxAttributes];
    NSDictionary *syntaxInfo = [info objectForKey:SMLSyntaxInfo];
    
    // compiler comfort
    (void)syntaxInfo;
    
    // this amount of logging makes the app sluggish
    NSLog(@"%@ group : %@ id : %li caller will colour : %@",  NSStringFromSelector(_cmd), group, groupID, (willColour ? @"YES" : @"NO"));
    
    NSString *subString = [string substringWithRange:range];
    NSScanner *rangeScanner = [NSScanner scannerWithString:subString];
    [rangeScanner setScanLocation:0];
    
    // group
    switch (groupID) {
        case kSMLSyntaxGroupNumber:
            break;
            
        case kSMLSyntaxGroupCommand:
            break;
            
        case kSMLSyntaxGroupInstruction:
            break;
            
        case kSMLSyntaxGroupKeyword:
        {
            // we can iterate over the string using an NSScanner to identiy our substrings or use a regex.
            // in this simple case we just colour the occurence of a given string as a false keyword.
            NSString *fauxKeyword = @"kosmic";
            while (YES) {
                
                // look for the keyword
                [rangeScanner scanUpToString:fauxKeyword intoString:nil];
                if ([rangeScanner isAtEnd]) break;
                     
                NSUInteger location = [rangeScanner scanLocation];
                if ([rangeScanner scanString:fauxKeyword intoString:NULL]) {
                    NSRange colourRange = NSMakeRange(range.location + location, [rangeScanner scanLocation] - location);
                    
                    // the block will colour the string
                    colourWithBlock(attributes, colourRange);
                }
            }
        }
            break;
            
        case kSMLSyntaxGroupAutoComplete:
            break;
            
        case kSMLSyntaxGroupVariable:
            break;
            
        case kSMLSyntaxGroupFirstString:
            break;
            
        case kSMLSyntaxGroupSecondString:
            break;
            
        case kSMLSyntaxGroupAttribute:
            break;
            
        case kSMLSyntaxGroupSingleLineComment:
            break;
            
        case kSMLSyntaxGroupMultiLineComment:
            break;
            
        case kSMLSyntaxGroupSecondStringPass2:
            break;
    }
}

/*
 
 - fragariaDocument:didColourWithBlock:string:range:info
 
 */
- (void)fragariaDocument:(id)document didColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))colourWithBlock string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info
{
    #pragma unused(document, colourWithBlock, string, range, info)
    NSLog(@"Did colour document.");
    
    // we can call colourWithBlock to perform final colouring

}
@end
