//
//  LocationViewController.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 28/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "LocationVC.h"

@interface LocationVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LocationVC

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// reload the table and stop the spinner
-(void)setLocations:(NSArray *)locations
{
    _locations = locations;
    [self.tableView reloadData];
    [self.progressIndicator stopAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locations count];
}

- (NSString *)titleForRow:(NSUInteger)row
{
    Location *location = self.locations[row];
    return location.fullName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    
    return cell;
}

// dismiss this vc and set the location on the previous vc
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate setLocation:self.locations[indexPath.row]];    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
