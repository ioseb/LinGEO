//
//  BookmarkDetailViewController.h
//  LinGO
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
