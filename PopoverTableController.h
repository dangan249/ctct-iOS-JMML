//
//  PopoverTableController.h
//

#import <Foundation/Foundation.h>

@interface PopoverTableController : UITableViewController {
	NSMutableArray *entryList;
	
	int selectedItem;
	id target;
	SEL doEntry;
}

- (void) setEntrySelector:(SEL) selector;


@property (retain,readwrite) NSMutableArray *entryList;
@property (assign) int selectedItem;
@property (assign,readwrite) id target;
@end
