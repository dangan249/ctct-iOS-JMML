//
//  WrapperDelegate.h
//

#import <Foundation/Foundation.h> 

@class Wrapper;

@protocol WrapperDelegate

@required
- (void)wrapper:(Wrapper *)wrapper didRetrieveData:(NSData *)data status:(int)statusCode;

@optional
- (void)wrapperHasBadCredentials:(Wrapper *)wrapper;
- (void)wrapper:(Wrapper *)wrapper didCreateResourceAtURL:(NSString *)url;
- (void)wrapper:(Wrapper *)wrapper didFailWithError:(NSError *)error;
- (void)wrapper:(Wrapper *)wrapper didReceiveStatusCode:(int)statusCode;

@end
