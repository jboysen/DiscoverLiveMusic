//
//  DetailsFooter.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "DetailsFooter.h"

@interface DetailsFooter() <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *mapNALabel;

@end

@implementation DetailsFooter

#define FOOTER_HEIGHT 169
#define FOOTER_HEIGHT_SMALL 31

#define MAP_ZOOM_FACTOR 0.01

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.contentView];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = FOOTER_HEIGHT;
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"DetailsFooter" owner:self options:nil];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)setDelegate:(DetailsTVC *)delegate
{
    _delegate = delegate;
    self.mapView.delegate = delegate;
    [self setupMap];
}

- (void)setupMap
{        
    if (self.event.coordinate.latitude != 0.0) {
        [self.mapView addAnnotation:self.event];
        self.mapView.hidden = NO;
        self.mapNALabel.hidden = YES;
        MKCoordinateRegion region = MKCoordinateRegionMake(self.event.coordinate, MKCoordinateSpanMake(MAP_ZOOM_FACTOR, MAP_ZOOM_FACTOR));
        [self.mapView setRegion:region];
        [self setFrame:CGRectMake(0, 0, self.frame.size.width, FOOTER_HEIGHT)];
    } else {
        self.mapView.hidden = YES;
        self.mapNALabel.hidden = NO;
        [self setFrame:CGRectMake(0, 0, self.frame.size.width, FOOTER_HEIGHT_SMALL)];
    }
}

@end
