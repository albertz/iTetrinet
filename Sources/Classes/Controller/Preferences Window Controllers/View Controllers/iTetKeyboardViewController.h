//
//  iTetKeyboardViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesViewController.h"

@class iTetKeyView;
@class iTetKeyConfiguration;

@interface iTetKeyboardViewController : iTetPreferencesViewController
{
	IBOutlet NSPopUpButton* configurationPopUpButton;
	
	IBOutlet iTetKeyView* moveLeftKeyView;
	IBOutlet iTetKeyView* moveRightKeyView;
	IBOutlet iTetKeyView* rotateCounterclockwiseKeyView;
	IBOutlet iTetKeyView* rotateClockwiseKeyView;
	IBOutlet iTetKeyView* moveDownKeyView;
	IBOutlet iTetKeyView* dropKeyView;
	IBOutlet iTetKeyView* discardSpecialKeyView;
	IBOutlet iTetKeyView* selfSpecialKeyView;
	IBOutlet iTetKeyView* gameChatKeyView;
	IBOutlet iTetKeyView* useSpecialOnPlayer1KeyView;
	IBOutlet iTetKeyView* useSpecialOnPlayer2KeyView;
	IBOutlet iTetKeyView* useSpecialOnPlayer3KeyView;
	IBOutlet iTetKeyView* useSpecialOnPlayer4KeyView;
	IBOutlet iTetKeyView* useSpecialOnPlayer5KeyView;
	IBOutlet iTetKeyView* useSpecialOnPlayer6KeyView;
	NSArray* keyViews;
	
	IBOutlet NSTextField* keyDescriptionField;
	
	IBOutlet NSWindow* saveSheetWindow;
	IBOutlet NSTextField* configurationNameField;
	IBOutlet NSButton* saveButton;
	
	iTetKeyConfiguration* unsavedConfiguration;
	
	BOOL displayingPrompt;
}

- (IBAction)changeConfiguration:(id)sender;
- (IBAction)saveConfiguration:(id)sender;
- (IBAction)closeSaveSheet:(id)sender;
- (IBAction)deleteConfiguration:(id)sender;

@end
