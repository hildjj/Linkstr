//
//  LSDocXBEL.h
//  Linkstr
//
//  Created by Joe Hildebrand on 1/2/08.
//  Copyright 2007-2008 Cursive Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LSDocXBEL : NSDocument
{
@private
    NSMutableArray *m_items;
}

- (id)initWithSelection:(NSArray*)items;
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;

@end
