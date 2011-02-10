//
//  Sites.h
//  Linkstr
//
//  Created by Joe Hildebrand on 9/15/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Sites : NSArrayController
{
}

+ (void)addSitesToMenu:(NSMenu*)menu target:(id)target action:(SEL)action;

@end
