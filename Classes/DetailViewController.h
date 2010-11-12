//
//  DetailViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "ShadowedTableView.h"
#import "EngGeo.h"

@interface DetailViewController : UIViewController <ADBannerViewDelegate> {

    IBOutlet UIWebView  *webView;
	EngGeo *trn;
    
    ADBannerView *banner;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) EngGeo *trn;
@property (nonatomic, retain) IBOutlet ADBannerView *banner;

@end
