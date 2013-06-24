//
//  VenueMapVC.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 30/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "VenueMapVC.h"
#import "CurrentLocation.h"
#import "Event.h"
#import "DetailsTVC.h"

@interface VenueMapVC () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate> {
    CLLocationCoordinate2D topLeftCoord, bottomRightCoord; // used to determine the rectangle to zoom into
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property BOOL hasZoomed; // used to decide whether to rezoom again

@end

@implementation VenueMapVC

// reset the zooming when the events has been set
// this will make sure that the map isn't reset when a pin has been tapped
// and the back button is hit on the DetailsVC
- (void)setEvents:(NSArray *)events
{
    _events = events;
    self.hasZoomed = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addAnnotationsAndCalcVisibleArea];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self zoomMap];
}

// add events with venue coordinates
// and narrow down the rectangle to zoom into
- (void)addAnnotationsAndCalcVisibleArea
{
    topLeftCoord = CLLocationCoordinate2DMake(-90, 180);
    bottomRightCoord = CLLocationCoordinate2DMake(90, -180);
    
    for (Event *event in self.events) {
        CLLocationCoordinate2D coordinate = [event coordinate];
        if (coordinate.latitude != 0.0 && coordinate.longitude != 0.0) {
            [self.mapView addAnnotation:event];
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, coordinate.latitude);
        }
    }
}

#define ALERT_TITLE @"Coordinates missing"
#define ALERT_CONTENT @"Could not retrieve enough information about the venues for the events this day."
#define ALERT_BUTTON @"OK"

// if no annotations; show an alert
// else zoom into the calculated rectangle
- (void)zoomMap
{
    if (self.hasZoomed) return;
    if ([self.mapView.annotations count] <= 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ALERT_CONTENT delegate:self cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON, nil];
        [alert show];
        return;
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2;
    
    // add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2;
    
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
    self.hasZoomed = YES;
}

#pragma mark - Map annotations

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Event class]]) {
        static NSString *ident = @"Annotation";
        MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:ident];
        if (!aView) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ident];
        } else {
            aView.annotation = annotation;
        }        
        aView.canShowCallout = YES;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return aView;
    }
    return nil;
}

// when the disclosure button is clicked show the DetailsTVC
- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"Details" sender:aView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // set the event on the DetailsVC
    if ([segue.identifier isEqualToString:@"Details"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *aView = sender;
            if ([aView.annotation isKindOfClass:[Event class]]) {
                Event *event = aView.annotation;
                if ([segue.destinationViewController respondsToSelector:@selector(setEvent:)]) {
                    [segue.destinationViewController performSelector:@selector(setEvent:) withObject:event];
                }
            }

        }
    }
}

#pragma mark - Table view data source

// only one section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// date and location row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

// set the date to what was set from the previous vc
// set the location to the location chosen on the home screen
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Detail" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Date";
        cell.detailTextLabel.text = self.date;
    } else {
        cell.textLabel.text = @"Location";
        cell.detailTextLabel.text = [CurrentLocation get].fullName;
    }
    
    return cell;
}

@end
