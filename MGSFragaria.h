/*
 *  MGSFragaria.h
 *  Fragaria
 *
 *  Created by Jonathan on 30/04/2010.
 *  Copyright 2010 mugginsoft.com. All rights reserved.
 *
 */

// valid keys for 
// - (void)setObject:(id)object forKey:(id)key;
// - (id)objectForKey:(id)key;

// BOOL
extern NSString * const MGSFOIsSyntaxColoured;
extern NSString * const MGSFOShowLineNumberGutter;
extern NSString * const MGSFOIsEdited;

// string
extern NSString * const MGSFOSyntaxDefinitionName;
extern NSString * const MGSFODocumentName;

// integer
extern NSString * const MGSFOGutterWidth;

// NSView *
extern NSString * const ro_MGSFOTextView; // readonly
extern NSString * const ro_MGSFOScrollView; // readonly
extern NSString * const ro_MGSFOGutterScrollView; // readonly

// NSObject
extern NSString * const MGSFODelegate;
extern NSString * const MGSFOBreakpointDelegate;
extern NSString * const MGSFOAutoCompleteDelegate;
extern NSString * const MGSFOSyntaxColouringDelegate;
extern NSString * const ro_MGSFOLineNumbers; // readonly
extern NSString * const ro_MGSFOSyntaxColouring; // readonly

@class MGSTextMenuController;
@class MGSExtraInterfaceController;

#import "MGSFragariaPreferences.h"
#import "MGSBreakpointDelegate.h"
#import "SMLSyntaxError.h"
#import "SMLSyntaxColouringDelegate.h"
#import "SMLSyntaxDefinition.h"

@protocol MGSFragariaTextViewDelegate <NSObject>
@optional
- (void)mgsTextDidPaste:(NSNotification *)note;
@end

@interface MGSFragaria : NSObject
{
	@private
	MGSExtraInterfaceController *extraInterfaceController;
    id docSpec;
    NSSet* objectGetterKeys;
    NSSet* objectSetterKeys;
}

@property (nonatomic, readonly) MGSExtraInterfaceController *extraInterfaceController;
@property (nonatomic, strong) id docSpec;

// class methods
+ (id)currentInstance;
+ (void)setCurrentInstance:(MGSFragaria *)anInstance;
+ (void)initializeFramework;
+ (id)createDocSpec;
+ (void)docSpec:(id)docSpec setString:(NSString *)string;
+ (void)docSpec:(id)docSpec setString:(NSString *)string options:(NSDictionary *)options;
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string;
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string options:(NSDictionary *)options;
+ (NSString *)stringForDocSpec:(id)docSpec;
+ (NSAttributedString *)attributedStringForDocSpec:(id)docSpec;
+ (NSAttributedString *)attributedStringWithTemporaryAttributesAppliedForDocSpec:(id)docSpec;

// instance methods
- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)embedInView:(NSView *)view;
- (void)setString:(NSString *)aString options:(NSDictionary *)options;
- (void)setAttributedString:(NSAttributedString *)aString options:(NSDictionary *)options;
@property (NS_NONATOMIC_IOSONLY, copy) NSAttributedString *attributedString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSAttributedString *attributedStringWithTemporaryAttributesApplied;
@property (NS_NONATOMIC_IOSONLY, copy) NSString *string;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSTextView *textView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) MGSTextMenuController *textMenuController;
@property (NS_NONATOMIC_IOSONLY, getter=isSyntaxColoured) BOOL syntaxColoured;
@property (NS_NONATOMIC_IOSONLY) BOOL showsLineNumbers;
- (void)reloadString;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)text options:(NSDictionary *)options;
@property (NS_NONATOMIC_IOSONLY, copy) NSArray *syntaxErrors;
+ (NSImage *)imageNamed:(NSString *)name;

@end
