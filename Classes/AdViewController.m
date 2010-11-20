//
//  AdViewController.m
//  LinGEO
//
//  Created by Lasha Dolidze on 11/13/10.
//  Copyright 2010 Picktek LLC. All rights reserved.
//

#import "AdViewController.h"


@implementation AdViewController

@synthesize banner, controller;

- (void)dealloc {
    banner.delegate = nil;
   [banner release];   
    [controller release];
    [super dealloc];
}

- (id)initWithController:(UIViewController*) ctl {
	if (self = [super init]) {
		self.controller = ctl;
	}
	return self;
}

-(void)createADBannerView
{
    double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (version >= 4.0) {
        // Depending on our orientation when this method is called, we set our initial content size.
        // If you only support portrait or landscape orientations, then you can remove this check and
        // select either ADBannerContentSizeIdentifier320x50 (if portrait only) or ADBannerContentSizeIdentifier480x32 (if landscape only).
        NSString *contentSize = UIInterfaceOrientationIsPortrait(controller.interfaceOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
        
        // Calculate the intial location for the banner.
        // We want this banner to be at the bottom of the view controller, but placed
        // offscreen to ensure that the user won't see the banner until its ready.
        // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
        CGRect frame;
        frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
        frame.origin = CGPointMake(0.0, CGRectGetMaxY(controller.view.bounds));
        
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
        [controller.view addSubview:bannerView];
        self.banner = bannerView;
        [bannerView release];
    } else {
        // get the window frame here.
        //CGRect appFrame = [UIScreen mainScreen].applicationFrame;
        
        CGRect appFrame;
        
        if(UIInterfaceOrientationIsPortrait(controller.interfaceOrientation)) {
            appFrame.size = CGSizeMake(320, 48);
        } else {
            appFrame.size = CGSizeMake(480, 32);        
        }
        
        appFrame.origin = CGPointMake(0.0, CGRectGetMaxY(controller.view.bounds));
        
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        // making flexible because this will end up in a navigation controller.
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        
        [controller.view addSubview:view];
        //controller.view = view;
        
        [view release];
        
        // Request an ad
        adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
        
        [adMobAd retain]; // this will be released when it loads (or fails to load)    
    }
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2 : 0.0;
    // by default content consumes the entire view area
    CGRect contentFrame = controller.view.bounds;
    
    double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (version >= 4.0) {

        // the banner still needs to be adjusted further, but this is a reasonable starting point
        // the y value will need to be adjusted by the banner height to get the final position
        CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
        CGFloat bannerHeight = 0.0;
        
        // First, setup the banner's content size and adjustment based on the current orientation
        if(UIInterfaceOrientationIsLandscape(controller.interfaceOrientation))
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
                             controller.view.frame = contentFrame;
                             [controller.view layoutIfNeeded];
                             banner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, 320, 32);
                         }];
    } else {
        CGRect frame = controller.view.frame;
        
        // put the ad at the bottom of the screen
        adMobAd.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 48);
    }
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


#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView {
    return @"a14cd8fb19d99e5"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
    return controller;
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
    return [UIColor colorWithRed:0.851 green:0.89 blue:0.925 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
    return [UIColor colorWithRed:0.298 green:0.345 blue:0.416 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
    return [UIColor colorWithRed:0.298 green:0.345 blue:0.416 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob: Did receive ad");
    // get the view frame
    CGRect frame = controller.view.frame;
    
    // put the ad at the bottom of the screen
    adMobAd.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 48);
    
    [controller.view addSubview:adMobAd];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob: Did fail to receive ad");
    [adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
    [adMobAd release];
    adMobAd = nil;
    // we could start a new ad request here, but in the interests of the user's battery life, let's not
}


@end
