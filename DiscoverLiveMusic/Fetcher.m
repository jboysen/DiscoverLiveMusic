//
//  Fetcher.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Fetcher.h"

@implementation Fetcher

+ (NSDictionary*)fetchURL:(NSString*)urlString
{
    NSString *url = [NSString stringWithFormat:@"%@%@&%@", [self rootURL], urlString, [self apiKey]];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    return (jsonData) ? [self parseJSON:jsonData] : nil;
}

+ (NSDictionary*)parseJSON:(NSData *)responseData
{
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    return json;
}

// implemented by sub classes
+ (NSString*)apiKey { return nil; }
+ (NSString*)rootURL { return nil; }

@end
