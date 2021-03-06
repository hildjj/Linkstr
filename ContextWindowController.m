#import "ContextWindowController.h"
#import "urlList.h"

@implementation ContextWindowController

+(NSArray*)supportedTypes;
{
    static NSArray *types;
    if (!types)
        types = [NSArray arrayWithObjects:
            @"WebURLsWithTitlesPboardType",
            NSURLPboardType, 
            NSStringPboardType, nil];    
    return types;
}

-(id)initWithContext:(NSManagedObjectContext *)context 
                name:(NSString*)name
              entity:(NSString*)entityName;
{
    if (!(self = [super initWithWindowNibName:@"UrlList" owner:self]))
        return nil;
    
    managedObjectContext = context;
    entity = entityName;
    
    [[self window] setTitle:name];
    [[self window] setFrameAutosaveName:[name stringByAppendingString:@"Win"]];
    return self;
}

- (void)windowDidLoad;
{
    [controller setEntityName:entity];
}

#pragma mark -
#pragma mark Copy/Paste/Drag/Drop

- (NSDragOperation)draggingEntered:(id)sender;
{
    NSPasteboard *pb = [sender draggingPasteboard];
    
    NSString *type = (NSString*)[[[self class] supportedTypes] firstObjectCommonWithArray:[pb types]];
    
    if (!type)
    {
        NSLog(@"No suppored drag type");
        return NSDragOperationNone;
    }
    return NSDragOperationCopy;    
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
    return [self doPaste:[sender draggingPasteboard]];
}

-(void)insertUrl:(NSString*)url;
{
    if (!url)
        return;
    if ([url length] == 0)
        return;
    
    urlList *u = [NSEntityDescription insertNewObjectForEntityForName:entity 
                                               inManagedObjectContext:managedObjectContext];
    [u setUrl:url];
}

-(void)insertUrls:(NSArray*)list;
{
    for (id loopItem in list)
    {
        [self insertUrl:loopItem];
    }
}

- (BOOL)doPaste:(NSPasteboard*)pb;
{
    NSString *typ = [pb availableTypeFromArray:[[self class] supportedTypes]];
    if (!typ)
        return NO;
    
    NSLog(@"Drag type: %@", typ);
        
    if ([typ isEqual:@"WebURLsWithTitlesPboardType"])
    {
        id plist = [pb propertyListForType:typ];
        if (!plist)
            return NO;        
        [self insertUrls:[plist objectAtIndex:0]];
        return YES;
    }
        
    if ([typ isEqual:NSURLPboardType])
    {
        NSURL *url = [NSURL URLFromPasteboard:pb];
        if (!url)
            return NO;
        [self insertUrl:[url relativeString]];            
        return YES;
    }
    
    if ([typ isEqual:NSStringPboardType])
    {
        [self insertUrls:[[pb stringForType:typ] componentsSeparatedByString:@"\n"]];        
        return YES;
    }
    
    return NO;    
}

- (IBAction)copy:(id)sender;
{
#pragma unused(sender)
    
}

- (IBAction)paste:(id)sender;
{
#pragma unused(sender)
    [self doPaste:[NSPasteboard generalPasteboard]];    
}

- (IBAction)cut:(id)sender;
{
#pragma unused(sender)
    
}
@synthesize entity;
@end
