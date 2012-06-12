//
//  SettingViewController.m
//  JMML
//

#import "SettingsViewController.h"
#import "JMMLAppDelegate.h"
#import "LoadingSpinnerViewController.h"

@implementation SettingsViewController

@synthesize SettingsVCdelegate;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
	// Listen to notifications to capture callback from asynch fetch
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fetcherNewContactList) 
												 name:@"fetcherNewContactList" 
											   object:nil];
	
	// Load values from Settings
	[txtLogin setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"login_name"]];
	[txtPassword setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
	BOOL validCreds = [self CheckCredentials:TRUE];
	
	[txtLineOne setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineOneText"]];
	[txtLineTwo setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineTwoText"]];
    [txtLineThree setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineThreeText"]];
    [txtLineFour setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineFourText"]];
	
	UIImage *image = [currentTheme image];
	if (image !=nil) {
		[photoImageView setImage:image];
	}
	
	// UITextBorderStyleRoundedRect has a fixed height within IB.
	// The workaround (within IB) is to set style to None, set height to 40 and then reset border programtically
	[txtLogin setBorderStyle:UITextBorderStyleRoundedRect];	
	[txtPassword setBorderStyle:UITextBorderStyleRoundedRect];
	
	[txtLineOne setBorderStyle:UITextBorderStyleRoundedRect];
	[txtLineTwo setBorderStyle:UITextBorderStyleRoundedRect];
	[txtLineThree setBorderStyle:UITextBorderStyleRoundedRect];	
	[txtLineFour setBorderStyle:UITextBorderStyleRoundedRect];
	
	[swTwitter setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"DisplayTwitter"]];
	
	[mytabBar setDelegate:self];
    if (!validCreds)
        [mytabBar setSelectedItem:[mytabBar.items objectAtIndex:0]];
    else 
        [mytabBar setSelectedItem:[mytabBar.items objectAtIndex:1]];
    [self tabBar:mytabBar didSelectItem:mytabBar.selectedItem];

    fontCTRL = [[FontController alloc] initWithNibName:@"fontstyle" bundle:nil];
    [fontCTRL setDelegate:self];
    [fontCTRL setHideFox:FALSE];

    fontPickerPopover = [[UIPopoverController alloc] initWithContentViewController:fontCTRL];
    [fontPickerPopover setDelegate:fontCTRL];

}

#pragma mark Display Options


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

	if (item.tag == 1) {
		credentialsView.hidden = FALSE;
		customizeUIView.hidden = TRUE;
		customizeFieldsView.hidden = TRUE;
	}
	else if (item.tag ==2) {
		credentialsView.hidden = TRUE;
		customizeUIView.hidden = FALSE;
		customizeFieldsView.hidden = TRUE;
	}
	else {
        // Couldnt figure out how to programmatically remove the "more" tab from the tabbar so it was deleted in IB
        // i.e. this case can not happen until added back
        credentialsView.hidden = TRUE;
		customizeUIView.hidden = TRUE;
		customizeFieldsView.hidden = FALSE;
	}	
}

- (IBAction) toggleEnabledForTwitter: (id) sender {

	if ([(UISwitch *)sender isOn])
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"DisplayTwitter"];
	else {
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"DisplayTwitter"];
	}

}

#pragma mark ContactListPicker

- (void)fetcherNewContactList {
	
	if (contactListsFetcher == nil)
		[btnSelectContactList setTitle:@"Missing Credentials" forState:UIControlStateNormal];
	else if ([[contactListsFetcher contactLists] count] == 0)
		[btnSelectContactList setTitle:@"Invalid Credentials" forState:UIControlStateNormal];
	else
		[btnSelectContactList setTitle:@"<Select Contact List>" forState:UIControlStateNormal];

	int idx =0;
	for (ContactList *contactlist in [contactListsFetcher contactLists]) {
		if ([contactlist.name compare:[[NSUserDefaults standardUserDefaults] stringForKey:@"activeContactListName"]] == NSOrderedSame) {
			[btnSelectContactList setTitle:contactlist.name forState:UIControlStateNormal];
			break;
		}
		idx++;
	}	
}


