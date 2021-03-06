//
//  SCRHomeViewController.m
//  Scrub
//
//  Created by Yousef Alowayed on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

/*
 <div>Icons made by <a href="http://www.flaticon.com/authors/madebyoliver" title="Madebyoliver">Madebyoliver</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
 */

#import <QuartzCore/QuartzCore.h>

#import "SCRHomeViewController.h"

@import MobileCoreServices;

#import "AppDelegate.h"
#import "SCRResultsViewController.h"
#import "SCRVideoTranscriber.h"
#import "SCRXMLReader.h"

#define MARGIN 30.0
#define WELCOME_LABEL_FONTSIZE 37.0
#define INSTRUCTION_LABEL_FONTSIZE 25.0
#define FIELD_FONTSIZE 20.0
#define SCRUB_BUTTON_RADIUS 75.0
#define BUTTON_FONTSIZE 40.0
#define VIDEO_BUTTON_RADIUS 35.0

@interface SCRHomeViewController () <UITextFieldDelegate, SCRViewControllerDismissalDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UILabel *welcomeLabel;
@property (nonatomic) UILabel *instructionLabel;
@property (nonatomic) UILabel *phraseLabel;
@property (nonatomic) UITextField *phraseField;
@property (nonatomic) UILabel *urlLabel;
@property (nonatomic) UITextField *urlField;
@property (nonatomic) UIButton *scrubButton;
@property (nonatomic) UIButton *customVideoButton;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (nonatomic) dispatch_queue_t workQueue;

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
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelFrame];
        [_welcomeLabel setText:@"Welcome to Scrub!"];
        [_welcomeLabel setFont:[UIFont fontWithName:kScrubFont size:WELCOME_LABEL_FONTSIZE]];
        [_welcomeLabel setTextColor:[UIColor whiteColor]];
        [_welcomeLabel setTextAlignment:NSTextAlignmentCenter];
        [_welcomeLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_welcomeLabel setNumberOfLines:-1]; // Unlimited lines
        [[self view] addSubview:_welcomeLabel];
    } else {
        [_welcomeLabel setFrame:welcomeLabelFrame];
    }
    
    CGRect instructionLabelFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 6.0), widthInsideMargins, heightInsideMargins / 6.0);
    if (!_instructionLabel) {
        _instructionLabel = [[UILabel alloc] initWithFrame:instructionLabelFrame];
        [_instructionLabel setText:@"Search YouTube by dialogue content with ease!"];
        [_instructionLabel setFont:[UIFont fontWithName:kScrubFont size:INSTRUCTION_LABEL_FONTSIZE]];
        [_instructionLabel setTextColor:[UIColor whiteColor]];
        [_instructionLabel setTextAlignment:NSTextAlignmentCenter];
        [_instructionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_instructionLabel setNumberOfLines:-1]; // Unlimited lines
        [[self view] addSubview:_instructionLabel];
    } else {
        [_instructionLabel setFrame:instructionLabelFrame];
    }
    
    // Set up phrase and URL fields in middle third of screen
    CGRect phraseLabelFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 3.0), widthInsideMargins, heightInsideMargins / 12.0);
    if (!_phraseLabel) {
        _phraseLabel = [[UILabel alloc] initWithFrame:phraseLabelFrame];
        [_phraseLabel setText:@"Phrase"];
        [_phraseLabel setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
        [_phraseLabel setTextColor:[UIColor whiteColor]];
        [_phraseLabel setTextAlignment:NSTextAlignmentCenter];
        [_phraseLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_phraseLabel setNumberOfLines:-1]; // Unlimited lines
        [[self view] addSubview:_phraseLabel];
    } else {
        [_phraseLabel setFrame:phraseLabelFrame];
    }
    
    CGRect phraseFieldFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 3.0) + phraseLabelFrame.size.height, widthInsideMargins, heightInsideMargins / 12.0);
    if (!_phraseField) {
        _phraseField = [[UITextField alloc] initWithFrame:phraseFieldFrame];
        [_phraseField setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
        [_phraseField setTextColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0]];
        [_phraseField setBackgroundColor:[UIColor whiteColor]];
        [_phraseField setBorderStyle:UITextBorderStyleRoundedRect];
        [_phraseField setPlaceholder:@"Enter a phrase"];
        [_phraseField setKeyboardType:UIKeyboardTypeDefault];
        [_phraseField setReturnKeyType:UIReturnKeyDone];
        [_phraseField setDelegate:self];
        [[self view] addSubview:_phraseField];
    } else {
        [_phraseField setFrame:phraseFieldFrame];
    }
    
    CGRect urlLabelFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 2.0), widthInsideMargins, heightInsideMargins / 12.0);
    if (!_urlLabel) {
        _urlLabel = [[UILabel alloc] initWithFrame:urlLabelFrame];
        [_urlLabel setText:@"YouTube URL"];
        [_urlLabel setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
        [_urlLabel setTextColor:[UIColor whiteColor]];
        [_urlLabel setTextAlignment:NSTextAlignmentCenter];
        [_urlLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_urlLabel setNumberOfLines:-1]; // Unlimited lines
        [[self view] addSubview:_urlLabel];
    } else {
        [_urlLabel setFrame:urlLabelFrame];
    }
    
    CGRect urlFieldFrame = CGRectMake(MARGIN, MARGIN + (heightInsideMargins / 2.0) + urlLabelFrame.size.height, widthInsideMargins, heightInsideMargins / 12.0);
    if (!_urlField) {
        _urlField = [[UITextField alloc] initWithFrame:urlFieldFrame];
        [_urlField setFont:[UIFont fontWithName:kScrubFont size:FIELD_FONTSIZE]];
        [_urlField setTextColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0]];
        [_urlField setBackgroundColor:[UIColor whiteColor]];
        [_urlField setBorderStyle:UITextBorderStyleRoundedRect];
        [_urlField setPlaceholder:@"Enter a YouTube URL"];
        [_urlField setKeyboardType:UIKeyboardTypeURL];
        [_urlField setReturnKeyType:UIReturnKeyDone];
        [_urlField setDelegate:self];
        [[self view] addSubview:_urlField];
    } else {
        [_urlField setFrame:urlFieldFrame];
    }
    
    // Put the "Scrub" button in the bottom third of the screen (ignoring bottom margin - looks weird otherwise)
    if (!_scrubButton) {
        _scrubButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scrubButton setTitle:@"SCRUB" forState:UIControlStateNormal];
        [[_scrubButton titleLabel] setFont:[UIFont fontWithName:kScrubFont size:BUTTON_FONTSIZE]];
        [_scrubButton setBackgroundColor:[UIColor whiteColor]];
        [_scrubButton setTitleColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0] forState:UIControlStateNormal];
        [_scrubButton setTitleColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:SELECTED_ALPHA] forState:UIControlStateSelected];
        [[_scrubButton layer] setCornerRadius:SCRUB_BUTTON_RADIUS];
        [_scrubButton setShowsTouchWhenHighlighted:YES];
        [_scrubButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:_scrubButton];
    }
    [_scrubButton setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2.0) - SCRUB_BUTTON_RADIUS, ([[UIScreen mainScreen] bounds].size.height * (5.0 / 6.0)) - SCRUB_BUTTON_RADIUS, 2.0 * SCRUB_BUTTON_RADIUS, 2.0 * SCRUB_BUTTON_RADIUS)];
    
    // (Temporarily) put video upload button in bottom left
    BOOL sourceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL videosAvailable = [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:kUTTypeMovie];
    if (sourceAvailable && videosAvailable) {
        CGRect customVideoButtonFrame = CGRectMake(MARGIN, [_scrubButton frame].origin.y + ([_scrubButton frame].size.height / 2.0) - VIDEO_BUTTON_RADIUS, 2.0 * VIDEO_BUTTON_RADIUS, 2.0 * VIDEO_BUTTON_RADIUS);
        if (!_customVideoButton) {
            _customVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_customVideoButton setBackgroundColor:[UIColor whiteColor]];
            [_customVideoButton setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
            [[_customVideoButton layer] setCornerRadius:VIDEO_BUTTON_RADIUS];
            [_customVideoButton addTarget:self
                                   action:@selector(_selectVideo:)
                         forControlEvents:UIControlEventTouchUpInside];
            [[self view] addSubview:_customVideoButton];
        }
        [_customVideoButton setFrame:customVideoButtonFrame];
    }
    
    // Set up queue and activity indicator for network data fetching
    _workQueue = dispatch_queue_create("com.drewtitus.Scrub.workQueue", NULL);
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [[self view] addSubview:_indicator];
    }
    [_indicator setFrame:CGRectMake(0.0, 0.0, INDICATOR_SIZE, INDICATOR_SIZE)];
    [_indicator setCenter:[[self view] center]];
    [_indicator bringSubviewToFront:[self view]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SCRResultsViewControllerDelegate

- (void)viewControllerWillDismiss:(SCRResultsViewController *)vc {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *theVideo = [[info allValues] objectAtIndex:0];
    
    // Transcribe the video!
    [_indicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(_workQueue, ^{
        NSArray<NSString *> *substrings = [[NSArray alloc] init];
        NSArray<NSNumber *> *timestamps = [[NSArray alloc] init];
        [[SCRVideoTranscriber sharedInstance] transcribeVideoAtURL:theVideo substringsResult:&substrings timestampsResult:&timestamps];
        
        NSLog(@"%@", substrings);
        NSLog(@"%@", timestamps);
        
        [self _presentAlert:@"Audio transcription" message:[NSString stringWithFormat:@"Substrings: %@\nTimestamps: %@", substrings, timestamps]];
        
        [self->_indicator stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
}

#pragma mark - Private

- (void)_selectVideo:(UIButton *)button {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    [ipc setMediaTypes:@[[NSString stringWithFormat:@"%@", kUTTypeMovie]]];
    [ipc setDelegate:self];
    
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)_presentAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)_buttonPressed:(UIButton *) button {
    NSString *phrase = [_phraseField text];
    if ([phrase length] != 0) {
        NSURLComponents *youtubeURLComps = [[NSURLComponents alloc] initWithString:[_urlField text]];
        NSArray<NSURLQueryItem *> *youtubeQueryItems = [youtubeURLComps queryItems];
        NSString *videoId = nil;
        for (NSURLQueryItem *item in youtubeQueryItems) {
            if ([[item name] isEqualToString:@"v"]) {
                videoId = [item value];
                break;
            }
        }
        if (!videoId) {
            // May be a shortened mobile URL - get the video ID from the path
            // Example: https://youtu.be/uXt8qF2Zzfo -> /uXt8qF2Zzfo -> uXt8qF2Zzfo
            videoId = [[youtubeURLComps path] substringFromIndex:1];
        }
        
        if (videoId) {
            //NSString *captionUrlString = [NSString stringWithFormat:@"https://www.youtube.com/api/timedtext?lang=en&v=%@", videoId];
            NSString *captionUrlString = [NSString stringWithFormat:@"https://www.youtube.com/api/timedtext?lang=en&v=%@", videoId];
            
            // Start network fetch of XML caption data
            [_indicator startAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            dispatch_async(_workQueue, ^{
                NSDictionary *dictionary = _getXMLDict(captionUrlString);
                
                // Change dict to form: {time1:value1, tiem2:value2}
                NSDictionary *formattedDictionary = _formatYoutubeCaptionDict(dictionary);
                
                // Update UI - must be on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_indicator stopAnimating];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    if ([formattedDictionary count] != 0) {
                        // Get results!
                        NSArray *timesArray = _getTimesOfPhrase(formattedDictionary, phrase);
                        
                        if ([timesArray count] != 0) {
                            NSArray *youtubeUrlArray = _getYoutubeUrls(videoId, timesArray);
                            
                            //NSLog(@"%@", youtubeUrlArray);
                            
                            [self presentViewController:[[SCRResultsViewController alloc] initWithDelegate: self urlArray:youtubeUrlArray]
                                               animated:NO
                                             completion:nil];
                            
                            // Clear fields so that they we get a fresh interface upon return
                            [_phraseField setText:@""];
                            [_urlField setText:@""];
                        } else {
                            // Notify user of lack of results
                            [self _presentAlert:@"No results found"
                                        message:[NSString stringWithFormat:@"No dialogue data found for this URL and the phrase \"%@\". Please try a different URL and/or phrase.", phrase]];
                        }
                    } else {
                        // Notify user of lack of caption data... sigh...
                        [self _presentAlert:@"No dialogue data found"
                                    message:@"No dialogue data found for this URL. This could be due to copyright issues, sadly..."];
                    }
                });
            });
        } else {
            // Notify user of URL error
            [self _presentAlert:@"Enter YouTube URL" message:@"Please enter a YouTube URL"];
        }
    } else {
        // Notify user of phrase error
        [self _presentAlert:@"Enter a phrase"
                    message:@"Please enter a phrase (for example, \"There's always money in the banana stand\""];
    }
}

/**
 * @return:
 */
NSDictionary* _getXMLDict(NSString* urlString) {
    NSURL *URL = [NSURL URLWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    
    return [SCRXMLReader dictionaryForXMLData:data];
}

/**
 * @return: dictionary of the form {time1:value1, tiem2:value2, ...}
 */
NSDictionary* _formatYoutubeCaptionDict(NSDictionary* dictionary) {
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
NSMutableArray* _getTimesOfPhrase(NSDictionary* dictionary, NSString* phrase) {
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

/**
 *
 */
NSArray* _getYoutubeUrls(NSString *videoId, NSArray *times) {
    
    // Need to construct: "https://youtu.be/ <videoId> ?t= <timeInSeconds> s
    NSMutableString *youtubeWatchUrl = [@"https://youtu.be/" mutableCopy];
    [youtubeWatchUrl appendString:videoId];
    [youtubeWatchUrl appendString:[@"?t=" mutableCopy]];
    
    NSMutableArray *youtubeUrlsArray = [NSMutableArray array];
    
    // Iterate through times:
    for (NSString* time in times) {
        NSMutableString *youtubeWatchUrlFull = [youtubeWatchUrl mutableCopy];
        NSInteger timeInt = [time integerValue];
        NSString *timeString = [NSString stringWithFormat: @"%ld", (long)timeInt];
        [youtubeWatchUrlFull appendString:timeString];
        [youtubeWatchUrlFull appendString:@"s"];
        [youtubeUrlsArray addObject:youtubeWatchUrlFull];
    }
    
    return youtubeUrlsArray;
}

@end
