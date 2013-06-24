//
//  DetailsTVC.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "DetailsTVC.h"
#import "DetailsHeader.h"
#import "DetailsFooter.h"
#import "LastFMFetcher.h"
#import "DLMAppDelegate.h"
#import "WebVC.h"
#import "DescriptionTableCell.h"
#import "SongkickVenue.h"
#import "SongkickFetcher.h"
#import "LoaderCell.h"
#import "Favorites.h"

@interface DetailsTVC () <EKEventEditViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) DetailsHeader *header; // lazy loaded view
@property (nonatomic, strong) DetailsFooter *footer; // lazy loaded view
@property (nonatomic) float loadingPercent; // used to determine how much of the loading bar to show

@property (nonatomic, strong) EKEventStore *eventStore; // used to create calendar entries

@property (nonatomic, strong) MKUserLocation *userLocation; // used to calculate the distance from current position to venue

@end

@implementation DetailsTVC

#define SECTION_DETAILS 0
#define SECTION_DESCRIPTION 1
#define SECTION_SEARCH 2
#define SECTION_LOCATION 3

#define DETAILS_ROW_DATE_TIME 0
#define DETAILS_ROW_SUPPORT_ARTIST 1

#define LOCATION_ROW_VENUE 0
#define LOCATION_ROW_ADDRESS1 1
#define LOCATION_ROW_ADDRESS2 2
#define LOCATION_ROW_DISTANCE 3

- (DetailsHeader*)header
{
    if (!_header) _header = [[DetailsHeader alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    return _header;
}

- (DetailsFooter*)footer
{
    if (!_footer) _footer = [[DetailsFooter alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    return _footer;
}

// update the distance row when user location is updated
- (void)setUserLocation:(MKUserLocation *)userLocation
{
    _userLocation = userLocation;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_LOCATION] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// reload the table view each time the percent loaded is updated
- (void)setLoadingPercent:(float)loadingPercent
{
    _loadingPercent = loadingPercent;
    [self.tableView reloadData];
}

// helper method
- (BOOL)finishLoading
{
    return (self.loadingPercent == 1);
}

#pragma mark - Setup code

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![self finishLoading]) { // load everything if first time
        self.loadingPercent = 0.0f;
        if (self.eventID) {
            [self loadEvent];
        } else if (self.event) {
            [self eventLoaded];
        } else {
            [self eventGone];
        }
    } else { // else reload the header and footer
        [self allLoaded];
    }
}

// load event based on id
// currently only used for segues from the home page
- (void)loadEvent
{
    dispatch_queue_t loaderQ = dispatch_queue_create("eventLoader", NULL);
    dispatch_async(loaderQ, ^{
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        Event* event = [SongkickFetcher getEventByID:self.eventID];
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        self.event = event;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.event.eventID == self.eventID) {
                [self eventLoaded];
            } else {
                [self eventGone];
            }
        });
    });
}

- (void)eventLoaded
{
    self.loadingPercent = 0.25f;
    [self queryLastFM];
}

#define GONE_TITLE @"Event gone"
#define GONE_CONTENT @"The favorited event has been deleted from the server. The event is automatically removed from your favorites."
#define GONE_BUTTON @"OK"

// if an event could not be found, remove it and return to previous vc
- (void)eventGone
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:GONE_TITLE message:GONE_CONTENT delegate:self cancelButtonTitle:nil otherButtonTitles:GONE_BUTTON, nil];
    [alert show];
    [Favorites removeWithId:self.eventID];
    [self.navigationController popViewControllerAnimated:YES];
}

// query last.fm for artist details
- (void)queryLastFM
{
    dispatch_queue_t loaderQ = dispatch_queue_create("lastfmLoader", NULL);
    dispatch_async(loaderQ, ^{
        if (!self.event.artist) {
            [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
            Artist* artist = [LastFMFetcher getArtist:self.event.mainArtist];
            [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
            self.event.artist = artist;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadImage];
        });
    });
}

// load the image from the url from last.fm
- (void)loadImage
{
    self.loadingPercent = 0.5f;
    dispatch_queue_t loaderQ = dispatch_queue_create("imageLoader", NULL);
    dispatch_async(loaderQ, ^{
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        NSData *imageData = [NSData dataWithContentsOfURL:self.event.artist.imageLargeURL];
        [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.header.imageData = imageData;
            [self loadVenue];
        });
    });
}