// Query web service for list of contact lists
- (void)getContactLists {

	// Initialize the Contact Lists Fetcher
	if (contactListsFetcher == nil)
		contactListsFetcher = [[ContactListsFetcher alloc] init];

	[contactListsFetcher fetchContactLists:txtLogin.text password:txtPassword.text];
}


- (BOOL)CheckCredentials:(BOOL)bSilent {

	UIAlertView *alert;
    BOOL validCreds = FALSE;

	if ((txtLogin.text == nil) || [txtLogin.text isEqualToString:@""]) {
		if (!bSilent) {
			alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Missing Login"]
														message:@"Please provide a login name."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		[txtLogin becomeFirstResponder];
		[btnSelectContactList setTitle:@"Missing Credentials" forState:UIControlStateNormal];		
	}
	else if ((txtPassword == nil) || [txtPassword.text isEqualToString: @""]) {
		if (!bSilent) {
			alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Missing Password"]
												   message:@"Please provide a password."
												  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		[txtPassword becomeFirstResponder];
		[btnSelectContactList setTitle:@"Missing Credentials" forState:UIControlStateNormal];
	}
	else {	
        [btnSelectContactList setTitle:@"Validating credentials ..." forState:UIControlStateNormal];
        [self getContactLists];
        validCreds = TRUE;
	}
    
    return validCreds;
}



// contactListPickerDelegate
- (void) contactListSelected:(id) popoverTableController {
	
	[contactListPickerPopover dismissPopoverAnimated:YES];
	
	NSString *sName = [contactListCTRL getContactListName:[contactListCTRL selectedItem]];
	NSString *sLink = [contactListCTRL getContactListLink:[contactListCTRL selectedItem]];
	[[NSUserDefaults standardUserDefaults] setObject:sName forKey:@"activeContactListName"];
	[[NSUserDefaults standardUserDefaults] setObject:sLink forKey:@"activeContactListLink"];

	[btnSelectContactList setTitle:sName forState:UIControlStateNormal];
}

- (IBAction)ContactListPicker:(id) sender {
	
	if (contactListsFetcher == nil) { 
		if ([self CheckCredentials:FALSE] == NO){
            return;
        }
    }
		
	if (contactListCTRL == nil) {
        contactListCTRL = [[ContactListSelector alloc] init];

        [contactListCTRL setTarget:self];
		[contactListCTRL setEntrySelector:@selector(contactListSelected:)];
        [contactListCTRL setEntryList:[contactListsFetcher contactLists]];
        
		[[contactListCTRL navigationItem] setTitle:@"Contact List"];
		UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:contactListCTRL] autorelease];
		
        contactListPickerPopover = [[UIPopoverController alloc] initWithContentViewController:navController]; 
    
    }
	
	// Select current row based on current active contact list
	int idx = 0;
	for (ContactList *contactlist in contactListCTRL.entryList) {
		if ([contactlist.name compare:[[NSUserDefaults standardUserDefaults] stringForKey:@"activeContactListName"]] == NSOrderedSame) {
			[contactListCTRL setSelectedItem:idx];
			break;
		}
		idx++;
	}	

	//Place popover placed near button
	[contactListPickerPopover presentPopoverFromRect:[(UIButton *)sender frame]
											  inView:self.view
							permittedArrowDirections:UIPopoverArrowDirectionAny
											animated:YES];
	
}

#pragma mark Image Picker

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:[self view]];
	
	if (![customizeUIView isHidden] && CGRectContainsPoint([photoImageView frame],touchLocation)) {
		[self loadImage:ipadImageView];
	}

}

- (void) loadImage: (id)sender {
	// Hide the keyboard it messes up the popover controls
	[txtLineOne resignFirstResponder];
	[txtLineTwo resignFirstResponder];
	[txtLineThree resignFirstResponder];
	[txtLineFour resignFirstResponder];	
	
	loadSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Load from Photo Library",@"Select a Theme",nil];
	[loadSheet showFromRect:[(UIView *)sender frame] inView:[self view] animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == loadSheet){
		[self doLoad:buttonIndex];
		[loadSheet release];
		loadSheet = nil;
	}
}

