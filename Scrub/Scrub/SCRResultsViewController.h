//
//  SCRResultsViewController.h
//  Scrub
//
//  Created by Andrew Titus on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCRResultsViewController;

@protocol SCRResultsViewControllerDelegate <NSObject>

- (void)viewControllerWillDismiss:(SCRResultsViewController *)vc;

@end

@interface SCRResultsViewController : UIViewController

- (instancetype)initWithDelegate:(id<SCRResultsViewControllerDelegate>)delegate urlArray:(NSArray<NSString *> *)urlArray;

@end
