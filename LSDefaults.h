//
//  LSDefaults.h
//  Linkstr
//
//  Created by Joe Hildebrand on 12/11/07.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *AGRESSIVE_CLOSE;
extern NSString *ALPHA;
extern NSString *AVOID_FUNNY;
extern NSString *DRAWER;
extern NSString *FIRST_TIME;
extern NSString *FLOAT;
extern NSString *IMPORT_HTTPS;
extern NSString *LAST_DELICIOUS;
extern NSString *SITES;
extern NSString *SQL_DEBUG;
extern NSString *TABLE_EVEN_BG;
extern NSString *TABLE_ODD_BG;
extern NSString *TABLE_TEXT_FG;
extern NSString *NAGLE_TIME_S;
extern NSString *REACH_HOST;
extern NSString *OLD_DEFAULT_APP;

extern NSString *LINK_NEW;
extern NSString *LINK_DEL;
extern NSString *LINKS_PENDING;
extern NSString *LINKS_REDUNDANT;
extern NSString *LINKS_HISTORY;
extern NSString *LINKS_IMPORT;

@interface LSDefaults : NSObject 
{
}

+ (void)setDefaults;

@end