- (void) loadThemes {
    
    if (themeController == nil) {
        themeController = [[ThemeSelector alloc] init];
        [themeController setTarget:self];
        [themeController setEntrySelector:@selector(themeSelected:)];
    }
}

- (void) doLoad: (int) buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self showImagepicker:ipadImageView];
			break;
		case 1:
            
            [self loadThemes];
			if (themePickerPopover == nil) {
				
				[[themeController navigationItem] setTitle:@"Themes"];
				UINavigationController *navController = [[[UINavigationController alloc] 
														  initWithRootViewController:themeController] autorelease];

				themePickerPopover = [[UIPopoverController alloc] initWithContentViewController:navController]; 
			}
			
			[themePickerPopover presentPopoverFromRect:[(UIButton *)ipadImageView frame]
													  inView:self.view
									permittedArrowDirections:UIPopoverArrowDirectionAny
													animated:YES];
			break;
	
			
		default:
			break;
	}
}

// writes the seleced image to the documents directory
- (void) SaveSelectedImage:(UIImage *) image {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/background.jpg"];
	[currentTheme setImage_name:[path description]];// [path description] is necessary to make sure its a string
    [currentTheme setImage:image];
    [self saveCurrentTheme];

}

// the user picked a theme...
- (void) themeSelected: (ThemeSelector*) sender {
	[themePickerPopover dismissPopoverAnimated:YES];	

	Theme *theme = [sender getThemeAtIndex:[sender selectedItem]];
    [self setCurrentTheme:theme];
	UIImage *image = [theme image];
	[photoImageView setImage:image];
	[self saveCurrentTheme];
}


// user loaded an image from the library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[imagePickerPopover dismissPopoverAnimated:YES];	
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[photoImageView setImage:image];
    [self SaveSelectedImage:image]; 
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	// The user canceled -- simply dismiss the image picker.
	[imagePickerPopover dismissPopoverAnimated:YES];
}

- (void)showImagepicker:(id) sender {
	
	// Let the user choose a new photo.
	if (imagePicker == nil) {
        imagePicker = [[UIImagePickerController alloc] init];
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary]; 
        [imagePicker setDelegate:self];
		[imagePicker setAllowsEditing:NO];
		
        imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];               
        [imagePickerPopover setDelegate:self];
    }
	
	[imagePickerPopover presentPopoverFromRect:[(UIButton *)sender frame]
										inView:self.view
					  permittedArrowDirections:UIPopoverArrowDirectionAny
									  animated:YES];
}

#pragma mark FontPicker

- (void) setFontStyle:(FontStyle*) style forLine:(int) line {
    // construct the setter method name
    NSString *stylemethod = [NSString stringWithFormat:@"setFs%d:",line];

    // call the selector
    [currentTheme performSelector:NSSelectorFromString(stylemethod) withObject:[style retain]];

    [self saveCurrentTheme]; 

}

- (Theme *) currentTheme {
    return currentTheme;
    
}

- (void) setCurrentTheme:(Theme *)c {
    if (c !=currentTheme) {
        if (currentTheme != nil) {
            [currentTheme release];
        }
        currentTheme = [[Theme alloc]initWithThemeString:[c toThemeString]];
    }
    [self saveCurrentTheme];
}

