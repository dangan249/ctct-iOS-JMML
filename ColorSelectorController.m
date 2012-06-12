//
//  ColorSelectorController.m
//  JMML
//

#import "ColorSelectorController.h"
#import "FontStyle.h"

@implementation ColorSelectorController

@synthesize target,selectedColor;

- (void) setEntrySelector:(SEL) selector {
	doEntry = selector;
}

- (void) dealloc {
	[entries release];
	entries = nil;
	
    [colorSV release];
    [colorView release];
    
	[super dealloc];
}

- (void) viewDidLoad {

	[super viewDidLoad];

	colorSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
	[colorSV setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:colorSV];

	colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
	[colorView setBackgroundColor:[UIColor whiteColor]];
	[colorSV addSubview:colorView];
	 
	[self loadColors];
	
	int row=0, col=0;
	for (int i=0; i < [entries count];i++) {
		row = i/4;
		col = i-row*4;
		ColorButton *colorButton = [[ColorButton alloc] init];
        [colorButton setMomentary:YES];
		[colorButton setFrame:CGRectMake(8+col*78, 12+row*78, 66, 66)];
		[colorButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventValueChanged];
		FontStyle *style = (FontStyle *) [entries objectAtIndex:i];
		[colorButton setColor:UIColorFromRGB([style RGBColor])];
		[colorButton setTag:i];
		[colorView addSubview: colorButton];
		[colorButton release];
	}
	
	[colorView setFrame:CGRectMake(0, 0, 320, (row+1)*78+40)];  // 40 is an iterated value to get the scroll to align correctly
	[colorSV setContentSize:[colorView frame].size];
}

- (void) setRGBColor:(long) RGBColor {
	selectedColor = RGBColor;
	UIColor *aColor = UIColorFromRGB (RGBColor);
    CGRect btnOffset = CGRectMake(0.0, 0.0, 0.0, 0.0);
    
	// clear out the old "check mark" and set the new one
    for (UIView *subview in [colorView subviews]) {
		if ([subview isKindOfClass:[ColorButton class]]) {
			ColorButton *button = (ColorButton *)subview;
			if ([button.color isEqual:aColor]) {
				[button setSelected:YES];
                btnOffset = [button frame];
            }
            else
				[button setSelected:NO];
		}
	}
    
    // Need to scroll row of selected color into view.  Remove  78 + 12 to make it the 2nd row in view
    int scrollOffset = btnOffset.origin.y - (78 + 12);
    if (scrollOffset < 0) scrollOffset = 0;
    [colorSV setContentOffset:CGPointMake(0, scrollOffset) animated:YES];

}

- (void) buttonPressed: (id) sender {
	// clear out the old "check mark"
    for (UIView *subview in [colorView subviews]) {
		if ([subview isKindOfClass:[ColorButton class]]) {
			[(ColorButton *)subview setSelected:NO];
		}
    }
	
	FontStyle *style = [entries objectAtIndex:[(ColorButton *)sender tag]];
	selectedColor = [style RGBColor];
    [(ColorButton *)sender setSelected: YES];
	[target performSelector:doEntry withObject: self];	
}

// reads colors.csv and polulates the entries array with UIColors
-(void) loadColors {
	entries = [[NSMutableArray arrayWithCapacity:10] retain];

	NSBundle *bundle = [NSBundle mainBundle];
	NSString *textFilePath = [bundle pathForResource:@"colors" ofType:@"csv"];
	NSError *error;
	NSString *fileContents = [NSString stringWithContentsOfFile:textFilePath encoding:NSUTF8StringEncoding error:&error];

	NSArray *colorsArray = [[NSArray alloc] initWithArray:[fileContents componentsSeparatedByString:@"\n"]];
	for (NSString *line in colorsArray) {
		FontStyle *style = [[FontStyle alloc] init];
		NSArray *colorComponents = [[NSArray alloc] initWithArray:[line componentsSeparatedByString:@","]];

		if ([line lengthOfBytesUsingEncoding:NSASCIIStringEncoding] > 0) { // skip blank lines
			// Support both RGBA and Hex to define colors
			if ([colorComponents count] > 1) {
				long red = [[colorComponents objectAtIndex:0] doubleValue];
				long green = [[colorComponents objectAtIndex:1] doubleValue];
				long blue = [[colorComponents objectAtIndex:2] doubleValue];
				[style setRGBColor:((red << 16) + (green << 8) + blue)];
			}
			else {
				long RGB = [style hexToLong:[colorComponents objectAtIndex:0]];
				[style setRGBColor:RGB];
			}
			[entries addObject:style];
		}
		[style release];
        [colorComponents release];
	}
	
	[colorsArray release];
}

@end
