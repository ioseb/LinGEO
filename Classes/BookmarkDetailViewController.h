//
//  BookmarkDetailViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import "Bookmark.h";

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AdViewController.h"

@interface BookmarkDetailViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	Bookmark *bookmark;
    
    IBOutlet UIWebView  *webView;
    
    AdViewController  *adViewController;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) Bookmark *bookmark;
@property (nonatomic, retain) AdViewController *adViewController;

@end
