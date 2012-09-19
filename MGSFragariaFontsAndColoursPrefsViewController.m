//
//  MGSFragariaFontsAndColoursPrefsViewController.m
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "MGSFragariaFontsAndColoursPrefsViewController.h"
#import "MGSFragariaPreferences.h"

@interface MGSFragariaFontsAndColoursPrefsViewController ()

@end

@implementation MGSFragariaFontsAndColoursPrefsViewController

/*
 
 - init
 
 */
- (id)init {
    self = [super initWithNibName:@"MGSPreferencesFontsAndColours" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        
    }
    return self;
}

/*
 
 - setFontAction:
 
 */
- (IBAction)setFontAction:(id)sender
{
#pragma unused(sender)
    
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSData *fontData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:MGSFragariaPrefsTextFont];
    NSFont *font = [NSUnarchiver unarchiveObjectWithData:fontData];
	[fontManager setSelectedFont:font isMultiple:NO];
	[fontManager orderFrontFontPanel:nil];
}

@end
