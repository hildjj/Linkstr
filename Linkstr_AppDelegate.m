//
//  Linkstr_AppDelegate.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/18/07.
//  Copyright Cursive Systems, Inc 2007 . All rights reserved.
//

#import "Linkstr_AppDelegate.h"
#import "PendingLink.h"
#import "urlList.h"
#import "ContextWindowController.h"
#import "KeyPressTableView.h"
#import "ImportHTML.h"
#import "Poster.h"
#import "Prefs.h"

NSString *PendingLinkPBoardType = @"PendingLinkPBoardType";

NSString *DRAWER = @"showDrawer";
NSString *ALPHA = @"alpha";
NSString *SQL_DEBUG = @"sqlDebug";
NSString *FLOAT = @"floatOnTop";
NSString *SITES = @"sites";
NSString *TABLE_TEXT_FG = @"tableTextForeground";
NSString *TABLE_ODD_BG = @"tableOddBackground";
NSString *TABLE_EVEN_BG = @"tableEvenBackground";
NSString *AGRESSIVE_CLOSE = @"agressiveClose";
NSString *FIRST_TIME = @"firstTime";
NSString *LAST_DELICIOUS = @"LastDeliciousDate";
NSString *IMPORT_HTTPS = @"importHTTPS";
NSString *AVOID_FUNNY = @"avoidFunnyLinks";

NSString *LINK_NEW = @"New Link";
NSString *LINK_DEL = @"Link Deleted";
NSString *LINKS_PENDING = @"Pending Links";
NSString *LINKS_REDUNDANT = @"Redundant Links";
NSString *LINKS_HISTORY = @"History Links";

NSString *DEL_UPDATE = @"https://api.del.icio.us/v1/posts/update";
NSString *DEL_ALL = @"https://api.del.icio.us/v1/posts/all";

static NSArray *s_SupportedTypes;

@implementation Linkstr_AppDelegate

- (NSMutableArray*)content;
{
    return [[[m_controller content] retain] autorelease];
}

- (NSWindow*)window;
{
    return [[m_win retain] autorelease];
}

+ (void)initialize;
{
    if (self != [Linkstr_AppDelegate class])
        return;
    
    NSArray *sites = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"Insert URL", @"name",
            @"%@", @"url",
            @"%@", @"description",
            @"u", @"key",
            @"formatURL:", @"formatter",
            [NSNumber numberWithUnsignedInt:NSControlKeyMask], @"mask",
            nil], @"URL",
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"Google", @"name",
            @"http://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8", @"url",
            @"Google search for '%@'", @"description",
            @"Google", @"image",
            @"g", @"key",
            [NSNumber numberWithUnsignedInt:NSControlKeyMask], @"mask",
            nil], @"Google",
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"Wikipedia", @"name",
            @"http://www.wikipedia.org/w/wiki.phtml?search=%@", @"url",
            @"Wikipedia search for '%@'", @"description",
            @"Wiki", @"image",
            @"w", @"key",
            [NSNumber numberWithUnsignedInt:NSControlKeyMask], @"mask",
            nil], @"Wikipedia",
        nil];
    
    [NSColor setIgnoresAlpha:NO];
    NSColor *txt_fg = [NSColor colorWithDeviceRed:1.0
                                            green:1.0
                                             blue:1.0
                                            alpha:0.6];
    NSColor *table_even_bg = [NSColor colorWithDeviceRed:0.2 
                                                   green:0.2 
                                                    blue:0.2
                                                   alpha:1.0];

    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"YES", DRAWER,
        @"NO", SQL_DEBUG,
        @"NO", FLOAT,
        @"YES", AGRESSIVE_CLOSE,
        @"YES", FIRST_TIME,
        @"NO", IMPORT_HTTPS,
        @"YES", AVOID_FUNNY,
        [NSNumber numberWithFloat:0.55], ALPHA,
        @"http://linkstr.net/changes.xml", @"SUFeedURL",
        sites, SITES,
        [NSArchiver archivedDataWithRootObject:txt_fg], TABLE_TEXT_FG,
        [NSArchiver archivedDataWithRootObject:table_even_bg], TABLE_EVEN_BG,
        [NSArchiver archivedDataWithRootObject:[NSColor blackColor]], TABLE_ODD_BG,
        nil]];
    
    s_SupportedTypes = [[NSArray arrayWithObjects:
        PendingLinkPBoardType,
        @"WebURLsWithTitlesPboardType",
        NSFilenamesPboardType,
        NSURLPboardType, 
        @"Apple Web Archive pasteboard type",
        NSStringPboardType, nil] retain];    
}

// order the keys of the array by the text that will be shown
int compareSites(id one, id two, void *context)
{
    NSDictionary *sites = (NSDictionary *)context;
    NSDictionary *od = [sites objectForKey:one];
    NSDictionary *td = [sites objectForKey:two];
    return [[od objectForKey:@"name"] compare:[td objectForKey:@"name"]];
}

