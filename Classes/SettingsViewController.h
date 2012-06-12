//
//  SettingViewController.h
//  JMML
//

#import <UIKit/UIKit.h>
#import "Wrapper.h"
#import "FontController.h"
#import "ContactListSelector.h"
#import "ContactListsFetcher.h"
#import "ThemeSelector.h"

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <UIActionSheetDelegate,UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> { 
    UIPopoverController *fontPickerPopover;

    id <SettingsViewControllerDelegate> SettingsVCdelegate;

	IBOutlet UITextField *txtLogin, *txtPassword;
	IBOutlet UITextField *txtLineOne, *txtLineTwo, *txtLineThree, *txtLineFour;
	
	UIImagePickerController *imagePicker;
	UIPopoverController *imagePickerPopover;
	
	IBOutlet UIImageView *photoImageView, *ipadImageView;
	IBOutlet UITabBar *mytabBar;
	IBOutlet UIView *credentialsView, *customizeUIView, *customizeFieldsView;

	//contacts
	ContactListsFetcher *contactListsFetcher;
	UIPopoverController *contactListPickerPopover;
    ContactListSelector *contactListCTRL;
	IBOutlet UIButton *btnSelectContactList;
	
	// themes
	UIPopoverController *themePickerPopover;
    ThemeSelector *themeController;
		
	IBOutlet UISwitch *swTwitter;
	
	UIActionSheet *loadSheet;
	
	//Fonts
	FontController *fontCTRL;
    
    Theme *currentTheme;
}

@property (nonatomic, assign) id <SettingsViewControllerDelegate> SettingsVCdelegate;
@property (retain) Theme *currentTheme;

- (void)getContactLists;
- (BOOL)CheckCredentials:(BOOL)bSilent;
- (IBAction)done;
- (void)showImagepicker:(id) sender;
- (IBAction)Fontpicker:(id) sender;
- (FontStyle *) getStyleForLine: (int) line;
- (void) setFontStyle:(FontStyle*) style forLine:(int) line;
- (void) contactListSelected:(id) popoverTableController;
- (IBAction)ContactListPicker:(id) sender;
- (IBAction) toggleEnabledForTwitter: (id) sender;  
- (IBAction) loadImage: (id)sender;
- (void) doLoad: (int) buttonIndex;
- (void) SaveSelectedImage:(UIImage *) image;
- (void) saveCurrentTheme;
- (void) loadCurrentTheme;
- (void) loadThemes;

@end

@protocol SettingsViewControllerDelegate
- (void)SettingsViewControllerDidFinish:(SettingsViewController *)controller;
@end


