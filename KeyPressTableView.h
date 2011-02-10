//
//  KeyPressTableView.h
//  Linkstr
//
//  Created by Joe Hildebrand on 7/21/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KeyPressTableViewDelegate
-(BOOL)keyPressOnTableView:(NSTableView*)view event:(NSEvent *)theEvent;
@end

@interface KeyPressTableView : NSTableView
{    
}

- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row;
@end

@interface NSColor (LSAlternatingColor)
+ (NSArray *)controlAlternatingRowBackgroundColors;
@end
