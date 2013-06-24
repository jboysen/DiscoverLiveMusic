//
//  LastFMFetcher.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Fetcher.h"
#import "LastFMArtist.h"

@interface LastFMFetcher : Fetcher

+ (LastFMArtist*)getArtist:(NSString*)query;

@end
