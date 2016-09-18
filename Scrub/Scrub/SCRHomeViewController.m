//
//  SCRHomeViewController.m
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCRHomeViewController.h"
#import "SCRXMLReader.h"

#define MARGIN 30.0
#define WELCOME_LABEL_FONTSIZE 37.0
#define INSTRUCTION_LABEL_FONTSIZE 25.0
#define FIELD_FONTSIZE 20.0
#define BUTTON_RADIUS 75.0
#define BUTTON_FONTSIZE 40.0
#define SELECTED_ALPHA 0.7

static NSString *kScrubFont = @"BreeSerif-Regular";

@interface SCRHomeViewController () <UITextFieldDelegate>

@end

@implementation SCRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Force status bar style update
    [self setNeedsStatusBarAppearanceUpdate];
    
    CGFloat widthInsideMargins = [[UIScreen mainScreen] bounds].size.width - (2.0 * MARGIN);
    CGFloat heightInsideMargins = [[UIScreen mainScreen] bounds].size.height - (2.0 * MARGIN);
    
    // Set up welcome label and instruction label in top third of screen
    CGRect welcomeLabelFrame = CGRectMake(MARGIN, MARGIN, widthInsideMargins, heightInsideMargins / 6.0);
    _welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelFrame];
    [_welcomeLabel setText:@"Welcome to Scrub!"];
    [_welcomeLabel setFont:[UIFont fontWithName:kScrubFont size:WELCOME_LABEL_FONTSIZE]];
    [_welcomeLabel setTextColor:[UIColor whiteColor]];
    [_welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [_welcomeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_welcomeLabel setNumberOfLines:-1]; // Unlimited lines
    [[self view] addSubview:_welcomeLabel];
    
    CGRect instructionLabelFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 6.0), widthInsideMargins, heightInsideMargins / 6.0);
    _instructionLabel = [[UILabel alloc] initWithFrame:instructionLabelFrame];
    [_instructionLabel setText:@"Search YouTube by dialogue content with ease!"];
    [_instructionLabel setFont:[UIFont fontWithName:kScrubFont size:INSTRUCTION_LABEL_FONTSIZE]];
    [_instructionLabel setTextColor:[UIColor whiteColor]];
    [_instructionLabel setTextAlignment:NSTextAlignmentCenter];
    [_instructionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_instructionLabel setNumberOfLines:-1]; // Unlimited lines
    [[self view] addSubview:_instructionLabel];
    
    // Set up phrase and URL fields in middle third of screen
    CGRect phraseLabelFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 3.0), widthInsideMargins, heightInsideMargins / 12.0);
    _phraseLabel = [[UILabel alloc] initWithFrame:phraseLabelFrame];
    [_phraseLabel setText:@"Phrase"];
    [_phraseLabel setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
    [_phraseLabel setTextColor:[UIColor whiteColor]];
    [_phraseLabel setTextAlignment:NSTextAlignmentCenter];
    [_phraseLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_phraseLabel setNumberOfLines:-1]; // Unlimited lines
    [[self view] addSubview:_phraseLabel];
    
    CGRect phraseFieldFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 3.0) + phraseLabelFrame.size.height, widthInsideMargins, heightInsideMargins / 12.0);
    _phraseField = [[UITextField alloc] initWithFrame:phraseFieldFrame];
    [_phraseField setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
    [_phraseField setTextColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0]];
    [_phraseField setBackgroundColor:[UIColor whiteColor]];
    [_phraseField setBorderStyle:UITextBorderStyleRoundedRect];
    [_phraseField setPlaceholder:@"Enter a phrase"];
    [_phraseField setDelegate:self];
    [[self view] addSubview:_phraseField];
    
    CGRect urlLabelFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 2.0), widthInsideMargins, heightInsideMargins / 12.0);
    _urlLabel = [[UILabel alloc] initWithFrame:urlLabelFrame];
    [_urlLabel setText:@"YouTube URL"];
    [_urlLabel setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
    [_urlLabel setTextColor:[UIColor whiteColor]];
    [_urlLabel setTextAlignment:NSTextAlignmentCenter];
    [_urlLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_urlLabel setNumberOfLines:-1]; // Unlimited lines
    [[self view] addSubview:_urlLabel];
    
    CGRect urlFieldFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 2.0) + urlLabelFrame.size.height, widthInsideMargins, heightInsideMargins / 12.0);
    _urlField = [[UITextField alloc] initWithFrame:urlFieldFrame];
    [_urlField setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
    [_urlField setTextColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0]];
    [_urlField setBackgroundColor:[UIColor whiteColor]];
    [_urlField setBorderStyle:UITextBorderStyleRoundedRect];
    [_urlField setPlaceholder:@"Enter a YouTube URL"];
    [_urlField setDelegate:self];
    [[self view] addSubview:_urlField];
    
    // Put the "Scrub" button in the bottom third of the screen (ignoring bottom margin - looks weird otherwise)
    _scrubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_scrubButton setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2.0) - BUTTON_RADIUS, ([[UIScreen mainScreen] bounds].size.height * (5.0 / 6.0)) - BUTTON_RADIUS, 2.0 * BUTTON_RADIUS, 2.0 * BUTTON_RADIUS)];
    [_scrubButton setTitle:@"SCRUB" forState:UIControlStateNormal];
    [[_scrubButton titleLabel] setFont:[UIFont fontWithName:kScrubFont size:BUTTON_FONTSIZE]];
    [_scrubButton setBackgroundColor:[UIColor whiteColor]];
    [_scrubButton setTitleColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0] forState:UIControlStateNormal];
    [_scrubButton setTitleColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:SELECTED_ALPHA] forState:UIControlStateSelected];
    [[_scrubButton layer] setCornerRadius:BUTTON_RADIUS];
    [_scrubButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_scrubButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITextFieldDelegate



#pragma mark - Public

- (void)buttonPressed:(UIButton *) button {
    NSString *videoId = @"zGb9smintY0";
    NSString *urlString = [NSString stringWithFormat:@"https://www.youtube.com/api/timedtext?&lang=en&v=%@", videoId];

    NSDictionary *dictionary = getXMLDict(urlString);
    
    //NSLog(@"%@", dictionary);
    
    // Change dict to form: {time1:value1, tiem2:value2}
    NSDictionary *formattedDictionary = formatYoutubeCaptionDict(dictionary);
    
    NSLog(@"formatted dict= %@", formattedDictionary);
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
 * @return: dictionary of the form {time1:value1, time2:value2, ...}
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

NSMutableArray* getTimesOfPhrase(NSDictionary* dictionary, NSString* phrase) {
    NSMutableArray *times = [NSMutableArray array];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL* stop) {
        
        if ([value rangeOfString:phrase].location == NSNotFound) {
        } else {
            [times addObject:key];
        }
        
    }];
    
    return times;
}


@end
