//
//  DetailViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>


#import "ShadowedTableView.h"
#import "EngGeo.h"
#import "PTeSpeak.h"

@interface DetailViewController : UIViewController <UIWebViewDelegate, PTeSpeakDelegate> {
    
    IBOutlet UIWebView  *webView;
	EngGeo *trn;
    
    NSInteger selectedWord;
    
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) EngGeo *trn;    
    
@end
