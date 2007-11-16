//
//  CreateCommand.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/22/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "LSCreateCommand.h"
#import "PendingLink.h"
#import "urlList.h"
#import "Linkstr_AppDelegate.h"

@implementation LSCreateCommand

- (id)performDefaultImplementation;
{
    unsigned long classCode = [[self createClassDescription] appleEventCode];
    if (classCode == 'pLnk')
    {
        NSDictionary *props = [self resolvedKeyDictionary];
        
        Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
        NSString *site = [props objectForKey:@"site"];
        PendingLink *p;
        if (site)
            p = [l insertTerms:[props objectForKey:@"terms"] forSite:site];
        else
            p = [l insertURL:[props objectForKey:@"url"]
             withDescription:[props objectForKey:@"descr"]];                

        return [p objectSpecifier];
    }
    else if (classCode == 'tRur')
    {
        NSDictionary *props = [self resolvedKeyDictionary];
        
        Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
        urlList *u = [l createRedundantUrl:[props  objectForKey:@"url"]];
        
        return [u objectSpecifier];
        
    }
    return [super performDefaultImplementation];
}
@end
