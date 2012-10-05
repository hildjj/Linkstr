//
//  LSDefaults.m
//  Linkstr
//
//  Created by Joe Hildebrand on 12/11/07.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import "LSDefaults.h"


@implementation LSDefaults

NSString *AGRESSIVE_CLOSE = @"agressiveClose";
NSString *ALPHA = @"alpha";
NSString *AVOID_FUNNY = @"avoidFunnyLinks";
NSString *DRAWER = @"showDrawer";
NSString *FIRST_TIME = @"firstTime";
NSString *FLOAT = @"floatOnTop";
NSString *IMPORT_HTTPS = @"importHTTPS";
NSString *LAST_DELICIOUS = @"LastDeliciousDate";
NSString *SITES = @"sites";
NSString *SQL_DEBUG = @"sqlDebug";
NSString *TABLE_EVEN_BG = @"tableEvenBackground";
NSString *TABLE_ODD_BG = @"tableOddBackground";
NSString *TABLE_TEXT_FG = @"tableTextForeground";
NSString *NAGLE_TIME_S = @"nagleTimeS";
NSString *REACH_HOST = @"reachHost";
NSString *OLD_DEFAULT_APP = @"oldDefaultApp_%@";

NSString *LINK_NEW = @"New Link";
NSString *LINK_DEL = @"Link Deleted";
NSString *LINKS_PENDING = @"Pending Links";
NSString *LINKS_REDUNDANT = @"Redundant Links";
NSString *LINKS_HISTORY = @"History Links";
NSString *LINKS_IMPORT = @"Import Links";

+ (void)setDefaults;
{
    NSArray *sites = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"Insert URL", @"name",
                       @"%@", @"url",
                       @"%@", @"description",
                       @"u", @"key",
                       @"formatURL:", @"formatter",
                       [NSNumber numberWithUnsignedInt:NSControlKeyMask], @"mask",
                       nil], @"URL",
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"Google", @"name",
                       @"http://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8", @"url",
                       @"Google search for '%@'", @"description",
                       @"Google", @"image",
                       @"g", @"key",
                       [NSNumber numberWithUnsignedInt:NSControlKeyMask], @"mask",
                       nil], @"Google",
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"Wikipedia", @"name",
                       @"http://www.wikipedia.org/w/wiki.phtml?search=%@", @"url",
                       @"Wikipedia search for '%@'", @"description",
                       @"Wiki", @"image",
                       @"w", @"key",
                       [NSNumber numberWithUnsignedInt:NSControlKeyMask], @"mask",
                       nil], @"Wikipedia",
                      nil];
    
    [NSColor setIgnoresAlpha:NO];
    NSColor *txt_fg = [NSColor colorWithDeviceRed:1.0
                                            green:1.0
                                             blue:1.0
                                            alpha:0.6];
    NSColor *table_even_bg = [NSColor colorWithDeviceRed:0.2 
                                                   green:0.2 
                                                    blue:0.2
                                                   alpha:1.0];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      @"YES", DRAWER,
      @"NO", SQL_DEBUG,
      @"NO", FLOAT,
      @"YES", AGRESSIVE_CLOSE,
      @"YES", FIRST_TIME,
      @"NO", IMPORT_HTTPS,
      @"YES", AVOID_FUNNY,
      [NSNumber numberWithFloat:0.1], NAGLE_TIME_S,
      [NSNumber numberWithFloat:0.55], ALPHA,
      // @"http://linkstr.net/changes.xml", @"SUFeedURL",
      sites, SITES,
      [NSArchiver archivedDataWithRootObject:txt_fg], TABLE_TEXT_FG,
      [NSArchiver archivedDataWithRootObject:table_even_bg], TABLE_EVEN_BG,
      [NSArchiver archivedDataWithRootObject:[NSColor blackColor]], TABLE_ODD_BG,
      @"www.google.com", REACH_HOST,
      nil]];
}
@end