// additional venue details loaded from Songkick.com
- (void)loadVenue
{
    self.loadingPercent = 0.75f;
    if (self.event.venue.venueID && ![self.event.venue isKindOfClass:[SongkickVenue class]]) {
        dispatch_queue_t loaderQ = dispatch_queue_create("venueLoader", NULL);
        dispatch_async(loaderQ, ^{
            [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
            SongkickVenue* venue = [SongkickFetcher getVenueByID:self.event.venue.venueID];
            [(DLMAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
            self.event.venue = venue;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self allLoaded];
            });
        });
    } else {
        [self allLoaded];
    }
}

// at last load the header and footer
- (void)allLoaded
{
    self.loadingPercent = 0.99f;
    [self setTableHeader];
    [self setTableFooter];
    self.loadingPercent = 1;
}

// set the event and delegate on header
- (void)setTableHeader
{
    self.header.event = self.event;
    self.header.delegate = self;
    self.tableView.tableHeaderView = self.header;
}

// set the event and delegate on footer
- (void)setTableFooter
{
    self.footer.event = self.event;
    self.footer.delegate = self;
    self.tableView.tableFooterView = self.footer;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![self finishLoading]) {
        return 1;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![self finishLoading]) {
        return 1;
    }
    switch (section) {
        case SECTION_DETAILS:
            return 1 + [[self.event supportArtists] count];
        case SECTION_SEARCH:
        case SECTION_DESCRIPTION:
            return 1;
        case SECTION_LOCATION:
            if (self.event.coordinate.latitude != 0.0) {
                return LOCATION_ROW_DISTANCE + 1;
            } else if ([self.event.venue isKindOfClass:[SongkickVenue class]] && self.event.venue.address1) {
                return LOCATION_ROW_ADDRESS2 + 1;
            } else {
                return LOCATION_ROW_VENUE + 1;
            }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (![self finishLoading]) {
        static NSString *loader = @"Loader";
        cell = [tableView dequeueReusableCellWithIdentifier:loader forIndexPath:indexPath];
        if ([cell isKindOfClass:[LoaderCell class]]) {
            ((LoaderCell*)cell).loadingPercent = self.loadingPercent;
            // remove the background on the loader cell
            cell.backgroundView = [[UIView alloc] init];
            cell.backgroundColor = [UIColor clearColor];
        }
    } else if (indexPath.section == SECTION_DETAILS || indexPath.section == SECTION_LOCATION) {
        cell = [self formatCell:tableView forIndexPath:indexPath];
    } else if (indexPath.section == SECTION_DESCRIPTION) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];
        if ([cell isKindOfClass:[DescriptionTableCell class]]) {
            ((DescriptionTableCell*)cell).descriptionText = self.event.artist.description;
        }
    } else if (indexPath.section == SECTION_SEARCH) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Youtube" forIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell*)formatCell:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath
{
    static NSString *detailId = @"Detail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailId forIndexPath:indexPath];
    
    if (indexPath.section == SECTION_LOCATION) {
        cell = [self formatLocationCell:cell forRow:indexPath.row];
    } else {
        cell = [self formatDetailCell:cell forRow:indexPath.row];
    }
    
    return cell;
}

- (UITableViewCell*)formatDetailCell:(UITableViewCell*)cell forRow:(NSInteger)row
{
    if (row == DETAILS_ROW_DATE_TIME) {
        cell.textLabel.text = @"Time";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.event.dateFormatted, self.event.timeFormatted];
    } else if (row >= DETAILS_ROW_SUPPORT_ARTIST) {
        int support = row - DETAILS_ROW_SUPPORT_ARTIST;
        cell.textLabel.text = [NSString stringWithFormat:@"Support %d", support + 1];
        cell.detailTextLabel.text = self.event.supportArtists[support];
    }
    
    return cell;
}

- (UITableViewCell*)formatLocationCell:(UITableViewCell*)cell forRow:(NSInteger)row
{
    if (row == LOCATION_ROW_VENUE) {
        cell.textLabel.text = @"Venue";
        cell.detailTextLabel.text = self.event.venue.name;
    } else if (row == LOCATION_ROW_ADDRESS1) {
        cell.textLabel.text = @"Street";
        cell.detailTextLabel.text = self.event.venue.address1;
    } else if (row == LOCATION_ROW_ADDRESS2) {
        cell.textLabel.text = @"Zip";
        cell.detailTextLabel.text = self.event.venue.address2;
    } else if (row == LOCATION_ROW_DISTANCE) {
        cell.textLabel.text = @"Distance";
        cell.detailTextLabel.text = [self distance];
    }
    
    return cell;
}

#define DESCRIPTION_HEIGHT 130.0f
#define NO_DESCRIPTION_HEIGHT 48.0f

