//
//  LSXMLAdditions.m
//  Linkstr
//
//  Created by Joe Hildebrand on 1/2/08.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import "LSXMLAdditions.h"


@implementation NSXMLElement (LSXMLAdditions)
- (NSString*)valueOfChildNamed:(NSString*)elementName;
{
    for (NSXMLElement *child in [self elementsForName:elementName])
        return [child stringValue];
    return nil;
}

- (NSString*)valueOfAttributeNamed:(NSString*)attributeName;
{
    NSXMLNode *node = [self attributeForName:attributeName];
    if (!node)
        return nil;
    return [node stringValue];
}

- (NSXMLElement*)firstElementNamed:(NSString*)elementName;
{
    for (NSXMLElement *child in [self elementsForName:elementName])
        return child;
    return nil;    
}
@end
