//
//  LSAParseHtmlCommand.m
//  Linkstr
//
//  Created by Joe Hildebrand on 8/16/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "LSParseHtmlCommand.h"
#import "ImportHTML.h"

@implementation LSParseHtmlCommand

- (id)performDefaultImplementation;
{
    NSString *html = [self directParameter];
    if (!html)
        return nil;
    NSString *source = [[self evaluatedArguments] objectForKey:@"source"];
    Linkstr_AppDelegate *l = (Linkstr_AppDelegate*)[[NSApplication sharedApplication] delegate];
    ImportHTML *importer = [[ImportHTML alloc] initWithHtmlString:html
                                                           source:source
                                                          linkstr:l];
    [importer popup];
    
    return nil;
}

@end
