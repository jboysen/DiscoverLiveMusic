//
//  Artist.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Artist : NSObject

@property (strong, readonly) NSDictionary *artist;
- (Artist*)initWithDictionary:(NSDictionary *)artist;

@property (strong, readonly) NSURL *imageLargeURL;

@end
