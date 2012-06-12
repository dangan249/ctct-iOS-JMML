//
//  JMMLAppDelegate.m
//  JMML
//

#import "JMMLAppDelegate.h"
#import "KioskViewController.h"
#import	"Constants.h"

@implementation JMMLAppDelegate

@synthesize window;

// IOS4 supports multitasking and we need to recheck connection and see if there are offline contacts to load
// also need to check if user "locked" the app

-(void) applicationWillEnterForeground:(UIApplication*)application {

    [[NSUserDefaults standardUserDefaults] synchronize];
	
    BOOL locked = [[NSUserDefaults standardUserDefaults] boolForKey:@"locked"];
    [KioskVC.btnSettings setHidden:locked];
		
	[KioskVC CheckCredentials];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	// Listen to notifications to show/dismiss/update loading screen
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(showLoadingView:) 
												 name:@"showLoadingView" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(dismissLoadingView) 
												 name:@"dismissLoadingView" 
											   object:nil];
	
	loadingSpinnerViewController = [[LoadingSpinnerViewController alloc] initWithNibName:@"LoadingSpinnerViewController" bundle:nil];
	[loadingSpinnerViewController.view setAlpha:0.0];
	//[loadingSpinnerViewController.view setFrame:CGRectMake(200, 200, 200, 200)];
	[loadingSpinnerViewController.view setFrame:CGRectMake(0, 0, 320, 520)];

	KioskVC = [[KioskViewController alloc] initWithNibName:@"KioskViewController" bundle:nil];
    [KioskVC.view setFrame:[UIScreen mainScreen].applicationFrame];

    // Update the Settings version with the version of the current build
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version"];
    [[NSUserDefaults standardUserDefaults] synchronize];

	[window addSubview:KioskVC.view];
    [window makeKeyAndVisible];
	
}


- (void)dealloc {
    [window release];
	[KioskVC release];
    [super dealloc];
}

- (void)showLoadingView:(NSNotification *)notification {
    
    // set custom message, if one was specified
    if (notification != nil) {
        NSString *loadingMessage = [[notification userInfo] objectForKey:@"loadingMessage"];
        if (loadingMessage != nil) {
            loadingSpinnerViewController.message.text = loadingMessage;
        }
        else
            loadingSpinnerViewController.message.text = DEFAULT_SPINNER_MESSAGE;
    }
    else
        loadingSpinnerViewController.message.text = DEFAULT_SPINNER_MESSAGE;
    
    
	[window addSubview:loadingSpinnerViewController.view];
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.75];
	[UIView setAnimationDuration:0.5];
	loadingSpinnerViewController.view.alpha = 1;
	[UIView commitAnimations];
}


- (void)dismissLoadingView {
	[window addSubview:loadingSpinnerViewController.view];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	loadingSpinnerViewController.view.alpha = 0;
	[UIView commitAnimations];
	
	[loadingSpinnerViewController.view removeFromSuperview];
}

+(BOOL) validateEmailString:(NSString *)emailString {
	
    // just make sure there's at least one @ character with stuff to either side of it
    NSRange atRange = [emailString rangeOfString:@"@"];
    NSRange dotRange = [emailString rangeOfString:@"." options:NSBackwardsSearch];
	
    if (atRange.location == NSNotFound) // was there an @ at all
        return FALSE;
    else if (atRange.location == 0) // don't start with the @
        return FALSE;
    else if ((atRange.location + atRange.length) == [emailString length]) // don't end with the @
        return FALSE;
	else if (dotRange.location == NSNotFound)	// was there an "." at all
		return FALSE;
    else if ((dotRange.location + dotRange.length) == [emailString length]) // don't end with the "." 
        return FALSE;
	else if (atRange.location > dotRange.location)	// Missing domain name
		return FALSE;
    else 
        return TRUE;
}

