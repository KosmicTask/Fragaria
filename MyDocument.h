//
//  MyDocument.h
//  Fragaria Document
//
//  Created by Jonathan on 24/07/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class MGSFragaria;

@interface MyDocument : NSDocument {
	IBOutlet NSView *editView;
	MGSFragaria *fragaria;
	BOOL isEdited;
}

@property (NS_NONATOMIC_IOSONLY, copy) NSString *syntaxDefinition;

@end
