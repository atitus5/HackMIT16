//
//  ViewController.m
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "ViewController.h"
#import "SCRXMLReader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGPoint size = {100.0, 50.0};
    CGPoint origin = {([UIScreen mainScreen].bounds.size.width - size.x) / 2.0, ([UIScreen mainScreen].bounds.size.height - size.y) / 2.0};
    
    _theButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_theButton setFrame:CGRectMake(origin.x, origin.y, size.x, size.y)];
    [_theButton setTitle:@"SCRUB" forState:UIControlStateNormal];
    //[_theButton setBackgroundColor:[UIColor redColor]];
    //[_theButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_theButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:_theButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public

- (void)buttonPressed:(UIButton *) button {
    NSURL *URL = [NSURL URLWithString:@"https://www.youtube.com/api/timedtext?&lang=en&v=zGb9smintY0"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    NSError *error = nil;
    
    NSDictionary *dictionary = [SCRXMLReader dictionaryForXMLData:data error:&error];
    NSLog(dictionary);
}


@end
