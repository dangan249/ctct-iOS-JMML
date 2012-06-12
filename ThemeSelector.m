//
//  ThemeSelector.m
//  JMML
//

#import "ThemeSelector.h"
#import "ThemeSelectorCell.h"

static NSMutableArray *themelist = nil;

@implementation ThemeSelector

+ (void) initialize {   //is called when the CLASS is loaded
    [self loadThemes];
    
}

+ (NSMutableArray*) themelist { // access to the static as a class variable
    return  themelist;
}


// constructor
- (id) init {
    
    self = [super init];
    entryList = [ThemeSelector themelist]; // set the instance variable to the class variable;
    // because PopoverTableController uses the instance variable entrylist
    
    return self;
}

- (CGSize) contentSizeForViewInPopoverView{

	return CGSizeMake(thumbnail_size, thumbnail_size*1.8);

}

// reads themes.csv and polulates the entries array with themes that contain images, thumbnails and fontstyles
+(void) loadThemes {
	themelist = [[NSMutableArray arrayWithCapacity:10] retain];
   
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *themeFilePath = [bundle pathForResource:@"themes" ofType:@"csv"];
	NSError *error;
	NSString *fileContents = [NSString stringWithContentsOfFile:themeFilePath encoding:NSUTF8StringEncoding error:&error];
    
	NSArray *themesArray = [[NSArray alloc] initWithArray:[fileContents componentsSeparatedByString:@"\n"]];

	for (NSString *tline in themesArray) {
        if ([tline length]==0) 
            break;
		Theme *t = [[Theme alloc]initWithThemeString:tline];
        [themelist addObject:t];
        [t release];
	}
	
	[themesArray release];
}


// reads themes.csv and polulates the entries array with themes that contain images, thumbnails and fontstyles
- (void) printThemes {
    
    NSAssert(themelist!=nil, @"saveThemes: entrylist is empty. No themes to list.");    

	for (Theme *t in themelist) {
        NSString * tline = [t toThemeString];
        NSLog(@"%@",tline);
	}
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Configure the table view.
    [self.tableView setRowHeight:thumbnail_size];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    selectedItem =-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setRowHeight:thumbnail_size];

	
	static NSString *CellIdentifier = @"Popover";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ThemeSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    // Configure the cell.
    [cell.imageView setImage:[[entryList objectAtIndex:indexPath.row] thumbnail]];

	return cell;
}

// returns the image at index x;
- (UIImage *) getImageAtIndex:(int) index{
	return [[entryList objectAtIndex:index]image];
}

// returns the image name at index x;
- (Theme *) getThemeAtIndex:(int) index{
	return [entryList objectAtIndex:index];
}

- (void) dealloc {
    
    [themelist release];
    themelist = nil;
    
	[images release];
	images = nil;
    
    [imageNames release];
    imageNames = nil;
    
    [themes release];
    themes = nil;
    
    [super dealloc];
}


@end
