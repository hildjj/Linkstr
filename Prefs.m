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

- (void)showWindow:(id)sender;
{
    [super showWindow:sender];
    [[self window] makeKeyAndOrderFront:sender];
}

@end
