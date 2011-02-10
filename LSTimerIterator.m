//
//  LSIterateState.m
//  Linkstr
//
//  Created by Joe Hildebrand on 12/21/09.
//  Copyright 2009 Cisco Systems. All rights reserved.
//

#import "LSTimerIterator.h"
#import <objc/objc-runtime.h>

@implementation LSTimerIterator

@synthesize startTime;
@synthesize total;
@synthesize count;

static uint (*uint_objc_msgSend)(id object, SEL cmd, id sender, id obj) = (uint (*)(id, SEL, id, id))&objc_msgSend;

- (void)timerFireMethod:(NSTimer*)theTimer
{
    if (cur >= self->total)
    {
        [theTimer invalidate];
        uint_objc_msgSend(self->target, self->selector, self, nil);
        [self->progress stopAnimation:self];
        [self->progress setHidden:YES];
        return;
    }
    int sz = 5;
    if ((cur + sz) > self->total)
    {
        sz = self->total - cur;
    }
    
    NSArray *slice = [self->items subarrayWithRange:NSMakeRange(cur, sz)];
    // Invoke the selector, hacking around the complier warning.
    uint res = uint_objc_msgSend(self->target, self->selector, self, slice);
    self->count += res;
    [self->progress incrementBy:sz];
    cur += sz;
}

- (id)initWithArray:(NSArray*)theItems 
       timeInterval:(NSTimeInterval)seconds
             target:(id)aTarget 
           selector:(SEL)aSelector 
            repeats:(BOOL)repeats
           progress:(NSProgressIndicator*)aProgress
{
    if (!theItems || ([theItems count] == 0))
        return nil;
    if (![super init])
        return nil;
    
    self->startTime = [NSCalendarDate calendarDate];
    self->items = theItems;
    self->total = [theItems count];
    self->count = 0;
    self->target = aTarget;
    self->selector = aSelector;
    if (aProgress)
    {
        self->progress = aProgress;
        [aProgress setHidden:NO];
        [aProgress setIndeterminate:NO];
        [aProgress setMinValue:0.0];
        [aProgress setMaxValue:(double)self->total];
        [aProgress setDoubleValue:0.0];        
        [aProgress startAnimation:self];
    }
    self->timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                   target:self
                                                 selector:@selector(timerFireMethod:)
                                                 userInfo:nil
                                                  repeats:repeats];
    [self timerFireMethod:self->timer];
    return self;
}

@end
