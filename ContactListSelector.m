//
//  ContactListSelector.m
//  JMML
//

#import "ContactListSelector.h"
#import "ContactList.h"

@implementation ContactListSelector

- (CGSize) contentSizeForViewInPopoverView{
	return CGSizeMake(320, 320);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactListpicker"];
    if (cell == nil) 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactListpicker"] autorelease];
    
    // Configure the cell...
    [cell.textLabel setText:[[entryList objectAtIndex:indexPath.row] name]];
	
	return cell;
}

-(NSString *) getContactListName:(int)index;{
	
	ContactList *contactList = [entryList objectAtIndex:index];
    return contactList.name;	
}

-(NSString *) getContactListLink:(int)index; {
    
	ContactList *contactList = [entryList objectAtIndex:index];
    return contactList.link;
}

@end
