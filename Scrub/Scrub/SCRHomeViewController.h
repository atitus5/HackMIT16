//
//  SCRHomeViewController.h
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol SCRViewControllerDismissalDelegate <NSObject>

- (void)viewControllerWillDismiss:(UIViewController *)vc;

@end

@interface SCRHomeViewController : UIViewController

@end

