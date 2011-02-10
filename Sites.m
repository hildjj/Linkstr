//
//  Sites.m
//  Linkstr
//
//  Created by Joe Hildebrand on 9/15/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "Sites.h"

extern NSString *SITES;

@implementation Sites

// order the keys of the array by the text that will be shown
NSInteger compareSites(id one, id two, void *context)
{
    NSDictionary *sites = (NSDictionary *)context;
    NSDictionary *od = [sites objectForKey:one];
    NSDictionary *td = [sites objectForKey:two];
    return [[od objectForKey:@"name"] compare:[td objectForKey:@"name"]];
}

- (NSString*)keyStringForKey:(NSString*)key andMask:(unsigned int)mask
{
    if (!key)
        return nil;

    NSMutableString *keyString = [NSMutableString stringWithCapacity:10];
    if (mask & NSControlKeyMask)
        [keyString appendFormat:@"%C", 0x2303];
    if (mask & NSAlternateKeyMask)
        [keyString appendFormat:@"%C", 0x2325];
    if (mask & NSShiftKeyMask)
        [keyString appendFormat:@"%C", 0x21E7];
    if (mask & NSCommandKeyMask)
        [keyString appendFormat:@"%C", 0x2318];
    [keyString appendString:[key uppercaseString]];
    return keyString;
}

- (void)fill
{
    id anon_sites = [[NSUserDefaults standardUserDefaults] objectForKey:SITES];
    NSDictionary *site;
    NSEnumerator *en;
    if ([anon_sites isKindOfClass:[NSArray class]])
    {
        // convert old.  Eventually, this will be deprecated out.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        en = [anon_sites objectEnumerator];
        while ((site = [en nextObject]))
            [dict setObject:site forKey:[site objectForKey:@"name"]];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:SITES];
        anon_sites = dict;
    }
    NSDictionary *sites = anon_sites;
    NSArray *keys = [sites allKeys];
    keys = [keys sortedArrayUsingFunction:compareSites context:sites];
    
    for (NSString *key in keys)
    {
        site = [sites objectForKey:key];
        NSMutableDictionary *msite = [site mutableCopy];
        NSString *keyString = [self keyStringForKey:[msite objectForKey:@"key"]
                                            andMask:[[msite objectForKey:@"mask"] unsignedIntValue]];
        if (keyString)
            [msite setObject:keyString forKey:@"keyString"];
        [self addObject:msite];
    }            
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    [self fill];
    return self;
}

-(id)init;
{
    if (!(self = [super init]))
        return nil;
    [self fill];
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [[self content] countByEnumeratingWithState:state objects:stackbuf count:len];
}

+ (void)addSitesToMenu:(NSMenu*)menu target:(id)target action:(SEL)action;
{
    Sites *s = [[Sites alloc] init];
    for (NSDictionary *site in s)
    {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTitle:[site objectForKey:@"name"]];
        NSString *key = [site objectForKey:@"key"];
        if (key)
            [item setKeyEquivalent:key];
        NSNumber *mask = [site objectForKey:@"mask"];
        if (mask)
            [item setKeyEquivalentModifierMask:[mask unsignedIntValue]];
        [item setTarget:target];
        [item setAction:action];
        [item setRepresentedObject:site];
        [menu addItem:item];
    }
}

@end
