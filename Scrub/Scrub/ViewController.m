//
//  ViewController.m
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGPoint size = {600.0, 200.0};
    CGPoint origin = {([[self view] window].bounds.size.width - size.x) / 2.0, ([[self view] window].bounds.size.height - size.y) / 2.0};
    
    NSLog(@"%f %f", size.x, size.y);
    NSLog(@"%f %f", origin.x, origin.y);
    _theButton = [[UIButton alloc] initWithFrame:CGRectMake(origin.x, origin.y, size.x, size.y)];
    [_theButton setTitle:@"SCRUB" forState:UIControlStateNormal];
    [_theButton setBackgroundColor:[UIColor redColor]];
    [_theButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_theButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:_theButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public

- (void)buttonPressed:(UIButton *)sender {
    // IMPLEMENT MEEEEEE
}


@end
