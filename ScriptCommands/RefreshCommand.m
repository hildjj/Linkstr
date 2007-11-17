//
//  RefreshCommand.m
//  InsDrppr
//
//  Created by Joe Hildebrand on 7/7/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "RefreshCommand.h"
#import "Linkstr_AppDelegate.h"

@implementation RefreshCommand

- (id)performDefaultImplementation
{
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    [l refresh:self]; 
    return nil;
}

@end
