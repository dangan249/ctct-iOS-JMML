//
//  Contact.h
//  JMML
//

#import <Foundation/Foundation.h>


@interface Contact : NSObject
{
	NSString *firstName;
	NSString *lastName;
	NSString *emailAddress;
	NSString *twitterName;
}

@property(retain, nonatomic) NSString *firstName, *lastName, *emailAddress, *twitterName;

@end

