//
//  FontController.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "FontSizeSelector.h"
#import "FontTypeSelector.h"
#import "ColorSelectorController.h"
#import "FontStyle.h"
#import "PopoverTableController.h"
#import "SegmentController.h"
#import "Theme.h"


@interface FontController : UIViewController <UIPopoverControllerDelegate>{
	
	FontSizeSelector *sizeSel;
    FontTypeSelector *typeSel;
	ColorSelectorController *colorSel;
	CGRect popoverLocation;
	id delegate;
	FontStyle *style;
	UIView *currentView;
	IBOutlet UIImageView *shadowView;	
	IBOutlet UILabel *txtFox; 
    IBOutlet UISegmentedControl *segStyle;
	int line;
	BOOL hideFox;
    int PopoverHeight;
}

@property (assign) id delegate;
@property (assign) int line; // the line whose style we are editing
@property (assign) BOOL hideFox;

-(void) showStyles;
-(void) showSize;
-(void) showColor;
-(IBAction) toggleState:(id)sender;

- (void) setSize:(NSString *) s;
- (void) setStyle: (FontStyle*) s;
- (void) adjustBkgColor:(UIColor *)aColor;

@end
