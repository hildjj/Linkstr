//
//  Linkstr_AppDelegate.h
//  Linkstr
//
//  Created by Joe Hildebrand on 7/18/07.
//  Copyright Cursive Systems, Inc 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Growl/Growl.h"
#import "ImageTextSheet.h"
#import "GrowlNagler.h"

@interface Linkstr_AppDelegate : NSObject <GrowlApplicationBridgeDelegate>
{
    IBOutlet NSWindow *m_win;
    IBOutlet NSArrayController *m_controller;  
    IBOutlet NSArrayController *m_sites;
    IBOutlet NSProgressIndicator *m_progress;
    IBOutlet NSDrawer *m_drawer;
    IBOutlet NSTableView *m_table;
    IBOutlet NSSearchField *m_search;
    IBOutlet ImageTextSheet *m_sheet;
    IBOutlet NSMenuItem *m_action;
        
    NSWindowController *m_feeds;
    NSWindowController *m_history;
    GrowlNagler *m_nagler;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    id persistentStore;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    BOOL m_closing;
}

+ (void)initialize;
- (void)awakeFromNib;
- (IBAction)setUnread:(id)sender;
- (IBAction)fade:(id)sender;
- (IBAction)unfade:(id)sender;
- (IBAction)setTopLevel:(id)sender;

- (NSMutableArray*)content;
- (NSWindow*)window;
- (void)keyPressOnTableView:(NSTableView*)view event:(NSEvent *)theEvent;

#pragma mark -
#pragma mark Toolbar methods

- (void) setupToolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
- (void) toggleDrawer;
- (IBAction)openSelected:(id)sender;
- (IBAction)launchAll:(id)sender;

#pragma mark -
#pragma mark Copy/Paste/Drag/Drop

- (NSDragOperation)draggingEntered:(id)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)doPaste:(NSPasteboard*)pb;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;

#pragma mark -
#pragma mark Popups

- (void)ensureSheet;
- (IBAction)genericPopup:(id)sender;
- (void)genericDone:(NSString*)text context:(void*)context;
- (IBAction)urlPopup:(id)sender;

- (IBAction)feedsPopup:(id)sender;
- (IBAction)historyPopup:(id)sender;

#pragma mark -
#pragma mark Storage

- (NSArray*)createdSortOrder;
- (NSArray*)createdDescendingSortOrder;
- (void)setCreatedDescendingSortOrder:(NSArray*)array;

- (NSArray*)fullContentUrls;
- (NSArray*)redundantUrls;
- (NSArray*)urlsForType:(NSString*)type;
- (NSArray*)unviewedLinks;
- (id)insertURL:(NSString*)url withDescription:(NSString*)desc;
- (BOOL)checkRedundant:(NSString*)url forType:(NSString*)type withDate:(NSCalendarDate*)date;
- (IBAction)importSafariHistory:(id)sender;
- (IBAction)postDeliciously:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (IBAction)toggleViewed:(id)sender;
- (IBAction)refresh:(id)sender;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
