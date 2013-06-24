//
//  LastFMArtist.m
//  DiscoverLiveMusic
//
//  Created by Jakob Jakobsen Boysen on 06/05/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "LastFMArtist.h"

@implementation LastFMArtist

- (NSURL*)imageLargeURL
{
    NSArray *sizes = [self.artist objectForKey:@"image"];
    NSString *imageUrl;
    for (NSDictionary *size in sizes) {
        if ([[size objectForKey:@"size"] isEqual:@"extralarge"]) {
            imageUrl = [size objectForKey:@"#text"];
        }
    }
    return [NSURL URLWithString:imageUrl];
}

- (NSString*)description
{
    NSString *html = [self.artist valueForKeyPath:@"bio.content"];
    return (html) ? [self stringByStrippingHTML:html] : nil;
}

// clean up the result from last.fm
-(NSString *)stringByStrippingHTML:(NSString*)html
{
    NSRange range;
    
    while ((range = [html rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        html = [html stringByReplacingCharactersInRange:range withString:@""];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@" +" withString:@" "
                                             options:NSRegularExpressionSearch
                                               range:NSMakeRange(0, html.length)];
    html = [html stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
    html = [html stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return html;
}

@end
