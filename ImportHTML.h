/* ImportHTML */

#import <Cocoa/Cocoa.h>
#import "Linkstr_AppDelegate.h"

@interface ImportHTML : NSObject
{
@private
    IBOutlet NSWindow *m_win;
//    IBOutlet NSTableView *m_table;
    IBOutlet NSArrayController *m_controller;
    IBOutlet NSButton *m_all;
    NSString *m_html;
    NSString *m_source;
    Linkstr_AppDelegate *m_delegate;
}

@property (retain) NSString *source;
@property (retain) Linkstr_AppDelegate *delegate;
@property (retain, getter=getHtml, setter=setHtml:) NSString* html;

- (id)initWithHtmlString:(NSString*)html 
                  source:(NSString*)source 
                 linkstr:(Linkstr_AppDelegate*)delegate;

- (void)insertCheckedLinks;
- (int)popup;
- (IBAction)done:(id)sender;
- (IBAction)setAll:(id)sender;

@end
