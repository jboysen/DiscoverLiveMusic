//
//  DLMAppDelegate.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 26/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

@end
