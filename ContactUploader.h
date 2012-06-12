//
//  ContactUpload.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "Wrapper.h"
#import "LocalContactRepository.h"

@interface ContactUploader : NSObject <WrapperDelegate> {

	LocalContactRepository *contactStore;
	Contact *currentContact;

	Wrapper *restWrapper;
	int totalContacts, currentIdx;
}

- (void) deleteContact:(NSString *)sEmailAddress;
- (Contact *) addContact:(NSString *)sEmailAddress First:(NSString *)sFirstName Last:(NSString *)sLastName Twitter:(NSString *)sTwitter;	
- (void) uploadContact:(Contact *)aContact Delegate:(id)delegate;	
- (void) UploadNextStoredContact;
- (void) UploadStoredContacts;

@end
