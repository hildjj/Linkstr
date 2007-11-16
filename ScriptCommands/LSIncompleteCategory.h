//
//  LSIncompleteCategory.h
//  Linkstr
//
//  Created by Joe Hildebrand on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Linkstr_AppDelegate.h"

@interface Linkstr_AppDelegate (LSIncompleteCategory)
- (id)valueInIncompletesWithUniqueID:(NSString *)string;
- (void)removeFromIncompletesAtIndex:(unsigned int)i;
- (id)createIncompleteUrl:(NSString*)url;
@end
