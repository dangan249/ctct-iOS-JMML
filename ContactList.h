//
//  ContactList.h
//  CTCT
//

#import <Foundation/Foundation.h>


@interface ContactList : NSObject {
	NSString *name;
	NSString *link;
    
@public
    int reportedSize; // size as reported by API, or -1 if unset. this will be updated by local operations (deletes, adds), but does not sync back.
}

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *link;
@property int reportedSize;

@end
