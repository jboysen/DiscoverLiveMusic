//
//  VenueMapVC.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 30/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VenueMapVC : UIViewController

@property (strong) NSString *date; // used for information
@property (strong, nonatomic) NSArray *events; // used to annotate the map

@end
