//
//  iTetField.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import <Cocoa/Cocoa.h>

#define ITET_FIELD_WIDTH	12
#define ITET_FIELD_HEIGHT	22

typedef enum
{
	obstructNone =	0,
	obstructVert =	1,
	obstructHoriz =	2
} iTetObstructionState;

@class iTetBlock;

@interface iTetField: NSObject <NSCopying>
{
	// Contents of the field, indexed row/column, bottom-to-top, left-to-right
	char contents[ITET_FIELD_HEIGHT][ITET_FIELD_WIDTH];
	
	// The delta created by the last block added to the field
	NSString* lastPartialUpdate;
}

// Initializer for an empty field
+ (id)field;

// Initializer from a fieldstring sent by the server
+ (id)fieldFromFieldstring:(NSString*)fieldstring;
- (id)initWithFieldstring:(NSString*)fieldstring;

// Initializers for a field with a starting stack height
+ (id)fieldWithStackHeight:(NSInteger)stackHeight;
- (id)initWithStackHeight:(NSInteger)stackHeight;

// Initializers for a random field
+ (id)fieldWithRandomContents;
- (id)initWithRandomContents;

// Copy initializer
- (id)initWithContents:(char[ITET_FIELD_HEIGHT][ITET_FIELD_WIDTH])fieldContents;

// Checks whether a block is in a valid position on the field
- (iTetObstructionState)blockObstructed:(iTetBlock*)block;

// Checks whether the specified cell is valid (i.e., on the field) and empty
- (iTetObstructionState)cellObstructedAtRow:(int)row
						 column:(int)col;

// Add the cells of the specified block to the field's contents
- (void)solidifyBlock:(iTetBlock*)block;

// Check for and clear completed lines on the field; returns the number of lines cleared
- (NSInteger)clearLinesAndRetrieveSpecials:(NSMutableArray*)specials;

// Clear completed lines, without retrieving specials or counting lines
- (void)clearLines;

// Add a partial update from the server to the field
- (void)applyPartialUpdate:(NSString*)partialUpdate;

// Adds the specified number of specials to the board, using the provided frequencies
// note: specialFrequencies must be exactly 100 characters in length
- (void)addSpecials:(NSInteger)count
   usingFrequencies:(char*)specialFrequencies;

// Adds lines of garbage to the bottom of the field, pushing other lines up
// Returns YES if the field overflows (player loses)
- (BOOL)addLines:(NSInteger)count;

// Clears the bottom line of the field, shifting others down; does not collect specials
- (void)clearBottomLine;

// Clears ten random cells on the board
- (void)clearRandomCells;

// Turns all special blocks on the board into normal cells
- (void)removeAllSpecials;

// Pulls all cells down, filling gaps
- (void)pullCellsDown;

// Randomly shifts all rows on the board 0-3 columns left or right
- (void)randomShiftRows;

// "Explodes" all block bomb specials on the field, scattering the cells around them
- (void)explodeBlockBombs;

// Shifts the specified row horizontally by the specified number of columns in the specified direction
- (void)shiftRow:(NSInteger)row
	  byAmount:(NSInteger)shiftAmount
     inDirection:(BOOL)shiftLeft;

// Returns the contents of the specified cell of the field
- (char)cellAtRow:(NSInteger)row
	     column:(NSInteger)column;

// The current fieldstring that describes the state of the field
- (NSString*)fieldstring;

// The fieldstring for last partial update
@property (readwrite, retain) NSString* lastPartialUpdate;

@end
