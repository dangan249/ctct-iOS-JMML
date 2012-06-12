//
//  LoadingSpinnerViewController.m
//  CTCT
//

#import "LoadingSpinnerViewController.h"


@implementation LoadingSpinnerViewController

@synthesize message;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}
- (void) viewDidLoad {
	
    [super viewDidLoad];
    [message setCenter:self.view.center];
    spinner.frame = CGRectMake(350,400, 60.0, 60.0);
}

- (void)dealloc {
    [spinner release];
    [spinner release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}



- (void)viewDidUnload {
    [spinner release];
    spinner = nil;
    [spinner release];
    spinner = nil;
    [super viewDidUnload];
}
@end
