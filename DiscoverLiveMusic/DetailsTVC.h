//
//  DetailsTVC.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

// protocol is used by the details header and footer
@protocol DetailsTVCDelegate

- (void)remind;
- (void)share;
- (void)favorite;

@end

@interface DetailsTVC : UITableViewController <MKMapViewDelegate, DetailsTVCDelegate>

@property (strong) Event *event; // set before segueing
@property long eventID; // also set before segueing

@end
