//
//  BookmarkDetailViewController.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PTeSpeak.h"

@interface BookmarkDetailViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	Bookmark *bookmark;
    
    IBOutlet UIWebView  *webView;
    
    
    NSInteger          selectedWord;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) Bookmark *bookmark;

@end
