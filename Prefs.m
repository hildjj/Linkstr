//
//  Prefs.m
//  Linkstr
//
//  Created by Joe Hildebrand on 9/13/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "Prefs.h"


@implementation Prefs

-(id)init;
{
    if (!(self = [super initWithWindowNibName:@"Prefs" owner:self]))
        return nil;
    return self;
}

- (void)dealloc;
{
    [m_sites release], m_sites = nil;
    
    [super dealloc];
}

@end
