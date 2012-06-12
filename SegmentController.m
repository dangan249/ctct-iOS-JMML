//
//  SegmentController.m
//  JMML
//
//  Created by Walsh, John on 7/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SegmentController.h"


@implementation SegmentController


- (void)setSelectedSegmentIndex:(NSInteger)toValue
{
	// Trigger UIControlEventValueChanged even when re-tapping the selected segment.
	if (self.selectedSegmentIndex == toValue) {
		[super setSelectedSegmentIndex:UISegmentedControlNoSegment];	// notify first
//		[self sendActionsForControlEvents:UIControlEventValueChanged];	// then unset
	} else {
		[super setSelectedSegmentIndex:toValue]; 
	}
}

@end
