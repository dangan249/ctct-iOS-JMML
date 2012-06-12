//
//  Wrapper.h
//  WrapperTest
//

#import <Foundation/Foundation.h> 
#import "WrapperDelegate.h"

@interface Wrapper : NSObject 
{
@private
    NSMutableData *receivedData;
    NSString *mimeType;
    NSURLConnection *conn;
    BOOL asynchronous;
    NSObject<WrapperDelegate> *delegate;
    NSString *username;
    NSString *password;
	NSInteger statusCode;
}

@property (nonatomic, readonly) NSData *receivedData;
@property (nonatomic) BOOL asynchronous;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) NSObject<WrapperDelegate> *delegate; // Do not retain delegates!

- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSString *)parameters;
- (void)uploadData:(NSData *)data toURL:(NSURL *)url;
- (void)cancelConnection;
- (NSDictionary *)responseAsPropertyList;
- (NSString *)responseAsText;

@end

