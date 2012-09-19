//
//  MGSPreferencesController.h
//  Fragaria
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MGSFragariaFontsAndColoursPrefsViewController.h"
#import "MGSFragariaTextEditingPrefsViewController.h"

@interface MGSFragariaPreferencesController : NSWindowController {

    IBOutlet NSTabView *tabView;
    
    MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
    MGSFragariaTextEditingPrefsViewController *textEditingPrefsViewController;
}
+ (void)initializeValues;
+ (MGSFragariaPreferencesController *)sharedInstance;

@property (readonly) MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
@property (readonly) MGSFragariaTextEditingPrefsViewController *textEditingPrefsViewController;

@end
