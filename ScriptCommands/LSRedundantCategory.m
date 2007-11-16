//
//  LSRedundantCategory.m
//  Linkstr
//
//  Created by Joe Hildebrand on 11/16/07.
//  Copyright 2007 Cursive Systems. All rights reserved.
//

#import "LSRedundantCategory.h"
#import "urlList.h"

@implementation Linkstr_AppDelegate (LSRedundantCategory)

- (id)valueInRedundantsWithUniqueID:(NSString *)string;
{
	NSURL *URIRepresentation = [NSURL URLWithString:string];
	NSManagedObjectID *objectID = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:URIRepresentation];
	urlList *returnValue = (urlList *)[[self managedObjectContext] objectWithID:objectID];
	return ([returnValue isDeleted] || [[[self managedObjectContext] deletedObjects] containsObject:returnValue]) ? nil: [[self managedObjectContext] objectWithID:objectID];
}

-(void)removeFromRedundantsAtIndex:(unsigned int)i;
{ 
    NSLog(@"TODO: remove object");
    urlList *u = [[self redundants] objectAtIndex:i];
    if (!u)
        return;  // TODO: throw error
    
    [[self managedObjectContext] deleteObject:u];    
} 

- (id)createRedundantUrl:(NSString*)url;
{
    NSLog(@"Create redundant: %@", url);
    
    NSFetchRequest *fetch = 
    [[self managedObjectModel] fetchRequestFromTemplateWithName:@"sourceExists"
                                          substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 url, @"URL", 
                                                                 @"R", @"TYPE", nil]];
    NSAssert(fetch, @"Fetch not found");
    NSArray *res = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
    urlList *u;
    if ([res count] > 0)
        u = [res objectAtIndex:0];
    else
    {
        u = [NSEntityDescription insertNewObjectForEntityForName:@"Sources" 
                                          inManagedObjectContext:[self managedObjectContext]];
        u.url = url;
        u.type = @"R";
    }
    return u;
}

@end
