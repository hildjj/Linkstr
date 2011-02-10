//
//  GrowlNagler.h
//  Linkstr
//
//  Created by Joe Hildebrand on 8/15/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GrowlNagler : NSObject 
{
@private
    NSMutableArray *m_queue;
    id m_delegate;
}

@property id delegate;
- (id)initWithDelegate:(id)delegate;
- (void)scheduleAddObject:(id)object;

@end

@interface NSObject(NaglerDelegateMethods)
- (void)nagler:(GrowlNagler*)growlNagler firedForPending:(NSArray*)pending;
@end
