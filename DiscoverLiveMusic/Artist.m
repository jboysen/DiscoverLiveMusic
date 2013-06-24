//
//  Artist.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Artist.h"

@interface Artist()

@property (strong) NSDictionary *artist;

@end

@implementation Artist

- (Artist*)initWithDictionary:(NSDictionary *)artist
{
    self = [super init];
    if (self) {
        self.artist = [[NSDictionary alloc] initWithDictionary:artist];
    }
    return self;
}

@end
