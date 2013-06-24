//
//  GPSLocationVC.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "GPSLocationVC.h"

@interface GPSLocationVC () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GPSLocationVC

// start getting current location coordinates when loading
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startStandardUpdates];
}

// lazy load the location manager
- (CLLocationManager*)locationManager
{
    if (!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

// set the current vc as delegate
- (void)startStandardUpdates
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 100;
    
    [self.locationManager startUpdatingLocation];
}

// event handler for location updates from the location manager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    dispatch_queue_t loaderQ = dispatch_queue_create("gpsLocationLoader", NULL);
    dispatch_async(loaderQ, ^{
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        NSArray* locations = [SongkickFetcher getLocationsByLocation:location];
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.locations = locations;
        });
        
    });
    
    [manager stopUpdatingLocation];
}

@end
