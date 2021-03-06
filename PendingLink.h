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
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key;
+ (NSArray *)copyKeys;
+ (BOOL)isFunny:(NSString*)str;
+ (NSString*)DeHTML:(NSString*)html;

- (NSString*) identifier;
- (NSDictionary *)dictionaryRepresentation;
- (NSScriptObjectSpecifier *)objectSpecifier;

@property (retain) NSCalendarDate *created;
@property (retain) NSCalendarDate *viewed;
@property (retain) NSString *source;
@property (retain) NSString *url;
@property (retain) NSString *text;

- (NSString *)descr;
- (NSImage*)unviewedImage;
- (BOOL)isPending;

- (void) awakeFromInsert;
- (NSXMLElement*)asHTML;
- (NSXMLElement*)asOPML;
- (NSXMLElement*)asAtom;
- (NSXMLElement*)asXBEL;

@end
