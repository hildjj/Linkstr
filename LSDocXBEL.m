//
//  LSDocXBEL.m
//  Linkstr
//
//  Created by Joe Hildebrand on 1/2/08.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import "LSDocXBEL.h"
#import "PendingLink.h"
#import "Linkstr_AppDelegate.h"
#import "LSXMLAdditions.h"
#import "LSDefaults.h"

@implementation LSDocXBEL

- (id)initWithSelection:(NSArray*)items;
{
    if (![self init])
        return nil;
    
    m_items = [items mutableCopy];
    return self;
}

- (BOOL)readFromFolder:(NSXMLElement*)folder intoUrls:(NSMutableDictionary*)urls intoDates:(NSMutableDictionary*)dates;
{
    for (NSXMLElement *bookmark in [folder elementsForName:@"bookmark"])
    {
        /*
         <bookmark href='http://tinyurl.com/2hxq6m' added='2008-01-02T10:44:39Z' visited='2008-01-02T10:44:39Z'>
           <title>Learning XML</title>
         </bookmark>
         */
        
        NSString *href = [bookmark valueOfAttributeNamed:@"href"];
        if (!href)
            continue;
        [urls setObject:[bookmark valueOfChildNamed:@"title"] forKey:href];
        NSString *added = [bookmark valueOfAttributeNamed:@"added"];
        if (added)
        {
            NSCalendarDate *created = [NSCalendarDate dateWithString:added calendarFormat:ATOM_DATE_FMT];
            [dates setObject:created forKey:href];
        }
    }
    
    for (NSXMLElement *f in [folder elementsForName:@"folder"])
        [self readFromFolder:f intoUrls:urls intoDates:dates];
    
    return YES;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
{
    NSLog(@"Reading type: %@", typeName);
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:outError];
    if (!doc)
    {
        NSLog(@"Invalid XML: %@", outError);
        return NO;
    }
    
    NSMutableDictionary *urls = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dates = [[NSMutableDictionary alloc] init];
    if (![self readFromFolder:[doc rootElement] intoUrls:urls intoDates:dates])
    {
        NSLog(@"Can't read XML");
        return NO;
    }
    
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    int changes = [l createLinksFromDictionary:urls onDates:nil fromSource:nil];
    NSLog(@"Growling changes: %d", changes);
    [GrowlApplicationBridge notifyWithTitle:@"Import Links" 
                                description:[NSString stringWithFormat:@"%d XBEL Links Added", changes] 
                           notificationName:LINKS_IMPORT
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@""];
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
{
    NSXMLDocument *doc = [NSXMLNode document];
    [doc setCharacterEncoding:@"UTF-8"];
    
    NSXMLElement *xbel = [NSXMLNode elementWithName:@"xbel"];
    [xbel addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1.0"]];
    [doc setRootElement:xbel];
    
    [xbel addChild:[NSXMLNode elementWithName:@"title" stringValue:@"Linkstr Links"]];
    
    for (PendingLink *p in m_items)
        [xbel addChild:[p asXBEL]];
    
    return [doc XMLDataWithOptions:
            NSXMLDocumentIncludeContentTypeDeclaration |
            NSXMLNodePrettyPrint | 
            NSXMLNodeCompactEmptyElement |
            NSXMLNodeUseSingleQuotes];    
}
@end
