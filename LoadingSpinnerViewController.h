//
//  LoadingSpinnerViewController.h
//  CTCT
//

#import <UIKit/UIKit.h>


@interface LoadingSpinnerViewController : UIViewController {

    IBOutlet UILabel *message;			// the line of text to display underneath the spinner
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) IBOutlet UILabel *message;


@end
