//
//  PopoverTableController.mm
//

#import "PopoverTableController.h"

@implementation PopoverTableController

@synthesize selectedItem,entryList,target;


- (void) setEntrySelector:(SEL) selector {
	doEntry = selector;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (CGSize) contentSizeForViewInPopoverView{
	int rows = [[self entryList] count];
	return CGSizeMake(320, 48*rows);
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int rows = [[self entryList] count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Popover";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    // Configure the cell.
    [cell.textLabel setText:[[self entryList] objectAtIndex:indexPath.row]];

	return cell;
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (selectedItem != -1)
        [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedItem inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
 
}

- (void) dealloc {
    
    [entryList release];
    entryList = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSAssert (target!=nil,@"No target delegate set for table selections. Use setTarget: on this controller to set a delegate with a doEntry method");
	
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
    selectedItem = indexPath.row;
	[target performSelector:doEntry withObject: self];

}

@end
