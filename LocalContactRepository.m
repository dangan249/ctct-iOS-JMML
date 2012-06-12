//
//  LocalContactRepository.m
//  JMML
//

#import "LocalContactRepository.h"


@implementation LocalContactRepository

- (int) retrieveNumContacts {
	
	NSArray * contacts = [self retrieveContacts];
	if (contacts == nil) return 0;
	
	int count = [contacts count];
	
	return count;
}
	
// Gets an array of contacts or nil if there are no contacts in the offline store
- (NSArray *)retrieveContacts {
	NSMutableArray *contacts = [[[NSMutableArray alloc] init] autorelease];
	NSError *error;
	NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

	NSArray *lines = [data componentsSeparatedByString:@"\n"];
	
	// number of items minus 1 because of the trailing \n
	int items = [lines count] - 1;
	
	if (items > 0) {
        
        for (int i = 0; i < items; i++) {
            NSArray *line = [[lines objectAtIndex:i] componentsSeparatedByString:@"#!#"];
            
            Contact *contact = [[Contact alloc] init];
            [contact setFirstName: [line objectAtIndex:0]];
            [contact setLastName: [line objectAtIndex:1]];
            [contact setEmailAddress: [line objectAtIndex:2]];
            [contact setTwitterName: [line objectAtIndex:3]];
            
            [contacts addObject:contact];
            
            [contact release];
        }
        return contacts;
    }
    else {
     
        
        return nil;
    }
}

// Delete a contact based on email address
- (void) deleteContact:(NSString *)sEmail {

	NSLog(@"Deleting contact %@",sEmail);
	
	// Get a list of all contacts
	NSArray *contacts = [self retrieveContacts];

	// Remove all contacts from the store
	[self removeAllContacts];
	
	// Add back all contacts except for one matching email address
	for (Contact *aContact in contacts) {
		if ([[aContact emailAddress] compare:sEmail] != NSOrderedSame){
			[self saveContact:aContact unique:TRUE];
		}
	}	
}

// Save a contact to the offline store
- (BOOL) saveContact:(Contact *)contact unique:(BOOL) bUnique {

	NSString *data = [contact firstName];
	data = [data stringByAppendingString:@"#!#"];
	data = [data stringByAppendingString:[contact lastName]];
	data = [data stringByAppendingString:@"#!#"];
	data = [data stringByAppendingString:[contact emailAddress]];
	data = [data stringByAppendingString:@"#!#"];
	data = [data stringByAppendingString:[contact twitterName]];
	data = [data stringByAppendingString:@"\n"];

	// Check if email is unique
	if (bUnique) {
		// Get a list of all contacts
		NSArray *contacts = [self retrieveContacts];
		
		for (Contact *aContact in contacts) {
			if ([[aContact emailAddress] compare:[contact emailAddress]] == NSOrderedSame){
				return FALSE;
			}
		}	
        
	}
	
	NSFileManager *fileMan = [NSFileManager defaultManager];
							
	if(![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
		[fileMan createFileAtPath:filePath contents:nil attributes:nil];
	}
	
	NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath: filePath];

	[fh seekToEndOfFile];
	
	[fh writeData: [data dataUsingEncoding:NSUTF8StringEncoding]];
	
	[fh closeFile];
	
	return TRUE;
}

// Remove all contacts in the offline store
- (void) removeAllContacts {
	NSError *error;
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];

}

- (id) init {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *dir = [documentsDirectory stringByAppendingPathComponent:@"JMML"];
	[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
	
	filePath = [dir stringByAppendingPathComponent:@"OfflineContacts.txt"];
	[filePath retain];
	
	return [super init];
}

- (void) dealloc
{
	[filePath release];
	[super dealloc];
}


@end
