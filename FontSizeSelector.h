//
//  FontSizeSelector.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "PopoverTableController.h"

@interface FontSizeSelector : PopoverTableController {

}
- (int) getSize;
- (void) setSize:(NSString *)size;


@end
