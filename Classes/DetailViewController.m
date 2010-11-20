//
//  DetailViewController.m
//  LinGEO
//

#import "LinGEOAppDelegate.h"
#import "DetailViewController.h"

@interface DetailViewController()
- (void)addToBookmarks;
@end



@implementation DetailViewController

@synthesize webView, trn;
@synthesize adViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
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

    self.adViewController = [[AdViewController alloc] initWithController:self]; 
    
    // If the banner wasn't included in the nib, create one.
    [adViewController createADBannerView];
    
    [adViewController layoutForCurrentOrientation:NO];
    
    
    
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
    [adViewController layoutForCurrentOrientation:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in DetailViewController");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = @"Details";

    [adViewController layoutForCurrentOrientation:NO];    
}

- (void)dealloc {
    [adViewController release];
	[webView release];
	[trn release];
	[super dealloc];
}



@end
