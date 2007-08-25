/* ImportHTML */

#import <Cocoa/Cocoa.h>
#import "Linkstr_AppDelegate.h"

@interface ImportHTML : NSObject
{
    IBOutlet NSWindow *m_win;
    IBOutlet NSTableView *m_table;
    IBOutlet NSArrayController *m_controller;
    IBOutlet NSButton *m_all;
    NSString *m_html;
    NSString *m_source;
    Linkstr_AppDelegate *m_delegate;
}

- (id)initWithHtmlString:(NSString*)html 
                  source:(NSString*)source 
                 linkstr:(Linkstr_AppDelegate*)delegate;

- (void)setHtml:(NSString*)html;
- (NSString*)html;

- (void)setSource:(NSString*)source;
- (NSString*)source;

- (void)setDelegate:(Linkstr_AppDelegate*)delegate;
- (Linkstr_AppDelegate*)delegate;

- (void)insertCheckedLinks;
- (void)popup;
- (IBAction)done:(id)sender;
- (IBAction)setAll:(id)sender;

@end
