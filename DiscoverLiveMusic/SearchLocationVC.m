//
//  SearchLocationVC.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "SearchLocationVC.h"

@interface SearchLocationVC () <UISearchBarDelegate>

@end

@implementation SearchLocationVC

// event handler for the Search button
// will query Songkick and set the locations array
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.progressIndicator startAnimating];
    [searchBar resignFirstResponder];
    
    NSString *query = searchBar.text;
    dispatch_queue_t loaderQ = dispatch_queue_create("queryLocationLoader", NULL);
    dispatch_async(loaderQ, ^{
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        NSArray* locations = [SongkickFetcher getLocationsByQuery:query];
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.locations = locations;
            if ([locations count] == 0) [self noResults:query];
        });
        
    });
}

// show an alert if no results could be found
- (void)noResults:(NSString*)query
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No results" message:[NSString stringWithFormat:@"No results for keyword: %@", query] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

@end
