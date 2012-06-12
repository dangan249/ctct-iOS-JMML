//
//  ThemeSelector.h
//  JMML
//


#import <Foundation/Foundation.h>
#import "PopoverTableController.h"
#import "MyUIImage.h"
#import "theme.h"

@interface ThemeSelector : PopoverTableController {

	NSMutableArray *images;
	NSMutableArray *imageNames;	
    NSMutableDictionary *themes;
}
// class methods
+ (NSMutableArray*)themelist;

+ (void) loadThemes;
- (void) printThemes;
- (UIImage *) getImageAtIndex:(int) index;
- (Theme *) getThemeAtIndex:(int) index;

@end
