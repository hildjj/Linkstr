//
//  KeyPressTableView.h
//  Linkstr
//
//  Created by Joe Hildebrand on 7/21/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KeyPressTableViewDelegate
-(void)keyPressOnTableView:(NSTableView*)view event:(NSEvent *)theEvent;
@end

@interface KeyPressTableView : NSTableView
{    
}

- (void)willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
@end

@interface NSColor (LSAlternatingColor)
+ (NSArray *)controlAlternatingRowBackgroundColors;
@end
