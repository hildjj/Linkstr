//
//  LSDocAtom.m
//  Linkstr
//
//  Created by Joe Hildebrand on 1/2/08.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import "LSDocAtom.h"
#import "PendingLink.h"
#import "Linkstr_AppDelegate.h"
#import "LSXMLAdditions.h"
#import "LSDefaults.h"

@interface NSString (LSGUIDString)
+ (NSString*) stringWithNewUUID;
@end

@implementation NSString (LSGUIDString)
+ (NSString*) stringWithNewUUID;
{
    //create a new UUID
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    //get the string representation of the UUID
    NSString	*newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return newUUID;
}
@end

@implementation LSDocAtom

- (id)initWithSelection:(NSArray*)items;
{
    if (![self init])
        return nil;
    
    m_items = [items mutableCopy];
    return self;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
{
    NSLog(@"Reading type: %@", typeName);
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:outError];
    if (!doc)
    {
        NSLog(@"Invalid XML: %@", outError ? *outError : nil);
        return NO;
    }
    
    NSXMLElement *feed = [doc rootElement];
    NSString *source = [feed valueOfChildNamed:@"link"];
    
    NSMutableDictionary *urls = [[NSMutableDictionary alloc] init];
    for (NSXMLElement *entry in [feed elementsForName:@"entry"])
    {
        NSXMLElement *lnk = [entry firstElementNamed:@"link"];
        NSString *u = [lnk valueOfAttributeNamed:@"href"];
        if (!u)
            continue;
        [urls setObject:[entry valueOfChildNamed:@"title"] forKey:u];
    }
    
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    int changes = [l createLinksFromDictionary:urls onDates:nil fromSource:source];
    [GrowlApplicationBridge notifyWithTitle:@"Import Links" 
                                description:[NSString stringWithFormat:@"%d Atom Links Added", changes] 
                           notificationName:LINKS_IMPORT
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@""];
    
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
{
#pragma unused(typeName)
#pragma unused(outError)
    NSXMLDocument *doc = [NSXMLNode document];
    [doc setCharacterEncoding:@"UTF-8"];
    NSXMLElement *feed = [NSXMLNode elementWithName:@"feed"];
    [feed addNamespace:[NSXMLNode namespaceWithName:@"" stringValue:@"http://www.w3.org/2005/Atom"]];
    [doc setRootElement:feed];
    [feed addChild:[NSXMLNode elementWithName:@"title" stringValue:@"Linkstr Links"]];
    NSXMLElement *lnk = [NSXMLNode elementWithName:@"link"];
    [feed addChild:lnk];
    [lnk setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @"http://linkstr.net/", @"href",
                                    @"related", @"rel",
                                    nil]];
    NSCalendarDate *now = [NSCalendarDate calendarDate];
    NSString *nows = [now descriptionWithCalendarFormat:ATOM_DATE_FMT];
    [feed addChild:[NSXMLNode elementWithName:@"updated"
                                  stringValue:nows]];
    NSXMLElement *author = [NSXMLNode elementWithName:@"author"];
    [feed addChild:author];
    [author addChild:[NSXMLNode elementWithName:@"name"
                                    stringValue:NSFullUserName()]];
    NSString *uurn = [NSString stringWithFormat:@"urn:uuid:%@", [NSString stringWithNewUUID]];
    [feed addChild:[NSXMLNode elementWithName:@"id" 
                                  stringValue:uurn]];
    
    for (PendingLink *p in m_items)
        [feed addChild:[p asAtom]];
    
    return [doc XMLDataWithOptions:
            NSXMLDocumentIncludeContentTypeDeclaration |
            NSXMLNodePrettyPrint | 
            NSXMLNodeCompactEmptyElement |
            NSXMLNodeUseSingleQuotes];    
}

@end
