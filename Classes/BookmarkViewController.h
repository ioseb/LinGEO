//
//  BookmarkViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import "ShadowedTableView.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AdViewController.h"

@interface BookmarkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UITableView *aTableView;

    AdViewController  *adViewController;
}

@property (nonatomic, retain) UITableView *aTableView;
@property (nonatomic, retain) AdViewController *adViewController;

- (void)updateBarButtons;

@end