- (void)awakeFromNib;
{
    m_closing = NO;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FLOAT])
        [m_win setLevel:NSFloatingWindowLevel];
    
    [m_win registerForDraggedTypes:s_SupportedTypes];
    [self setupToolbar]; 

    [m_table setDoubleAction:@selector(openSelected:)];
    [self setUnread:self];
    m_nagler = [[[GrowlNagler alloc] init] retain];
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    NSMenu *menu = [m_action submenu];
    id anon_sites = [[NSUserDefaults standardUserDefaults] objectForKey:SITES];
    NSDictionary *site;
    NSEnumerator *en;
    if ([anon_sites isKindOfClass:[NSArray class]])
    {
        // convert old.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        en = [anon_sites objectEnumerator];
        while ((site = [en nextObject]))
            [dict setObject:site forKey:[site objectForKey:@"name"]];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:SITES];
        anon_sites = dict;
    }
    NSDictionary *sites = anon_sites;
    NSArray *keys = [sites allKeys];
    keys = [keys sortedArrayUsingFunction:compareSites context:sites];
    
    en = [keys objectEnumerator];
    NSString *key;
    while ((key = [en nextObject]))
    {
        site = [sites objectForKey:key];
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTitle:[site objectForKey:@"name"]];
        key = [site objectForKey:@"key"];
        if (key)
            [item setKeyEquivalent:key];
        NSNumber *mask = [site objectForKey:@"mask"];
        if (mask)
            [item setKeyEquivalentModifierMask:[mask unsignedIntValue]];
        [item setAction:@selector(genericPopup:)];
        [item setRepresentedObject:site];
        [menu addItem:item];
//        [m_sites addObject:site];
    }        
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FIRST_TIME])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FIRST_TIME];
        if ([[self content] count] == 0)
        {
            [self insertURL:@"http://linkstr.net/GettingStarted.html" withDescription:@"Double-click here to start"];
        }
    }
}

- (void) dealloc 
{    
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [m_nagler release], m_nagler = nil;
    [m_prefs release], m_prefs = nil;
    [m_feeds release], m_feeds = nil;
    [m_history release], m_history = nil;
    
    [super dealloc];
}

- (NSString *)applicationSupportFolder;
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, 
                                                         NSUserDomainMask, 
                                                         YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
}

// Set the undread count in the icon
- (IBAction)setUnread:(id)sender;
{
    NSArray *unviewed = [self unviewedLinks];
    unsigned count = [unviewed count];
    
    if (count == 1)
        [m_win setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@: %ld Pending Link", @"window title, one link"), [[NSProcessInfo processInfo] processName], count]];
    else
        [m_win setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@: %ld Pending Links", @"window title, multiple links"), [[NSProcessInfo processInfo] processName], count]];
    
    NSImage *base = [NSImage imageNamed:@"Linkstr"];
    if (count == 0)
    {
        [NSApp setApplicationIconImage:base];
        return;
    }
    NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:48];
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor redColor], NSForegroundColorAttributeName,
		font, NSFontAttributeName,
		nil];
    NSString *cs = [NSString stringWithFormat:@"%ld", count];
    NSSize c_size = [cs sizeWithAttributes:attr];
    NSImage *red = [[NSImage alloc] initWithSize:[base size]];
    [red setFlipped:YES];
    NSRect rect = { NSZeroPoint, [base size] };
    rect.origin.x = rect.size.width - c_size.width - 3;
    rect.origin.y = rect.size.height - c_size.height - 3;
    
    [red lockFocus];
    [base compositeToPoint:NSMakePoint(0,rect.size.height) operation:NSCompositeSourceOver];    
    [cs drawInRect:rect withAttributes:attr];
    [red unlockFocus];
    [NSApp setApplicationIconImage:red];
    [red release];
}

#pragma mark -
#pragma mark Toolbar methods

