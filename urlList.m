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
