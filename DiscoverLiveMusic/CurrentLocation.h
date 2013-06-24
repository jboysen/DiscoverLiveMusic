//
//  CurrentLocation.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface CurrentLocation : NSObject

+ (void)set:(Location*)location;
+ (Location*)get;

@end
