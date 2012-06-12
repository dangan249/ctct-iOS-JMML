//
//  KioskViewController.m
//  JMML
//

#import "KioskViewController.h"
#import "JMMLAppDelegate.h"
#import "Constants.h"

@implementation KioskViewController

@synthesize	btnSettings;

- (void) viewDidLoad {
	
    [super viewDidLoad];
	
	if (SettingsVC == nil ) {
		SettingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
		[SettingsVC setSettingsVCdelegate:self];
        
        // If IOS5 or later, preload the theme images.
        // This should work in IOS4 but it doesnt, lots of memory leaks
        if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)
            [self performSelectorInBackground:@selector(preLoadThemes) withObject:nil];
	}
	
	bOffline = FALSE;
	[self CheckCredentials];
    
	BOOL bTest = [[NSUserDefaults standardUserDefaults] boolForKey:@"SetupComplete"];
	if (!bTest) {		// First time using App, need to setup defaults
        Theme *currentTheme = [[[Theme alloc]initWithThemeString:DEFAULTHEME]autorelease];
        [SettingsVC setCurrentTheme:currentTheme]; // sync 
        
		[[NSUserDefaults standardUserDefaults] setObject:@"Welcome to JMML Kiosk" forKey:@"LineOneText"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@"Sponsored by Constant Contact" forKey:@"LineTwoText"];
		
		[[NSUserDefaults standardUserDefaults] setObject: @"Touch lower right corner to setup" forKey:@"LineThreeText"];		
		
		[[NSUserDefaults standardUserDefaults] setObject: @"Alternatively text <keyword> to 22828 to subscribe" forKey:@"LineFourText"];		

		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"locked"];
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"DisplayTwitter"];
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"SetupComplete"];
		
	}
    else {
        [SettingsVC loadCurrentTheme];
    }
    
	[self refreshUI];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"locked"]) {
		[btnSettings setHidden:TRUE];
	}
    else {
        // preload the fonts only if not Locked 
        if (fontCTRL == nil) {
            fontCTRL = [[FontController alloc] initWithNibName:@"fontstyle" bundle:nil];
            [fontCTRL setDelegate:self];
            [fontCTRL setHideFox:TRUE];

            fontPickerPopover = [[UIPopoverController alloc] initWithContentViewController:fontCTRL];
            [fontPickerPopover setDelegate:fontCTRL];
        }
    }  
    
	// UITextBorderStyleRoundedRect has a fixed height within IB.
	// The workaround (within IB) is to set style to None, set height to 40 and then reset border programtically
	[txtFirstName setBorderStyle:UITextBorderStyleRoundedRect];
	[txtLastName setBorderStyle:UITextBorderStyleRoundedRect];
	[txtEmail setBorderStyle:UITextBorderStyleRoundedRect];
	[txtTwitterHandle setBorderStyle:UITextBorderStyleRoundedRect];

	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handlePanGesture:)];
	[self.view addGestureRecognizer:panGesture];	
	[panGesture release];
	
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 400.0, 247.0)];
	[self.view addSubview:imageView];

}

//Wrapper selector to prefetch themes in the background
- (void) preLoadThemes {

    [SettingsVC loadThemes];

}

#pragma mark CTCT webservices

- (void) TestCredentials:(NSString *)sLogin password:(NSString *)sPassword {

	// Initialize the REST engine
	if(restWrapper == nil) {
		restWrapper = [[Wrapper alloc] init];
	}
	
	// Configure the connection with user input and the api key
	[restWrapper setDelegate:self];
	[restWrapper setUsername:[[kCtctApiKey stringByAppendingString:@"%"] stringByAppendingString: sLogin]];
	[restWrapper setPassword:sPassword];
	[restWrapper setAsynchronous:TRUE];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// Send request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ws/customers/%@/", kCtctWebserviceRoot, [sLogin stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];	
	[restWrapper sendRequestTo:url usingVerb: @"GET" withParameters: nil];	
		
}

- (void)CheckCredentials {

	if (([[NSUserDefaults standardUserDefaults] stringForKey:@"login_name"] == nil) ||
		([[NSUserDefaults standardUserDefaults] stringForKey:@"password"] == nil)) {
		credentialsAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Missing Credentials"]
										   message:@"Please setup your account."
										  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[credentialsAlert show];
		
	}
	else {	
		[self TestCredentials:[[NSUserDefaults standardUserDefaults] stringForKey:@"login_name"] password:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
	}
}



// figure out, if the credentials need to be entered.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == credentialsAlert) {
		[self GotoSettings:self];
		[credentialsAlert release];
	}
	
}


