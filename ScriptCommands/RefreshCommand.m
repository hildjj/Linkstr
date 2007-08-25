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
    // You might think this would lead to a leak, but you'd be wrong.
    // Apparently calling through the delegate leads to an NSInvocation, which then
    // calls back here.  Without the retain, we'd release twice.
    [self retain];
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    [l refresh:self]; 
    return nil;
     
}

@end
