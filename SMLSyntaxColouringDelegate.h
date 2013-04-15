//
//  SMLSyntaxColouringDelegate.h
//  Fragaria
//
//  Created by Jonathan on 14/04/2013.
//
//

#import <Foundation/Foundation.h>

// syntax colouring information dictionary keys
extern NSString *SMLSyntaxTag;
extern NSString *SMLSyntaxTagID;
extern NSString *SMLSyntaxWillColour;
extern NSString *SMLSyntaxAttributes;
extern NSString *SMLSyntaxInfo;

// syntax colouring tag names
extern NSString *SMLSyntaxTagNumber;
extern NSString *SMLSyntaxTagCommand;
extern NSString *SMLSyntaxTagInstruction;
extern NSString *SMLSyntaxTagKeyword;
extern NSString *SMLSyntaxTagAutoComplete;
extern NSString *SMLSyntaxTagVariable;
extern NSString *SMLSyntaxTagFirstString;
extern NSString *SMLSyntaxTagSecondString;
extern NSString *SMLSyntaxTagAttribute;
extern NSString *SMLSyntaxTagSingleLineComment;
extern NSString *SMLSyntaxTagMultiLineComment;
extern NSString *SMLSyntaxTagSecondStringPass2;

// syntax colouring tag IDs
enum {
    kSMLSyntaxTagNumber = 0,
    kSMLSyntaxTagCommand = 1,
    kSMLSyntaxTagInstruction = 2,
    kSMLSyntaxTagKeyword = 3,
    kSMLSyntaxTagAutoComplete = 4,
    kSMLSyntaxTagVariable = 5,
    kSMLSyntaxTagSecondString = 6,
    kSMLSyntaxTagFirstString = 7,
    kSMLSyntaxTagAttribute = 8,
    kSMLSyntaxTagSingleLineComment = 9,
    kSMLSyntaxTagMultiLineComment = 10,
    kSMLSyntaxTagSecondStringPass2 = 11
};
typedef NSInteger SMLSyntaxTagInteger;

@protocol SMLSyntaxColouringDelegate <NSObject>

/*
 
 Use these methods to partially customise or overridde the syntax colouring.
 
 Arguments used in the delegate methods
 ======================================
 
 document: Fragaria document spec
 block: block to colour string. the arguments are a colour info dictionary and the range to be coloured
 string: document string. This is supplied as a convenience. The string can also be retrieved from the document.
 range: range of string to colour.
 info: an information dictionary
 
 Info dictionary keys 
 ======================
 
 SMLSyntaxTag: NSString describing the tag being coloured.
 SMLSyntaxTagID:  NSNumber identyfying the tag being coloured.
 SMLSyntaxWillColour: NSNumber containing a BOOL indicating whether the caller will colour the string.
 SMLSyntaxAttributes: NSDictionary of NSAttributed string attributes used to colour the string.
 SMLSyntaxInfo: NSDictionary containing Fragaria syntax definition.
 
 Delegate calling
 ================
 
  The delegate will receive messages in the following order:range:info:
 
  // we will colour this document
 - fragariaDocument:willColourWithBlock:string:range:info
 
 // the *ColourTagWithBlock methods are sent for each tag defined by SMLSyntaxTagInteger
 foreach tag
 
    // Fragaria will colour this tag.
    // to do initial colouring: colour as required and have the delegate return NO.
    // to prevent tag colouring simply return YES.
    // to completely override the colouring: colour as required and have the delegate return YES.
    BOOL delegateDidColour = (- fragariaDocument:willColourTagWithBlock:string:range:info)

    // if delegateDidColour is NO then the Fragaria will colour the code once the above method returns.
    // if delegateDidColour is YES then the Fragaria will NOT colour the code any further once the above method returns.
 
    // Fragaria did colour this tag.
    // an opportunity for additional colouring to complement that already performed by Fragaria.
    - fragariaDocument:didColourTagWithBlock:string:range:info
 end
 
 // we did colour this document
 - fragariaDocument:willDidWithBlock:string:range:info
 
 Colouring the string
 ====================
 
 Each delegate method includes a block that can can be called with a dictionary of attributes and a range to affect colouring.
 */
- (void)fragariaDocument:(id)document willColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (BOOL)fragariaDocument:(id)document willColourTagWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (void)fragariaDocument:(id)document didColourTagWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (void)fragariaDocument:(id)document didColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
@end
