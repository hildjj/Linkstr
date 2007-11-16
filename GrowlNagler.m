//
//  GrowlNagler.m
//  Linkstr
//
//  Created by Joe Hildebrand on 8/15/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "GrowlNagler.h"
#import "Growl/Growl.h"

@implementation GrowlNagler

- (id)init;
{
    self = [super init];
    if (!self)
        return nil;
    m_queue = [[NSMutableArray alloc] init];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1000.0
                                               target:self
                                             selector:@selector(timerFired:)
                                             userInfo:nil
                                              repeats:YES];
    return self;
}

- (void)timerFired:(NSTimer*)theTimer;
{
    [m_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1000.0]];
    int count = [m_queue count];
    PendingLink *p;
    switch (count)
    {
    case 0:
        return;
    case 1:
        p = [m_queue objectAtIndex:0];
        [GrowlApplicationBridge notifyWithTitle:[p text] 
                                    description:[p url]
                               notificationName:@"New Link"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:[p url]];    
        break;
    default:
        [GrowlApplicationBridge notifyWithTitle:@"Pending Links"
                                    description:[NSString stringWithFormat:@"%d Links Added", count] 
                               notificationName:@"New Link"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:@""];    
        break;
    }
    [m_queue removeAllObjects];
    
}

- (void)scheduleAdd:(PendingLink *)p;
{
    [m_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    [m_queue addObject:p];
}
@end
