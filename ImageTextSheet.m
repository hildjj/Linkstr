#import "ImageTextSheet.h"

@implementation ImageTextSheet

- (id)init
{
    if (![super init])
        return nil;
    [NSBundle loadNibNamed:@"ImageTextSheet" owner:self];
    return self;
}

- (void)setDelegate:(id)delegate
{
    m_delegate = delegate;
}

- (id)delegate
{
    return m_delegate;
}

- (void)popup:(NSWindow*)parent callback:(SEL)sel context:(void*)contextInfo;
{
    m_callback = sel;
    [NSApp beginSheet:m_win 
       modalForWindow:parent 
        modalDelegate:self 
       didEndSelector:@selector(sheetDidEnd: returnCode: contextInfo:) 
          contextInfo:contextInfo];
}

- (void)sheetDidEnd:(NSWindow *)sheet 
         returnCode:(int)returnCode 
        contextInfo:(void *)contextInfo;
{
    if (returnCode != NSOKButton)
        return;
    if (!m_delegate)
        return;
    NSString *val = [m_text stringValue];
    if ([val length] == 0)
        return;
    [m_text setStringValue:@""];
    objc_msgSend(m_delegate, m_callback, val, contextInfo);
}

- (IBAction)done:(id)sender
{
    NSButton *s = sender;
    if (!s)
        return;
    if ([s tag] == 0)
        [NSApp endSheet:m_win returnCode:NSOKButton];
    else
        [NSApp endSheet:m_win returnCode:NSCancelButton];
    [m_win orderOut:nil];
}

- (void)setTitle:(NSString*)title
{
    [m_win setTitle:title];
    [m_title setStringValue:title];
}

- (void)setImage:(NSImage*)image
{
    NSSize new_image_size = {0.0, 0.0};
    if (image)
    {
        new_image_size = [image size];
    }
    
    // min size
    NSSize min;
    min.width = new_image_size.width + 200;
    int h = new_image_size.height + 60;
    min.height = h > 104 ? h : 104;
    [m_win setMinSize:min];

    // start size
    /*
    NSRect contentFrameInWindowCoordinates = [m_win contentRectForFrameRect:[m_win frame]];
    
    float heightAdjustment = min.height - NSHeight(contentFrameInWindowCoordinates);
    contentFrameInWindowCoordinates.origin.y -= heightAdjustment;
    contentFrameInWindowCoordinates.size.height += heightAdjustment;
    [m_win setFrame:[m_win frameRectForContentRect:contentFrameInWindowCoordinates] 
            display:[m_win isVisible]
            animate:[m_win isVisible]];
    */
    
    
    NSSize win_size = [m_win frame].size;
    win_size.width = min.width;
    win_size.height = min.height;
    [m_win setContentSize:win_size];
    
    
    
    [m_image setFrameSize:new_image_size];
    [m_image setImage:image];
    
    // textbox width
    NSRect tf = [m_text frame];
    tf.origin.x = new_image_size.width + 28;
    tf.size.width = min.width - tf.origin.x - 20;
    [m_text setFrame:tf];
    
    // max size
    min.width = 1000;
    [m_win setMaxSize:min];
    
    [m_win display];
}
        
@end
