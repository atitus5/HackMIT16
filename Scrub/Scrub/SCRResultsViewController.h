//
//  SCRResultsViewController.h
//  Scrub
//
//  Created by Andrew Titus on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCRHomeViewController.h"

@class SCRResultsViewController;

@interface SCRResultsViewController : UIViewController

- (instancetype)initWithDelegate:(id<SCRViewControllerDismissalDelegate>)delegate urlArray:(NSArray<NSString *> *)urlArray;

@end
