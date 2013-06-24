//
//  WebVC.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 09/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "WebVC.h"
#import "DLMAppDelegate.h"

@interface WebVC() <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - Web view

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
}

// when loading is done, hide the network indicator
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
}

@end
