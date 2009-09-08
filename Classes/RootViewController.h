//
//  RootViewController.h
//  LinGO
//
//  Created by Mr.Woods on 8/2/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	IBOutlet UITableView *aTableView;
	IBOutlet UISearchBar *aSearchBar;
}

@property (retain) UITableView *aTableView;
@property (retain) UISearchBar *aSearchBar;

@end
