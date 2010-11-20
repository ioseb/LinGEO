//
//  DetailViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>


#import "ShadowedTableView.h"
#import "EngGeo.h"
#import "AdViewController.h"

@interface DetailViewController : UIViewController {
    
    AdViewController  *adViewController;
    
    IBOutlet UIWebView  *webView;
	EngGeo *trn;
    
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) EngGeo *trn;    
@property (nonatomic, retain) AdViewController *adViewController;
    
@end
