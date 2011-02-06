//
//  iTetChannelListEntry.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/23/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetGameplayState.h"

@interface iTetChannelListEntry : NSObject
{
	NSString* channelName;
	NSString* channelDescription;
	NSInteger currentPlayers;
	NSInteger maxPlayers;
	iTetGameplayState channelState;
	BOOL localPlayerChannel;
}

+ (id)channelListEntryWithName:(NSString*)name
				   description:(NSString*)desc
				currentPlayers:(NSInteger)playerCount
					maxPlayers:(NSInteger)max
						 state:(iTetGameplayState)gameState;
- (id)initWithName:(NSString*)name
	   description:(NSString*)desc
	currentPlayers:(NSInteger)playerCount
		maxPlayers:(NSInteger)max
			 state:(iTetGameplayState)gameState;

@property (readonly) NSString* channelName;
@property (readonly) NSString* channelDescription;
@property (readonly) NSString* players;
@property (readonly) NSNumber* sortablePlayers;
@property (readonly) iTetGameplayState channelState;
@property (readonly) NSNumber* sortableState;
@property (readwrite, assign, getter=isLocalPlayerChannel) BOOL localPlayerChannel;

@end
