//
//  Venue.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 30/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Venue : NSObject <MKAnnotation>

@property (strong, nonatomic, readonly) NSDictionary *venue;
- (Venue*)initWithDictionary:(NSDictionary*)venue; // designated initializer

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *address1;
@property (strong, nonatomic, readonly) NSString *address2;
@property (nonatomic) long venueID;

@end
