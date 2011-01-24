//
//  iTetTextAttributes.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	noColor =			0,
	blackTextColor =	4,
	whiteTextColor =	24,
	grayTextColor =		6,
	silverTextColor =	15,
	redTextColor =		20,
	yellowTextColor =	25,
	limeTextColor =		14,
	greenTextColor =	12,
	oliveTextColor =	18,
	tealTextColor =		23,
	cyanTextColor =		3,
	blueTextColor =		5,
	darkBlueTextColor =	17,
	purpleTextColor =	19,
	maroonTextColor =	16,
	magentaTextColor =	8
} iTetTextColorAttribute;

typedef enum
{
	italicText =		22,
	underlineText =		31,
	boldText =			2
} iTetTextFontAttribute;

#define ITET_HIGHEST_ATTR_CODE	31

extern NSString* const iTetCommandMessagePrefix;
extern NSString* const iTetActionMessagePrefix;

extern NSString* const iTetLocalActionMessageIndicator;
extern NSString* const iTetRemoteActionMessageIndicator;

extern NSString* const iTetLocalPlayerNicknameAttributeName;

@interface iTetTextAttributes : NSObject

// Returns an NSCharacterSet containing all characters used as formatting data in the TetriNET protocol
+ (NSCharacterSet*)chatTextAttributeCharacterSet;

// Returns a dictionary containing the default text attributes for the partyline message view
+ (NSDictionary*)defaultChatTextAttributes;

// Returns a dictionary containing the text attributes used to highlight the local player's name on the partyline message view
+ (NSDictionary*)localPlayerNameTextAttributes;

// Returns a dictionary containing the default text attributes for the game actions list
+ (NSDictionary*)defaultGameActionsTextAttributes;

// Returns a dictionary containing a bolded version of the text attributes for the game actions list
+ (NSDictionary*)boldFontGameActionsTextAttributes;

// Returns a dictionary containing the default text attributes for the channels list
+ (NSDictionary*)defaultChannelsListTextAttributes;

// Returns the text attribute corresponding to the specified attribute code
+ (NSDictionary*)chatTextAttributeForCode:(uint8_t)attributeCode;

// Returns the foreground text color represented by the specified color code
+ (NSColor*)chatTextColorForCode:(uint8_t)attribute;

// Returns the color code representing the specified foreground text color
+ (iTetTextColorAttribute)codeForChatTextColor:(NSColor*)color;

// Returns the default foreground text color (black)
+ (NSColor*)defaultTextColor;

// Returns the color used to highlight the local player's name
+ (NSColor*)localPlayerNameTextColor;

// Returns the text colors for various event descriptions in the game actions list
+ (NSColor*)goodSpecialDescriptionTextColor;
+ (NSColor*)badSpecialDescriptionTextColor;
+ (NSColor*)linesAddedDescriptionTextColor;

// Returns the fonts used in the partyline message view
+ (NSFont*)chatTextFontWithTraits:(NSFontTraitMask)fontTraits;
+ (NSFont*)plainChatTextFont;
+ (NSFont*)boldChatTextFont;
+ (NSFont*)italicChatTextFont;
+ (NSFont*)boldItalicChatTextFont;

// Returns the fonts used in the game actions list
+ (NSFont*)gameActionsTextFont;
+ (NSFont*)boldGameActionsTextFont;

// Returns the font used in the channels list
+ (NSFont*)channelsListTextFont;

@end

