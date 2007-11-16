// 
//  urlList.m
//  Linkstr
//
//  Created by Joe Hildebrand on 7/20/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "urlList.h"

@implementation urlList 

+ (NSArray *)copyKeys;
{
    static NSArray *copyKeys = nil;
    if (!copyKeys) 
        copyKeys = [[NSArray alloc] initWithObjects: @"type", @"url", @"created", nil];
    return copyKeys;
}

- (NSDictionary *)dictionaryRepresentation;
{
    return [self dictionaryWithValuesForKeys:[[self class] copyKeys]];
}

@dynamic type;
@dynamic url;
@dynamic created;

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
                                             key:@"redundants"
                                        uniqueID:[self identifier]];
	return specifier;
}
@end
