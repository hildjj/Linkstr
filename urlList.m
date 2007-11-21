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
    NSString *key;
    if ([self.type isEqualToString:@"R"])
        key = @"redundants";
    else if ([self.type isEqualToString:@"I"])
        key = @"incompletes";
    else
    {
        NSAssert(NO, @"URL of type not R or I");
        return nil;
    }
    
	[specifier initWithContainerClassDescription:appDesc
                              containerSpecifier:[NSApp objectSpecifier] 
                                             key:key
                                        uniqueID:[self identifier]];
	return specifier;
}
@end
