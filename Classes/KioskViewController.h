//
//  KioskViewController.h
//  JMML
//

#import <UIKit/UIKit.h>
#import "Wrapper.h"
#import "SettingsViewController.h"
#import "ContactUploader.h"
#import "FontController.h"


#define DEFAULTHEME @"theme_image1.jpg,Arial,1,0,0xffffff,36,Arial,1,0,0xffffff,28,Arial,1,0,0xffffff,24,Arial,1,0,0xffffff,24"

@interface KioskViewController : UIViewController <SettingsViewControllerDelegate, WrapperDelegate,UIAlertViewDelegate>  {
	UIPopoverController *fontPickerPopover;

	IBOutlet UITextField *txtEmail, *txtFirstName, *txtLastName;
	IBOutlet UILabel *lblLineOne;
	IBOutlet UILabel *lblLineTwo;
	IBOutlet UILabel *lblLineThree;
	IBOutlet UILabel *lblLineFour;
	IBOutlet UITextField *txtTwitterHandle;
	
	UIAlertView *credentialsAlert;
	
	Wrapper *restWrapper;

	BOOL bOffline;
	ContactUploader *contactUploader;
						
	SettingsViewController *SettingsVC;

	IBOutlet UIImageView *backgroundImageView;
	
	IBOutlet UIButton *btnSettings;
	IBOutlet UIButton *btnSubscribe;
	UIImageView *imageView;
	FontController *fontCTRL;
}

@property (nonatomic, retain) UIButton *btnSettings;

- (void) TestCredentials:(NSString *)sLogin password:(NSString *)sPassword;
- (void) CheckCredentials;
- (IBAction) subscribe;
- (IBAction) GotoSettings:(id)sender;
- (void) showFontPicker:(id)sender;
- (void) setFontStyle:(FontStyle*) style forLine:(int) line;
- (BOOL) validateContact;
- (void) refreshUI;

@end

