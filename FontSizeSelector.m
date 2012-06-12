//
//  FontSizeSelector.m
//  JMML
//

#import "FontSizeSelector.h"


@implementation FontSizeSelector

// constructor
- (id) init {
    
    self = [super init];
    entryList = [[NSArray arrayWithObjects:@"20",@"24",@"28",@"32",@"36",@"40",@"44",@"48",@"52",@"56",@"60",nil] retain];
    
    return self;
}

// returns the currently selected size
- (int) getSize {
	NSString *size =[entryList objectAtIndex:selectedItem];
	
	return [size intValue];
}

// sets the size from the prefs
- (void) setSize:(NSString *)size {

	selectedItem = [entryList indexOfObject:size];	

// IOS 4 requires the following, IOS 5 doesnt and the didviewAppear method of popovercontroller gets called.
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 5.0) {
        [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedItem inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

@end
