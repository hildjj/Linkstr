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

- (NSDictionary *)dictionaryRepresentation;
- (NSScriptObjectSpecifier *)objectSpecifier;

@property (retain) NSCalendarDate *created;
@property (retain) NSCalendarDate *viewed;
@property (retain) NSString *source;
@property (retain) NSString *url;
@property (retain) NSString *text;

- (NSString *)descr;
- (BOOL)isViewed;
- (NSImage*)unviewedImage;

- (void) awakeFromInsert;
- (NSXMLElement*)asHTML;
@end
