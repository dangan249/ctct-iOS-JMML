//
//  ColorPickerPopover.m
//  JMML
//
//  Created by John Walsh on 6/10/10.
//  Copyright 2010 Constant Contact. All rights reserved.
//

#import "ColorPickerPopover.h"

@implementation ColorPickerController
@synthesize colors;
@synthesize delegate;
@synthesize buttonID;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(150.0, 220.0);
    self.colors = [NSMutableArray array];
		[colors addObject:@"Red"];
		[colors addObject:@"Black"];
		[colors addObject:@"Blue"];
		[colors addObject:@"Green"];
		[colors addObject:@"White"];
	self.clearsSelectionOnViewWillAppear = NO;
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
/*	// Select current row based on color of "lineX"
	int i=0;
	for (NSString *color in colors) {
		if ([color compare:[[NSUserDefaults standardUserDefaults] stringForKey:[buttonID currentTitle]]] == NSOrderedSame) {
			[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
		i++;
	}
*/}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [colors count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"colorpicker";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString *color = [colors objectAtIndex:indexPath.row];
    cell.textLabel.text = color;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (delegate != nil) {
		NSString *color = [colors objectAtIndex:indexPath.row];
        [delegate colorSelected:color sender:buttonID];
    }
}

#pragma mark ----
#pragma mark Default Functions

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}

- (void)didReceiveMemoryWarning {
 
	[super didReceiveMemoryWarning];
   
}

- (void)dealloc {
	[colors release];
    [super dealloc];
}

@end

