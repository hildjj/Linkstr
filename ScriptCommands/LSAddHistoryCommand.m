//
//  LSAddHistoryCommand.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/26/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "LSAddHistoryCommand.h"
#import "Linkstr_AppDelegate.h"

@implementation LSAddHistoryCommand

- (id)performDefaultImplementation;
{
    NSString *url = [self directParameter];
    if (!url)
        return nil;
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    BOOL ret = [l checkRedundant:url forType:@"H" withDate:nil withDescription:nil];
    return [NSNumber numberWithBool:ret];
}
@end
