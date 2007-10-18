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
NSString *GOOG = @"http://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8";
NSString *WIKI = @"http://www.wikipedia.org/w/wiki.phtml?search=%@";

+ (void)initialize;
{
    if (self != [PendingLink class])
        return;
    
    UNREAD = [[NSImage imageNamed:@"unread"] retain];
//    [UNREAD setScalesWhenResized:YES];
//    [UNREAD setSize:NSMakeSize(10, 10)];
        
    [self setKeys:[NSArray arrayWithObjects:@"text", @"url", nil]
          triggerChangeNotificationsForDependentKey:@"descr"];
}

+ (NSArray *)copyKeys;
{
    static NSArray *copyKeys = nil;
    if (!copyKeys) 
        copyKeys = [[NSArray alloc] initWithObjects: @"url", @"created", @"viewed", @"text", @"source", nil];
    return copyKeys;
}
/*
+ (NSString*)googleUrl:(NSString*)terms;
{
    NSString *pct = [terms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:GOOG, pct];
}

+ (NSString*)wikipediaUrl:(NSString*)terms;
{
    NSString *pct = [terms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:WIKI, pct];
}
*/
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


- (NSString *)source 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"source"];
    tmpValue = [self primitiveValueForKey: @"source"];
    [self didAccessValueForKey: @"source"];
    
    return tmpValue;
}

- (void)setSource:(NSString *)value 
{
    [self willChangeValueForKey: @"source"];
    [self setPrimitiveValue: value forKey: @"source"];
    [self didChangeValueForKey: @"source"];
}

- (NSString *)url 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"url"];
    tmpValue = [self primitiveValueForKey: @"url"];
    [self didAccessValueForKey: @"url"];
    
    return tmpValue;
}

- (void)setUrl:(NSString *)value 
{
    [self willChangeValueForKey: @"url"];
    [self setPrimitiveValue: value forKey: @"url"];
    [self didChangeValueForKey: @"url"];
}

- (NSCalendarDate *)viewed 
{
    NSCalendarDate * tmpValue;
    
    [self willAccessValueForKey: @"viewed"];
    tmpValue = [self primitiveValueForKey: @"viewed"];
    [self didAccessValueForKey: @"viewed"];
    
    return tmpValue;
}

- (void)setViewed:(NSCalendarDate *)value 
{
    [self willChangeValueForKey: @"viewed"];
    [self willChangeValueForKey: @"isViewed"];
    [self willChangeValueForKey: @"unviewedImage"];
    [self setPrimitiveValue: value forKey: @"viewed"];
    [self didChangeValueForKey: @"unviewedImage"];
    [self didChangeValueForKey: @"isViewed"];
    [self didChangeValueForKey: @"viewed"];
}

- (BOOL)isViewed;
{
    NSCalendarDate * tmpValue = [self viewed];
    return (tmpValue != nil);
}

- (NSString *)descr 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"descr"];
    tmpValue = [self text];
    if (!tmpValue)
        tmpValue = [self url];
    [self didAccessValueForKey: @"descr"];
    
    return tmpValue;
}

- (NSCalendarDate *)created 
{
    NSCalendarDate * tmpValue;
    
    [self willAccessValueForKey: @"created"];
    tmpValue = [self primitiveValueForKey: @"created"];
    [self didAccessValueForKey: @"created"];
    
    return tmpValue;
}

- (void)setCreated:(NSCalendarDate *)value 
{
    [self willChangeValueForKey: @"created"];
    [self setPrimitiveValue: value forKey: @"created"];
    [self didChangeValueForKey: @"created"];
}

- (NSString *)text 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"text"];
    tmpValue = [self primitiveValueForKey: @"text"];
    [self didAccessValueForKey: @"text"];
    
    return tmpValue;
}

- (void)setText:(NSString *)value 
{
    [self willChangeValueForKey: @"text"];
    [self setPrimitiveValue: value forKey: @"text"];
    [self didChangeValueForKey: @"text"];
}

- (NSImage*)unviewedImage
{
    [self willAccessValueForKey: @"unviewedImage"];
    if ([self viewed])
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
    if (![self created])
        [self setCreated:[NSCalendarDate calendarDate]];
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
    if ([self created])
    {
        NSXMLElement *p = [NSXMLNode elementWithName:@"div" stringValue:@"Created: "];
        [p addChild:[NSXMLNode elementWithName:@"b" stringValue:[[self created] description]]];
        [dv addChild:p];
    }
    if ([self viewed])
    {
        NSXMLElement *p = [NSXMLNode elementWithName:@"div" stringValue:@"Viewed: "];
        [p addChild:[NSXMLNode elementWithName:@"b" stringValue:[[self viewed] description]]];
        [dv addChild:p];
    }
    if ([self source])
    {
        NSXMLElement *p = [NSXMLNode elementWithName:@"div" stringValue:@"Source: "];
        [dv addChild:p];        
        NSXMLElement *a = [NSXMLNode elementWithName:@"a" stringValue:[self source]];
        [p addChild:a];
        [a addAttribute:[NSXMLNode attributeWithName:@"href" stringValue:[self source]]];
    }
    return dv;
}
@end
