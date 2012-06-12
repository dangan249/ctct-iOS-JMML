//
//  DetailViewController.m
//  JMML
//
//  Created by Walsh, John on 7/2/10.
//  Copyright 2010 Constant Contact. All rights reserved.
//

#import "DetailViewController.h"
#import	"CoreText/CTFont.h"

@implementation FontDetailSelector

// sets the type from the prefs
- (void) setFontDetailName:(NSString *) detail {
	
	selectedItem = [entryList indexOfObject:detail];
	if (selectedItem != NSNotFound)
		[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedItem inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
	
}

- (NSString*) getFontDetailName: (int) index {
	
	return [entryList objectAtIndex:index];
}

- (NSString *)styleNameForIndex:(NSUInteger)index inFontFamily:(NSString *)famName {
    
	NSString *fontName = [[UIFont fontNamesForFamilyName:famName] objectAtIndex:index];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, 0.0, NULL);
    CFStringRef style = CTFontCopyName(fontRef, kCTFontStyleNameKey);
    CFRelease(fontRef);
    
	return [(NSString*)style autorelease];
}

- (void) setFontFamily: (NSString *) family {
	
	if (entryList == nil) 
		entryList = [[NSMutableArray alloc] init];
	else
		[entryList removeAllObjects];
	
	NSMutableArray *fontNames = [NSMutableArray arrayWithArray:[UIFont fontNamesForFamilyName:family]];
	
	for (int idx = 0; idx < [fontNames count]; idx++) {
		[entryList addObject:[self styleNameForIndex:idx inFontFamily:family]];
	}
	
	fontFamily = family;
	[self.tableView reloadData];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"FontDetail";
    
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }    
	
    // Configure the cell.
    cell.textLabel.text = [[self entryList] objectAtIndex:indexPath.row];

	// CTFont is used to get the displayname, however we use fontNames to get the actual font name for UIFont
	// Doesnt seem like it should be this difficult but all the font manufacters have a different naming scheme
	NSMutableArray *fontNames = [NSMutableArray arrayWithArray:[UIFont fontNamesForFamilyName:fontFamily]];
	[cell.textLabel setFont:[UIFont fontWithName:[fontNames objectAtIndex:indexPath.row] size:16]];
	
	return cell;
}

@end