//
//  iTetWinlistEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetWinlistEntry.h"

@implementation iTetWinlistEntry

+ (id)playerEntryWithName:(NSString *)name
					score:(NSInteger)score
{
	return [[[self alloc] initWithName:name
								 score:score
								isTeam:NO] autorelease];
}

+ (id)teamEntryWithName:(NSString*)name
				  score:(NSInteger)score
{
	return [[[self alloc] initWithName:name
								 score:score
								isTeam:YES] autorelease];
}

- (id)initWithName:(NSString*)name
			 score:(NSInteger)score
			isTeam:(BOOL)isTeam
{
	entryName = [name copy];
	entryScore = score;
	teamEntry = isTeam;
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize entryName;
@synthesize entryScore;
@synthesize teamEntry;

@end
