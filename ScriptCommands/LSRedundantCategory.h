//
//  LSRedundantCategory.h
//  Linkstr
//
//  Created by Joe Hildebrand on 11/16/07.
//  Copyright 2007 Cursive Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Linkstr_AppDelegate.h"

@interface Linkstr_AppDelegate (LSRedundantCategory)
- (id)valueInRedundantsWithUniqueID:(NSString *)string;
- (void)removeFromRedundantsAtIndex:(unsigned int)i;
- (id)createRedundantUrl:(NSString*)url;
@end