- (void) setupToolbar;
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [m_win setToolbar:[toolbar autorelease]];      
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
{
    return [NSArray arrayWithObjects:@"launch",
        @"clear",
        @"removeLink",
        @"refresh",
        @"drawer",
        NSToolbarSeparatorItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier, 
        NSToolbarCustomizeToolbarItemIdentifier, 
        nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
{
    return [NSArray arrayWithObjects:@"launch", 
        @"clear",
        @"removeLink",
        @"drawer",
        NSToolbarFlexibleSpaceItemIdentifier, 
        NSToolbarCustomizeToolbarItemIdentifier, 
        nil];    
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    if ([itemIdentifier isEqualToString:@"removeLink"]) 
    {
        [item setLabel:NSLocalizedString(@"Remove", @"remove link")];
        [item setPaletteLabel:[item label]];
        [item setToolTip:[item label]];
        [item setImage:[NSImage imageNamed:@"Remove"]];
        [item setTarget:self];
        [item setAction:@selector(removeSelected:)];
    }    
    else if ([itemIdentifier isEqualToString:@"refresh"]) 
    {
        [item setLabel:NSLocalizedString(@"Refresh", @"refresh all")];
        [item setPaletteLabel:[item label]];
        [item setToolTip:[item label]];
        [item setImage:[NSImage imageNamed:@"Refresh"]];
        [item setTarget:self];
        [item setAction:@selector(refresh:)];
    }    
    else if ([itemIdentifier isEqualToString:@"launch"]) 
    {
        [item setLabel:NSLocalizedString(@"Open all", @"open all pending")];
        [item setPaletteLabel:[item label]];
        [item setToolTip:@"Open unseen links"];
        [item setTarget:self];
        [item setAction:@selector(launchAll:)];
        
        NSURL *appURL = nil;
        OSStatus err = LSGetApplicationForURL((CFURLRef)[NSURL URLWithString:@"http:"],
                                              kLSRolesAll, NULL, (CFURLRef *)&appURL);
        if (err == noErr)
        {
            NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
            [item setImage:iconImage];
        }
    }    
    else if ([itemIdentifier isEqualToString:@"drawer"]) 
    {
        [item setLabel:NSLocalizedString(@"Details", @"open drawer")];
        [item setPaletteLabel:[item label]];
        [item setToolTip:[item label]];
        [item setImage:[NSImage imageNamed:@"Sections"]];
        [item setTarget:self];
        [item setAction:@selector(toggleDrawer:)];
    } 
    else if ([itemIdentifier isEqualToString:@"clear"]) 
    {
        [item setLabel:NSLocalizedString(@"Clear Viewed", @"clear the viewed flag")];
        [item setPaletteLabel:[item label]];
        [item setToolTip:[item label]];
        [item setImage:[NSImage imageNamed:@"aquaball"]];
        [item setTarget:self];
        [item setAction:@selector(toggleViewed:)];
    } 
    
    return [item autorelease];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
{
    SEL action = [theItem action];
    // NSLog(@"action: %@", NSStringFromSelector(action));
    
    if (action == @selector(removeSelected:) )
        return [m_controller canRemove];
    if (action == @selector(launchAll) )
        return [[m_controller selectedObjects] count] > 0;
    if (action == @selector(toggleViewed:) )
    {
        NSArray *selected = [m_controller selectedObjects];
        if ([selected count] == 0)
            return NO;
        
        NSEnumerator *en = [selected objectEnumerator];
        PendingLink *p;
        while ((p = [en nextObject]))
        {
            if ([p viewed])
            {
                [theItem setLabel:NSLocalizedString(@"Mark unread", @"mark selected unread")];
                return YES;
            }
        }
        
        [theItem setLabel:NSLocalizedString(@"Mark read", @"mark selected read")];
        return YES;
    }
    return YES;
}

- (IBAction)toggleDrawer:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:DRAWER] forKey:DRAWER];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
    [(KeyPressTableView*)aTableView willDisplayCell:aCell forTableColumn:aTableColumn row:rowIndex];
}

- (IBAction)openSelected:(id)sender;
{
    NSUndoManager *undo = [self windowWillReturnUndoManager:nil];
    [undo beginUndoGrouping];
    
    NSEnumerator *en = [[m_controller selectedObjects] objectEnumerator];
    PendingLink *p;
    NSCalendarDate *date = [NSCalendarDate calendarDate];
    while ((p = [en nextObject]))
    {        
        NSURL *url = [NSURL URLWithString:[p url]];
        if (!url)
        {
            NSLog(@"'%@' is an invalid URL", [p url]);
            NSBeep();
            continue;
        }
        
        if ([url isFileURL])
        {
            if (![[NSWorkspace sharedWorkspace] openFile:[url path]])
            {
                NSLog(@"'%@' cannot be opened", [url path]);
                NSBeep();
                continue;
            }
        }
        else if (![[NSWorkspace sharedWorkspace] openURL:url])
        {
            NSLog(@"'%@' cannot be opened", url);
            NSBeep();
            continue;
        }
        
        [p setViewed:date];
    }
    [undo endUndoGrouping];
    [self setUnread:self];
}

- (IBAction)launchAll:(id)sender;
{
    [m_progress startAnimation:self];
    NSArray *unviewed = [self unviewedLinks];
    if ([unviewed count] == 0)
    {
        [m_progress stopAnimation:self];
        return;
    }
    
    NSEnumerator *en = [unviewed objectEnumerator];
    PendingLink *p;
    NSMutableArray *urls = [NSMutableArray array];
    
    NSUndoManager *undo = [self windowWillReturnUndoManager:nil];
    [undo beginUndoGrouping];
    NSCalendarDate *date = [NSCalendarDate calendarDate];
    while ((p = [en nextObject]))
    {
        NSURL *url = [NSURL URLWithString:[p url]];
        if (url)
            [urls addObject:url];
        else
            NSLog(@"Invalid URL: '%@'", [p url]);
        [p setViewed:date];
    }
    [self saveAction:self];
    [undo endUndoGrouping];
    
    // TODO: batch in groups of 5 and sleep for a second between.
    [[NSWorkspace sharedWorkspace] openURLs:urls 
                    withAppBundleIdentifier:nil 
                                    options:NSWorkspaceLaunchAsync | NSWorkspaceLaunchWithoutActivation
             additionalEventParamDescriptor:nil
                          launchIdentifiers:nil];
    
    [self setUnread:self];
    
    [m_progress stopAnimation:self];    
    
    [GrowlApplicationBridge notifyWithTitle:@"Links Opened" 
                                description:[NSString stringWithFormat:@"%d Links", [urls count]] 
                           notificationName:LINKS_PENDING
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@""];
}

#pragma mark -
#pragma mark Growl methods

