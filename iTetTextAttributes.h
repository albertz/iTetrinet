//
//  iTetTextAttributes.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
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
	boldText =			2,
	boldItalicText =	30 // Not part of the spec, just for our use; never sent over the wire
} iTetTextFontAttribute;

#define ITET_HIGHEST_ATTR_CODE	31

typedef union
{
	uint8_t code;
	iTetTextColorAttribute colorAttribute;
	iTetTextFontAttribute fontAttribute;
} iTetTextAttributeCode;

// Returns the NSColor represented by the specified color code
NSColor* iTetTextColorForAttribute(iTetTextColorAttribute attribute);

// Returns the color code representing the specified NSColor
iTetTextColorAttribute iTetAttributeForTextColor(NSColor* color);
