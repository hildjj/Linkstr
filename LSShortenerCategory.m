//
//  LSShortenerCategory.m
//  Linkstr
//
//  Created by Joe Hildebrand on 8/31/10.
//  Copyright (c) 2010 Cisco Systems, Inc. All rights reserved.
//

#import "LSShortenerCategory.h"
#import "urlList.h"

@implementation Linkstr_AppDelegate (LSShortenerCategory)

- (id)valueInShortnersWithUniqueID:(NSString *)string;
{
	NSURL *URIRepresentation = [NSURL URLWithString:string];
	NSManagedObjectID *objectID = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:URIRepresentation];
	urlList *returnValue = (urlList *)[[self managedObjectContext] objectWithID:objectID];
	return ([returnValue isDeleted] || [[[self managedObjectContext] deletedObjects] containsObject:returnValue]) ? nil: [[self managedObjectContext] objectWithID:objectID];
}

-(void)removeFromShortenersAtIndex:(unsigned int)i;
{ 
    NSLog(@"TODO: remove object");
    urlList *u = [[self shorteners] objectAtIndex:i];
    if (!u)
        return;  // TODO: throw error
    
    [[self managedObjectContext] deleteObject:u];    
} 

- (id)createShortenerUrl:(NSString*)url;
{
    NSLog(@"Create shortener: %@", url);
    
    NSFetchRequest *fetch = 
    [[self managedObjectModel] fetchRequestFromTemplateWithName:@"sourceExists"
                                          substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 url, @"URL", 
                                                                 @"S", @"TYPE", nil]];
    NSAssert(fetch, @"Fetch not found");
    NSArray *res = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
    urlList *u;
    if (res && ([res count] > 0))
        u = [res objectAtIndex:0];
    else
    {
        u = [NSEntityDescription insertNewObjectForEntityForName:@"Sources" 
                                          inManagedObjectContext:[self managedObjectContext]];
        u.url = url;
        u.type = @"S";

        // Delete old URLs that start with this shortener
        fetch = 
        [[self managedObjectModel] fetchRequestFromTemplateWithName:@"fetchShortened"
                                              substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     url, @"SHORTENER",
                                                                     nil]];
        NSAssert(fetch, @"Fetch not found");
        res = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
        if (res)
        {
            for (PendingLink *p in res)
            {
                [[self managedObjectContext] deleteObject:p];
            }
        }
    }
    return u;
}

@end
