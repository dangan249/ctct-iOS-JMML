//
//  ContactListsFetcher.h
//  CTCT
//

#import <Foundation/Foundation.h>
#import "Wrapper.h"
#import "ContactList.h"

@interface ContactListsFetcher : NSObject <WrapperDelegate, NSXMLParserDelegate> {
	NSMutableArray *contactLists;
	NSMutableString *currentStringValue;
	ContactList *currentContactList;
	bool inEntry;
	NSString *nextLink;
	bool moreContactLists;
	Wrapper *restWrapper;
}

@property (retain, nonatomic) NSMutableArray *contactLists;
@property bool moreContactLists;

- (void)fetchContactLists:(NSString *)username password:(NSString *)password;
- (void)fetchNextPage;
- (ContactList *)searchForList:(NSString *)link;

@end
