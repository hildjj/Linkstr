/* ImageTextSheet */

#import <Cocoa/Cocoa.h>

@interface ImageTextSheet : NSObject
{
    IBOutlet NSWindow *m_win;
    IBOutlet NSImageView *m_image;
    IBOutlet NSTextField *m_text;
    IBOutlet NSTextField *m_title;
    
    id m_delegate;
    SEL m_callback;
}

- (void)setDelegate:(id)delegate;
- (id)delegate;

- (void)popup:(NSWindow*)parent callback:(SEL)sel context:(void*)contextInfo;
- (IBAction)done:(id)sender;
- (void)setTitle:(NSString*)title;
- (void)setImage:(NSImage*)image;
@end
