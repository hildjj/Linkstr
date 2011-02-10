//
//  LSIterateState.h
//  Linkstr
//
//  Created by Joe Hildebrand on 12/21/09.
//  Copyright 2009 Cisco Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LSTimerIterator : NSObject
{
    NSArray *items;
    NSCalendarDate *startTime;
    NSTimer *timer;
    NSProgressIndicator *progress;
    id target;
    SEL selector;
    int total;
    int count;
    int cur;
}

// selector takes form:
// - (uint)firedIterator:(LSTimerIterator*)it withObjects:(NSArray*)group
- (id)initWithArray:(NSArray*)theItems 
       timeInterval:(NSTimeInterval)seconds
             target:(id)target 
           selector:(SEL)aSelector 
            repeats:(BOOL)repeats
           progress:(NSProgressIndicator*)aProgress;

@property (readonly)NSCalendarDate *startTime;
@property (readonly)int total;
@property (readonly)int count;
@end
