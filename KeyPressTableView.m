//
//  KeyPressTableView.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/21/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "KeyPressTableView.h"

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

- (void) dealloc 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
    [super dealloc];
}

- (void)defaultsDidChange:(NSNotification *)note
{
    [s_foreground release], s_foreground = nil;
    [s_backgroundColors release], s_backgroundColors = nil;
    [self setNeedsDisplay];
}

- (void)keyDown:(NSEvent *)theEvent;
{
    id del = [self delegate];
    if ([del respondsToSelector:@selector(keyPressOnTableView:event:)])
    {
		[(id <KeyPressTableViewDelegate>)del keyPressOnTableView:self event:theEvent];
	}    
    [super keyDown:theEvent];
}

- (void)willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
    if (![aCell respondsToSelector:@selector(setTextColor:)]) // we can change the text color
        return;
    
    if (!s_foreground)
    {
        NSData *d=[[NSUserDefaults standardUserDefaults] dataForKey:@"tableTextForeground"];
        if (!d)
            return;
        s_foreground = [(NSColor *)[NSUnarchiver unarchiveObjectWithData:d] retain];
    }
    [aCell setTextColor:s_foreground];
}

@end

@implementation NSColor (LSAlternatingColor)

+ (NSArray *)controlAlternatingRowBackgroundColors; 
{
    if (!s_backgroundColors)
    {
        NSData *d = [[NSUserDefaults standardUserDefaults] dataForKey:@"tableOddBackground"];
        if (!d)
            return nil;
        NSColor *odd = (NSColor *)[NSUnarchiver unarchiveObjectWithData:d];

        d = [[NSUserDefaults standardUserDefaults] dataForKey:@"tableEvenBackground"];
        if (!d)
            return nil;
        NSColor *even = (NSColor *)[NSUnarchiver unarchiveObjectWithData:d];
            
        s_backgroundColors = [[NSArray arrayWithObjects:odd, even, nil] retain];
    }
    return [[s_backgroundColors retain] autorelease];
}
@end
