//
//  Prefs.m
//  Linkstr
//
//  Created by Joe Hildebrand on 9/13/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "Prefs.h"
#import "KeyPressTableView.h"

@implementation Prefs

-(id)init;
{
    if (!(self = [super initWithWindowNibName:@"Prefs" owner:self]))
        return nil;
    
    return self;
}

- (void)dealloc;
{
    [m_sites release], m_sites = nil;
    
    [super dealloc];
}

- (void)showWindow:(id)sender;
{
    [super showWindow:sender];
    [[self window] makeKeyAndOrderFront:sender];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
    [(KeyPressTableView*)aTableView willDisplayCell:aCell forTableColumn:aTableColumn row:rowIndex];
}

@end