- (NSDictionary *)registrationDictionaryForGrowl;
{
    NSArray *all = [NSArray arrayWithObjects:LINK_NEW, LINK_DEL, LINKS_PENDING, LINKS_REDUNDANT, LINKS_HISTORY, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:all, GROWL_NOTIFICATIONS_ALL, all, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

- (NSString *)applicationNameForGrowl;
{
    return [[NSProcessInfo processInfo] processName];
}

- (void) growlNotificationWasClicked:(id)clickContext;
{
    [self unfade:self];
    // TODO: if clickContext is not @"", search for that URL, 
    // select it, and scroll it visible.
}
#pragma mark -
#pragma mark Window methods

- (IBAction)fade:(id)sender;
{
    double alph = [[[NSUserDefaults standardUserDefaults] objectForKey:ALPHA] doubleValue];
    [[[m_drawer contentView] window] setAlphaValue:alph];
    [m_win setAlphaValue:alph];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FLOAT])
    {
        // Goal: put this window behind the topmost.
        // This... worked.  Can't say as I understand why, but after a 
        // couple of hourse playing around trying to find the window number 
        // of the topmost window, I submit.
        [m_win orderWindow:NSWindowAbove relativeTo:0];
    }
}

- (IBAction)unfade:(id)sender;
{
    [[[m_drawer contentView] window] setAlphaValue:1.0];
    [m_win setAlphaValue:1.0];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FLOAT])
        [m_win orderFrontRegardless];  // at least it's not irregardless...
    m_closing = NO;
}

- (IBAction)setTopLevel:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FLOAT])
        [m_win setLevel:NSFloatingWindowLevel];
    else
        [m_win setLevel:NSNormalWindowLevel];
}

- (void)windowDidBecomeMain:(id)sender
{
    [self unfade:self];
}

- (void)windowDidResignMain:(id)sender
{
    if (m_closing)
        m_closing = NO;
    else
        [self fade:self];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:AGRESSIVE_CLOSE])
        [NSApp terminate:self];
    else
        m_closing = YES;
}

-(void)keyPressOnTableView:(NSTableView*)view event:(NSEvent *)theEvent;
{
    unichar ch = [[theEvent characters] characterAtIndex:0];
    switch (ch)
    {
        case ' ':
            [self toggleViewed:[theEvent window]];
            break;
        case NSBackspaceCharacter:
        case NSDeleteCharacter:
        case NSDeleteCharFunctionKey:
        case NSDeleteFunctionKey:
            [self removeSelected:[theEvent window]];
            break;
        default:
            //NSLog(@"%x", ch);
            ;
    }
}

#pragma mark -
#pragma mark Copy/Paste/Drag/Drop

- (NSDragOperation)draggingEntered:(id)sender;
{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSString *type = (NSString*)[s_SupportedTypes firstObjectCommonWithArray:[pb types]];
    
    if (!type)
    {
        NSLog(@"No suppored drag type");
        return NSDragOperationNone;
    }
    [self unfade:self];
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
    BOOL ret = [self doPaste:[sender draggingPasteboard]];
    [self fade:self];
    return ret;
}

- (BOOL)doPaste:(NSPasteboard*)pb;
{
    /*
    NSEnumerator *en1 = [[pb types] objectEnumerator];
    NSString *t;
    while ((t = [en1 nextObject]))
    {
        NSLog(@"%@ = %@", t, [pb stringForType:t]);
    }
     */
    
    NSString *typ = [pb availableTypeFromArray:s_SupportedTypes];
    if (!typ)
        return NO;
    
    // NSLog(@"Drag type: %@", typ);
    
    [m_controller setFilterPredicate:nil];
    if ([typ isEqual:PendingLinkPBoardType])
    {
        NSData *data = [pb dataForType:PendingLinkPBoardType];
        if (!data)
            return NO;
        
        NSArray *pendings = [NSUnarchiver unarchiveObjectWithData:data];
        unsigned i, count = [pendings count];
        PendingLink *p;
        for (i = 0; i < count; i++) 
        {
            p = [NSEntityDescription insertNewObjectForEntityForName:@"PendingLink" 
                                              inManagedObjectContext:[self managedObjectContext]];
            [p setValuesForKeysWithDictionary:[pendings objectAtIndex:i]];
        }
        [self setUnread:self];
        return YES;
    }
    
    if ([typ isEqual:@"WebURLsWithTitlesPboardType"])
    {
        id plist = [pb propertyListForType:typ];
        if (!plist)
            return NO;        
        
        NSArray *url_list = [plist objectAtIndex:0];
        NSArray *desc_list = [plist objectAtIndex:1];
        unsigned int i;
        for (i=0; i<[url_list count]; i++)
        {
            [self insertURL:[url_list objectAtIndex:i]
            withDescription:[desc_list objectAtIndex:i]];
        }
        [self setUnread:self];
        return YES;
    }
    
    if ([typ isEqual:NSFilenamesPboardType])
    {
        id plist = [pb propertyListForType:typ];
        if (!plist)
            return NO;        
        
        NSEnumerator *en = [plist objectEnumerator];
        NSString *fil;
        while ((fil = [en nextObject]))
        {
            NSURL *url = [NSURL fileURLWithPath:fil];
            [self insertURL:[url relativeString]
            withDescription:fil];
        }
        [self setUnread:self];
        return YES;        
    }
    
    if ([typ isEqual:@"Apple Web Archive pasteboard type"])
    {
        NSDictionary *plist = [pb propertyListForType:typ];
        NSDictionary *resource = [plist objectForKey:@"WebMainResource"];
        NSData *data = [resource objectForKey:@"WebResourceData"];
        NSString *html = [[[NSString alloc] initWithData:data
                                                encoding:NSUTF8StringEncoding] autorelease];
        NSString *source = [resource objectForKey:@"WebResourceURL"];
        ImportHTML *importer = [[ImportHTML alloc] initWithHtmlString:html
                                                               source:source
                                                              linkstr:self];
        if (![importer popup])
        {
            // If there were no links, this was plain text that happened to get
            // copied from an HTML source.  Hope there was also a string 
            // pasteboard type.
            NSString *str = [pb stringForType:NSStringPboardType];
            if (!str)
                str = html;
            PendingLink *p = [self insertTerms:str forSite:@"Google"];
            [p setSource:source];
            [self setUnread:self];
        }
        return YES;
    }
    
    if ([typ isEqual:NSURLPboardType])
    {
        NSURL *url = [NSURL URLFromPasteboard:pb];
        if (!url)
            return NO;
        
        // Firefox links.
        NSString *desc = [pb stringForType:@"CorePasteboardFlavorType 0x75726C64"];
        [self insertURL:[url relativeString] withDescription:desc];            
        [self setUnread:self];
        return YES;
    }
    
    if ([typ isEqual:NSStringPboardType])
    {
        NSString *str = [pb stringForType:typ];
        NSURL *url = [NSURL URLWithString:str];
        if (url && [url scheme])
        {
            [self insertURL:str withDescription:nil];
            return YES;
        }

        [self insertTerms:str forSite:@"Google"];
        [self saveAction:self];
        [self setUnread:self];
        return YES;
    }
    
    return NO;    
}

