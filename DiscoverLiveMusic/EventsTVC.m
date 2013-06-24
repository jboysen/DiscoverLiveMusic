//
//  EventsTVC.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 29/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "EventsTVC.h"
#import "VenueMapVC.h"
#import "DLMAppDelegate.h"
#import "DetailsTVC.h"
#import "CurrentLocation.h"
#import "SongkickFetcher.h"

@interface EventsTVC () <UISearchBarDelegate>

@property (nonatomic, strong) NSDictionary *events; // key: "yyyy-MM-dd", value: NSArray of Events
@property (strong) NSArray *eventDates; // array of NSDate
@property (nonatomic, strong) NSDictionary *eventsFiltered; // key: "yyyy-MM-dd", value: NSArray of Events
@property (strong) NSArray *eventDatesFiltered; // array of NSDate
@property (strong) Location *lastLocation; // the last location loaded
@property int currentPage; // the current page loaded from Songkick (results are paginated)
@property BOOL hasReachedEnd; // whether the last page of the Songkick results has been senn
@property (strong, nonatomic) NSDateFormatter *sharedDateFormatter; // a date formatter to use for section titles and event times
@property BOOL isFiltering; // if filtering is on continous scroll is disabled
@property int filterScope; // the current scope selected
@property (weak, nonatomic) IBOutlet UISearchBar *filterBar; // only height of frame used to show a nice animation hiding the filter bar

@end

@implementation EventsTVC

// lazy load the date formatter
// the format has to be set before use
- (NSDateFormatter*)sharedDateFormatter
{
    if (!_sharedDateFormatter)_sharedDateFormatter = [[NSDateFormatter alloc] init];
    return _sharedDateFormatter;
}

// manually set the refresh action
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl beginRefreshing];
    [self.refreshControl addTarget:self
                            action:@selector(loadEvents)
                  forControlEvents:UIControlEventValueChanged];
}

// load events every time view is shown
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadEvents];
}

// only load the events if the location changed or it is nil
- (void)loadEvents
{
    if (!self.lastLocation || ![self.lastLocation isEqual:[CurrentLocation get]]) {
        [self.refreshControl beginRefreshing];
        self.currentPage = 1;
        self.hasReachedEnd = NO;
        self.isFiltering = NO;
        self.lastLocation = [CurrentLocation get];
        [self resetEvents];
        [self asyncLoadEvents];
    } else {
        [self.refreshControl endRefreshing];
    }
}

// clear events to show a blank list if the location changed
// and hide the filter bar
- (void)resetEvents
{
    self.events = [[NSDictionary alloc] init];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.tableView.contentOffset = CGPointMake(0, self.filterBar.frame.size.height);
                     } completion:nil];
}

- (void)setEvents:(NSDictionary*)events
{
    _events = events;
    self.eventDates = [self sortedDaysFromKeys:[events allKeys]];
    [self.tableView reloadData];
}

- (void)setEventsFiltered:(NSDictionary *)eventsFiltered
{
    _eventsFiltered = eventsFiltered;
    self.eventDatesFiltered = [self sortedDaysFromKeys:[eventsFiltered allKeys]];
    [self.tableView reloadData];
}

// convert all NSString keys to NSDate, sort them and return them
- (NSArray*)sortedDaysFromKeys:(NSArray*)keys
{
    NSMutableArray *unsortedDays = [[NSMutableArray alloc] init];
    [self.sharedDateFormatter setDateFormat:@"yyyy-MM-dd"];
    for (NSString *key in keys) {
        NSDate *date = [self.sharedDateFormatter dateFromString:key];
        [unsortedDays addObject:date];
    }
    return [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
}

// helper method to easily retrieve an array of events for a particular day
- (NSArray*)eventsForSection:(NSInteger)section
{
    [self.sharedDateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (self.isFiltering) {
        return self.eventsFiltered[[self.sharedDateFormatter stringFromDate:self.eventDatesFiltered[section]]];
    } else {
        return self.events[[self.sharedDateFormatter stringFromDate:self.eventDates[section]]];
    }
}

// prepare new view controllers with data based on the clicked item
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            NSArray *eventsForDay = [self eventsForSection:indexPath.section];
            if ([segue.identifier isEqualToString:@"VenueMap"]) {
                if ([segue.destinationViewController isKindOfClass:[VenueMapVC class]]) {
                    VenueMapVC *vc = segue.destinationViewController;
                    vc.date = [self tableView:self.tableView titleForHeaderInSection:indexPath.section];
                    vc.events = eventsForDay;
                }
            }            
            if ([segue.identifier isEqualToString:@"Details"]) {
                if ([segue.destinationViewController isKindOfClass:[DetailsTVC class]]) {
                    Event *event = eventsForDay[indexPath.row];
                    DetailsTVC *vc = segue.destinationViewController;                    
                    vc.event = event;
                }
            }
        }
    }
}

