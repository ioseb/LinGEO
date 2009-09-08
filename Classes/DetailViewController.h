//
//  DetailViewController.h
//  LinGO
//
//  Created by Mr.Woods on 8/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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
