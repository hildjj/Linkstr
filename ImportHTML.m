#import "ImportHTML.h"
#import "KeypressTableView.h"

@implementation ImportHTML

@synthesize source = m_source;
@synthesize delegate = m_delegate;

- (id)init
{
    if (![super init])
        return nil;
    [NSBundle loadNibNamed:@"Importer" owner:self];
    return self;
}

- (id)initWithHtmlString:(NSString*)html
                  source:(NSString*)source 
                 linkstr:(Linkstr_AppDelegate*)delegate;
{
    if (![self init])
        return nil;
    self.delegate = delegate;
    self.html = html;
    self.source = source;
    
    return self;
}

- (void)awakeFromNib;
{
}

- (NSString*)getHtml;
{
    return m_html;
}

- (void)searchElement:(NSXMLElement*)e
{
    if ([[e name] isEqual:@"a"])
    {
        NSXMLNode *href = [e attributeForName:@"href"];
        if (href)
        {
            [m_controller addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], @"checked", 
                [href stringValue], @"url",
                [e stringValue], @"desc",
                nil]];
        }
    }
    
    for (NSXMLNode *child in [e children])
    {
        if ([child kind] == NSXMLElementKind)
            [self searchElement:(NSXMLElement*)child];
    }
}

- (void)setHtml:(NSString*)html;
{
    m_html = html;
    
    NSXMLDocument *doc = 
        [[NSXMLDocument alloc] initWithXMLString:m_html
                                         options:NSXMLDocumentTidyHTML
                                           error:nil];
    [self searchElement:[doc rootElement]];
}

- (int)popup;
{
    assert(m_controller);
    assert([m_controller content]);
    int len = [[m_controller content] count];
    if (len == 0)
        return 0;
    if (len == 1)
    {
        [self insertCheckedLinks];
        return 1;
    }
    [m_win makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    return len;
}

- (void)insertCheckedLinks;
{
    NSMutableDictionary *possible = [NSMutableDictionary dictionaryWithCapacity:[[m_controller content] count]];
    for (NSDictionary *lnk in [m_controller content])
    {
        if (![[lnk objectForKey:@"checked"] boolValue])
            continue;
        [possible setObject:[lnk objectForKey:@"desc"] forKey:[lnk objectForKey:@"url"]];
    }    
    int count = [self.delegate createLinksFromDictionary:possible onDates:nil fromSource:self.source];
    [GrowlApplicationBridge notifyWithTitle:@"Pending Links"
                                description:[NSString stringWithFormat:@"%d Links Added", count] 
                           notificationName:@"New Link"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@""];    
}

- (IBAction)done:(id)sender;
{
    NSButton *s = sender;
    if (!s)
        return;
    if ([s tag] == 0)
    {
        [NSApp endSheet:m_win returnCode:NSOKButton];
        [self insertCheckedLinks];
    }
    else
        [NSApp endSheet:m_win returnCode:NSCancelButton];
    [m_win orderOut:nil];    
}

- (IBAction)setAll:(id)sender;
{
#pragma unused(sender)
    if ([m_all state] < 0)
    {
        [m_all setState:1];
    }
}
@end
