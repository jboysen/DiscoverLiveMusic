//
//  Location.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (strong, readonly) NSDictionary* location;

- (Location*)initWithDictionary:(NSDictionary*)location; // designated initializer

@property (strong, nonatomic) NSString *fullName;
@property (nonatomic) long metroID;

@end
