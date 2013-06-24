//
//  Venue.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 30/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Venue.h"

@interface Venue ()

@property (strong) NSDictionary *venue;

@end

@implementation Venue

- (Venue*)initWithDictionary:(NSDictionary *)venue
{
    self = [super init];
    if(self) {
        self.venue = [[NSDictionary alloc] initWithDictionary:venue];
    }
    return self;
}

- (NSString*)name
{
    return [self.venue objectForKey:@"displayName"];
}

- (long)venueID
{
    NSString *val = [self.venue valueForKeyPath:@"id"];
    return ([val isKindOfClass:[NSNull class]]) ? 0 : [val longLongValue];
}

#pragma mark - MKAnnotaion protocol properties

- (CLLocationCoordinate2D)coordinate
{
    if ([[self.venue objectForKey:@"lat"] isKindOfClass:[NSNumber class]]) {
        CLLocationDegrees lat = [[self.venue objectForKey:@"lat"] doubleValue];
        CLLocationDegrees lng = [[self.venue objectForKey:@"lng"] doubleValue];
        return CLLocationCoordinate2DMake(lat, lng);
    }
    return CLLocationCoordinate2DMake(0.0, 0.0);
}

@end
