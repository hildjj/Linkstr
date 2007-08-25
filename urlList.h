//
//  urlList.h
//  Linkstr
//
//  Created by Joe Hildebrand on 7/20/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface urlList :  NSManagedObject  
{
}

- (NSString *)type;
- (void)setType:(NSString *)value;

- (NSString *)url;
- (void)setUrl:(NSString *)value;

- (NSCalendarDate *)created;
- (void)setCreated:(NSCalendarDate *)value;

@end
