//
//  Details.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 03/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "DetailsHeader.h"
#import "DLMAppDelegate.h"

@interface DetailsHeader()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoader;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *noImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end

@implementation DetailsHeader

#define HEADER_HEIGHT 182

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.contentView];
}

#define PADDING 10

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = HEADER_HEIGHT;
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"DetailsHeader" owner:self options:nil];
        [self.contentView setFrame:CGRectMake(PADDING, PADDING, frame.size.width-PADDING*2, frame.size.height-PADDING)];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)setEvent:(Event *)event
{
    _event = event;
    self.artistLabel.text = self.event.mainArtist;
    [self formatFavoriteButton];
}

- (void)setImageData:(NSData *)imageData
{
    if (imageData) {
        [self.imageView setImage:[self scaleImageWithData:imageData]];
        self.imageView.hidden = NO;
        self.imageView.backgroundColor = [UIColor clearColor];
    } else {
        self.noImageLabel.hidden = NO;
    }
    [self.imageLoader stopAnimating];
}

// create an image an scale it down to save memory
- (UIImage*)scaleImageWithData:(NSData*)data
{
    UIImage *image = [UIImage imageWithData:data];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat scale = self.imageView.frame.size.width / width;
    if (scale > self.imageView.frame.size.height / height)
        scale = self.imageView.frame.size.height / height;
    CGSize newSize = CGSizeMake(width*scale, height*scale);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Favorite

- (IBAction)favorite
{
    [self.delegate favorite];
    [self formatFavoriteButton];
}

- (void)formatFavoriteButton
{
    [self.favoriteButton setImage:[UIImage imageNamed: (self.event.isFavorite) ? @"starred" : @"star"] forState:UIControlStateNormal];
}

#pragma mark - Share

- (IBAction)share
{
    [self.delegate share];
}

#pragma mark - Set reminder

- (IBAction)remind
{
    [self.delegate remind];
}

@end
