//
//  Favorites.h
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 11/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface Favorites : NSObject

+ (NSArray*)all;
+ (void)remove:(Event*)event;
+ (void)add:(Event*)event;
+ (BOOL)contains:(Event*)event;
+ (void)removeWithId:(long)eventID;

@end
