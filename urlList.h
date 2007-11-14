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

@property (retain) NSString *type;
@property (retain) NSString *url;
@property (retain) NSCalendarDate *created;

@end
