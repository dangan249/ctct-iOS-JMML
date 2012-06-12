//
//  ContactList.m
//  CTCT
//

#import "ContactList.h"


@implementation ContactList

@synthesize name;
@synthesize link;
@synthesize reportedSize;

- (id) init {

    if(self = [super init]) {
        reportedSize = -1;
    }
    
    return self;
}


- (void)dealloc {
	[name release];
	[link release];
    [super dealloc];
}


@end
