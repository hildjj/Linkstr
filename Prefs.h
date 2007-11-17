//
//  Prefs.h
//  Linkstr
//
//  Created by Joe Hildebrand on 9/13/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Prefs : NSWindowController
{
    IBOutlet NSArrayController *m_sites;
}

-(id)init;

@end
