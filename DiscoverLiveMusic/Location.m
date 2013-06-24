//
//  Location.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Location.h"

@interface Location ()

@property (strong) NSDictionary *location;

@end

@implementation Location

- (Location*)initWithDictionary:(NSDictionary *)location
{
    self = [super init];
    if (self) {
        self.location = [[NSDictionary alloc] initWithDictionary:location];
    }
    return self;
}

@end
