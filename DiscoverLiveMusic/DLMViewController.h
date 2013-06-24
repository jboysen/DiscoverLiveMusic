//
//  DLMViewController.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 26/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

// used by the location controllers
@protocol DLMViewControllerDelegate

-(void)setLocation:(Location*)location;

@end

@interface DLMViewController : UITableViewController<DLMViewControllerDelegate>



@end
