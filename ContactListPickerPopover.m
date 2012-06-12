//
//  ContactListPickerPopover.m
//  JMML
//
//  Created by John Walsh on 6/12/10.
//  Copyright 2010 Constant Contact. All rights reserved.
//

#import "Remove Me from the Project"
#import "ContactListPickerPopover.h"
#import "ContactList.h"

@implementation ContactListController
@synthesize delegate;
@synthesize Lists;

- (void)viewDidLoad {
	
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 400.0);

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [Lists count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"contactListpicker";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
    cell.textLabel.text = [[Lists objectAtIndex:indexPath.row] name];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (delegate != nil) {
		ContactList *contactList = [Lists objectAtIndex:indexPath.row];
		[delegate contactListSelected:contactList.name link:contactList.link];
    }
}

#pragma mark Standard UI methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return YES;
}

- (void)didReceiveMemoryWarning {
	
	[super didReceiveMemoryWarning];
	
}

- (void)dealloc {
	[Lists release];
	
    [super dealloc];
}


@end

