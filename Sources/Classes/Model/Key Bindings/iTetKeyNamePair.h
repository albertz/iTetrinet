//
//  iTetKeyNamePair.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/12/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

#define iTetSpacebarPlaceholderString	NSLocalizedStringFromTable(@"space", @"Keyboard", @"Name of the spacebar key, in lowercase")

#define iTetLeftArrowKeyCode	123
#define iTetRightArrowKeyCode	124
#define iTetDownArrowKeyCode	125
#define iTetUpArrowKeyCode		126

#define iTetCapsLockKeyCode		57

extern NSString* const iTetLeftArrowKeyPlaceholderString;
extern NSString* const iTetRightArrowKeyPlaceholderString;
extern NSString* const iTetUpArrowKeyPlaceholderString;
extern NSString* const iTetDownArrowKeyPlaceholderString;

@interface iTetKeyNamePair : NSObject <NSCoding, NSCopying>
{
	NSInteger keyCode;
	NSString* keyName;
	BOOL numpadKey;
	CGFloat minDisplayWidth;
}

+ (id)keyNamePairFromKeyEvent:(NSEvent*)event;
+ (id)keyNamePairWithKeyCode:(NSInteger)code
						name:(NSString*)name;
+ (id)keyNamePairWithKeyCode:(NSInteger)code
						name:(NSString*)name
				   numpadKey:(BOOL)isOnNumpad;

- (id)initWithKeyEvent:(NSEvent*)event;
- (id)initWithKeyCode:(NSInteger)code
				 name:(NSString*)name
			numpadKey:(BOOL)isOnNumpad;

@property (readonly) NSInteger keyCode;
@property (readonly) NSString* keyName;
@property (readonly) CGFloat minDisplayWidth;
@property (readonly, getter=isNumpadKey) BOOL numpadKey;
@property (readonly) BOOL isArrowKey;
@property (readonly) NSString* printedName;

@end
