#import "ImportHTML.h"
#import "KeypressTableView.h"

@implementation ImportHTML

- (id)init
{
    if (![super init])
        return nil;
    [NSBundle loadNibNamed:@"Importer" owner:self];
    return self;
}

- (void) dealloc 
{
    [m_html release], m_html = nil;
    [m_source release], m_source = nil;
    [m_delegate release], m_delegate = nil;
    [super dealloc];
}

- (id)initWithHtmlString:(NSString*)html
                  source:(NSString*)source 
                 linkstr:(Linkstr_AppDelegate*)delegate;
{
    if (![self init])
        return nil;
    [self setDelegate:delegate];
    [self setHtml:html];
    [self setSource:source];
    
    return self;
}

- (void)awakeFromNib;
{
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
    
    NSEnumerator *en = [[e children] objectEnumerator];
    NSXMLNode *child;
    while ((child = [en nextObject]))
    {
        if ([child kind] == NSXMLElementKind)
            [self searchElement:(NSXMLElement*)child];
    }
}

- (void)setHtml:(NSString*)html;
{
    m_html = [html retain];
    
    NSXMLDocument *doc = 
        [[NSXMLDocument alloc] initWithXMLString:m_html
                                         options:NSXMLDocumentTidyHTML
                                           error:nil];
    [self searchElement:[doc rootElement]];
}

- (NSString*)html;
{
    return [[m_html retain] autorelease];
}

- (void)setSource:(NSString*)source;
{
    m_source = [source retain];
}

- (NSString*)source;
{
    return [[m_source retain] autorelease];
}

- (void)setDelegate:(Linkstr_AppDelegate*)delegate;
{
    m_delegate = [delegate retain];
}

- (Linkstr_AppDelegate*)delegate;
{
    return [[m_delegate retain] autorelease];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
    [(KeyPressTableView*)aTableView willDisplayCell:aCell forTableColumn:aTableColumn row:rowIndex];
}

- (void)popup;
{
    assert(m_controller);
    assert([m_controller content]);
    int len = [[m_controller content] count];
    if (len == 0)
        return;
    if (len == 1)
    {
        [self insertCheckedLinks];
        return;
    }
    [m_win makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)insertCheckedLinks;
{
    NSEnumerator *en = [[m_controller content] objectEnumerator];
    NSDictionary *link;
    while ((link = [en nextObject]))
    {
        if (![[link objectForKey:@"checked"] boolValue])
            continue;
        PendingLink *p = [m_delegate insertURL:[link objectForKey:@"url"]
                               withDescription:[link objectForKey:@"desc"]];
        [p setSource:m_source];
    }    
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
    if ([m_all state] < 0)
    {
        [m_all setState:1];
    }
}
@end
