//
//  RootViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import "ShadowedTableView.h"

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    
	IBOutlet ShadowedTableView *aTableView;
	IBOutlet UISearchBar *aSearchBar;
    
}

@property (retain) ShadowedTableView *aTableView;
@property (retain) UISearchBar *aSearchBar;

@end
