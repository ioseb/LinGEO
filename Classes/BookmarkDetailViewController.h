//
//  BookmarkDetailViewController.h
//  LinGO
//
//  Created by Mr.Woods on 8/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h";

@interface BookmarkDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
	IBOutlet UITableView *aTableView;
	Bookmark *bookmark;
}

@property (nonatomic, retain) UITableView *aTableView;
@property (nonatomic, retain) Bookmark *bookmark;

@end
