//
//  Details.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MessageUI/MessageUI.h>
#import "Event.h"
#import "DetailsTVC.h"

@interface DetailsHeader : UIView

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) UIViewController<DetailsTVCDelegate> *delegate;
@property (strong, nonatomic) NSData *imageData;

@end
