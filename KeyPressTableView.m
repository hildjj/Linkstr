//
//  KeyPressTableView.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/21/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "KeyPressTableView.h"
#import "LSDefaults.h"
#import <objc/runtime.h>

static NSColor *s_foreground = nil;
static NSArray *s_backgroundColors = nil;

@implementation KeyPressTableView

- (void)awakeFromNib;
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification 
                                               object:nil];
}

- (void)finalize; 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
    [super finalize];
}


- (void)defaultsDidChange:(NSNotification *)note
{
    s_foreground = nil;
    s_backgroundColors = nil;
    [self setNeedsDisplay];
}

- (void)keyDown:(NSEvent *)theEvent;
{
    id del = [self delegate];
    if ([del respondsToSelector:@selector(keyPressOnTableView:event:)])
    {
		if ([(id <KeyPressTableViewDelegate>)del keyPressOnTableView:self event:theEvent])
            return;
	}    
    
    [super keyDown:theEvent];
}

- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row;
{
    id aCell = [super preparedCellAtColumn:column row:row];
    if (![aCell respondsToSelector:@selector(setTextColor:)]) // we can change the text color
        return aCell;
    
    if (!s_foreground)
    {
        NSData *d=[[NSUserDefaults standardUserDefaults] dataForKey:TABLE_TEXT_FG];
        if (!d)
            return aCell;
        s_foreground = (NSColor *)[NSUnarchiver unarchiveObjectWithData:d];
    }
    [aCell setTextColor:s_foreground];
    return aCell;
}
@end

@implementation NSColor (LSAlternatingColor)

+ (NSArray *)controlAlternatingRowBackgroundColors; 
{
    if (!s_backgroundColors)
    {
        NSData *d = [[NSUserDefaults standardUserDefaults] dataForKey:TABLE_ODD_BG];
        if (!d)
            return nil;
        NSColor *odd = (NSColor *)[NSUnarchiver unarchiveObjectWithData:d];

        d = [[NSUserDefaults standardUserDefaults] dataForKey:TABLE_EVEN_BG];
        if (!d)
            return nil;
        NSColor *even = (NSColor *)[NSUnarchiver unarchiveObjectWithData:d];
            
        s_backgroundColors = [NSArray arrayWithObjects:odd, even, nil];
    }
    return s_backgroundColors;
}
@end