- (IBAction)copy:(id)sender;
{    
    NSArray *selectedObjects = [m_controller selectedObjects];
    unsigned i, count = [selectedObjects count];
    if (count == 0) {
        return;
    }
    
    NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *copyStringsArray = [NSMutableArray arrayWithCapacity:count];
    PendingLink *p;
    
    for (i = 0; i < count; i++) 
    {
        p = (PendingLink *)[selectedObjects objectAtIndex:i];
        [copyObjectsArray addObject:[p dictionaryRepresentation]];
        [copyStringsArray addObject:[p url]];
    }
    
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard declareTypes:[NSArray arrayWithObjects:
        PendingLinkPBoardType,
        NSStringPboardType, nil]
                              owner:self];
    NSData *copyData = [NSArchiver archivedDataWithRootObject:copyObjectsArray];
    [generalPasteboard setData:copyData forType:PendingLinkPBoardType];
    [generalPasteboard setString:
        [copyStringsArray componentsJoinedByString:@"\n"]
                         forType:NSStringPboardType];    
}

- (IBAction)paste:(id)sender;
{
    [self doPaste:[NSPasteboard generalPasteboard]];
}

- (IBAction)cut:(id)sender;
{
    [self copy:self];
    [self removeSelected:self];
}

#pragma mark -
#pragma mark Popups

- (void)ensureSheet;
{
    if (!m_sheet)
    {
        m_sheet = [[[ImageTextSheet alloc] init] retain];
        [m_sheet setDelegate:self];
    }    
}

- (IBAction)genericPopup:(id)sender;
{
    NSMenuItem *item = sender;
    NSDictionary *site = [item representedObject];
    [self ensureSheet];
    [m_sheet setTitle:[site objectForKey:@"name"]];
    [m_sheet setImage:[NSImage imageNamed:[site objectForKey:@"image"]]];
    [m_sheet popup:m_win 
          callback:@selector(genericDone:context:) 
           context:site];
}

- (NSString*)formatXEP:(NSString*)text
{
    int i = [text intValue]; 
    return [NSString stringWithFormat:@"%04d", i];
}

- (NSString*)formatURL:(NSString*)text
{
    NSURL *url = [NSURL URLWithString:text];
    if ([url scheme] == nil)
        return [@"http://" stringByAppendingString:text];
    return text;
}

- (PendingLink*)genericDone:(NSString*)text context:(void*)context
{ 
    NSDictionary *site = (NSDictionary*)context;
    NSString *fmt = [site objectForKey:@"formatter"]; 
    NSString *pct = nil;
    if (fmt)
    {
        SEL sf = NSSelectorFromString(fmt);
        if (sf)
            pct = [self performSelector:sf withObject:text];
    }
    if (!pct)
        pct = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:[site objectForKey:@"url"], pct];        
    NSString *desc = [NSString stringWithFormat:[site objectForKey:@"description"], text]; 
    return [self insertURL:url withDescription:desc];
}

- (PendingLink*)insertTerms:(NSString*)terms forSite:(NSString*)site;
{
    NSDictionary *sites = [[NSUserDefaults standardUserDefaults] objectForKey:SITES];
    NSDictionary *s = [sites objectForKey:site];
    if (!s)
        return nil;
    return [self genericDone:terms context:s];    
}

- (void)urlDone:(NSString*)text context:(void*)context
{
    NSString *us = text;
    NSURL *url = [NSURL URLWithString:text];
    if ([url scheme] == nil)
    {
        us = [@"http://" stringByAppendingString:text];
    }
    [self insertURL:us withDescription:text];
}

- (IBAction)scriptsMenu:(id)sender;
{
    NSString *proc = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    proc = [proc stringByDeletingLastPathComponent];
    proc = [proc stringByDeletingLastPathComponent];    
    proc = [proc stringByAppendingPathComponent:@"Resources"];
    proc = [proc stringByAppendingPathComponent:@"Scripts"];
    
    NSURL *url = [NSURL fileURLWithPath:proc];
    NSLog(@"scripts: '%@'", url);
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)prefsPopup:(id)sender;
{
    NSLog(@"prefs");
    if (!m_prefs)
        m_prefs = [[Prefs alloc] init];
    [m_prefs showWindow:self];
}

