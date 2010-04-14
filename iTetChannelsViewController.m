//
//  iTetChannelsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//

#import "iTetChannelsViewController.h"
#import "iTetChatViewController.h"
#import "iTetPlayersController.h"
#import "iTetWindowController.h"
#import "iTetNetworkController.h"

#import "iTetChannelInfo.h"

#import "iTetServerInfo.h"
#import "AsyncSocket.h"

#import "iTetLocalPlayer.h"

#import "iTetMessage+QueryMessageFactory.h"
#import "iTetChannelListQueryMessage.h"
#import "iTetChannelListEntryMessage.h"
#import "iTetPlayerListQueryMessage.h"
#import "iTetPlayerListEntryMessage.h"
#import "iTetJoinChannelMessage.h"

#import "NSString+MessageData.h"
#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"

#define iTetQueryNetworkPort			(31457)
#define iTetOutgoingQueryTerminator		(0xFF)
#define iTetIncomingResponseTerminator	(0x0A)

@interface iTetChannelsViewController (Private)

- (void)sendQueryMessage:(iTetMessage<iTetOutgoingMessage>*)message;
- (void)listenForResponse;

- (void)setChannels:(NSArray*)newChannels;
- (void)setLocalPlayerChannelName:(NSString*)channelName;

@end


@implementation iTetChannelsViewController

- (id)init
{
	querySocket = [[AsyncSocket alloc] initWithDelegate:self];
	updateChannels = [[NSMutableArray alloc] init];
	channels = [[NSArray alloc] init];
	localPlayerChannelName = [[NSString alloc] init];
	
	return self;
}

- (void)awakeFromNib
{
	// Set up the channels list double-click action
	[channelsTableView setTarget:self];
	[channelsTableView setDoubleAction:@selector(doubleClick)];
}

