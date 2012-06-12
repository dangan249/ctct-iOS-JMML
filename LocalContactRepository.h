//
//  LocalContactRepository.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "Contact.h"


@interface LocalContactRepository : NSObject {
	NSString *filePath;

}

- (NSArray *) retrieveContacts;
- (BOOL) saveContact:(Contact *)contact unique:(BOOL)bUnique;
- (void) removeAllContacts;
- (void) deleteContact:(NSString *)sEmail;
- (int) retrieveNumContacts;

@end