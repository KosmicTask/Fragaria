//
//  MGSScanner.m
//  Fragaria
//
//  Created by Jonathan on 12/08/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "MGSScanner.h"

@implementation MGSScanner

/*
 
 - initWithString:
 
 */
- (id)initWithString:(NSString *)aString
{
	self = [super initWithString:aString];
	if (self) {
		maxIndex = [aString length] -1;
	}
	
	return self;
}

/*
 
 setScanLocation:
 
 */
- (void)setScanLocation:(NSUInteger)index 
{
	if (index > maxIndex) {
		index = maxIndex;
	}
	
	[super setScanLocation:index];
}

@end
