//
//  Event.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "Artist.h"

@interface Event : NSObject <MKAnnotation>

#define TIME_NA @"N/A"

@property (strong, readonly) NSDictionary *event;
- (Event*)initWithDictionary:(NSDictionary*)event; // designated initializer

@property (strong, readonly) NSDate *date;
@property (strong, readonly) NSString *dateFormatted;
@property (strong, readonly) NSDate *dateTime;
@property (strong, readonly) NSString *timeFormatted;
@property (strong, readonly) NSString *mainArtist;
@property (strong, readonly) NSArray *supportArtists;
@property (strong, nonatomic) Venue *venue;
@property (strong) Artist *artist;
@property (readonly) BOOL hasTime;
@property (strong, readonly) NSURL *url;
@property (nonatomic) long eventID;
@property (nonatomic) BOOL isFavorite;

@end
