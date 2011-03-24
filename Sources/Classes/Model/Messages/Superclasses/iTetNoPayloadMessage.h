//
//  iTetNoPayloadMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@interface iTetNoPayloadMessage : iTetMessage

/*!
 Creates and returns a new message object.
 */
+ (id)message;

@end
