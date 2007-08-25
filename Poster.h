//
//  Keychain.h
//  Linkstr
//
//  Created by Joe Hildebrand on 8/22/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Poster : NSObject 
{
    IBOutlet NSWindow *m_win;
    IBOutlet NSTextField *m_user;
    IBOutlet NSTextField *m_pass;
    
    int m_outstanding;
    int m_total;
    id m_delegate;
}

- (id)initWithDelegate:(id)delegate;
- (IBAction)done:(id)sender;

- (void)getURL:(NSString*)url;
- (void)getURL:(NSString*)url withParams:(NSDictionary*)params;

@end

@interface NSObject(PosterDelegateMethods)
- (void)poster:(Poster*)poster finishedOutstanding:(int)total;
@end

