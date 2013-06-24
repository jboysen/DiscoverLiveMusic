//
//  SongkickFetcher.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 26/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "SongkickFetcher.h"

@implementation SongkickFetcher

+ (NSString*)apiKey
{
    return @"apikey=tdSQnlXvXWdYYiyX";
}

+ (NSString*)rootURL
{
    return @"http://api.songkick.com/api/3.0";
}

+ (NSArray*)locationArray:(NSArray*)array
{
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    for (NSDictionary *location in array) {
        [locations addObject:[[SongkickLocation alloc] initWithDictionary:location]];
    }
    
    return locations;
}

+ (SongkickLocation*)getLocationByIP
{
    NSDictionary *data = [self fetchURL:@"/search/locations.json?location=clientip&page=1&per_page=1"];
    
    return (data) ? [[SongkickLocation alloc] initWithDictionary:[data valueForKeyPath:@"resultsPage.results.location"][0]] : nil;
}

+ (NSArray*) getLocationsByLocation:(CLLocation*)location
{
    NSDictionary *data = [self fetchURL:[NSString stringWithFormat:@"/search/locations.json?location=geo:%f,%f", location.coordinate.latitude, location.coordinate.longitude]];
    return [self locationArray:[data valueForKeyPath:@"resultsPage.results.location"]];
}

+ (NSArray*)getLocationsByQuery:(NSString *)query
{
    NSDictionary *data = [self fetchURL:[NSString stringWithFormat:@"/search/locations.json?query=%@", query]];
    return [self locationArray:[data valueForKeyPath:@"resultsPage.results.location"]];
}

+ (NSDictionary*) getEventsByMetroID:(long)metroID page:(int)page existingEvents:(NSDictionary *)events
{
    NSDictionary *data = [self fetchURL:[NSString stringWithFormat:@"/metro_areas/%ld/calendar.json?page=%d&per_page=20", metroID, page]];
    
    NSArray *newEvents = [data valueForKeyPath:@"resultsPage.results.event"];
    
    return [self mergeEvents:newEvents existingEvents:events];
}

+ (NSDictionary*)mergeEvents:(NSArray*)newEvents existingEvents:(NSDictionary*)events
{
    NSMutableDictionary *grouped = [[NSMutableDictionary alloc] initWithDictionary:events];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    for (NSDictionary *event in newEvents) {
        SongkickEvent *newEvent = [[SongkickEvent alloc] initWithDictionary:event];
        NSString *key = [dateFormatter stringFromDate:newEvent.date];
        NSMutableArray *group = [grouped objectForKey:key];
        if (!group) {
            group = [[NSMutableArray alloc] init];
            [grouped setValue:group forKey:key];
        }
        [group addObject:newEvent];
        [group sortUsingComparator:^NSComparisonResult(SongkickEvent *obj1, SongkickEvent *obj2) {
            return [obj1.dateTime compare:obj2.dateTime];
        }];
    }
    return grouped;
}

+ (SongkickVenue*) getVenueByID:(long)venueID
{
    NSDictionary *data = [self fetchURL:[NSString stringWithFormat:@"/venues/%ld.json?", venueID]];
    return [[SongkickVenue alloc] initWithDictionary:[data valueForKeyPath:@"resultsPage.results.venue"]];
}

+ (SongkickEvent*) getEventByID:(long)eventID
{
    NSDictionary *data = [self fetchURL:[NSString stringWithFormat:@"/events/%ld.json?", eventID]];
    return [[SongkickEvent alloc] initWithDictionary:[data valueForKeyPath:@"resultsPage.results.event"]];
}

@end
