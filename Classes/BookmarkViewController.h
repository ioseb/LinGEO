//
//  BookmarkViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import "ShadowedTableView.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BookmarkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UITableView *aTableView;
}

@property (nonatomic, retain) UITableView *aTableView;

- (void)updateBarButtons;

@end
