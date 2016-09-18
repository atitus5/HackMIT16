//
//  SCRHomeViewController.h
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define BG_R (77.0/256.0)
#define BG_G (179.0/256.0)
#define BG_B (230.0/256.0)

@interface SCRHomeViewController : UIViewController

@property (nonatomic) UILabel *welcomeLabel;
@property (nonatomic) UILabel *instructionLabel;
@property (nonatomic) UILabel *phraseLabel;
@property (nonatomic) UITextField *phraseField;
@property (nonatomic) UILabel *urlLabel;
@property (nonatomic) UITextField *urlField;
@property (nonatomic) UIButton *scrubButton;

@end