// Validate contact details
- (BOOL) validateContact {
	NSString *sErrMsg;
	
	if ([txtFirstName.text isEqualToString:@""]) {
		sErrMsg = @"Please provide First Name.";
		[txtFirstName becomeFirstResponder];
	}
	else if ([txtLastName.text isEqualToString:@""]) {
		sErrMsg = @"Please provide Last Name.";
		[txtLastName becomeFirstResponder];
	} 
	else if ([txtEmail.text isEqualToString:@""]) {
			sErrMsg = @"An email address must be provided.";
			[txtEmail becomeFirstResponder];
	}
	else if (! [JMMLAppDelegate validateEmailString:txtEmail.text]) {
		sErrMsg = @"The format of your email address is not valid, Please check email address.";
		[txtEmail becomeFirstResponder];
	} 
	else if ([[NSUserDefaults standardUserDefaults] stringForKey:@"activeContactListLink"] == nil) {
		sErrMsg = @"Please select a contact list to be used for new contacts.";
	}
	else {
		return TRUE;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:sErrMsg delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[sErrMsg release];
	
	return FALSE;
}

// Handle "subscribe" button from UI and upload contact to CTCT
- (IBAction)subscribe {

	if (![self validateContact]) return;

	// Initialize the Contact Uploader
	if (contactUploader == nil)
		contactUploader = [[ContactUploader alloc] init];
		
	// Make a contact and store it in the repository
	Contact *aContact = [contactUploader addContact:txtEmail.text First:txtFirstName.text Last:txtLastName.text Twitter:txtTwitterHandle.text];
	
	// If we're offline not much to do ...
	if (bOffline) {
		UIAlertView *alert;
		
		if (aContact == nil)
			alert = [[UIAlertView alloc] initWithTitle:@""
											   message:@"A contact with this email address already exists."
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		else {
			alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
											   message:[NSString stringWithFormat:@"%@ %@ is subscribed!", txtFirstName.text, txtLastName.text]	
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
  
        [alert show];
		[alert release];
		
		
		[txtEmail setText:@""];
		[txtFirstName setText:@""];
		[txtLastName setText:@""];
		[txtTwitterHandle setText:@""];
	}
	else {
		[contactUploader uploadContact:aContact Delegate:self];		//Wrapper method will handle completion tasks
	}

    
	//Hide the keyboard
	[txtEmail resignFirstResponder];
	[txtFirstName resignFirstResponder];
	[txtLastName resignFirstResponder];
	[txtTwitterHandle resignFirstResponder];

}

#pragma mark Settings

- (void) refreshUI {
	FontStyle *style;
    NSLog (@"refresh UI");
	[lblLineOne setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineOneText"]];
	style = [SettingsVC getStyleForLine:1];
	[lblLineOne setFont:[UIFont fontWithName:[style actualFontName] size:[style size]]];
	[lblLineOne setTextColor:[style color]];
    
	[lblLineTwo setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineTwoText"]];
	style = [SettingsVC getStyleForLine:2];
	[lblLineTwo setFont:[UIFont fontWithName:[style actualFontName] size:[style size]]];
	[lblLineTwo setTextColor:[style color]];
	
	[lblLineThree setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineThreeText"]];
	style = [SettingsVC getStyleForLine:3];
	[lblLineThree setFont:[UIFont fontWithName:[style actualFontName] size:[style size]]];
	[lblLineThree setTextColor:[style color]];

	[lblLineFour setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"LineFourText"]];
	style = [SettingsVC getStyleForLine:4];
	[lblLineFour setFont:[UIFont fontWithName:[style actualFontName] size:[style size]]];
	[lblLineFour setTextColor:[style color]];

    UIImage *bkgImage = [[SettingsVC currentTheme]image];
    [backgroundImageView setImage:bkgImage];
				
	
	//  Hide/Show twitter and adjust Subscribe button & Email
	CGRect frameSubscribe = btnSubscribe.frame;
	CGRect frameTwitter = txtTwitterHandle.frame;
	CGRect frameEmail = txtEmail.frame;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DisplayTwitter"] == FALSE) {
		[txtTwitterHandle setHidden:TRUE];
		frameEmail.origin.y = frameTwitter.origin.y;
	}
	else { 
		[txtTwitterHandle setHidden:FALSE];
		frameEmail.origin.y = frameTwitter.origin.y + 70.0;
	}
	frameSubscribe.origin.y = frameEmail.origin.y + 70.0;
	[btnSubscribe setFrame:frameSubscribe];
	[txtEmail setFrame:frameEmail];
}

// Access to Settings via "tools" button 
- (IBAction)GotoSettings:(id)sender {


	[SettingsVC setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentModalViewController:SettingsVC animated:YES];
}

- (void)SettingsViewControllerDidFinish:(SettingsViewController *)controller {

	[self dismissModalViewControllerAnimated:YES];

	[self refreshUI];
}

#pragma mark FontController


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
// If locked dont allow the editting of the font style
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"locked"]) {
		return;
	}
	
	UITouch *touch = [touches anyObject];
	NSInteger numTaps = [touch tapCount];
	
	if (numTaps == 2) {
		if ((touch.view.tag == 1) || (touch.view.tag == 2) || (touch.view.tag == 3) || (touch.view.tag == 4)) {
			[self showFontPicker:[touch view]];
		}
	}
}


- (void) setFontStyle:(FontStyle*) style forLine:(int) line {
	
	[SettingsVC setFontStyle:style forLine:line];
	
	[self refreshUI];
}


- (void) showFontPicker:(id) sender {

	// Hide the keyboard it messes up the popover controls
	[txtEmail resignFirstResponder];
	[txtFirstName resignFirstResponder];
	[txtLastName resignFirstResponder];
	[txtTwitterHandle resignFirstResponder];

	int line = [sender tag];

    // Playing around with RECT to get the arrow to be closer to the text "bottom" and skewed left.
    
    CGRect popoverRect = [(UIButton *)sender frame];
    popoverRect.size.width = 500;
    popoverRect.origin.y -= 10;
    
    [fontPickerPopover presentPopoverFromRect:popoverRect
									   inView:self.view
					 permittedArrowDirections:UIPopoverArrowDirectionAny
									 animated:YES];

	[fontCTRL setLine:line];
	[fontCTRL setStyle:[SettingsVC getStyleForLine:line]];
    
    // First time thru we want to display Styles segment
    static BOOL firstTime = TRUE;
    if (firstTime) {
        firstTime = FALSE;
        [fontCTRL showStyles];
    }   
}

#pragma mark show/hide keyboard

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	
    CGRect viewFrame = self.view.frame;
		
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait)
		viewFrame.origin.y += 0;
	else if (orientation == UIInterfaceOrientationPortraitUpsideDown) 
		viewFrame.origin.y += 0;
    else if (orientation == UIInterfaceOrientationLandscapeLeft)
		viewFrame.origin.x -= 150;
	else if (orientation == UIInterfaceOrientationLandscapeRight)
		viewFrame.origin.x += 150;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1.0];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	
    CGRect viewFrame = self.view.frame;

	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait)
		viewFrame.origin.y += 0;
	else if (orientation == UIInterfaceOrientationPortraitUpsideDown) 
		viewFrame.origin.y += 0;
    else if (orientation == UIInterfaceOrientationLandscapeLeft)
		viewFrame.origin.x += 150;
	else if (orientation == UIInterfaceOrientationLandscapeRight)
		viewFrame.origin.x -= 150;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[txtEmail resignFirstResponder];
	[txtFirstName resignFirstResponder];
	[txtLastName resignFirstResponder];
	[txtTwitterHandle resignFirstResponder];

}


