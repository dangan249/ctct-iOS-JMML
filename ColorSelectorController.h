//
//  ColorSelectorController.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "ColorButton.h"

@interface ColorSelectorController : UIViewController {
	id target;
	SEL doEntry;
	NSMutableArray *entries;
	long selectedColor;
	UIScrollView *colorSV;
	UIView *colorView;
}


- (void) setEntrySelector:(SEL) selector;
- (void) loadColors;
- (void) setRGBColor:(long) aColor;

@property (assign) long selectedColor;
@property (assign,readwrite) id target;

@end
