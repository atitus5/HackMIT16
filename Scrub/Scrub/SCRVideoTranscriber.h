//
//  SCRVideoTranscriber.h
//  Scrub
//
//  Created by Andrew Titus on 9/18/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCRVideoTranscriber : NSObject

- (void)transcribeVideoAtURL:(NSURL *)assetURL substringsResult:(NSArray<NSString *> **)substrings timestampsResult:(NSArray<NSNumber *> **)timestamps;

+ (instancetype)sharedInstance;

@end
