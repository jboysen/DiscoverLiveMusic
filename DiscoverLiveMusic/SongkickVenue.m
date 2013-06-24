//
//  SongkickVenue.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 10/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "SongkickVenue.h"

@implementation SongkickVenue

- (NSString*)address1
{
    return [self.venue objectForKey:@"street"];
}

- (NSString*)address2
{
    return [self.venue objectForKey:@"zip"];    
}

@end
