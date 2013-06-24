//
//  LocationViewController.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 28/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLMViewController.h"
#import "DLMAppDelegate.h"
#import "SongkickFetcher.h"

@interface LocationVC : UIViewController

@property (strong, nonatomic) UIViewController<DLMViewControllerDelegate> *delegate; // should be set before this vc appears
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator; // show this when fetching from Songkick
@property (strong, nonatomic) NSArray *locations; // array for the table view

@end
