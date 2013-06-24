//
//  LastFMFetcher.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "LastFMFetcher.h"
#import "LastFMArtist.h"

@implementation LastFMFetcher

+ (NSString*)apiKey
{
    return @"api_key=04bea27b7978eaaf8eaa5dde7a7fd7e6";
}

+ (NSString*)rootURL
{
    return @"http://ws.audioscrobbler.com/2.0/?format=json";
}

+ (LastFMArtist*)getArtist:(NSString *)query
{
    NSDictionary *artist = [self fetchURL:[NSString stringWithFormat:@"&method=artist.getinfo&artist=%@", query]];
    
    return (artist) ? [[LastFMArtist alloc] initWithDictionary:[artist objectForKey:@"artist"]] : nil;
}

@end
