//
//  iTetClientInfoReplyMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetClientInfoReplyMessage.h"
#import "NSString+MessageData.h"

@implementation iTetClientInfoReplyMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = clientInfoReplyMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetClientInfoReplyMessageFormat	=	@"clientinfo %@ %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetClientInfoReplyMessageFormat, [self clientName], [self clientVersion]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

- (NSString*)clientName
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

- (NSString*)clientVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
}

@end
