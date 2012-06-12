//
//  ContactListsFetcher.m
//  CTCT
//

#import "ContactListsFetcher.h"
#import "JMMLAppDelegate.h"
#import "Constants.h"

@implementation ContactListsFetcher

@synthesize contactLists;
@synthesize moreContactLists;

#pragma mark fetchContactLists

// Gets the initial list of contact lists
- (void)fetchContactLists:(NSString *)username password:(NSString *)password {
	if(contactLists == nil) {
		contactLists = [[NSMutableArray alloc] initWithCapacity:15];
	}
	
	// Start the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// Clear out the contactlist
	[contactLists removeAllObjects];
	
	moreContactLists = NO;
	
	// Initialize the REST engine
	if(restWrapper == nil) {
		restWrapper = [[Wrapper alloc] init];
	}	
	
	// Configure the connection with user input and the api key
	restWrapper.delegate = self;
	restWrapper.username = [[kCtctApiKey stringByAppendingString:@"%"] 
							stringByAppendingString: username];
	restWrapper.password = password;
	restWrapper.asynchronous = TRUE;
	
	// Send request
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ws/customers/%@/lists", kCtctWebserviceRoot, [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[restWrapper sendRequestTo:url usingVerb: @"GET" withParameters: nil];		

}


// Gets the next page 
- (void)fetchNextPage {
	moreContactLists = NO;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURL *urlCampaign = [NSURL URLWithString:[kCtctWebserviceRoot stringByAppendingString:nextLink]];
	[restWrapper sendRequestTo:urlCampaign usingVerb: @"GET" withParameters:nil];
	
}


- (ContactList *)searchForList:(NSString *)link {
	ContactList *list = nil;
	
	for(int i = 0; i < [contactLists count]; i++) {
		if([((ContactList *)[contactLists objectAtIndex:i]).link isEqualToString:link]) {
			list = (ContactList *)[contactLists objectAtIndex:i];
			break;
		}
	}
	
	return list;
}

#pragma mark NSXMLParser

// Start of a new element. Clear the current string. 
// If start of a new contact list, create a new object for that.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    

    if (currentStringValue)
        [currentStringValue release];
    
    currentStringValue = [[NSMutableString alloc] init];
    
	// Check if there is a link to a next page
	if([elementName isEqualToString:@"link"] && [[attributeDict valueForKey:@"rel"] isEqualToString:@"next"]) {
		moreContactLists = YES;
		nextLink = [[NSString alloc] initWithString:[attributeDict valueForKey:@"href"]];
	}
	
	// If beginning a new entry, create a new contact list object
	if ([elementName isEqualToString:@"entry"]) {
		inEntry = YES;
		currentContactList = [[ContactList alloc] init];
    }
}


// End of characters reached, simply append it to the current string.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (currentStringValue)
        [currentStringValue appendString:string];
}


// End of a tag reached. Update current contact list accordingly. 
// If reach end of contact list entry, add to the list of contact lists and release.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	// Create ContactList objects
	if(inEntry) {
		if([elementName isEqualToString:@"id"]) {
			currentContactList.link = currentStringValue;
		}  else if([elementName isEqualToString:@"Name"]) {
			currentContactList.name = currentStringValue;
        }  else if([elementName isEqualToString:@"ContactCount"]) {
			currentContactList.reportedSize = [currentStringValue intValue];
		} else if([elementName isEqualToString:@"entry"]) {
			// Don't add some of the system default contact lists
			if(![currentContactList.name isEqualToString:@"Active"] &&
			   ![currentContactList.name isEqualToString:@"Removed"] &&
			   ![currentContactList.name isEqualToString:@"Do Not Mail"]) {
				[contactLists addObject: currentContactList];
			}
			[currentContactList release];
			currentContactList = nil;
			inEntry = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"fetcherNewContactList" object:nil];
		}
	}
	
    [currentStringValue release];
    currentStringValue = nil;

}


#pragma mark WrapperDelegate

- (void)wrapperHasBadCredentials:(Wrapper *)wrapper {
	
	// Stop the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:@"Your credentials are invalid, Please check Login Name and Password."
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];
	[alert release];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fetcherNewContactList" object:nil];

}

// Successfully queried server and retrieved data
- (void)wrapper:(Wrapper *)wrapper didRetrieveData:(NSData *)data status:(int)statusCode{
	// Use an event-driven xml parser
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: data];
	[parser setDelegate:self];
	inEntry = NO;
	[parser parse];
	[parser release];
	
	// Stop the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(moreContactLists) {
		[self fetchNextPage];
	}
}


- (void)wrapper:(Wrapper *)wrapper didReceiveStatusCode:(int)statusCode {

	// Stop network activitiy symbol
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if (statusCode == 403){
		// Invalid Credentials 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
										   message:@"Your credentials are invalid, Please check Login Name and Password."
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
    }
}


- (void)wrapper:(Wrapper *)wrapper didFailWithError:(NSError *)error {
	// Stop network activitiy indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error.code == NSURLErrorNotConnectedToInternet)
		return;		
	else {
		// show the error
		[JMMLAppDelegate showDialogForError:error showForUnknownError:TRUE];
	}
}

#pragma mark Standard UI methods

- (void)dealloc {
    
	[contactLists release];
    [currentStringValue release];
    [currentContactList release];
	[restWrapper release];
	[nextLink release];
    
    [super dealloc];	
}


@end
