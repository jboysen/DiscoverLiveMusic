//
//  LoaderCell.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 12/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "LoaderCell.h"

@interface LoaderCell()

@property (weak, nonatomic) IBOutlet UIProgressView *progessView;

@end

@implementation LoaderCell

- (void)setLoadingPercent:(float)loadingPercent
{
    _loadingPercent = loadingPercent;
    [self.progessView setProgress:loadingPercent animated:YES];
}

@end
