//
//  LSCheckRedundantCommand.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/25/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "LSCheckRedundantCommand.h"
#import "Linkstr_AppDelegate.h"

@implementation LSCheckRedundantCommand

- (id)performDefaultImplementation;
{
    NSString *url = [self directParameter];
    if (!url || !url.length)
        return nil;
    NSString *desc = [[self evaluatedArguments] objectForKey:@"desc"];
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    BOOL ret = [l checkRedundant:url forType:@"R" withDate:nil withDescription:desc];
    return [NSNumber numberWithBool:ret];
}
@end
