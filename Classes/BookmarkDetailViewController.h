//
//  BookmarkDetailViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import "Bookmark.h";

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BookmarkDetailViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	Bookmark *bookmark;
    
    IBOutlet UIWebView  *webView;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) Bookmark *bookmark;

@end