// custom heights for some of the cells 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self finishLoading]) {
        return self.tableView.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    }
    if (indexPath.section == SECTION_DESCRIPTION) {
        if (self.event.artist.description && ![self.event.artist.description isEqualToString:@""]) {
            return DESCRIPTION_HEIGHT;
        } else {
            return NO_DESCRIPTION_HEIGHT;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#define YOUTUBE_SEARCH_URL @"http://m.youtube.com/results?q=%@"

// prepare the web vc for a youtube search
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Youtube"]) {
        WebVC *vc = segue.destinationViewController;
        NSString *urlString = [NSString stringWithFormat:YOUTUBE_SEARCH_URL, self.event.mainArtist];
        vc.url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
}

// distance is shown with an accuracy of 100m
- (NSString*)distance
{
    if (self.userLocation) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.event.coordinate.latitude longitude:self.event.coordinate.longitude];
        CLLocationDistance distance = [self.userLocation.location distanceFromLocation:loc];

        double rounded = round(distance / 10) * 10;
        
        if (rounded > 1000) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setRoundingMode: NSNumberFormatterRoundDown];
            [formatter setMaximumFractionDigits:2];
            return [NSString stringWithFormat:@"%@ km", [formatter stringFromNumber:[NSNumber numberWithDouble:rounded / 1000]]];
        } else {
            return [NSString stringWithFormat:@"%d m", (int)rounded];
        }
    }
    return @"N/A";
}

#pragma mark - Map annotations

// dont show the call out on the pin in this view
- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Event class]]) {
        static NSString *ident = @"Annotation";
        MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:ident];
        if (!aView) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        }
        aView.annotation = annotation;
        aView.canShowCallout = NO;
        return aView;
    } else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        self.userLocation = (MKUserLocation*)annotation;
    }
    return nil;
}

#pragma mark - Reminders

// show the native new calendar entry vc
- (void)remind
{
    EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
    evc.eventStore = self.eventStore;
    evc.event = [self getEKEvent];
    evc.editViewDelegate = self;
    if([self.eventStore respondsToSelector: @selector(requestAccessToEntityType:completion:)]) {
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:evc animated:YES completion:^(void){}];
                });
            }
        }];
    }
}

// lazy load the event store used to save the calendar entry
- (EKEventStore*)eventStore
{
    if (!_eventStore) _eventStore = [[EKEventStore alloc] init];
    return _eventStore;
}

// create a calendar entry with some default input
- (EKEvent*)getEKEvent
{
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = self.event.title;
    event.location = self.event.venue.name;
    event.startDate = self.event.dateTime;
    if (self.event.hasTime) {
        event.endDate = [self.event.dateTime dateByAddingTimeInterval:60*60*2];
    } else {
        event.endDate = self.event.dateTime;
        event.allDay = YES;
    }
    event.URL = self.event.url;
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:-60*60*24]];
    return event;
}

// if event was saved, save it to the event store and dismiss the vc
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    if (action == EKEventEditViewActionSaved) {
        [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:nil];
    }
    
    [controller dismissViewControllerAnimated:YES completion:^(void) {}];
}

#pragma mark - Share

#define MAIL_SUBJECT @"%@ at %@"
#define MAIL_BODY @"Have you seen %@ is playing at %@, %@ %@?\n\nWant to go?"

// show the default create mail vc
- (void)share
{
    MFMailComposeViewController *mailvc = [[MFMailComposeViewController alloc] init];
    mailvc.mailComposeDelegate = self;
    [mailvc setSubject:[NSString stringWithFormat:MAIL_SUBJECT, self.event.mainArtist, self.event.venue.name]];
    [mailvc setMessageBody:[NSString stringWithFormat:MAIL_BODY, self.event.mainArtist, self.event.venue.name, self.event.dateFormatted, self.event.timeFormatted] isHTML:NO];
    [self presentViewController:mailvc animated:YES completion:^(void){}];
}

// delegate method when the user wants to exit the mail controller
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *info;
    switch (result)
    {
        case MFMailComposeResultSaved:
            info = @"No email sent, message saved to draft";
            break;
        case MFMailComposeResultSent:
            info = @"Email sent";
            break;
        case MFMailComposeResultCancelled:
        case MFMailComposeResultFailed:
        default:
            info = @"No email sent";
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail info" message:info delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [controller dismissViewControllerAnimated:YES completion:^(void) {}];
}

#pragma mark - Favorite

- (void)favorite
{
    self.event.isFavorite = ![Favorites contains:self.event];
}

#pragma mark - Cleanup code

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // make sure to cut references in the header and footer, so they are able to release them selves
    self.header.delegate = nil;    
    self.footer.delegate = nil;
}


@end