- (IBAction)feedsPopup:(id)sender;
{
    if (!m_feeds)
        m_feeds = [[ContextWindowController alloc] initWithContext:[self managedObjectContext] 
                                                              name:NSLocalizedString(@"Feeds", @"Feed window title") 
                                                            entity:@"Sources"];
    [m_feeds showWindow:self];
}

- (IBAction)historyPopup:(id)sender;
{
    if (!m_history)
        m_history = [[ContextWindowController alloc] initWithContext:[self managedObjectContext] 
                                                                name:NSLocalizedString(@"History", @"History window title") 
                                                              entity:@"Seen"];
    [m_history showWindow:self];
}

#pragma mark -
#pragma mark Storage

- (NSArray*)createdSortOrder;
{
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    NSArray *as = [NSArray arrayWithObject:sort];
    [sort release];
    return as;
}
- (NSArray*)createdDescendingSortOrder;
{
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *as = [NSArray arrayWithObject:sort];
    [sort release];
    return as;
}

- (void)setCreatedDescendingSortOrder:(NSArray*)array;
{
    
}

- (NSArray*)fullContentUrls;
{
    return [self urlsForType:@"F"];
}
- (NSArray*)redundantUrls;
{
    return [self urlsForType:@"R"];
}

- (NSArray*)urlsForType:(NSString*)type;
{
    NSFetchRequest *fetch = 
    [[self managedObjectModel] fetchRequestFromTemplateWithName:@"urlByType"
                                          substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:type, @"TYPE", nil]];
    [fetch setSortDescriptors:[self createdSortOrder]];
    NSAssert(fetch, @"Fetch not found");
    return [[[[self managedObjectContext] executeFetchRequest:fetch error:nil] retain] autorelease];
}

- (PendingLink*)pendingForUrl:(NSString*)url;
{
    NSFetchRequest *fetch = 
    [[self managedObjectModel] fetchRequestFromTemplateWithName:@"fetchURL"
substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:url, @"URL", nil]];
    NSAssert(fetch, @"Fetch not found");
    NSArray *res = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
    if ([res count] < 1)
        return nil;
    return [res objectAtIndex:0];
}

- (NSArray*)unviewedLinks;
{
    NSFetchRequest *fetch = [[[self managedObjectModel] fetchRequestTemplateForName:@"unviewed"] copy];
    NSAssert(fetch, @"Fetch not found");
    [fetch setSortDescriptors:[self createdSortOrder]];
    NSArray *ret = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
    [fetch release];
    return ret;
}

- (NSString*)DeHTML:(NSString*)html;
{
    NSRange r = [html rangeOfString:@"&"];
    if (r.location == NSNotFound)
        return html;
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *as = [[NSAttributedString alloc] initWithHTML:data
                                                   documentAttributes:nil];
    return [[as string] autorelease];
    /*
    NSError *err;
    NSXmlDocument *doc = [[NSXMLDocument alloc] initWithXMLString:html 
                                                          options:NSXMLDocumentTidyHTML 
                                                            error:&err];
    
    [doc release];
        */
}

- (BOOL)isFunny:(NSString*)str
{
    if (!str)
        return NO;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:AVOID_FUNNY])
        return NO;
    
    int funny = 0;
    uint i;
    for (i=0; i<[str length]; i++)
    {
        unichar c = [str characterAtIndex:i];
        if (c > 566) // arbitrary
            funny++;
        if (funny > 3) // that's pretty funny
            return YES;            
    }
    
    return NO;
}

- (id)insertURL:(NSString*)url withDescription:(NSString*)desc;
{
    return [self insertURL:url 
           withDescription:desc 
                withViewed:nil 
               withCreated:[NSCalendarDate calendarDate]];
}

- (id)insertURL:(NSString*)url 
withDescription:(NSString*)desc
     withViewed:(NSCalendarDate*)viewed
    withCreated:(NSCalendarDate*)created;
{
    if ((![[NSUserDefaults standardUserDefaults] boolForKey:IMPORT_HTTPS]) &&
        ([url hasPrefix:@"https"]))
        return nil;
    
    if ([self isFunny:desc])
        return nil;
    
    PendingLink *p = [self pendingForUrl:url];
    if (!p)
    {
        p = [NSEntityDescription insertNewObjectForEntityForName:@"PendingLink" 
                                          inManagedObjectContext:[self managedObjectContext]];
        [p setUrl:url];
        if (desc && [desc length])
            [p setText:[self DeHTML:desc]];
        [p setCreated:created];
    }
    [p setViewed:viewed];
    
    [m_nagler scheduleAdd:p];
    [self setUnread:self];
    [m_table scrollRowToVisible:0];
    return [[p retain] autorelease];
}

- (BOOL)checkRedundant:(NSString*)url 
               forType:(NSString*)type 
              withDate:(NSCalendarDate*)date
       withDescription:(NSString*)desc;
{
    PendingLink *p = [self pendingForUrl:url];
    if (p)
        return YES;

    if ([self isFunny:desc])
        return YES;
    
    NSFetchRequest *fetch = 
    [[self managedObjectModel] fetchRequestFromTemplateWithName:@"checkRedundant"
                                          substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:url, @"URL", nil]];
    NSAssert(fetch, @"Fetch not found");
    NSArray *res = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
    BOOL ret = ([res count] > 0);
    urlList *red;
    if (ret)
    {
        red = [res objectAtIndex:0];
    }
    else
    {
        red = [NSEntityDescription insertNewObjectForEntityForName:@"Seen" 
                                            inManagedObjectContext:[self managedObjectContext]];
        [red setUrl:url];
        [red setType:type];        
    }
    if (date)
        [red setCreated:date];
    return ret;
}

