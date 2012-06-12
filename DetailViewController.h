//
//  DetailViewController.h
//  JMML
//
//  Created by Walsh, John on 7/2/10.
//  Copyright 2010 Constant Contact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopoverTableController.h"

@interface FontDetailSelector : PopoverTableController {

	NSString *fontFamily;
	
}

- (NSString *) getFontDetailName: (int) index;
- (void) setFontDetailName:(NSString *) type;
- (void) setFontFamily:(NSString *) family;

@end
