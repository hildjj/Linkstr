//
//  LSAddChromeHistory.m
//  Linkstr
//
//  Created by Joe Hildebrand on 8/26/10.
//  Copyright (c) 2010 Cisco Systems, Inc. All rights reserved.
//

#import "LSAddChromeHistoryCommand.h"
#import "Linkstr_AppDelegate.h"

@implementation LSAddChromeHistoryCommand

- (id)performDefaultImplementation;
{
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    [l importChromeHistory:self];
    return nil;
}

@end
