//
//  PendingLink.h
//  CoreDataTest
//
//  Created by Joe Hildebrand on 7/18/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface PendingLink : NSManagedObject  
{
}

+ (void)initialize;
+ (NSArray *)copyKeys;
+ (NSString*)googleUrl:(NSString*)terms;
+ (NSString*)wikipediaUrl:(NSString*)terms;

- (NSDictionary *)dictionaryRepresentation;
- (NSScriptObjectSpecifier *)objectSpecifier;

- (NSString *)source;
- (void)setSource:(NSString *)value;

- (NSString *)url;
- (void)setUrl:(NSString *)value;

- (NSCalendarDate *)viewed;
- (void)setViewed:(NSCalendarDate *)value;

- (NSString *)descr;
- (BOOL)isViewed;

- (NSCalendarDate *)created;
- (void)setCreated:(NSCalendarDate *)value;

- (NSString *)text;
- (void)setText:(NSString *)value;

- (NSImage*)unviewedImage;

- (void) awakeFromInsert;
//- (BOOL)validateForInsert:(NSError **)error;
@end