#pragma mark - Filter bar

// hide keyboard
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

// hide keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

// research if scope has changed
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    self.filterScope = selectedScope;
    [self search:searchBar.text];
}

#define SCOPE_ARTIST 0
#define SCOPE_VENUE 1

// search when text changes
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self search:searchBar.text];
}

// search artist or venue based on the scope
// isFiltering is changed based on the length of the search text
- (void)search:(NSString*)searchText
{
    if (searchText.length != 0) {
        self.isFiltering = YES;
        
        NSMutableDictionary *filtered = [[NSMutableDictionary alloc] init];
        
        for (NSString *date in [self.events allKeys]) {
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (Event *event in [self.events objectForKey:date]) {
                NSRange range;
                if (self.filterScope == SCOPE_ARTIST) {
                    range = [event.mainArtist rangeOfString:searchText options:NSCaseInsensitiveSearch];
                } else {
                    range = [event.venue.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
                }
                if (range.location != NSNotFound) {
                    [events addObject:event];
                }
            }
            if ([events count] > 0) {
                [filtered setValue:events forKey:date];
            }
        }
        self.eventsFiltered = filtered;
    } else {
        self.isFiltering = NO;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.isFiltering) ? [self.eventsFiltered count] :[self.events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *eventsForDay = [self eventsForSection:section];
    return [eventsForDay count] + 1;
}

// decide whether two dates are equal
- (BOOL)dateIsEqual: (NSDate*)firstDate otherDate:(NSDate*)secondDate
{
	NSDateComponents *components1 = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
	NSDateComponents *components2 = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:secondDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

#define ONE_DAY 60*60*24

// show Today, Tomorrow or the date of the section as title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *date = (self.isFiltering) ? self.eventDatesFiltered[section] : self.eventDates[section];
    
    if ([self dateIsEqual:[NSDate date] otherDate:date]) {
        return @"Today";
    } else if ([self dateIsEqual:[[NSDate date] dateByAddingTimeInterval:ONE_DAY] otherDate:date]) {
        return @"Tomorrow";
    } else {
        [self.sharedDateFormatter setDateFormat:@"EEEE d MMMM"];
        return [self.sharedDateFormatter stringFromDate:date];    
    }
}

// if the row is the last one, show the "Show map..." cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSArray *eventsForDay = [self eventsForSection:indexPath.section];
    if ([eventsForDay count] == indexPath.row) {
        static NSString *eventId = @"Map";
        cell = [tableView dequeueReusableCellWithIdentifier:eventId forIndexPath:indexPath];
    } else {
        static NSString *eventId = @"Event";
        cell = [tableView dequeueReusableCellWithIdentifier:eventId forIndexPath:indexPath];
        
        Event *event = eventsForDay[indexPath.row];
        
        cell.textLabel.text = event.title;
        cell.detailTextLabel.text = event.subtitle;
    }
    
    return cell;
}

// custom view for section titles
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    [aView setBackgroundColor:[UIColor whiteColor]];
    UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, aView.frame.size.width, aView.frame.size.height)];
    header.text = [self tableView:tableView titleForHeaderInSection:section];
    header.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [aView addSubview:header];
    return aView;
}

// load even more events when the bottom of the table view has been reached
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isFiltering && !self.hasReachedEnd && indexPath.section == [self.eventDates count] - 1) {
        NSArray *eventsForDay = [self eventsForSection:indexPath.section];
        if(indexPath.row == [eventsForDay count] - 1) {
            [self asyncLoadEvents];
        }
    }
}

// 20 events are loaded on each request
// the SongkickFetcher method will merge the new events loaded into the existing events
// if the number of events is the same we conclude that no new events has been loaded
// and we set hasReachedEnd to YES, meaning it will stop requesting more events when
// we reach the bottom
// if we retrieved new events we increment the currentPage to be used in the next request
- (void)asyncLoadEvents
{
    dispatch_queue_t loaderQ = dispatch_queue_create("eventsLoader", NULL);
    dispatch_async(loaderQ, ^{
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        NSDictionary* newEvents = [SongkickFetcher getEventsByMetroID:self.lastLocation.metroID page:self.currentPage existingEvents:self.events];
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        if ([newEvents count] == [self.events count]) {
            self.hasReachedEnd = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        } else {
            self.currentPage++;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.events = newEvents;
                [self.refreshControl endRefreshing];
            });
        }
    });
}

@end
