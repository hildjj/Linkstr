//
//  LSAddSafariHistoryCommand.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/26/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "LSAddSafariHistoryCommand.h"
#import "Linkstr_AppDelegate.h"

@implementation LSAddSafariHistoryCommand

- (id)performDefaultImplementation;
{
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    [l importSafariHistory:self];
    return nil;
}
@end
