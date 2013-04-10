//
//  SMLSyntaxError.h
//  Fragaria
//
//  Created by Viktor Lidholt on 4/9/13.
//
//

#import <Foundation/Foundation.h>

@interface SMLSyntaxError : NSObject
{
}

@property (nonatomic,copy) NSString* description;
@property (nonatomic,assign) int line;
@property (nonatomic,assign) int character;

@end
