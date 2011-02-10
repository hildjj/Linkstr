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
#import "Poster.h"
#import "PendingLink.h"
#import "LSHostReach.h"

NSString *ATOM_DATE_FMT;

@interface Linkstr_AppDelegate : NSObject <GrowlApplicationBridgeDelegate, NSToolbarDelegate, NSOpenSavePanelDelegate>
{
    IBOutlet NSWindow *m_win;
    IBOutlet NSArrayController *m_controller;  
    IBOutlet NSProgressIndicator *m_progress;
    IBOutlet NSDrawer *m_drawer;
    IBOutlet NSTableView *m_table;
    IBOutlet NSSearchField *m_search;
    IBOutlet ImageTextSheet *m_sheet;
    IBOutlet NSMenuItem *m_action;
    IBOutlet NSView *m_fileTypeView;
    IBOutlet NSComboBox *m_fileType;
        
    LSHostReach *m_hostReach;
    NSWindowController *m_prefs;
    NSWindowController *m_feeds;
    NSWindowController *m_history;
    GrowlNagler *m_nagler;
    Poster *m_poster;
    int m_unread;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    id persistentStore;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    BOOL m_closing;
    BOOL m_offline;
}

+ (void)initialize;
- (void)awakeFromNib;
- (IBAction)setUnread:(id)sender;
- (IBAction)fade:(id)sender;
- (IBAction)unfade:(id)sender;
- (IBAction)setTopLevel:(id)sender;

@property (readonly) NSWindow *window;
@property int unreadCount;
@property BOOL offline;

- (NSMutableArray*)links;
- (BOOL)keyPressOnTableView:(NSTableView*)view event:(NSEvent *)theEvent;

#pragma mark -
#pragma mark Toolbar methods

- (void) setupToolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
- (IBAction)toggleDrawer:(id)sender;
- (IBAction)openSelected:(id)sender;
- (IBAction)launchAll:(id)sender;
- (IBAction)undoLaunch:(id)sender;

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

- (PendingLink*)insertTerms:(NSString*)terms forSite:(NSString*)site;
- (IBAction)scriptsMenu:(id)sender;

- (IBAction)prefsPopup:(id)sender;
- (IBAction)feedsPopup:(id)sender;
- (IBAction)historyPopup:(id)sender;

#pragma mark -
#pragma mark Storage

- (NSArray*)createdSortOrder;
- (NSArray*)createdDescendingSortOrder;

- (NSArray*)incompletes;
- (NSArray*)redundants;
- (NSArray*)shorteners;

- (NSArray*)urlsForType:(NSString*)type;
- (NSArray*)unviewedLinks;
- (NSArray*)unviewedLinksWithLimit:(NSUInteger)limit;
- (NSArray*)lastBatch;
- (int) createLinksFromDictionary:(NSMutableDictionary*)possible
                          onDates:(NSDictionary*)dates
                       fromSource:(NSString*)sourceURL;
- (id)insertURL:(NSString*)url withDescription:(NSString*)desc
     withViewed:(NSCalendarDate*)viewed
    withCreated:(NSCalendarDate*)created
     fromSource:(NSString*)source;
- (id)insertURL:(NSString*)url withDescription:(NSString*)desc fromSource:(NSString*)source;
- (BOOL)checkRedundant:(NSString*)url 
               forType:(NSString*)type 
              withDate:(NSCalendarDate*)date
       withDescription:(NSString*)desc;
- (IBAction)importSafariHistory:(id)sender;
- (IBAction)importChromeHistory:(id)sender;
- (IBAction)importDeliciousHistory:(id)sender;
- (IBAction)postDeliciously:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (IBAction)toggleViewed:(id)sender;
- (IBAction)refresh:(id)sender;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)exportAction:sender;
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;

@end

