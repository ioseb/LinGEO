//
//  DetailViewController.h
//  LinGO
//

#import <UIKit/UIKit.h>
#import "EngGeo.h"

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *aTableView;
	EngGeo *trn;
}

@property (nonatomic, retain) UITableView *aTableView;
@property (nonatomic, retain) EngGeo *trn;

@end
