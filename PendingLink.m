// 
//  PendingLink.m
//  CoreDataTest
//
//  Created by Joe Hildebrand on 7/18/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "PendingLink.h"
#import "Linkstr_AppDelegate.h"

@implementation PendingLink 

static NSImage *UNREAD;

+ (void)initialize;
{
    if (self != [PendingLink class])
        return;
    
    UNREAD = [[NSImage imageNamed:@"unread"] retain];
        
    [PendingLink setKeys:[NSArray arrayWithObjects:@"text", @"url", nil]
        triggerChangeNotificationsForDependentKey:@"descr"];
    [PendingLink setKeys:[NSArray arrayWithObjects:@"viewed", nil]
        triggerChangeNotificationsForDependentKey:@"isViewed"];
    [PendingLink setKeys:[NSArray arrayWithObjects:@"viewed", nil]
        triggerChangeNotificationsForDependentKey:@"unviewedImage"];
    
}

+ (NSArray *)copyKeys;
{
    static NSArray *copyKeys = nil;
    if (!copyKeys) 
        copyKeys = [[NSArray alloc] initWithObjects: @"url", @"created", @"viewed", @"text", @"source", nil];
    return copyKeys;
}

- (NSDictionary *)dictionaryRepresentation;
{
    return [self dictionaryWithValuesForKeys:[[self class] copyKeys]];
}

- (NSScriptObjectSpecifier *)objectSpecifier;
{ 
    NSScriptClassDescription* appDesc = (NSScriptClassDescription*)[NSApp classDescription]; 
    return [[[NSNameSpecifier alloc] 
        initWithContainerClassDescription:appDesc 
                       containerSpecifier:[NSApp objectSpecifier] 
                                      key:@"contents" 
                                     name:[self url]] autorelease]; 
} 

@dynamic created;
@dynamic source;
@dynamic url;
@dynamic viewed;
@dynamic text;

- (BOOL)isViewed;
{
    return (self.viewed != nil);
}

- (NSString *)descr 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"descr"];
    tmpValue = self.text;
    if (!tmpValue)
        tmpValue = self.url;
    [self didAccessValueForKey: @"descr"];
    
    return tmpValue;
}

- (NSImage*)unviewedImage
{
    [self willAccessValueForKey: @"unviewedImage"];
    if (self.viewed)
    {
        [self didAccessValueForKey: @"unviewedImage"];
        return nil;        
    }
    [self didAccessValueForKey: @"unviewedImage"];
    return UNREAD;
}

- (void) awakeFromInsert;
{
    [super awakeFromInsert];
    if (!self.created)
        self.created = [NSCalendarDate calendarDate];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSLog(@"undefined key(%@): %@", [self class], key);
    return nil;
}

- (NSXMLElement*)asHTML;
{
    NSXMLElement *dv = [NSXMLNode elementWithName:@"div"];
    [dv addNamespace:[NSXMLNode namespaceWithName:@"" stringValue:@"http://www.w3.org/1999/xhtml"]];
    if (self.created)
    {
        NSXMLElement *p = [NSXMLNode elementWithName:@"div" stringValue:@"Created: "];
        [p addChild:[NSXMLNode elementWithName:@"b" stringValue:[self.created description]]];
        [dv addChild:p];
    }
    if (self.viewed)
    {
        NSXMLElement *p = [NSXMLNode elementWithName:@"div" stringValue:@"Viewed: "];
        [p addChild:[NSXMLNode elementWithName:@"b" stringValue:[self.viewed description]]];
        [dv addChild:p];
    }
    if (self.source)
    {
        NSXMLElement *p = [NSXMLNode elementWithName:@"div" stringValue:@"Source: "];
        [dv addChild:p];        
        NSXMLElement *a = [NSXMLNode elementWithName:@"a" stringValue:self.source];
        [p addChild:a];
        [a addAttribute:[NSXMLNode attributeWithName:@"href" stringValue:self.source]];
    }
    return dv;
}
@end
