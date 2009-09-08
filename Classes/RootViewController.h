//
//  RootViewController.h
//  LinGO
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	IBOutlet UITableView *aTableView;
	IBOutlet UISearchBar *aSearchBar;
}

@property (retain) UITableView *aTableView;
@property (retain) UISearchBar *aSearchBar;

@end
