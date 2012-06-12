//
//  ContactUploader.m
//  JMML
//

#import "ContactUploader.h"
#import "JMMLAppDelegate.h"
#import "Constants.h"

@implementation ContactUploader

#pragma mark Destructor

- (void)dealloc {	

	[contactStore release];
	contactStore = nil;

    [currentContact release];
    currentContact = nil;

    [restWrapper release];
	restWrapper = nil;
	
	[super dealloc];
}

#pragma mark Contact Tools

- (void) deleteContact:(NSString *)sEmailAddress {
	
	[contactStore deleteContact:sEmailAddress];
}

// addContact returns TRUE if the contact is aded to Store and nil if duplicate entry based on setting unique:TRUE
- (Contact *) addContact:(NSString *)sEmailAddress First:(NSString *)sFirstName Last:(NSString *)sLastName Twitter:(NSString *)sTwitter  {	
	
	Contact *aContact = [[[Contact alloc] init]autorelease];
		
	[aContact setFirstName: sFirstName];
	[aContact setLastName: sLastName];
	[aContact setEmailAddress: sEmailAddress];
	[aContact setTwitterName: sTwitter];
		
	if (contactStore == nil) 
		contactStore = [[LocalContactRepository alloc] init];
		
	if ([contactStore saveContact:aContact unique:TRUE]) {
		return aContact;
	}
	else {
		return nil; 
	}
}

- (void) uploadContact:(Contact *)aContact Delegate:(id)delegate {	
	
	NSString *sLoginName = [[NSUserDefaults standardUserDefaults] stringForKey:@"login_name"];		
	NSString *sPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	// Initialize the REST engine
	if (restWrapper == nil) {
		restWrapper = [[Wrapper alloc] init];
	}	
	
	// Configure the connection with user input and the api key
	[restWrapper setDelegate:delegate];
	[restWrapper setUsername:[[kCtctApiKey stringByAppendingString:@"%"] 
							stringByAppendingString: sLoginName]];
	[restWrapper setPassword:sPassword];
	[restWrapper setAsynchronous:TRUE];	
	
	// Build xml parameters
	NSString *parameters = @"<entry xmlns=\"http://www.w3.org/2005/Atom\">";
	// The <id> element must have an acceptable format (<id>data:,<id> will work). 
	// The id must contain a URI, but since the value is not used by the server, any URI will work. 
	parameters = [parameters stringByAppendingString:@"<id>data:,</id>"];
	// The title and author elements may be empty. 
	parameters = [parameters stringByAppendingString:@"<title type=\"text\"> </title>"];
	parameters = [parameters stringByAppendingString:@"<author></author>"];
	// The updated element must contain a date or date/time value, but again the value is not used by the server.
	parameters = [parameters stringByAppendingString:@"<updated>2008-04-16</updated>"];
	parameters = [parameters stringByAppendingString:@"<summary type=\"text\">Contact</summary>"];
	
	parameters = [parameters stringByAppendingString:@"<content type=\"application/vnd.ctct+xml\">"];
	parameters = [parameters stringByAppendingString:@"<Contact xmlns=\"http://ws.constantcontact.com/ns/1.0/\">"];
	
	parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"<EmailAddress>%@</EmailAddress>", [aContact emailAddress]]];
	parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"<FirstName>%@</FirstName>", [aContact firstName]]];
	parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"<LastName>%@</LastName>", [aContact lastName]]];
	parameters = [parameters stringByAppendingString:@"<OptInSource>ACTION_BY_CONTACT</OptInSource>"]; 
	parameters = [parameters stringByAppendingString:@"<ContactLists><ContactList id=\""];
	parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"activeContactListLink"]]];
	parameters = [parameters stringByAppendingString:@"\" /></ContactLists>"];
	
	// If Twitter Field is visible and has content send it along
	if (([[NSUserDefaults standardUserDefaults] boolForKey:@"DisplayTwitter"] == TRUE) && ([[aContact twitterName] compare:@""] != NSOrderedSame))
		parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"<CustomField15>Twitter Handle:%@</CustomField15>",[aContact twitterName]]];
	parameters = [parameters stringByAppendingString:@"</Contact></content></entry>"];	
	
	// Show network activitiy symbol
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// Send request
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ws/customers/%@/contacts", kCtctWebserviceRoot, [sLoginName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[restWrapper sendRequestTo:url usingVerb: @"POST" withParameters: parameters];		
		
}

- (void) UploadStoredContacts {
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"activeContactListLink"] == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error"
										   message:@"Stored contacts are available for upload.  Please select a contact list to be used for new subscribers."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}

	if (contactStore == nil) 
		contactStore = [[LocalContactRepository alloc] init];
	
	totalContacts = [contactStore retrieveNumContacts];
	if (totalContacts > 0) {
		
		currentIdx = 1;
		[self UploadNextStoredContact];
	}	
}

- (void) UploadNextStoredContact {

	// This code is called from the completion routine of the previously uploaded contact
	// until all contacts are uploaded.
	
	NSArray *contacts = [contactStore retrieveContacts];
	if (contacts != nil) {
		
		// Show the network activity indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        if (currentContact != nil)      
            [currentContact release];
				
		currentContact = [[contacts objectAtIndex:0] retain];  // get first one, need to retain due to asynch comm with API service
        
		NSLog(@"Uploading contact %d of %d Email:%@ First:%@ Last:%@ Twitter:%@", currentIdx, totalContacts,
			  [currentContact emailAddress], [currentContact firstName], [currentContact lastName], [currentContact twitterName]);
		
		NSString *str = [NSString stringWithFormat:@"Uploading %@ %@\n\n %d of %d",[currentContact firstName], [currentContact lastName], currentIdx, totalContacts]; 
		NSDictionary* msg = [NSDictionary dictionaryWithObject:str forKey:@"loadingMessage"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"showLoadingView" object:nil userInfo:msg];
		
		[self uploadContact:currentContact Delegate:self];

	}
	else {
		// Tear down the Notifier when completed uploading
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLoadingView" object:nil];
	}
}

#pragma mark Wrapper

// Received status back from web service; finished request
// Also called by synchronous calls to handle errors

- (void)wrapper:(Wrapper *)wrapper didRetrieveData:(NSData *)data status:(int)statusCode{
	
	NSLog (@"ContactUploader[didRetrieveData] statuscode :%d", statusCode);
	
	// Stop the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (statusCode == 201){				// Success adding email address! 
		
		// Remove contact from store
		[self deleteContact:[currentContact emailAddress]];
		
	}
	else if (statusCode == 400){		// bad formed request		

		// Remove contact from store
		[self deleteContact:[currentContact emailAddress]];
				
    }
	else if (statusCode == 409){		// email already exists
		
		// Remove contact from store
		[self deleteContact:[currentContact emailAddress]];
		
    }
	else {

		NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode userInfo:nil ];
		if ([JMMLAppDelegate showDialogForError:error showForUnknownError:TRUE] == FALSE){	
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
											   message:[NSString stringWithFormat:@"Data cannot be sent to Constant Contact.  Statuscode = %d", statusCode]	
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

			[alert show];
			[alert release];
		}
		
		return;  // abort uploading if problem occurs
	}
	
	currentIdx++;
    [currentContact release];
    currentContact = nil;
    
	[self UploadNextStoredContact];
	
}


- (void)wrapper:(Wrapper *)wrapper didFailWithError:(NSError *)error {
	
	// Stop the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
	
    [currentContact release];
    currentContact = nil;
   
	// show the error
   [JMMLAppDelegate showDialogForError:error showForUnknownError:TRUE];
}

@end
