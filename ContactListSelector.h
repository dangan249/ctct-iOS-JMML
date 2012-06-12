//
//  ContactListSelector.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "PopoverTableController.h"

@interface ContactListSelector : PopoverTableController {

}

-(NSString *) getContactListName: (int) index;
-(NSString *) getContactListLink: (int) index;

@end
