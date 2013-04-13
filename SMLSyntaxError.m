//
//  SMLSyntaxError.m
//  Fragaria
//
//  Created by Viktor Lidholt on 4/9/13.
//
//

#import "SMLSyntaxError.h"

@implementation SMLSyntaxError

- (void) dealloc
{
    self.description = NULL;
    self.code = NULL;
    [super dealloc];
}

@end