// creates a modal dialog explaining the error and returns true if it knows the error, or just returns false if it doesn't know the error
+(BOOL) showDialogForError:(NSError *)error showForUnknownError:(BOOL)showForUnknown {
    
    NSString *errorTitle = nil;
    NSString *errorBody = nil;
    
    if (error.code == NSURLErrorNotConnectedToInternet) {
        errorTitle = ERROR_TITLE_NO_NETWORK;
        errorBody  = ERROR_BODY_NO_NETWORK;
    } else if (error.code == NSURLErrorUnknown) {
        errorTitle = ERROR_TITLE_NETWORK_UNKNOWN;
        errorBody  = ERROR_BODY_NETWORK_UNKNOWN;
    } else if (error.code == NSURLErrorCancelled) {
        errorTitle = ERROR_TITLE_CANCELED;
        errorBody  = ERROR_BODY_CANCELED;
    } else if ((error.code == NSURLErrorBadURL) ||
               (error.code == NSURLErrorTimedOut) ||
               (error.code == NSURLErrorUnsupportedURL) ||
               (error.code == NSURLErrorCannotFindHost) ||
               (error.code == NSURLErrorCannotConnectToHost) ||
               (error.code == NSURLErrorDataLengthExceedsMaximum) ||
               (error.code == NSURLErrorNetworkConnectionLost) ||
               (error.code == NSURLErrorDNSLookupFailed) ||
               (error.code == NSURLErrorResourceUnavailable) ||
               (error.code == NSURLErrorRedirectToNonExistentLocation) ||
               (error.code == NSURLErrorBadServerResponse) ||
               (error.code == NSURLErrorUserCancelledAuthentication) ||
               (error.code == NSURLErrorSecureConnectionFailed) ||
               (error.code == NSURLErrorServerCertificateHasBadDate) ||
               (error.code == NSURLErrorServerCertificateUntrusted) ||
               (error.code == NSURLErrorServerCertificateHasUnknownRoot) ||
               (error.code == NSURLErrorServerCertificateNotYetValid) ||
               (error.code == NSURLErrorClientCertificateRejected) ||
               (error.code == NSURLErrorCannotLoadFromNetwork)) {
        errorTitle = ERROR_TITLE_COULDNT_CONNECT;      
        errorBody  = ERROR_BODY_COULDNT_CONNECT;
    } else if ((error.code == NSURLErrorUserAuthenticationRequired) ||
               (error.code == NSURLErrorZeroByteResource) ||
               (error.code == NSURLErrorCannotDecodeRawData) ||
               (error.code == NSURLErrorCannotDecodeContentData) ||
               (error.code == NSURLErrorCannotParseResponse) ||
               (error.code == NSURLErrorFileDoesNotExist) ||
               (error.code == NSURLErrorFileIsDirectory) ||
               (error.code == NSURLErrorNoPermissionsToReadFile) ||
               (error.code == NSURLErrorCannotCreateFile) ||
               (error.code == NSURLErrorCannotOpenFile) ||
               (error.code == NSURLErrorCannotCloseFile) ||
               (error.code == NSURLErrorCannotWriteToFile) ||
               (error.code == NSURLErrorCannotRemoveFile) ||
               (error.code == NSURLErrorCannotMoveFile) ||
               (error.code == NSURLErrorDownloadDecodingFailedMidStream) ||
               (error.code == NSURLErrorDownloadDecodingFailedToComplete)) {
        errorTitle = ERROR_TITLE_INVALID_RESPONSE;      
        errorBody  = ERROR_BODY_INVALID_RESPONSE;      
    }
		
  
    if ((errorBody == nil) && showForUnknown) {
        errorTitle = ERROR_TITLE_NETWORK_UNKNOWN;
        errorBody  = ERROR_BODY_NETWORK_UNKNOWN;
    }
    
 
    if (errorBody != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                        message:[NSString stringWithFormat:@"%@ (%d)", errorBody, error.code]
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return TRUE;
    } else {
        return FALSE;
    }
}

@end
