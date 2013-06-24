//
//  DetailsFooter.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "DetailsTVC.h"

@interface DetailsFooter : UIView

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) UIViewController<DetailsTVCDelegate, MKMapViewDelegate> *delegate;

@end
