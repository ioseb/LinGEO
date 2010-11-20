//
//  AdViewController.h
//  LinGEO
//
//  Created by Lasha Dolidze on 11/13/10.
//  Copyright 2010 Picktek LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "AdMobDelegateProtocol.h"
#import "AdMobView.h"

@class AdMobView;
@interface AdViewController : NSObject <ADBannerViewDelegate, AdMobDelegate> {

    UIViewController *controller;

    // iAds banner
    ADBannerView *banner;
    
    // adMob banner
    AdMobView *adMobAd;
}

@property (nonatomic, retain) ADBannerView *banner;
@property (nonatomic, retain) UIViewController *controller;

- (id)initWithController:(UIViewController*) ctl;

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
