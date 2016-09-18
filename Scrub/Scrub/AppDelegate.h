//
//  AppDelegate.h
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BG_R (77.0/256.0)
#define BG_G (179.0/256.0)
#define BG_B (230.0/256.0)
#define SELECTED_ALPHA 0.5
#define INDICATOR_SIZE 40.0

extern NSString * const kScrubFont;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

