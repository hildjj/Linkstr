//
//  GrowlNagler.h
//  Linkstr
//
//  Created by Joe Hildebrand on 8/15/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PendingLink.h"

@interface GrowlNagler : NSObject 
{
    NSMutableArray *m_queue;
    NSTimer *m_timer;
}

- (void)scheduleAdd:(PendingLink *)p;

@end
