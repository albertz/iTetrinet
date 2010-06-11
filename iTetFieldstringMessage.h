//
//  iTetFieldstringMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetFieldstringMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSString* fieldstring;
	NSInteger playerNumber;
	BOOL partial;
}

+ (id)fieldMessageForPlayer:(iTetPlayer*)player;
+ (id)partialUpdateMessageForPlayer:(iTetPlayer*)player;
- (id)initWithContents:(NSString*)fieldstringContents
		  playerNumber:(NSInteger)playerNum
		 partialUpdate:(BOOL)isPartial;

@property (readonly) NSString* fieldstring;
@property (readonly) NSInteger playerNumber;
@property (readonly, getter=isPartialUpdate) BOOL partial;

@end
