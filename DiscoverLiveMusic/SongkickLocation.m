//
//  SongkickLocation.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 13/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "SongkickLocation.h"

@implementation SongkickLocation

- (NSString*)fullName
{
    return [NSString stringWithFormat:@"%@, %@", [self.location valueForKeyPath:@"city.displayName"], [self.location valueForKeyPath:@"city.country.displayName"]];
}

- (long)metroID
{
    NSString *val = [self.location valueForKeyPath:@"metroArea.id"];
    return ([val isKindOfClass:[NSNull class]]) ? 0 : [val longLongValue];
}

@end
