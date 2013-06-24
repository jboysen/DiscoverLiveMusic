//
//  Event.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Event.h"
#import "Favorites.h"

@interface Event()

@property (strong, nonatomic) NSDictionary *event;

@end

@implementation Event

- (Event*)initWithDictionary:(NSDictionary *)event
{
    self = [super init];
    if (self) {
        self.event = [[NSDictionary alloc] initWithDictionary:event];
    }
    return self;
}

- (Venue*)venue
{
    if (!_venue) _venue = [[Venue alloc] initWithDictionary:[self.event objectForKey:@"venue"]];
    return _venue;
}

- (BOOL)isFavorite
{
    return [Favorites contains:self];
}

- (void)setIsFavorite:(BOOL)isFavorite
{
    if (isFavorite) {
        [Favorites add:self];
    } else {
        [Favorites remove:self];
    }
}

#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(0.0, 0.0);
}

@end
