//
//  LSShortenerCategory.h
//  Linkstr
//
//  Created by Joe Hildebrand on 8/31/10.
//  Copyright (c) 2010 Cisco Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Linkstr_AppDelegate.h"

@interface Linkstr_AppDelegate (LSShortenerCategory)
- (id)valueInShortnersWithUniqueID:(NSString *)string;
- (void)removeFromShortenersAtIndex:(unsigned int)i;
- (id)createShortenerUrl:(NSString*)url;
@end