- (IBAction)importSafariHistory:(id)sender;
{
    [m_progress startAnimation:self];
    NSString *hf = @"~/Library/Safari/History.plist";
    NSError *er;
    NSData *hist = [NSData dataWithContentsOfFile:[hf stringByExpandingTildeInPath]
                                          options:NSUncachedRead|NSMappedRead
                                            error:&er];
    if (!hist)
    {
        NSLog(@"Can't open Safari history: %@", er);
        [m_progress stopAnimation:self];
        return;
    }
    
    NSPropertyListFormat fmt;
    NSString *err;
    NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:hist
                                                           mutabilityOption:NSPropertyListImmutable 
                                                                     format:&fmt
                                                           errorDescription:&err];
    if (err)
    {
        NSLog(err);
        [m_progress stopAnimation:self];
        return;
    }

    NSCalendarDate *last = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastSafariLinkDate"];
    if (!last)
        last = [NSCalendarDate distantPast];
    
    NSArray *h = (NSArray*)[plist objectForKey:@"WebHistoryDates"];
    NSEnumerator *en = [h objectEnumerator];
    NSDictionary *entry;
    int changes = 0;
    NSCalendarDate *first = nil;
    
    NSUndoManager *undo = [self windowWillReturnUndoManager:nil];
    [undo beginUndoGrouping];
    PendingLink *p;
    while ((entry = [en nextObject]))
    {
        NSString *dates = [entry objectForKey:@"lastVisitedDate"];
        NSCalendarDate *date = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[dates doubleValue]];

        if (!first)
            first = date;

        if ([date earlierDate:last] == date)
            break;
        
        NSString *url = [entry objectForKey:@""];
        if ((![[NSUserDefaults standardUserDefaults] boolForKey:IMPORT_HTTPS]) &&
            ([url hasPrefix:@"https"]))
            continue;
        
        p = [self insertURL:url 
            withDescription:[entry objectForKey:@"title"]
                 withViewed:date
                withCreated:date];
        if ([[p created] isEqual:date])
            changes++;
        [p release];
    }

    if (first)
    {
        [[NSUserDefaults standardUserDefaults] setObject:first forKey:@"LastSafariLinkDate"];
    }
    
    [undo endUndoGrouping];
    [self refresh:self];
    [m_progress stopAnimation:self];
    
    [GrowlApplicationBridge notifyWithTitle:@"History Links" 
                                description:[NSString stringWithFormat:@"%d Links Added", changes] 
                           notificationName:LINKS_HISTORY
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@""];
}

- (IBAction)importDeliciousHistory:(id)sender;
{
    Poster *post = [[Poster alloc] initWithDelegate:self];
    [m_progress startAnimation:self];
    [post getURL:DEL_UPDATE];
}

- (IBAction)postDeliciously:(id)sender;
{
    NSArray *all = [m_controller selectedObjects];
    if ([all count] == 0)
        return;
    
    [m_progress startAnimation:self];
    Poster *k = [[[Poster alloc] initWithDelegate:self] retain];
    NSEnumerator *en = [all objectEnumerator];
    PendingLink *p;
    while ((p = [en nextObject]))
    {
        [k getURL:@"https://api.del.icio.us/v1/posts/add"
       withParams:[NSDictionary dictionaryWithObjectsAndKeys:
           [p url], @"url",
           [p text], @"description", 
           @"linkstr", @"tags",
           @"no", @"shared",
           nil]];
    }
}

- (void)poster:(Poster*)poster finishedOutstanding:(int)total;
{
    [m_progress stopAnimation:self];
}

- (NSCalendarDate*)parseDeliciousDate:(NSString*)str;
{
    return [NSCalendarDate dateWithString:[str stringByAppendingString:@"UTC"] 
                           calendarFormat:@"%Y-%m-%dT%H:%M:%SZ%Z"];
}

- (void)poster:(Poster*)poster finishedLoadingUpdate:(NSDictionary*)context
{
    NSData *data = [context objectForKey:@"data"];
    NSError *err;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data
                                                     options:0 
                                                       error:&err];
    if (!doc)
    {
        NSLog(@"Error parsing XML doc: %@", err);
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"XML: %@", str);
        [str release];
        return;
    }
    NSXMLElement *posts = [doc rootElement];
    // <update time="2007-09-04T04:43:06Z" />
    NSString *t = [[posts attributeForName:@"time"] stringValue];
    NSCalendarDate *date = [self parseDeliciousDate:t];
        
    NSCalendarDate *last = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_DELICIOUS];
    if (!last)
        last = [NSCalendarDate distantPast];
    
     if (![date isGreaterThan:last])
     {
         [GrowlApplicationBridge notifyWithTitle:@"Del.icio.us Links" 
                                     description:@"No new links"
                                notificationName:LINKS_HISTORY
                                        iconData:nil
                                        priority:0
                                        isSticky:NO
                                    clickContext:@""];    
         
         return;
     }

     [poster getURL:DEL_ALL];
}

