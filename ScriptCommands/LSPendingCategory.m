//
//  LSPendingCategory.m
//  Linkstr
//
//  Created by Joe Hildebrand on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "LSPendingCategory.h"
#import "PendingLink.h"

@implementation Linkstr_AppDelegate (LSPendingCategory)

- (id)valueInLinksWithUniqueID:(NSString *)string;
{
	NSURL *URIRepresentation = [NSURL URLWithString:string];
	NSManagedObjectID *objectID = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:URIRepresentation];
	PendingLink *returnValue = (PendingLink *)[[self managedObjectContext] objectWithID:objectID];
	return ([returnValue isDeleted] || [[[self managedObjectContext] deletedObjects] containsObject:returnValue]) ? nil: [[self managedObjectContext] objectWithID:objectID];
}

- (void)insertInContent:(PendingLink*)p;
{
    NSLog(@"insert: %@", [p url]);
    [[self managedObjectContext] insertObject:p];    
}


@end
