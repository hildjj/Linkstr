// 
//  PendingLink.m
//  CoreDataTest
//
//  Created by Joe Hildebrand on 7/18/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "PendingLink.h"
#import "Linkstr_AppDelegate.h"
#import "LSDefaults.h"

@implementation PendingLink 

@dynamic created;
@dynamic source;
@dynamic url;
@dynamic viewed;
@dynamic text;

static NSImage *UNREAD;

+ (void)initialize;
{
    if (self != [PendingLink class])
        return;
    
    UNREAD = [NSImage imageNamed:@"unread"];            
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"descr"])
    {
        return [NSArray arrayWithObjects:@"text", @"url", nil];
    }
    if ([key isEqualToString:@"unviewedImage"])
    {
        return [NSArray arrayWithObjects:@"viewed", nil];
    }
    return nil;
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
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:AVOID_FUNNY])
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

+ (NSString*)DeHTML:(NSString*)html;
{
    NSRange r = [html rangeOfString:@"&"];
    if (r.location == NSNotFound)
        return html;
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *as = [[NSAttributedString alloc] initWithHTML:data
                                                   documentAttributes:nil];
    return [as string];
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
	NSUniqueIDSpecifier *specifier = [[NSUniqueIDSpecifier alloc]
                                      initWithContainerClassDescription:appDesc
                                                     containerSpecifier:[NSApp objectSpecifier] 
                                                                    key:@"links"
                                                               uniqueID:[self identifier]];
	return specifier;
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

- (NSXMLElement*)asOPML;
{
    NSXMLElement *outl = [NSXMLNode elementWithName:@"outline" ];
    [outl setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     self.descr, @"text",
                                     @"link", @"type",
                                     self.url, @"url",
                                     nil]];
    return outl;
}

- (NSString*)dateAsString:(NSCalendarDate*)date;
{
    return [date descriptionWithCalendarFormat:ATOM_DATE_FMT 
                                      timeZone:nil 
                                        locale:nil];
}

- (NSXMLElement*)asAtom;
{
    NSXMLElement *entry = [NSXMLNode elementWithName:@"entry" ];
    [entry addChild:[NSXMLNode elementWithName:@"id"
                                   stringValue:self.url]];
    [entry addChild:[NSXMLNode elementWithName:@"title"
                                   stringValue:self.descr]];
    [entry addChild:[NSXMLNode elementWithName:@"updated"
                                   stringValue:[self dateAsString:self.created]]];
    NSXMLElement *lnk = [NSXMLNode elementWithName:@"link"];
    [entry addChild:lnk];
    [lnk addAttribute:[NSXMLNode attributeWithName:@"href" stringValue:self.url]];
    
    NSXMLElement *content = [NSXMLNode elementWithName:@"content"];
    [entry addChild:content];
    [content addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"xhtml"]];
    [content addChild:[self asHTML]]; 
    return entry;
}

- (NSXMLElement*)asXBEL;
{
    /*
    <bookmark href="http://www.oreilly.com/catalog/learnxml/">
      <title>Learning XML</title>
      <desc>Eric T. Ray, (O'Reilly)</desc>
    </bookmark>
    */
    
    NSXMLElement *bookmark = [NSXMLNode elementWithName:@"bookmark" ];
    [bookmark addAttribute:[NSXMLNode attributeWithName:@"href" stringValue:self.url]];
    // XBEL docs aren't terribly clear on date format.
    [bookmark addAttribute:[NSXMLNode attributeWithName:@"added" 
                                            stringValue:[self dateAsString:self.created]]];
    if (self.viewed)
        [bookmark addAttribute:[NSXMLNode attributeWithName:@"visited" 
                                                stringValue:[self dateAsString:self.viewed]]];
        
    if (self.text)
        [bookmark addChild:[NSXMLNode elementWithName:@"title"
                                          stringValue:self.text]];
    
    return bookmark;
}

@end