- (void)dealloc
{
	// Disconnect the query socket
	[querySocket disconnect];
	
	// De-register for notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[querySocket release];
	[currentServer release];
	[updateChannels release];
	[channels release];
	[localPlayerChannelName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

- (void)requestChannelListFromServer:(iTetServerInfo*)server
{
	// Hold a reference to the server
	currentServer = [server retain];
	
	// Assume, until we determine otherwise, that the server supports the Query protocol
	serverSupportsQueries = YES;
	
	// Attempt to open a Query-protocol connection to the server
	[querySocket connectToHost:[currentServer address]
						onPort:iTetQueryNetworkPort
						 error:NULL];
	
	// If the connection fails here, simply abort and retry when someone asks us to refresh the list; that being said, we shouldn't fail here very often, since this method should only be called after the network controller has already established a connection to the server over the game socket
}
	 
- (IBAction)refreshChannelList:(id)sender
{
	// If we already know that this server doesn't support the Query protocol, don't bother trying to refresh
	if (!serverSupportsQueries)
		return;
	
	// If we're not looking at the chat view tab, delay the refresh until the user switches
	if (![[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
		return;
	
	// If we already have a channel query pending or in progress, ignore the attempt to refresh
	if (channelQueryStatus != noQuery)
		return;
	
	// If we have a player query in progress, wait for it to complete before refreshing the channels
	if (playerQueryStatus == queryInProgress)
	{
		channelQueryStatus = pendingQuery;
		return;
	}
	
	// If we have been disconnected since the last query, (by a read timeout on the server's end, for instance) reconnect
	if (![querySocket isConnected])
	{
		[querySocket connectToHost:[currentServer address]
							onPort:iTetQueryNetworkPort
							 error:NULL];
		
		// Request will be sent automatically when the socket reopens
		return;
	}
	
	// If we are still connected, make an immediate request for the channel list
	[self sendQueryMessage:[iTetChannelListQueryMessage message]];
	channelQueryStatus = queryInProgress;
	
	// Listen for the query response
	[self listenForResponse];
}

- (IBAction)refreshLocalPlayerChannel:(id)sender
{
	// If we already know that this server doesn't support the Query protocol, don't bother trying to refresh
	if (!serverSupportsQueries)
		return;
	
	// If we already have a player query pending or in progress, ignore the attempt to refresh
	if (playerQueryStatus != noQuery)
		return;
	
	// If we have a channel query in progress, wait for it to complete
	if (channelQueryStatus == queryInProgress)
	{
		playerQueryStatus = pendingQuery;
		return;
	}
	
	// If we're not looking at the chat view tab, delay the refresh until the user switches
	if (![[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
	{
		playerQueryStatus = pendingQuery;
		return;
	}
	
	// If we have been disconnected since the last query, reconnect
	if (![querySocket isConnected])
	{
		[querySocket connectToHost:[currentServer address]
							onPort:iTetQueryNetworkPort
							 error:NULL];
		
		// Player query will be performed automatically (after a channel query)
		return;
	}
	
	// If we are still connected, make an immediate request for the channel list
	[self sendQueryMessage:[iTetPlayerListQueryMessage message]];
	playerQueryStatus = queryInProgress;
	
	// Listen for the query response
	[self listenForResponse];
}

- (void)stopQueriesAndDisconnect
{
	// Disconnect the socket
	[querySocket disconnect];
	
	// De-register for tab-change notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Clear the channel list
	[self setChannels:nil];
}

- (void)tabChanged:(NSNotification*)notification
{
	// If the chat tab is now active, refresh the channel list
	if ([[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
		[self refreshChannelList:self];
}

#pragma mark -
#pragma mark Changing Channels

- (void)switchToChannelNamed:(NSString*)channelName
{
	// Append a status message to the chat view
	[chatController appendStatusMessage:[NSString stringWithFormat:@"Switching to channel: %@", channelName]];
	
	// Send a "/join" message to the server
	[networkController sendMessage:[iTetJoinChannelMessage messageWithChannelName:channelName
																		   player:[playersController localPlayer]]];
}

- (void)doubleClick
{
	// Check that the double-click was on a channel
	NSInteger row = [channelsTableView clickedRow];
	if ((row < 0) || (row >= (NSInteger)[channels count]))
		return;
	
	// Check that the player is not already in this channel
	NSString* channelName = [[[channelsArrayController arrangedObjects] objectAtIndex:row] channelName];
	if ([channelName isEqualToString:localPlayerChannelName])
		return;
	
	// Attempt to switch to the channel described in the clicked row
	[self switchToChannelNamed:channelName];
}

#pragma mark -
#pragma mark Queries

- (void)sendQueryMessage:(iTetMessage<iTetOutgoingMessage>*)message
{
	// FIXME: debug logging
	NSData* messageData = [message rawMessageData];
	NSLog(@"DEBUG:       sending query message: '%@'", [NSString stringWithMessageData:messageData]);
	
	// Append a terminator byte and enqueue the message for sending
	[querySocket writeData:[messageData dataByAppendingByte:iTetOutgoingQueryTerminator]
			   withTimeout:-1
					   tag:0];
}

- (void)listenForResponse
{
	// Ask the socket to call us back when it sees a query-response message terminator
	[querySocket readDataToData:[NSData dataWithByte:iTetIncomingResponseTerminator]
					withTimeout:-1
							tag:0];
}

#pragma mark -
#pragma mark AsyncSocket Delegate Methods

- (void)onSocket:(AsyncSocket*)socket
didConnectToHost:(NSString*)host
			port:(UInt16)port
{
	// FIXME: debug logging
	NSLog(@"DEBUG: query socket open to host: %@", host);
	
	// Request the channel list
	[self sendQueryMessage:[iTetChannelListQueryMessage message]];
	channelQueryStatus = queryInProgress;
	
	// Perform a player list query when the channel query finishes
	playerQueryStatus = pendingQuery;
	
	// Listen for the query response
	[self listenForResponse];
	
	// Register for notifications when the selected tab of the main window changes, to refresh the channel list
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tabChanged:)
												 name:iTetWindowControllerSelectedTabViewItemDidChangeNotification
											   object:nil];
}

- (void)onSocket:(AsyncSocket*)socket
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
	// If we have determined that the server doesn't support the query protocol, don't bother reading the message
	if (!serverSupportsQueries)
		return;
	
	// Trim the terminator character from the end of the data
	data = [data subdataToIndex:([data length] - 1)];
	
	// FIXME: debug logging
	NSLog(@"DEBUG: query message data received: '%@'", [NSString stringWithMessageData:data]);
	
	// Parse the message data _after_ this method returns
	// The channel description is formatted with HTML, which must be parsed by NSAttributedString's initWithHTML: methods. These methods fork the execution into another thread, which may cause the socket to call this callback again before the parsing is finished, resulting in the socket's buffer not being flushed properly. By returning from this method before attempting to parse the data, we ensure that the socket's buffer is flushed before the next read is attempted.
	[self performSelector:@selector(parseMessageData:)
			   withObject:data
			   afterDelay:0.0];
}

- (void)parseMessageData:(NSData*)messageData
{
	// Attempt to parse the data as a Query response message
	iTetMessage* message = [iTetMessage queryMessageFromData:messageData];
	
	// If the message is not a valid Query response, abort the attempt to retrieve channels
	if (message == nil)
	{
		serverSupportsQueries = NO;
		channelQueryStatus = noQuery;
		playerQueryStatus = noQuery;
		[querySocket disconnect];
		return;
	}
	
	// Otherwise, determine the nature of the message
	switch ([message messageType])
	{
		case channelListEntryMessage:
		{
			// Create a new entry for the channel list
			iTetChannelListEntryMessage* channelMessage = (iTetChannelListEntryMessage*)message;
			iTetChannelInfo* channel = [iTetChannelInfo channelInfoWithName:[channelMessage channelName]
																description:[channelMessage channelDescription]
															 currentPlayers:[channelMessage playerCount]
																 maxPlayers:[channelMessage maxPlayers]
																	  state:[channelMessage gameState]];
			
			// Check if the channel is the local players'
			if ([[channel channelName] isEqualToString:localPlayerChannelName])
				[channel setLocalPlayerChannel:YES];
			
			// Add the entry to a temporary list
			[updateChannels addObject:channel];
			
			// Continue listening for reply messages
			[self listenForResponse];
			
			break;
		}
		case playerListEntryMessage:
		{
			// Check if the entry corresponds to the local player
			iTetPlayerListEntryMessage* playerMessage = (iTetPlayerListEntryMessage*)message;
			if ([[playerMessage nickname] isEqualToString:[[playersController localPlayer] nickname]])
			{
				// Change the which channel is recognized as the local player's
				[self setLocalPlayerChannelName:[playerMessage channelName]];
			}
			
			// Continue listening for reply messages
			[self listenForResponse];
			
			break;
		}
		case queryResponseTerminatorMessage:
		{
			// Determine whether this is the end of a player list or a channels list
			if (channelQueryStatus == queryInProgress)
			{
				channelQueryStatus = noQuery;
				
				// Signals the end of the list of channels; finalize the list
				[self setChannels:updateChannels];
				
				// Clear the temporary list
				[updateChannels removeAllObjects];
				
				// If necessary, begin a player list request
				if (playerQueryStatus == pendingQuery)
				{
					[self sendQueryMessage:[iTetPlayerListQueryMessage message]];
					playerQueryStatus = queryInProgress;
					[self listenForResponse];
				}
			}
			else if (playerQueryStatus == queryInProgress)
			{
				playerQueryStatus = noQuery;
				
				// If necessary, begin a new channel list request
				if (channelQueryStatus == pendingQuery)
				{
					[self sendQueryMessage:[iTetChannelListQueryMessage message]];
					channelQueryStatus = queryInProgress;
					[self listenForResponse];
				}
			}
			else
			{
				NSLog(@"WARNING: query-response-terminator received with no query in-progress");
			}
			
			break;
		}	
		default:
			NSLog(@"WARNING: invalid message type detected in channel view controller: '%d'", [message messageType]);
			break;
	}
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// FIXME: debug logging
	NSLog(@"DEBUG: query socket will disconnect with error: %@", error);
	
	// If an error occurred, abort quietly, but make note that the server doesn't support the Query protocol
	if (error != nil)
		serverSupportsQueries = NO;
}

- (void)onSocketDidDisconnect:(AsyncSocket*)socket
{
	// FIXME: debug logging
	NSLog(@"DEBUG: query socket has disconnected");
	
	channelQueryStatus = noQuery;
	playerQueryStatus = noQuery;
}

#pragma mark -
#pragma mark Accessors

- (void)setChannels:(NSArray*)newChannels
{
	[self willChangeValueForKey:@"channels"];
	
	// Copy the new list of channels
	newChannels = [newChannels copy];
	
	// Release the old list
	[channels release];
	
	// Swap the old list for the new
	channels = newChannels;
	
	[self didChangeValueForKey:@"channels"];
}
@synthesize channels;

- (void)setLocalPlayerChannelName:(NSString*)channelName
{
	// Disallow nil channel names
	if (channelName == nil)
		channelName = [NSString string];
	
	// If the name isn't changing, do nothing (fail-fast optimization)
	if ([localPlayerChannelName isEqualToString:channelName])
		return;
	
	[self willChangeValueForKey:@"channels"];
	
	// Attempt to un-mark the player's previous channel
	NSArray* filteredChannels = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"channelName == %@", localPlayerChannelName]];
	for (iTetChannelInfo* channel in filteredChannels)
		[channel setLocalPlayerChannel:NO];
	
	// Find and mark the player's new channel
	filteredChannels = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"channelName == %@", channelName]];
	if ([filteredChannels count] > 0)
	{
		if ([filteredChannels count] > 1)
			NSLog(@"WARNING: multiple channels named '%@' on this server!", channelName);
		
		[[filteredChannels objectAtIndex:0] setLocalPlayerChannel:YES];
	}
	else
	{
		NSLog(@"WARNING: no channels named '%@' on this server!", channelName);
	}
	
	[self didChangeValueForKey:@"channels"];
	
	[self willChangeValueForKey:@"localPlayerChannelName"];
	
	// We don't need to bother with the "retain first" business, since we've already eliminated the possibility that this is the same object
	[localPlayerChannelName release];
	localPlayerChannelName = [channelName retain];
	
	[self didChangeValueForKey:@"localPlayerChannelName"];
}
@synthesize localPlayerChannelName;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"channels"])
		return NO;
	
	if ([key isEqualToString:@"localPlayerChannelName"])
		return NO;
	
	return [super automaticallyNotifiesObserversForKey:key];
}

@end