- (void)poster:(Poster*)poster finishedLoadingAll:(NSDictionary*)context
{
    NSData *data = [context objectForKey:@"data"];
    NSError *err;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data
                                                     options:0 
                                                       error:&err];
    if (!doc)
    {
        NSLog(@"Error parsing XML doc: %@", err);
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"XML: %@", str);
        [str release];
        return;
    }
    NSXMLElement *posts = [doc rootElement];
    // <posts update="2007-08-24T16:20:40Z">
    NSString *update = [[posts attributeForName:@"update"] stringValue];
    NSCalendarDate *update_date = [self parseDeliciousDate:update];
    NSLog(@"update: %@", update_date);

    NSCalendarDate *last = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_DELICIOUS];
    if (!last)
        last = [NSCalendarDate distantPast];
    
    NSEnumerator *en = [[posts elementsForName:@"post"] objectEnumerator];
    NSXMLElement *post;
    int changes = 0;
    while ((post = [en nextObject]))
    {
        NSString *t = [[post attributeForName:@"time"] stringValue];
        NSCalendarDate *d = [self parseDeliciousDate:t];

        // hope they're in order.
        if ([d isLessThanOrEqualTo:last])
            break;
        
        NSString *u = [[post attributeForName:@"href"] stringValue];
        if ((![[NSUserDefaults standardUserDefaults] boolForKey:IMPORT_HTTPS]) &&
            ([u hasPrefix:@"https"]))
            continue;
        
        PendingLink *p = [self insertURL:u 
                         withDescription:[[post attributeForName:@"description"] stringValue]
                              withViewed:d
                             withCreated:d];
        if ([[p created] isEqual:d])
            changes++;
        [p release];
    }
    [doc release];  
    
    [[NSUserDefaults standardUserDefaults] setObject:update_date forKey:LAST_DELICIOUS];
    [self refresh:self];
    
    [GrowlApplicationBridge notifyWithTitle:@"Del.icio.us Links" 
                                description:[NSString stringWithFormat:@"%d Links Added", changes] 
                           notificationName:LINKS_HISTORY
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@""];    
}

- (void)poster:(Poster*)poster finishedLoading:(NSDictionary*)context;
{
    int code = [[context objectForKey:@"code"] intValue];
    if (code != 200)
    {
        NSLog(@"Error code: %d", code);
        return;
    }
    
    NSString *url = [context objectForKey:@"url"];
    if ([url isEqual:DEL_UPDATE])
        [self poster:poster finishedLoadingUpdate:context];
    else if ([url isEqual:DEL_ALL])
        [self poster:poster finishedLoadingAll:context];
}

- (IBAction)removeSelected:(id)sender;
{
    int row = [m_table selectedRow];
    NSRect rect = [m_table frameOfCellAtColumn:0 row:row];
    NSPoint center = [m_table convertPoint:NSMakePoint(NSMidX(rect),NSMidY(rect))
                                    toView:nil];
    center = [[m_table window] convertBaseToScreen:center];
    
    NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault,
                          center,
                          rect.size,
                          nil,nil,nil);
    
    [m_controller remove:sender];
    [self setUnread:self];
}

- (IBAction)toggleViewed:(id)sender;
{
    NSArray *all = [m_controller selectedObjects];
    if ([all count] == 0)
        return;
    NSUndoManager *undo = [self windowWillReturnUndoManager:nil];
    NSAssert(undo, @"Invalid undo");
    [undo beginUndoGrouping];
    
    NSEnumerator *en = [all objectEnumerator];
    PendingLink *p;
    NSCalendarDate *date = [NSCalendarDate calendarDate];
    while ((p = [en nextObject]))
    {
        if ([p viewed])
            [p setViewed:nil];
        else
            [p setViewed:date];
    }
    
    if (![undo isUndoing])
        [undo setActionName:@"Toggle viewed flag"];
    
    [[self managedObjectContext] processPendingChanges];
    [undo endUndoGrouping];
    [self setUnread:self];
}

- (IBAction)refresh:(id)sender;
{
    [m_controller fetch:sender];
    [self setUnread:self];
}

/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle and all of the 
    framework bundles.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    NSMutableSet *allBundles = [[NSMutableSet alloc] init];
    [allBundles addObject: [NSBundle mainBundle]];
    [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator 
{

    if (persistentStoreCoordinator != nil) 
    {
        return persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] )
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Linkstr.lite"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSError *error;    
    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    if (!persistentStore)
        [[NSApplication sharedApplication] presentError:error];

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext 
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator == nil) 
        return nil;
    
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window 
{
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender 
{
    [m_progress startAnimation:self];
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) 
    {
        [[NSApplication sharedApplication] presentError:error];
    }
    [m_progress stopAnimation:self];
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) 
    {
        if ([managedObjectContext commitEditing]) 
        {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
            {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        else 
        {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}

- (void)insertInContent:(PendingLink*)p
{
    NSLog(@"insert: %@", [p url]);
    [[self managedObjectContext] insertObject:p];    
}

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{ 
    NSLog(@"key: %@", key);
    
    static NSSet *implemented;
    if (!implemented)
        implemented = [NSSet setWithObjects:
            @"content", @"redundantUrls", @"insertInContent", nil];

    if ([implemented containsObject:key])
        return YES;
    
    return NO;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSLog(@"undefined key(%@): %@", [self class], key);
    return nil;
}
@end
