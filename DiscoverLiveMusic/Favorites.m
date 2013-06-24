//
//  Favorites.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 11/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "Favorites.h"
#import "SongkickEvent.h"

@implementation Favorites

#define EVENTS_KEY @"EVENTS"

+ (NSDictionary*)events
{
    NSDictionary *events = [[NSUserDefaults standardUserDefaults] dictionaryForKey:EVENTS_KEY];
    return (events) ? events : [[NSDictionary alloc] init];
}

+ (NSArray*)all
{
    return [[self events] allValues];
}

+ (NSString*)idStr:(long)eventID
{
    return [NSString stringWithFormat:@"%ld", eventID];
}

+ (void)remove:(Event*)event
{
    NSMutableDictionary *events = [[self events] mutableCopy];
    
    [events removeObjectForKey:[self idStr:event.eventID]];
    
    [[NSUserDefaults standardUserDefaults] setObject:events forKey:EVENTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)add:(Event*)event
{
    NSMutableDictionary *events = [[self events] mutableCopy];
    
    NSDictionary *propertyEvent = @{
                                    @"id": [self idStr:event.eventID],
                                    @"title": event.title,
                                    @"subtitle": [NSString stringWithFormat:@"%@ %@", event.dateFormatted, event.subtitle]
                                    };
    
    [events setValue:propertyEvent forKey:[self idStr:event.eventID]];
    
    [[NSUserDefaults standardUserDefaults] setObject:events forKey:EVENTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)contains:(Event*)event
{
    return ([[self events] objectForKey:[self idStr:event.eventID]]) ? YES : NO;
}

+ (void)removeWithId:(long)eventID
{
    NSMutableDictionary *events = [[self events] mutableCopy];
    
    [events removeObjectForKey:[self idStr:eventID]];
    
    [[NSUserDefaults standardUserDefaults] setObject:events forKey:EVENTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
