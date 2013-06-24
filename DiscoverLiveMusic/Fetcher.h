//
//  Fetcher.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fetcher : NSObject

+ (NSDictionary*)fetchURL:(NSString*)urlString;
+ (NSDictionary*)parseJSON:(NSData *)responseData;

+ (NSString*)apiKey;
+ (NSString*)rootURL;

@end
