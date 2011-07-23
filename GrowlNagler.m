//
//  GrowlNagler.m
//  Linkstr
//
//  Created by Joe Hildebrand on 8/15/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "GrowlNagler.h"
#import "LSDefaults.h"

@implementation GrowlNagler

@synthesize delegate = m_delegate;

- (id)initWithDelegate:(id)delegate;
{
    self = [super init];
    if (!self)
        return nil;
    self.delegate = delegate;
    m_queue = [[NSMutableArray alloc] init];
    return self;
}

- (void)timerFired;
{
    //    NSLog(@"fire: %@", [NSCalendarDate date]);
    if ([self.delegate respondsToSelector:@selector(nagler:firedForPending:)])
        [self.delegate nagler:self firedForPending:m_queue];

    [m_queue removeAllObjects];
}

- (void)scheduleAddObject:(id)object;
{
    NSLog(@"add: %@", [NSCalendarDate date]);
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [m_queue addObject:object];
    double delay = [[NSUserDefaults standardUserDefaults] floatForKey:NAGLE_TIME_S];
    [self performSelector:@selector(timerFired) withObject:nil afterDelay:delay];
}
@end
