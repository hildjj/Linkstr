//
//  LSXMLAdditions.h
//  Linkstr
//
//  Created by Joe Hildebrand on 1/2/08.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSXMLElement (LSXMLAdditions)
- (NSXMLElement*)firstElementNamed:(NSString*)elementName;
- (NSString*)valueOfChildNamed:(NSString*)elementName;
- (NSString*)valueOfAttributeNamed:(NSString*)attributeName;
@end
