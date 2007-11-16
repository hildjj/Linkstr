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
    
    UNREAD = [NSImage imageNamed:@"unread"];
        
    [PendingLink setKeys:[NSArray arrayWithObjects:@"text", @"url", nil]
        triggerChangeNotificationsForDependentKey:@"descr"];
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

+ (BOOL)isFunny:(NSString*)str;
{
    if (!str)
        return NO;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"avoidFunnyLinks"])
        return NO;
    
    int funny = 0;
    uint i;
    for (i=0; i<[str length]; i++)
    {
        unichar c = [str characterAtIndex:i];
        if ((c == '&') ||
            (c > 566)) // arbitrary
            funny++;
        if (funny > 3) // yessir, that's pretty funny
        {
            NSLog(@"Funny, isn't it: '%@'", str);
            return YES;                        
        }
    }
    
    return NO;
}

- (NSDictionary *)dictionaryRepresentation;
{
    return [self dictionaryWithValuesForKeys:[[self class] copyKeys]];
}

- (NSString*) identifier
{
	return [[[self objectID] URIRepresentation] absoluteString];
}

- (NSScriptObjectSpecifier *)objectSpecifier;
{
    NSScriptClassDescription* appDesc = (NSScriptClassDescription*)[NSApp classDescription]; 
	NSUniqueIDSpecifier *specifier = [NSUniqueIDSpecifier alloc];
	[specifier initWithContainerClassDescription:appDesc
                              containerSpecifier:[NSApp objectSpecifier] 
                                             key:@"links"
                                        uniqueID:[self identifier]];
	return specifier;
}

@dynamic created;
@dynamic source;
@dynamic url;
@dynamic viewed;
@dynamic text;

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

- (BOOL)isPending;
{
    [self willAccessValueForKey: @"isPending"];
    BOOL ret = (self.viewed == nil);
    [self didAccessValueForKey: @"isPending"];
    return ret;
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

