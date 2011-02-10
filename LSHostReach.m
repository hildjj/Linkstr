//
//  LSHostReach.m
//  Linkstr
//
//  Created by Joe Hildebrand on 10/25/09.
//  Copyright 2009 Cisco Systems. All rights reserved.
//

#import "LSHostReach.h"


@implementation LSHostReach

@synthesize host;

- (void)fire:(SCNetworkConnectionFlags)flags
{
    NSNumber *nxt = [NSNumber numberWithBool:((flags & kSCNetworkFlagsReachable) == kSCNetworkFlagsReachable)];
    if (![nxt isEqualToNumber:last])
    {
        last = nxt;
        [target performSelector:sel withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                nxt, LSHostReach_REACHABLE,
                                                host, LSHostReach_HOST,
                                                self, LSHostReach_SENDER,
                                                nil]];
    }
}
     
static void reachCB(SCNetworkReachabilityRef target,
                    SCNetworkConnectionFlags flags,
                    void *                   info)
{
    LSHostReach *reach = (id)info;
    [reach fire:flags];
}

- (id)initWithHost:(NSString*)aHost forTarget:(id)aTarget andSelector:(SEL)aSel
{
    
    if (!aHost || !aTarget || !aSel) 
        return nil;
    
    self = [super init];
    if (!self)
        return nil;
    
    last = [NSNumber numberWithInt:-1];
    reachRef = SCNetworkReachabilityCreateWithName(NULL, 
                                                   [aHost cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!reachRef)
    {
        NSLog(@"Error, reach exceeds grasp: '%s'", SCErrorString(SCError()));
        return nil;        
    }
    
    SCNetworkReachabilityContext context = {
        .version         = 0,
        .info            = self,
        .retain          = NULL,
        .release         = NULL,
        .copyDescription = NULL
    };
    
    if (!SCNetworkReachabilitySetCallback(reachRef,
                                          reachCB,
                                          &context))
    {
        NSLog(@"Error, reach callback: '%s'", SCErrorString(SCError()));
        CFRelease(reachRef); reachRef = nil;
        return nil;
    }
    
    if (!SCNetworkReachabilityScheduleWithRunLoop(reachRef, 
                                                  CFRunLoopGetCurrent(), 
                                                  kCFRunLoopDefaultMode))
    {
        NSLog(@"Error, reach schedule: '%s'", SCErrorString(SCError()));
        CFRelease(reachRef); reachRef = nil;
        return nil;        
    }
    
    SCNetworkConnectionFlags flags;    
    if (!SCNetworkReachabilityGetFlags(reachRef, &flags))
    {
        NSLog(@"Error, flags: '%s'", SCErrorString(SCError()));
        SCNetworkReachabilityUnscheduleFromRunLoop(reachRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
        CFRelease(reachRef); reachRef = nil;
        return nil;        
    }
    
    host = aHost;
    target = aTarget;
    sel = aSel;
    
    // Send notification now
    [self fire:flags];
    return self;
}

- (void)finalize
{
    if (reachRef)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
        
        CFRelease(reachRef); reachRef = nil;
    }
    
    [super finalize];
}
@end