#pragma mark Standard UI methods

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer { 
	
	static BOOL zoro1, zoro2, zoro3;
	
	CGPoint translate = [recognizer translationInView:recognizer.view.superview];	
	
	
	if (translate.y < -300) 
		zoro1 = TRUE;
	
	if ((translate.y > -50) && zoro1)
		zoro2 = TRUE;
	
	if ((translate.y < -300) && (translate.x > 250) && zoro2 && !zoro3) {
		imageView.image = [UIImage imageNamed:@"easter2.jpg"];
		
		zoro3 = TRUE;
	}
	
	if (zoro3) {
		CGPoint location = [recognizer locationInView:self.view];
		if ((location.x != NSNotFound) && (location.y != NSNotFound)) {
		    location.y -= imageView.frame.size.height / 2;
			imageView.center = location;
			imageView.alpha = 1.0;
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:10.0];
			imageView.alpha = 0.0;
			[UIView commitAnimations];
		}
		else {
			NSLog(@"location out of range");
		}

	}
	
    if (recognizer.state == UIGestureRecognizerStateEnded) {
		zoro1 = FALSE;
		zoro2 = FALSE;
		zoro3 = FALSE;
	}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	if (textField == txtFirstName) {
		// Move focus to Last Name
		[txtLastName becomeFirstResponder];
	}
	else if (textField == txtLastName) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DisplayTwitter"] == TRUE) {
			//Move focus to TwitterHandle
			[txtTwitterHandle becomeFirstResponder];
		}
		else {
			//Move focus to Email Address
			[txtEmail becomeFirstResponder];
		}	
	}
	else if (textField == txtTwitterHandle) {
		//Move focus to Email Addres
		[txtEmail becomeFirstResponder];
	}
	else if (textField == txtEmail) {
		// JMML !!
		[self subscribe];
	}
	else
		NSAssert (YES, @"Keyboard display method missing case");
	
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {	
	[SettingsVC release];
	SettingsVC = nil;
	
	[restWrapper release];
	restWrapper = nil;
	
	[contactUploader release];
	contactUploader = nil;
	
	[fontCTRL release];
	fontCTRL = nil;
	
    [fontPickerPopover release];
    fontPickerPopover = nil;
    
	[super dealloc];
}

