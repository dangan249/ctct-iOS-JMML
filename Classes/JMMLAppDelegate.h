//
//  JMMLAppDelegate.h
//  JMML
//

#import "KioskViewController.h"
#import "LoadingSpinnerViewController.h"

@interface JMMLAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    KioskViewController *KioskVC;
	LoadingSpinnerViewController *loadingSpinnerViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

+ (BOOL)validateEmailString:(NSString *)emailString;
+ (BOOL)showDialogForError:(NSError *)error showForUnknownError:(BOOL)showForUnknown;

@end

