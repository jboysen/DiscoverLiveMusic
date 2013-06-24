//
//  CurrentLocation.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "CurrentLocation.h"

// Singleton object used to be able to easily retrieve the current location in all view controllers
static Location *currentLocation = nil;

@implementation CurrentLocation

+ (Location*)get
{
    return currentLocation;
}

+ (void)set:(Location*)location
{
    currentLocation = location;
}

@end
