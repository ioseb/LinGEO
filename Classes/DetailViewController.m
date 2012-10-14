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
    "margin: 10 40 20 40;"
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
    ".s7 {"
    "border-bottom: 1px solid #c0c0c0;"
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
        [string appendFormat:@"<div class='s3'>&nbsp;&nbsp;&nbsp;&nbsp;%@</div>"
         "<div class='s7'><a href='callback:%d'><img id=\"mplayer%d\" src=\"Play-icon.png\" /></a></div>", [trn.geo objectAtIndex:i], i, i];
    }
    [string appendString:@"</body></html>"];
                                              
    return string;
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if ( [[[inRequest URL] scheme] isEqualToString:@"callback"] ) {
        
        if([[PTeSpeak sharedPTeSpeak] isSpeak]) {
            [[PTeSpeak sharedPTeSpeak] stop];
            return NO;
        }
        
        NSString *indexStr = [[[inRequest URL] absoluteString ] substringFromIndex:[[[inRequest URL] scheme] length] + 1];
        
        int inx = [indexStr intValue];
        if(inx > -1) {
            
            selectedWord = inx;
            [[PTeSpeak sharedPTeSpeak] speak:[trn.geo objectAtIndex:inx]];
            
        }
        
        return NO;
    }
    
    return YES;
}

- (void)speakDidStart:(PTeSpeak *)espeak
{
    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"var mid = document.getElementById(\"mplayer%d\");"    
      "mid.src = \"Stop-icon.png\";", selectedWord]];
}

- (void)speakDidEnd:(PTeSpeak *)espeak
{
    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"var mid = document.getElementById(\"mplayer%d\");"    
      "mid.src = \"Play-icon.png\";", selectedWord]];
}

- (void)speakWithError:(PTeSpeak *)espeak error:(OSStatus)error
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"alert('Unable to create Audio queue')"];
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

    
    //PTeSpeak *espeak = [PTeSpeak sharedPTeSpeak];

    [[PTeSpeak sharedPTeSpeak] setDelegate:self];
    [[PTeSpeak sharedPTeSpeak] setupWithVoice:@"ka" volume:100 rate:150 pitch:40];
    
    
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
    webView.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSMutableString *output = [self generateHTMLoutput];
    [webView loadHTMLString:output baseURL:baseURL];
    [output release];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[PTeSpeak sharedPTeSpeak] stop];
}

- (void)addToBookmarks {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate addToBookmarks:trn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in DetailViewController");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = @"Details";
}

- (void)dealloc {
	[webView release];
	[trn release];
	[super dealloc];
}



@end
