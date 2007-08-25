//
//  CreateCommand.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/22/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "LSCreateCommand.h"
#import "PendingLink.h"
#import "Linkstr_AppDelegate.h"

@implementation LSCreateCommand

- (id)performDefaultImplementation;
{
    unsigned long classCode = [[self createClassDescription] appleEventCode];
    if (classCode == 'pLnk')
    {
        NSDictionary *props = [self resolvedKeyDictionary];
        NSLog(@"create pending link: %@", props);
        NSLog(@"desc: %@", [props objectForKey:@"descr"]);
        
        Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
        PendingLink *p = [l insertURL:[props objectForKey:@"url"]
                      withDescription:[props objectForKey:@"descr"]];                

//        NSString *uniqueID = [[[p objectID] URIRepresentation] absoluteString];
//        NSLog(@"Done (uid=%@)", uniqueID);
        return [p objectSpecifier];
        //return [[NSUniqueIDSpecifier alloc] initWithContainerClassDescription:[documentSpecifier keyClassDescription] containerSpecifier:documentSpecifier key:@"persons" uniqueID:uniqueID];
    }
    
    return [super performDefaultImplementation];
}
@end