- (void) saveCurrentTheme {
    [[NSUserDefaults standardUserDefaults] setObject:[currentTheme toThemeString] forKey:@"current_theme"];
    //save the image
    [currentTheme saveImage];
    
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadCurrentTheme {
    NSString *themeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_theme"];
    currentTheme = [[Theme alloc]initWithThemeString:themeString];
}


- (FontStyle *) getStyleForLine: (int) line {
    // construct the getter method name
    NSString *stylemethod = [NSString stringWithFormat:@"fs%d",line];
    // call the getter
    FontStyle *style = (FontStyle*) [currentTheme performSelector:NSSelectorFromString(stylemethod)];
	return style;
}



- (void) Fontpicker:(id) sender {
	
	// Hide the keyboard it messes up the popover controls
	[txtLineOne resignFirstResponder];
	[txtLineTwo resignFirstResponder];
	[txtLineThree resignFirstResponder];

	[fontCTRL setLine:[sender tag]];
	[fontCTRL setStyle:[self getStyleForLine:[sender tag]]];
    [fontCTRL setHideFox:FALSE];
    [fontPickerPopover presentPopoverFromRect:[(UIButton *)sender frame]
									   inView:self.view
					 permittedArrowDirections:UIPopoverArrowDirectionAny
									 animated:YES];
    
    static BOOL firstTime = TRUE;
    if (firstTime) {
        firstTime = FALSE;
        [fontCTRL showStyles];
    }   
}

#pragma mark Done

- (IBAction)done {
	// Save settings
	[[NSUserDefaults standardUserDefaults] setObject:txtLogin.text forKey:@"login_name"];	
	[[NSUserDefaults standardUserDefaults] setObject:txtPassword.text forKey:@"password"];
	
	[[NSUserDefaults standardUserDefaults] setObject:txtLineOne.text forKey:@"LineOneText"];
	[[NSUserDefaults standardUserDefaults] setObject:txtLineTwo.text forKey:@"LineTwoText"];
	[[NSUserDefaults standardUserDefaults] setObject:txtLineThree.text forKey:@"LineThreeText"];		
	[[NSUserDefaults standardUserDefaults] setObject:txtLineFour.text forKey:@"LineFourText"];		
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[SettingsVCdelegate SettingsViewControllerDidFinish:self];	
}

#pragma mark Standard UI Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	if (textField == txtLogin) {
		[txtPassword becomeFirstResponder];
	}
	else if (textField == txtPassword) {
		// Check credentials on "Done"
		[self CheckCredentials:FALSE];

        LoadingSpinnerViewController *spinner = [[LoadingSpinnerViewController alloc] init];
        [self.view addSubview:spinner.view];
        [spinner release]; 
         dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
         dispatch_async(downloadQueue, ^{
         
         [NSThread sleepForTimeInterval:2];
         // do any UI stuff on the main UI thread
         
         dispatch_async(dispatch_get_main_queue(), ^{                
       
             [spinner.view removeFromSuperview];
         });
         
         });
        
         
         dispatch_release(downloadQueue);
          
		// the user pressed the "Done" button, dismiss the keyboard
		[textField resignFirstResponder];
	}
	else if (textField == txtLineOne) {
		// Move focus to Line Two
		[txtLineTwo	becomeFirstResponder];
	}
	else if (textField == txtLineTwo) {
		//Move focus to Line Three
		[txtLineThree becomeFirstResponder];
	}
	else if (textField == txtLineThree) {
		//Move focus to Line Four
		[txtLineFour becomeFirstResponder];
	}
	else if (textField == txtLineFour) {
		// the user pressed the "Done" button, dismiss the keyboard
		[textField resignFirstResponder];
	}
	else
		return NO;
	
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {

	[imagePicker release];
	[imagePickerPopover release];
	imagePicker = nil;

	[contactListCTRL release];
	contactListCTRL = nil;
	
	[contactListPickerPopover release];
	contactListPickerPopover = nil;

    [contactListsFetcher release];
	contactListsFetcher = nil;
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    [currentTheme release];
	[imagePicker release];
	[imagePickerPopover release];
	imagePicker = nil;
	
	[fontCTRL release];
	fontCTRL = nil;
    
    [fontPickerPopover release];
    fontPickerPopover = nil;

	[contactListCTRL release];
	contactListCTRL = nil;
	
	[contactListPickerPopover release];
	contactListPickerPopover = nil;
	
	[contactListsFetcher release];
	contactListsFetcher = nil;
	
	[super dealloc];
}

@end
