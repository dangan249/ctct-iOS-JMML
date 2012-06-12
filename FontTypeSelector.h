//
//  FontTypeSelector.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "PopoverTableController.h"
#import "FontStyle.h"


@interface FontTypeSelector : PopoverTableController {
	
}
- (FontStyle*) getStyle: (int) index;
- (void) setFontType:(NSString *)type;

// class methods
+ (void) loadFontList;
+ (NSMutableArray*)fontlist;


@end
