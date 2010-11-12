//
//  DetailViewController.m
//  LinGEO
//

#import "LinGEOAppDelegate.h"
#import "DetailViewController.h"

@interface DetailViewController()
- (void)addToBookmarks;
@end

@interface DetailViewController()

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
-(void)layoutForCurrentOrientation:(BOOL)animated;

// A simple method that creates an ADBannerView
// Useful if you need to create the banner view in code
// such as when designing a universal binary for iPad
-(void)createADBannerView;

@end

@implementation DetailViewController

@synthesize webView, trn, banner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

-(void)createADBannerView
{
    // Depending on our orientation when this method is called, we set our initial content size.
    // If you only support portrait or landscape orientations, then you can remove this check and
    // select either ADBannerContentSizeIdentifier320x50 (if portrait only) or ADBannerContentSizeIdentifier480x32 (if landscape only).
    NSString *contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
    
    // Calculate the intial location for the banner.
    // We want this banner to be at the bottom of the view controller, but placed
    // offscreen to ensure that the user won't see the banner until its ready.
    // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0, CGRectGetMaxY(self.view.bounds));
    
    // Now to create and configure the banner view
    ADBannerView *bannerView = [[ADBannerView alloc] initWithFrame:frame];
    //bannerView.backgroundColor = [UIColor redColor];
    
    // Set the delegate to self, so that we are notified of ad responses.
    bannerView.delegate = self;
    // Set the autoresizing mask so that the banner is pinned to the bottom
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    // Since we support all orientations in this view controller, support portrait and landscape content sizes.
    // If you only supported landscape or portrait, you could remove the other from this set.
    bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
    
    // At this point the ad banner is now be visible and looking for an ad.
    [self.view addSubview:bannerView];
    self.banner = bannerView;
    [bannerView release];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2 : 0.0;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
        bannerHeight = 32.0;
    }
    else
    {
        banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
        bannerHeight = 50.0;
    }
    
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(banner.bannerLoaded)
    {
        contentFrame.size.height -= bannerHeight;
		bannerOrigin.y -= bannerHeight;
    }
    else
    {
		bannerOrigin.y += bannerHeight;
    }
    
    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         webView.frame = contentFrame;
                         [webView layoutIfNeeded];
                         banner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, 320, 32);
                     }];
}


- (NSMutableString*)generateHTMLoutput
{
    NSMutableString *string = [NSMutableString new];
    
    [string appendFormat:@"<html>"
    "<style>"
    "body {"
    "margin: 10 10 20 40;"
    "}"
    "#word {"
    "font-family: Georgia;"
    "font-size: 78px;"
    "font-weight: bold;"
    "}"
    "#transcript {"
    "font-family: Georgia;"
    "font-size: 74px;"
    "}"
    ".s3 {"
    "font-family: Georgia;"
    "font-size: 60px;"
    "font-weight: bold;"
    "}"
    "i {"
    "color: #72c53e;"
    "}"
    "</style>"
    "<body bgcolor='#FFF3E0'>"
    "<div id='word'>%@</div>"
    "<div id='transcript'>&nbsp;%@</div>", [trn eng], [trn transcription]];

    for(int i = 0; i < [trn.types count]; i++) {
        [string appendFormat:@"<div class='s3'>%d.&nbsp;<i>%@</i></div>", i + 1, [[trn.types objectAtIndex:i] lowercaseString]];
        [string appendFormat:@"<div class='s3'>&nbsp;&nbsp;&nbsp;&nbsp;%@</div>", [trn.geo objectAtIndex:i]];
    }
    [string appendString:@"</body></html>"];
                                              
    return string;
}

//If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
											  initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
											  target:self action:@selector(addToBookmarks)];
    
	LinGEOAppDelegate *delegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([delegate bookmarkExists:(int)trn.pk]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
    
    // If the banner wasn't included in the nib, create one.
    if(banner == nil) {
        [self createADBannerView];
    }
    
    [self layoutForCurrentOrientation:NO];
    
 /*   NSString *path = [[NSBundle mainBundle] pathForResource:@"webViewContent" ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
	NSString *htmlString = [[NSString alloc] initWithData: 
                            [readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
 */   
    
    // to make html content transparent to its parent view -
	// 1) set the webview's backgroundColor property to [UIColor clearColor]
	// 2) use the content in the html: <body style="background-color: transparent">
	// 3) opaque property set to NO
	//
	webView.opaque = NO;
	webView.backgroundColor = [UIColor clearColor];
    
    NSMutableString *output = [self generateHTMLoutput];
    [webView loadHTMLString:output baseURL:nil];
    [output release];
}

- (void)addToBookmarks {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate addToBookmarks:trn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutForCurrentOrientation:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in DetailViewController");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = @"Details";

    [self layoutForCurrentOrientation:NO];    
}

- (void)dealloc {
	[webView release];
	[trn release];
    
    banner.delegate = nil;
    [banner release];
    
	[super dealloc];
}

#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutForCurrentOrientation:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Error: %@\n", [error localizedDescription]);
    [self layoutForCurrentOrientation:YES];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}


@end
