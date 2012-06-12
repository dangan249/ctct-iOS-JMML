//
//  Wrapper.m
//  WrapperTest
//

#import "Wrapper.h"

@interface Wrapper (Private)
- (void)startConnection:(NSURLRequest *)request;
@end

@implementation Wrapper

@synthesize receivedData;
@synthesize asynchronous;
@synthesize mimeType;
@synthesize username;
@synthesize password;
@synthesize delegate;
@synthesize statusCode;

#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if(self = [super init])
    {
        receivedData = [[NSMutableData alloc] init];
        conn = nil;
		
        asynchronous = YES;
        mimeType = @"text/html";
        delegate = nil;
        username = @"";
        password = @"";
    }
	
    return self;
}

- (void)dealloc
{
    [receivedData release];
    receivedData = nil;
    self.mimeType = nil;
    self.username = nil;
    self.password = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSString *)parameters
{
    NSData *body = nil;
    NSString *contentType = @"text/html; charset=utf-8";
    NSURL *finalURL = url;
    
    if ([verb isEqualToString:@"POST"] || [verb isEqualToString:@"PUT"])
    {
        contentType = @"application/atom+xml; charset=utf-8";
        body = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    }
	
    NSMutableDictionary* headers = [[[NSMutableDictionary alloc] init] autorelease];
    [headers setValue:contentType forKey:@"Content-Type"];
    [headers setValue:mimeType forKey:@"Accept"];
    [headers setValue:@"no-cache" forKey:@"Cache-Control"];
    [headers setValue:@"no-cache" forKey:@"Pragma"];
    [headers setValue:@"close" forKey:@"Connection"]; // Avoid HTTP 1.1 "keep alive" for the connection
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:verb];
    [request setAllHTTPHeaderFields:headers];
    if (parameters != nil)
    {
        [request setHTTPBody:body];
    }
    [self startConnection:request];
}

- (void)uploadData:(NSData *)data toURL:(NSURL *)url
{

    NSString* stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    
    NSMutableDictionary* headers = [[[NSMutableDictionary alloc] init] autorelease];
    [headers setValue:@"no-cache" forKey:@"Cache-Control"];
    [headers setValue:@"no-cache" forKey:@"Pragma"];
    [headers setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forKey:@"Content-Type"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSMutableData* postData = [NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"test.bin\"\r\n\r\n" 
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
	
    [self startConnection:request];
}

- (void)cancelConnection
{
    [conn cancel];
    [conn release];
    conn = nil;
}

- (NSDictionary *)responseAsPropertyList
{
    NSString *errorStr = nil;
    NSPropertyListFormat format;
    NSDictionary *propertyList = [NSPropertyListSerialization propertyListFromData:receivedData
                                                                  mutabilityOption:NSPropertyListImmutable
                                                                            format:&format
                                                                  errorDescription:&errorStr];
    [errorStr release];
    return propertyList;
}

- (NSString *)responseAsText
{
    return [[[NSString alloc] initWithData:receivedData 
								  encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark -
#pragma mark Private methods

- (void)startConnection:(NSURLRequest *)request
{
    if (asynchronous)
    {
		[self cancelConnection];
        conn = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:self
                                       startImmediately:YES];
        
        if (!conn)
        {
            if ([delegate respondsToSelector:@selector(wrapper:didFailWithError:)])
            {
                NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[request URL] forKey:NSURLErrorFailingURLStringErrorKey];
                [info setObject:@"Could not open connection" forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:@"Wrapper" code:1 userInfo:info];
                [delegate wrapper:self didFailWithError:error];
            }
        }
    }
    else
    {
        NSURLResponse* response = [[NSURLResponse alloc] init];
        NSError* error = [[NSError alloc] init];
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [receivedData setData:data];
		statusCode = error.code;
		if ([delegate respondsToSelector:@selector(wrapper:didRetrieveData:status:)])
		{
			[delegate wrapper:self didRetrieveData:receivedData status:statusCode];
		}
        [response release];
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSInteger count = [challenge previousFailureCount];
    if (count == 0)
    {
        NSURLCredential* credential = [NSURLCredential credentialWithUser:username
																 password:password
															  persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:credential 
               forAuthenticationChallenge:challenge];
		
    }
    else
    {
//         [[challenge sender] cancelAuthenticationChallenge:challenge];
		[self cancelConnection];
        if ([delegate respondsToSelector:@selector(wrapperHasBadCredentials:)])
        {
            [delegate wrapperHasBadCredentials:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    statusCode = [httpResponse statusCode];
    switch (statusCode)
    {
        case 200:
            break;
			
        case 201:
        {
            NSString* url = [[httpResponse allHeaderFields] objectForKey:@"Location"];
            if ([delegate respondsToSelector:@selector(wrapper:didCreateResourceAtURL:)])
            {
                [delegate wrapper:self didCreateResourceAtURL:url];
            }
            break;
        }
            
			
        default:
        {
            if ([delegate respondsToSelector:@selector(wrapper:didReceiveStatusCode:)])
            {
                [delegate wrapper:self didReceiveStatusCode:statusCode];
            }
            break;
        }
    }
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self cancelConnection];
    if ([delegate respondsToSelector:@selector(wrapper:didFailWithError:)])
    {
        [delegate wrapper:self didFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cancelConnection];
    if ([delegate respondsToSelector:@selector(wrapper:didRetrieveData:status:)])
    {
        [delegate wrapper:self didRetrieveData:receivedData status:statusCode];
    }
}

@end