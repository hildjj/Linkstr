/* FeedsWindowController */

#import <Cocoa/Cocoa.h>
#import "KeyPressTableView.h"

@interface ContextWindowController : NSWindowController
{
    IBOutlet NSArrayController *controller;
    IBOutlet KeyPressTableView *tableView;
    NSManagedObjectContext *managedObjectContext;
    NSString *entity;
}

-(id)initWithContext:(NSManagedObjectContext *)context 
                name:(NSString*)name
              entity:(NSString*)entityName;
- (void)dealloc;
- (void)windowDidLoad;

#pragma mark -
#pragma mark Copy/Paste/Drag/Drop

-(void)insertUrl:(NSString*)url;
-(void)insertUrls:(NSArray*)list;

- (NSDragOperation)draggingEntered:(id)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)doPaste:(NSPasteboard*)pb;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;

@end