#pragma mark WrapperDelegate

// Received status back from web service; finished request
// Also called by synchronous calls to handle errors
		 
- (void)wrapper:(Wrapper *)wrapper didRetrieveData:(NSData *)data status:(int)statusCode{

	UIAlertView *alert = nil;
	BOOL bClearInputFields = FALSE;
	
	NSLog (@"KioskVC[didRetrieveData] statuscode :%d", statusCode);
	
	// Stop the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if (statusCode == 200){				// Success checking credentials! 
		// Upload contacts
		if (contactUploader == nil)
			contactUploader = [[ContactUploader alloc] init];
		
		[contactUploader UploadStoredContacts];
		return;
	}
	else if (statusCode == 201){		// Success adding email address! 
		
		bClearInputFields = TRUE;
		
		alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Thanks %@", txtFirstName.text]	
                                           message:@"You are now subscribed to our mailing list. Please watch your email for our newsletter"	
                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	}
	else if (statusCode == 400){		// Invalid email format
		
		[txtEmail becomeFirstResponder];
		
		alert = [[UIAlertView alloc] initWithTitle:@""
										   message:@"The format of your email address is not valid, Please check email address."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
	else if (statusCode == 403){		// Invalid Credentials

		alert = [[UIAlertView alloc] initWithTitle:@""
										   message:@"Your credentials are invalid, Please check Login Name and Password."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
	else if (statusCode == 409){		// email already exists
		
		bClearInputFields = TRUE;
		
		alert = [[UIAlertView alloc] initWithTitle:@""
										   message:@"A contact with this email address already exists."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else if (statusCode == NSURLErrorNotConnectedToInternet) {
		
		bOffline = TRUE;

		alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
										   message:@"Contacts will be saved and uploaded when the Internet is available."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	}	
	else {
		
		NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode userInfo:nil ];
		if ([JMMLAppDelegate showDialogForError:error showForUnknownError:TRUE] == FALSE){	

			alert = [[UIAlertView alloc] initWithTitle:@"Error"
											   message:[NSString stringWithFormat:@"Data cannot be sent to Constant Contact.  Statuscode = %d", statusCode]	
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		}
	}

	// Remove contact from store
	[contactUploader deleteContact:txtEmail.text];

	if (alert != nil) {
		[alert show];
		[alert release];
	}
	
	if (bClearInputFields ) {
		[txtEmail setText:@""];
		[txtFirstName setText:@""];
		[txtLastName setText:@""];
		[txtTwitterHandle setText:@""];
	}
}

- (void)wrapperHasBadCredentials:(Wrapper *)wrapper {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
									   message:@"Your credentials are invalid, Please check Login Name and Password."
									  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

- (void)wrapper:(Wrapper *)wrapper didFailWithError:(NSError *)error {
	
	// Stop the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (error.code == NSURLErrorNotConnectedToInternet) {
		bOffline = TRUE;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
										   message:@"Contacts will be saved and uploaded when the Internet is available."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		return;
	}
	
	// show the error
    [JMMLAppDelegate showDialogForError:error showForUnknownError:TRUE];
}

@end
