//
//  SCRViewController.m
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "SCRViewController.h"
#import "SCRXMLReader.h"

@interface SCRViewController ()

@end

@implementation SCRViewController

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
    NSString *phrase = @"that";
    NSString *videoId = @"zGb9smintY0";
    NSString *urlString = [NSString stringWithFormat:@"https://www.youtube.com/api/timedtext?&lang=en&v=%@", videoId];

    NSDictionary *dictionary = getXMLDict(urlString);
    
    //NSLog(@"%@", dictionary);
    
    // Change dict to form: {time1:value1, tiem2:value2}
    NSDictionary *formattedDictionary = formatYoutubeCaptionDict(dictionary);
    
    NSLog(@"formatted dict= %@", formattedDictionary);
    
    NSArray *timesArray = getTimesOfPhrase(formattedDictionary, phrase);
    
    NSLog(@"%@", timesArray);
}

/**
 * @return:
 */
NSDictionary* getXMLDict(NSString* urlString) {
    NSURL *URL = [NSURL URLWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    
    return [SCRXMLReader dictionaryForXMLData:data];
}

/**
 * @return: dictionary of the form {time1:value1, tiem2:value2, ...}
 */
NSDictionary* formatYoutubeCaptionDict(NSDictionary* dictionary) {
    NSMutableDictionary* formattedDict = [NSMutableDictionary dictionaryWithDictionary:@{}];
    // dictionary = {"transcript: <Dict>"}
    
    // {"text": <Array>}
    NSMutableDictionary* textDict = dictionary[@"transcript"];
    
    // [<Set>, <Set>, ...]
    NSMutableArray* captionSetsArray = textDict[@"text"];
    
    // Iterate through the list:
    //  captionSet = {"start":"0", "dur":"3.22", "text":"I said a thing"}
    for (NSMutableDictionary* captionSet in captionSetsArray) {
        NSString* time = captionSet[@"start"];
        NSString* text = captionSet[@"text"];
        formattedDict[time] = text;
    }
    
    return formattedDict;
}

/**
 * @param dictionary : of the form {"0":"hi", "1.5":"welcome"} where the numbers are times
 *                      in seconds and the strings are the dialouge during that time
 * @param phrase : a phrase to be matched in the dictionary values
 * @return: list of times where phrase appeared. Case insensitive search
 */
NSMutableArray* getTimesOfPhrase(NSDictionary* dictionary, NSString* phrase) {
    phrase = [phrase lowercaseString];
    NSMutableArray *times = [NSMutableArray array];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL* stop) {
        if ([[value lowercaseString] rangeOfString:phrase].location == NSNotFound) {
        } else {
            [times addObject:key];
        }
    }];
    
    return times;
}


@end
