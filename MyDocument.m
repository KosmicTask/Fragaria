//
//  MyDocument.m
//  Fragaria Document
//
//  Created by Jonathan on 24/07/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "MyDocument.h"
#import <MGSFragaria/MGSFragaria.h>

@implementation MyDocument

/*
 
 - init
 
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
     
    }
    return self;
}


#pragma mark -
#pragma mark Nib loading
/*
 
 - windowNibName
 
 */
- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

/*
 
 - windowControllerDidLoadNib:
 
 */
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

	// create an instance
	fragaria = [[MGSFragaria alloc] init];
	
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
    if (NO) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:MGSFragariaPrefsLineWrapNewDocuments];
    }
	
	// define initial document configuration
	//
	// see MGSFragaria.h for details
	//
    if (YES) {
        [fragaria setObject:@YES forKey:MGSFOIsSyntaxColoured];
        [fragaria setObject:@YES forKey:MGSFOShowLineNumberGutter];
    }

    // set text
	[fragaria setString:@"// We Don't need the future"];
	

	// access the NSTextView
	NSTextView *textView = [fragaria objectForKey:ro_MGSFOTextView];
	
#pragma unused(textView)
	
}

#pragma mark -
#pragma mark NSDocument data
/*
 
 - dataOfType:error:
 
 */
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
#pragma unused(typeName)
	
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

/*
 
 readFromData:ofType:error:
 
 */
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
#pragma unused(data)
#pragma unused(typeName)
	
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
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
 
 fragaria delegate method
 
 */
- (void)textDidChange:(NSNotification *)notification
{
	#pragma unused(notification)
	
	NSWindow *window = [self windowControllers][0];
	
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
