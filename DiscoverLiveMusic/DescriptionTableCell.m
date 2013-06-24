//
//  DescriptionTableCell.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 09/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "DescriptionTableCell.h"

@interface DescriptionTableCell()

@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UILabel *noDescriptionLabel;

@end

@implementation DescriptionTableCell

- (void)setDescriptionText:(NSString *)descriptionText
{
    _descriptionText = descriptionText;
    if (descriptionText && ![descriptionText isEqualToString:@""]) {
        self.descriptionView.text = descriptionText;
        self.descriptionView.hidden = NO;
    } else {
        self.noDescriptionLabel.hidden = NO;
    }
}

@end
