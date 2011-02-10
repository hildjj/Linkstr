//
//  OpenAllCommand.m
//  InsDrppr
//
//  Created by Joe Hildebrand on 7/1/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "OpenAllCommand.h"
#import "Linkstr_AppDelegate.h"

@implementation OpenAllCommand

- (id)performDefaultImplementation
{
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    [l launchAll:self];
    return nil;
}

@end
