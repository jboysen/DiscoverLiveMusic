//
//  DLMViewController.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 26/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "DLMViewController.h"
#import "DLMAppDelegate.h"
#import "LocationVC.h"
#import "CurrentLocation.h"
#import "Favorites.h"
#import "Event.h"
#import "DetailsTVC.h"
#import "SongkickFetcher.h"

@interface DLMViewController ()

@property (strong, nonatomic) NSArray *favorites;
@property (strong, nonatomic) Location *location;

@end

@implementation DLMViewController

#define SECTION_TOP 0
#define SECTION_FAVORITES 1

// reload the favorites section everytime it is reset
- (void)setFavorites:(NSArray *)favorites
{
    _favorites = favorites;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_FAVORITES] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// load the location based on the IP address (Songkick supports this)
- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self loadLocationFromIP];
}

// reload favorites everytime the view appears, as it could have changed
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.favorites = [Favorites all];
}

// set the extra data on the view controller segued to
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        if ([segue.identifier isEqualToString:@"Location"]) {
            if ([segue.destinationViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tbc = segue.destinationViewController;
                for (UIViewController *vc in tbc.viewControllers) {
                    if ([vc isKindOfClass:[LocationVC class]]) {
                        ((LocationVC*)vc).delegate = self;
                    }
                }
            }
        }
    } else if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            NSDictionary *tempEvent = self.favorites[indexPath.row];
            NSString *eventID = [tempEvent objectForKey:@"id"];
            if ([segue.identifier isEqualToString:@"Details"]) {
                if ([segue.destinationViewController isKindOfClass:[DetailsTVC class]]) {
                    DetailsTVC *vc = segue.destinationViewController;
                    vc.eventID = [eventID longLongValue];
                }
            }
        }
    }
}

// async fetch the location from Songkick
- (void)loadLocationFromIP
{
    dispatch_queue_t loaderQ = dispatch_queue_create("locationLoader", NULL);
    dispatch_async(loaderQ, ^{
        
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        Location* location = [SongkickFetcher getLocationByIP];
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.location = location;
        });
    });
}

// load the top part of the view when the location is set
-(void)setLocation:(Location*)location
{
    _location = location;
    [CurrentLocation set:location];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_TOP] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table

#define TOP_HEIGHT 123

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_TOP) {
        return TOP_HEIGHT;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_TOP) {
        return 1;
    }
    return ([self.favorites count] > 0) ? [self.favorites count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == SECTION_TOP) {
        static NSString *top = @"Top";
        cell = [self formatTopCell:[tableView dequeueReusableCellWithIdentifier:top forIndexPath:indexPath]];
    } else if (indexPath.section == SECTION_FAVORITES) {
        if ([self.favorites count] == 0) {
            static NSString *none = @"None";
            cell = [tableView dequeueReusableCellWithIdentifier:none forIndexPath:indexPath];
        } else {
            static NSString *eventId = @"Event";
            cell = [tableView dequeueReusableCellWithIdentifier:eventId forIndexPath:indexPath];
            NSDictionary *event = self.favorites[indexPath.row];
            cell.textLabel.text = [event objectForKey:@"title"];
            cell.detailTextLabel.text = [event objectForKey:@"subtitle"];
        }
    }
    
    return cell;
}

// format the UI elements of the top - retrieve them by tag
- (UITableViewCell*)formatTopCell:(UITableViewCell*)cell
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIView alloc] init];
    if (self.location) {
        UIButton *button = (UIButton*)[cell viewWithTag:1];
        UIActivityIndicatorView *loader = (UIActivityIndicatorView*)[cell viewWithTag:2];
        [button setTitle:self.location.fullName forState:UIControlStateNormal];
        [loader stopAnimating];
        button.hidden = NO;
    }
    return cell;
}

@end
