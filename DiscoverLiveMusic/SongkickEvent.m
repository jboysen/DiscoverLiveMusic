//
//  SongkickEvent.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "SongkickEvent.h"
#import "SongkickVenue.h"

@interface SongkickEvent()

@property (strong, nonatomic) SongkickVenue *songkickVenue;

@end

@implementation SongkickEvent 

- (NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter dateFromString:[self.event valueForKeyPath:@"start.date"]];
}

- (NSString*)dateFormatted
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEEE d MMMM"];
    return [format stringFromDate:self.date];
}

- (NSDate*)dateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *time = self.timeFormatted;
    
    if (!self.hasTime) {
        time = @"23:59";
    }
    
    return [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [self.event valueForKeyPath:@"start.date"], time]];
}

- (NSString*)timeFormatted
{
    NSString *time = [self.event valueForKeyPath:@"start.time"];
    if ([time isKindOfClass:[NSString class]]) {
        return [time substringToIndex:5];
    } else {
        return TIME_NA;
    }
}

- (BOOL)hasTime
{
    return ![self.timeFormatted isEqualToString:TIME_NA];
}

- (NSArray*)getArtists
{
    return [self.event valueForKeyPath:@"performance"];
}

- (NSString*)mainArtist
{
    if ([[self getArtists] count] > 0) {
        NSDictionary* artist = [self getArtists][0];
        return [artist objectForKey:@"displayName"];
    }
    return @"N/A";
}

- (NSArray*)supportArtists
{
    NSMutableArray *artists = [[NSMutableArray alloc] init];
    NSArray *tempArray = [[self getArtists] subarrayWithRange:NSMakeRange(1, [[self getArtists] count] - 1)];
    for (NSDictionary *artist in tempArray) {
        [artists addObject:[artist objectForKey:@"displayName"]];
    }
    return artists;
}

- (NSURL*)url
{
    return [NSURL URLWithString:[self.event objectForKey:@"uri"]];
}

- (long)eventID
{
    NSString *val = [self.event valueForKeyPath:@"id"];
    return ([val isKindOfClass:[NSNull class]]) ? 0 : [val longLongValue];
}

#pragma mark - MKAnnotaion protocol properties and methods

- (CLLocationCoordinate2D)coordinate
{
    return [self.venue coordinate];
}

- (NSString*)title
{
    return self.mainArtist;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%@ at %@", self.timeFormatted, self.venue.name];
}

@end
