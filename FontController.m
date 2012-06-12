//
//  FontController.m
//  JMML
//

#import "FontController.h"
#import "SettingsViewController.h"

@implementation FontController
@synthesize delegate,line, hideFox;


#define DEFAULT_POPOVERHEIGHT 380

- (CGSize) contentSizeForViewInPopoverView {

    return CGSizeMake (320, PopoverHeight); 
}

- (void) viewDidLoad {

    CGRect SegmentRect, FoxRect;
    FoxRect = [txtFox frame];
    SegmentRect = [segStyle frame];

    PopoverHeight = DEFAULT_POPOVERHEIGHT;
    int offset = FoxRect.size.height + SegmentRect.size.height;
    
	if (hideFox) {
		offset  -= FoxRect.size.height;            
        PopoverHeight -= FoxRect.size.height;    
	}
    
	CGRect f = CGRectMake(0, offset, 320, (PopoverHeight - offset));
	
	if (typeSel == nil)
		typeSel = [[FontTypeSelector alloc]init];
	if (sizeSel == nil)
		sizeSel = [[FontSizeSelector alloc]init];
	if (colorSel == nil)
		colorSel = [[ColorSelectorController alloc]init];
    
	[[typeSel view]setFrame:f];
	[[sizeSel view]setFrame:f];
	[[colorSel view]setFrame:f];
	
	[typeSel setTarget:self];
	[typeSel setEntrySelector:@selector(familySelected:)];
	[sizeSel setTarget:self];
	[sizeSel setEntrySelector:@selector(sizeSelected:)];
	[colorSel setTarget:self];
	[colorSel setEntrySelector:@selector(colorSelected:)];
	
	style = [[FontStyle alloc]init];
	[style setSize:28];
	[style setRGBColor:0x000000];	// white
	[style setFamilyName:@"Helvetica"];
	[style UpdateStyleTraits:YES italic:NO];

}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
	[delegate setFontStyle:style forLine:line];
	return YES;
}

- (void) setSize:(NSString *) s {
	[style setSize:[s intValue]];
	[sizeSel setSize:s];
}

- (void) updateQuickBrownFox {

	[txtFox setFont:[UIFont fontWithName:[style actualFontName] size:[style size]]];
	[txtFox setTextColor:[style color]];
	[self adjustBkgColor:[style color]];

	[delegate setFontStyle:style forLine:line];
}

- (void) setStyle: (FontStyle *) s {
    
    // need to release style to prevent leak
    if (style != nil)
        [style release];
    
	style = s;
	
	NSString *sizeString = [NSString stringWithFormat:@"%d",[style size]];
	[sizeSel setSize: sizeString];
	[typeSel setFontType:[style displayName]];
	[colorSel setRGBColor:[style RGBColor]];
	
	[self updateQuickBrownFox];
}

- (void) sizeSelected:(id) popoverTableController {
	[style setSize:[sizeSel getSize]];
	[self updateQuickBrownFox];
}

- (void) familySelected:(id) popoverTableController {
	FontStyle *selectedStyle = [typeSel getStyle:[typeSel selectedItem]];
	[style setFamilyName:[selectedStyle familyName]];
	[style setActualFontName:[selectedStyle actualFontName]];
	[style setDisplayName:[selectedStyle displayName]];

	[self updateQuickBrownFox];
}

- (void) adjustBkgColor:(UIColor *)aColor {
	float *components = (float*)CGColorGetComponents([aColor CGColor]);
	float red = components[0];
	float green = components[1];
	float blue = components[2];
	if ((red > .85) && (green > .85) && (blue > .85))
		[txtFox setBackgroundColor:[UIColor lightGrayColor]];
	else
		[txtFox setBackgroundColor:[UIColor whiteColor]];	
}

- (void) colorSelected:(ColorSelectorController*) csCRTL {

	[style setRGBColor:[csCRTL selectedColor]];
	
	[self updateQuickBrownFox];
}

- (IBAction)toggleState:(id)sender {
	
	switch ([sender selectedSegmentIndex])
	{
		case 0:	
		{
			[self showStyles];	
			break;
		}
		case 1: 
		{	
			[self showSize];	
			break;
		}
		case 2:	
		{
			[self showColor];	
			break;
		}
	}
}

-(void) showStyles {
	[currentView removeFromSuperview];
	currentView = [typeSel view];
	
	if (hideFox) {
		[[self view] addSubview:currentView ];
	}
	else {
		[[self view] insertSubview:currentView belowSubview:shadowView];
	}
}

-(void) showColor {
	[currentView removeFromSuperview];
	currentView = [colorSel view];

	if (hideFox) {
		[[self view] addSubview:currentView ];
	}
	else {
		[[self view] insertSubview:currentView belowSubview:shadowView];
	}
}

-(void) showSize {
	[currentView removeFromSuperview];
	currentView = [sizeSel view];
	
	if (hideFox) {
		[[self view] addSubview:currentView ];
	}
	else {
		[[self view] insertSubview:currentView belowSubview:shadowView];
	}
}

#pragma mark Standard UI Methods

- (void)dealloc {
	[style release];
    style = nil;
	
	[typeSel release];
	typeSel = nil;
	
	[sizeSel release];
	sizeSel= nil;
	
	[colorSel release];
	colorSel = nil;
		
	[super dealloc];
}

@end
