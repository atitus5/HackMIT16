//
//  SCRVideoTranscriber.h
//  Scrub
//
//  Created by Andrew Titus on 9/18/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCRVideoTranscriber : NSObject

- (NSArray<NSURL *> *)transcribeVideoAtURL:(NSURL *)assetURL;

+ (instancetype)sharedInstance;

@end
