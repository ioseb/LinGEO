//
//  BookmarkViewController.h
//  LinGO
//
//  Created by Mr.Woods on 8/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *aTableView;
}

@property (nonatomic, retain) UITableView *aTableView;

@end
