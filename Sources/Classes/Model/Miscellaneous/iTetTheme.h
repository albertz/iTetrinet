//
//  iTetTheme.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

#define ITET_DEF_CELL_WIDTH		20
#define ITET_DEF_CELL_HEIGHT	20

@interface iTetTheme : NSObject <NSCoding>
{
	NSString* themeFilePath;
	NSString* imageFilePath;
	
	NSString* themeName;
	NSString* themeAuthor;
	NSString* themeDescription;
	
	NSImage* localFieldBackground;
	NSImage* remoteFieldBackground;
	NSSize cellSize;
	NSArray* cellImages;
	NSArray* specialImages;
	NSImage* preview;
}

+ (iTetTheme*)currentTheme;
+ (NSArray*)defaultThemes;
+ (id)defaultTheme;
+ (id)themeFromThemeFile:(NSString*)path;

// Designated initializer; all others call this
- (id)initWithThemeFile:(NSString*)path;

- (void)copyFilesToSupportDirectory;
- (void)removeFilesFromSupportDirectory;

@property (readonly) NSString* themeFilePath;
@property (readonly) NSString* imageFilePath;

@property (readonly) NSString* themeName;
@property (readonly) NSString* themeAuthor;
@property (readonly) NSString* themeDescription;

@property (readonly) NSImage* localFieldBackground;
@property (readonly) NSImage* remoteFieldBackground;

@property (readonly) NSSize cellSize;
- (NSImage*)imageForCellType:(uint8_t)cellType;

@property (readonly) NSImage* preview;

@end
