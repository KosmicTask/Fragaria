//
//  MGSPreferencesController.m
//  KosmicEditor
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "MGSFragariaFramework.h"

@implementation MGSPreferencesController

#pragma mark -
#pragma mark Instance methods

/*
 
 -initWithWindow: is the designated initializer for NSWindowController.
 
 */
- (id)initWithWindow:(NSWindow *)window
{
#pragma unused(window)
	
    self = [super initWithWindow:window];
	if (self) {
    
    }
	return self;
}


/*
 
 - showWindow:
 
 */
- (void)showWindow:(id)sender
{
    // load view controllers
    textEditingPrefsViewController = [MGSFragariaPreferences sharedInstance].textEditingPrefsViewController;

    fontsAndColoursPrefsViewController = [MGSFragariaPreferences sharedInstance].fontsAndColoursPrefsViewController;

    [super showWindow:sender];
}

/*
 
 - setupToolbar
 
 */
- (void)setupToolbar
{
	[self addView:generalView label:NSLocalizedString(@"General", @"Preferences tab name")];

	[self addView:textEditingPrefsViewController.view label:NSLocalizedString(@"Text Editing", @"Preferences tab name")];
    
    [self addView:fontsAndColoursPrefsViewController.view label:NSLocalizedString(@"Fonts & Colours", @"Preferences tab name")];
		
}

/*
 
 - changeFont:
 
 */
- (void)changeFont:(id)sender
{
    /* NSFontManager will send this method up the responder chain */
    [fontsAndColoursPrefsViewController changeFont:sender];
}

/*
 
 - revertToStandardSettings:
 
 */
- (void)revertToStandardSettings:(id)sender
{
    [[MGSFragariaPreferences sharedInstance] revertToStandardSettings:sender];
}
@end
