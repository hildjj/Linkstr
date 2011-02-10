//
//  LSHostReach.h
//  Linkstr
//
//  Created by Joe Hildebrand on 10/25/09.
//  Copyright 2009 Cisco Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <SystemConfiguration/SystemConfiguration.h>

#define LSHostReach_REACHABLE @"LSHostReach_REACHABLE"
#define LSHostReach_HOST      @"LSHostReach_HOST"
#define LSHostReach_SENDER    @"LSHostReach_SENDER"

@interface LSHostReach : NSObject 
{
    NSString *host;
    SCNetworkReachabilityRef reachRef;
    id target;
    SEL sel;
    NSNumber *last;
}

@property (readonly) NSString *host;

- (id)initWithHost:(NSString*)aHost forTarget:(id)aTarget andSelector:(SEL)aSel;

@end
