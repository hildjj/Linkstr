//
//  Keychain.m
//  Linkstr
//
//  Created by Joe Hildebrand on 8/22/07.
//  Copyright 2007 Cursive Systems, Inc. All rights reserved.
//

#import "Poster.h"

@implementation Poster

- (id)initWithDelegate:(id)delegate;
{
    if (![super init])
        return nil;
    
    m_pending = [[NSMutableArray alloc] init];
    m_delegate = delegate;
    m_outstanding = 0;
    m_total = 0;
    [NSBundle loadNibNamed:@"Keychain" owner:self];
    return self;
}

- (NSMutableDictionary*)contextForConnection:(NSURLConnection*)connection
{
    // well, of course I wish this wasn't a linear search.
    // But NSURLConnection can't be used as a hash key.
    for (NSMutableDictionary *dict in [m_pending objectEnumerator])
    {
        if ([[dict objectForKey:@"connection"] isEqual:connection])
        {
            return dict;
        }
    }
    return nil;
}

- (IBAction)done:(id)sender;
{
    NSButton *s = sender;
    if (!s)
        return;
    [NSApp stopModalWithCode:[s tag]];
}

- (void)getURL:(NSString*)url;
{
    NSURL *u = [NSURL URLWithString:url];
    if (!u)
        return;
    NSMutableURLRequest *req = 
        [NSMutableURLRequest requestWithURL:u
                                cachePolicy:NSURLCacheStorageNotAllowed
                            timeoutInterval:60.0];
    [req setValue:[[NSProcessInfo processInfo] processName]
        forHTTPHeaderField:@"User-Agent"];
    
    m_outstanding++;
    m_total++;
    NSURLConnection *con = 
        [NSURLConnection connectionWithRequest:req delegate:self];
    if (con == nil)
    {
        NSLog(@"could not open connection to: %@", url);
        return;
    }
    [m_pending addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
        url, @"url",
        con, @"connection",
        req, @"request",
        [NSMutableData data], @"data",
        nil]];
}

- (NSString*)urlEscape:(NSString*)str;
{
    static NSString *repl = @"@?&/;+'\"";
    NSMutableString *u = [[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    unsigned int i;
    for (i=0; i<[repl length]; i++)
    {
        unichar c = [repl characterAtIndex:i];
        [u replaceOccurrencesOfString:[NSString stringWithCharacters:&c length:1]
                           withString:[NSString stringWithFormat:@"%%%02x", c]
                              options:0 
                                range:NSMakeRange(0, [u length])];
    }
    return u;
}

- (void)getURL:(NSString*)url withParams:(NSDictionary*)params;
{
    NSMutableString *murl = [url mutableCopy];
    BOOL first = YES;
    NSEnumerator *en = [params keyEnumerator];
    NSString *key;
    while ((key = [en nextObject]))
    {
        if (first)
        {
            [murl appendString:@"?"];
            first = NO;
        }
        else
            [murl appendString:@"&"];
        [murl appendFormat:@"%@=%@", key, [self urlEscape:[params objectForKey:key]]];
    }
    [self getURL:murl];
}

- (void)finished:(NSURLConnection *)connection;
{
    NSDictionary *dict = [self contextForConnection:connection];
    [m_pending removeObject:dict];
    m_outstanding--;
    assert(m_outstanding == (int)[m_pending count]);
    
    if ([m_delegate respondsToSelector:@selector(poster:finishedLoading:)])
        [m_delegate poster:self finishedLoading:dict];

    if (m_outstanding != 0)
        return;
    
    if ([m_delegate respondsToSelector:@selector(poster:finishedOutstanding:)])
        [m_delegate poster:self finishedOutstanding:m_total];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    [self finished:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
    [self finished:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    if ([challenge previousFailureCount] > 2)
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        NSRunAlertPanel(@"Authentication Error",
                        @"Too many retries.  Giving up.",
                        @"OK", nil, nil);
    }
    
    while (1)
    {
        int code = [NSApp runModalForWindow:m_win];
        [m_win orderOut:self];
        if (code)
        {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            return;
        }
        if (([[m_pass stringValue] length] == 0) ||
            ([[m_user stringValue] length] == 0))
            NSBeep();
        else
            break;
    }
        
    NSURLCredential *cred = [NSURLCredential credentialWithUser:[m_user stringValue]
                                                       password:[m_pass stringValue]
                                                    persistence:NSURLCredentialPersistencePermanent];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    NSMutableDictionary *dict = [self contextForConnection:connection];
    [[dict objectForKey:@"data"] appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSMutableDictionary *dict = [self contextForConnection:connection];
    int code = [(NSHTTPURLResponse*)response statusCode];
    [dict setObject:[NSNumber numberWithInt:code] forKey:@"code"];
    NSMutableData *data = [dict objectForKey:@"data"];
    [data setLength:0];  // might get called more than once, on redirects
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
{
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    [self finished:connection];
}
@end
