//
//  SongkickFetcher.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 26/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Fetcher.h"
#import "SongkickLocation.h"
#import "SongkickEvent.h"
#import "SongkickVenue.h"

@interface SongkickFetcher : Fetcher

+ (NSArray*) getLocationsByLocation:(CLLocation*)location;
+ (NSArray*) getLocationsByQuery:(NSString*)query;
+ (SongkickLocation*)getLocationByIP;
+ (NSDictionary*) getEventsByMetroID:(long)metroID page:(int)page existingEvents:(NSDictionary*)events;
+ (SongkickVenue*) getVenueByID:(long)venueID;
+ (SongkickEvent*) getEventByID:(long)eventID;

@end
