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

- (NSString *)type 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"type"];
    tmpValue = [self primitiveValueForKey: @"type"];
    [self didAccessValueForKey: @"type"];
    
    return tmpValue;
}

- (void)setType:(NSString *)value 
{
    [self willChangeValueForKey: @"type"];
    [self setPrimitiveValue: value forKey: @"type"];
    [self didChangeValueForKey: @"type"];
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

- (void) awakeFromInsert;
{
    [super awakeFromInsert];
    if (![self created])
        [self setCreated:[NSCalendarDate calendarDate]];
}

- (NSScriptObjectSpecifier *)objectSpecifier;
{ 
    NSScriptClassDescription* appDesc = (NSScriptClassDescription*)[NSApp classDescription]; 
    return [[[NSNameSpecifier alloc] 
        initWithContainerClassDescription:appDesc 
                       containerSpecifier:nil 
                                      key:@"redundantUrls" 
                                     name:@"urlList"] autorelease]; 
} 
@end
