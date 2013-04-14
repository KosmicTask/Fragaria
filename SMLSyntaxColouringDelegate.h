//
//  SMLSyntaxColouringDelegate.h
//  Fragaria
//
//  Created by Jonathan on 14/04/2013.
//
//

#import <Foundation/Foundation.h>

@protocol SMLSyntaxColouringDelegate <NSObject>
- (BOOL) fragariaDocument:(id)document string:(NSString *)string colourRange:(NSRange)rangeToRecolour info:(NSDictionary *)info;
@end
