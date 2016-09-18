//
//  SCRResultsViewController.m
//  Scrub
//
//  Created by Andrew Titus on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "SCRResultsViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "SCRHomeViewController.h"
#import "YTPlayerView.h"

#define PLAYER_MARGIN 30.0
#define BUTTON_SIDELEN 75.0
#define URL_FONTSIZE 25.0
#define SELECTED_TIMESTAMP_INDEX_FONTSIZE 50.0
#define BACK_BUTTON_RADIUS 20.0

@interface SCRResultsViewController () <UITextViewDelegate, YTPlayerViewDelegate>

@property (nonatomic, weak) id<SCRResultsViewControllerDelegate> delegate;
@property (nonatomic) NSArray *urlArray;
@property (nonatomic) NSString *videoId;
@property (nonatomic) NSArray<NSNumber *> *timestamps;

@property (nonatomic) UIButton *backButton;
@property (nonatomic) YTPlayerView *playerView;
@property (nonatomic) UITextView *urlView;
@property (nonatomic) UILabel *selectedTimestampIndexView;
@property (nonatomic) UIButton *previousTimestampButton;
@property (nonatomic) UIButton *nextTimestampButton;
@property (nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic) NSUInteger currentTimestampIndex;

@end

@implementation SCRResultsViewController

- (instancetype)initWithDelegate:(id<SCRResultsViewControllerDelegate>)delegate urlArray:(NSArray<NSString *> *)urlArray {
    self = [self init];
    if (self) {
        _delegate = delegate;
        _urlArray = urlArray;
        
        NSMutableArray<NSNumber *> *tmpTimestamps = [[NSMutableArray alloc] initWithCapacity:[_urlArray count]];
        NSURLComponents *currentURLComps;
        NSString *currentTimestampString;
        for (NSString *urlString in urlArray) {
            // Get the timestamps out of the (single) query item
            currentURLComps = [[NSURLComponents alloc] initWithString:urlString];
            currentTimestampString = [[[currentURLComps queryItems] lastObject] value];
            [tmpTimestamps addObject:[NSNumber numberWithDouble:[[currentTimestampString substringToIndex:([currentTimestampString length] - 1)] doubleValue]]];
        }
        
        // Sort timestamps earliest to latest
        _timestamps = (NSArray *)[tmpTimestamps sortedArrayUsingComparator:^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
            return [num2 compare:num1];
        }];
        _currentTimestampIndex = 0;
        
        // All URLs have the same video ID - let's just get it once
        // Strip the video ID out of the path
        _videoId = [[currentURLComps path] substringFromIndex:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Force status bar style update
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self _setUpForSize:[[UIScreen mainScreen] bounds].size];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // During rotation
        [self _setUpForSize:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // After rotation
    }];
}

#pragma mark - YTPlayerViewDelegate

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [_indicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self _setUpForCurrentTimestamp];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStateBuffering:
        case kYTPlayerStateUnstarted:
            [_indicator startAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            break;
        default:
            [_indicator stopAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark - Private

- (void)_goHome:(UIButton *)button {
    [_playerView stopVideo];
    _playerView = nil;
    
    [_delegate viewControllerWillDismiss:self];
}

- (void)_goToPreviousTimestamp:(UIButton *)button {
    _currentTimestampIndex--;
    [self _setUpForCurrentTimestamp];
}

- (void)_goToNextTimestamp:(UIButton *)button {
    _currentTimestampIndex++;
    [self _setUpForCurrentTimestamp];
}

- (void)_setUpForCurrentTimestamp {
    [_playerView seekToSeconds:[[_timestamps objectAtIndex:_currentTimestampIndex] floatValue]
                allowSeekAhead:YES];
    [_urlView setText:[NSString stringWithFormat:@"Link: %@", [_urlArray objectAtIndex:_currentTimestampIndex]]];
    
    // Don't have the options to go to next/previous timestamp if at beginning/end
    if (_currentTimestampIndex == 0) {
        [_previousTimestampButton setAlpha:0.0];
        [_previousTimestampButton setUserInteractionEnabled:NO];
    } else {
        [_previousTimestampButton setAlpha:1.0];
        [_previousTimestampButton setUserInteractionEnabled:YES];
    }
    
    if (_currentTimestampIndex == ([_timestamps count] - 1)) {
        [_nextTimestampButton setAlpha:0.0];
        [_nextTimestampButton setUserInteractionEnabled:NO];
    } else {
        [_nextTimestampButton setAlpha:1.0];
        [_nextTimestampButton setUserInteractionEnabled:YES];
    }
    
    [_selectedTimestampIndexView setText:[NSString stringWithFormat:@"%lu/%lu", _currentTimestampIndex + 1, [_timestamps count]]];
}

- (void)_setUpForSize:(CGSize)size {
    CGRect backButtonFrame, playerFrame, urlFrame, selectedTimestampIndexFrame, previousTimestampButtonFrame, nextTimestampButtonFrame, indicatorFrame;
    CGFloat widthInsideMargins = size.width - (2.0 * PLAYER_MARGIN);
    CGFloat heightInsideMargins = size.height - (2.0 * PLAYER_MARGIN);
    
    NSDictionary *playerVars = @{
        @"playsinline": @1,
        @"cc-load-policy": @(YES),
        @"theme": @"light",
        @"autoplay": @(YES)
    };
    CGFloat playerWidth, playerHeight, playerOriginX, playerOriginY;
    if (size.height > size.width) {
        // Treat as portrait
        playerWidth = widthInsideMargins;
        playerHeight = playerWidth * (9.0 / 16.0);
        playerOriginX = PLAYER_MARGIN + ((widthInsideMargins - playerWidth) / 2.0);
        playerOriginY = MAX(PLAYER_MARGIN, PLAYER_MARGIN + (heightInsideMargins / 3.0) - (playerHeight / 2.0));
        backButtonFrame = CGRectMake(playerOriginX, (playerOriginY - BUTTON_SIDELEN) / 2.0, BUTTON_SIDELEN, BUTTON_SIDELEN);
    } else {
        // Treat as landscape
        playerHeight = heightInsideMargins / 2.0;
        playerWidth = playerHeight * (16.0 / 9.0);
        playerOriginX = PLAYER_MARGIN + ((widthInsideMargins - playerWidth) / 2.0);
        playerOriginY = MAX(PLAYER_MARGIN + (((size.height / 4.0) - playerHeight) / 2.0), PLAYER_MARGIN);
        backButtonFrame = CGRectMake((playerOriginX - BUTTON_SIDELEN) / 2.0, playerOriginY + ((playerHeight - BUTTON_SIDELEN) / 2.0), BUTTON_SIDELEN, BUTTON_SIDELEN);
    }
    CGFloat remainingHeight = heightInsideMargins - playerHeight;
    
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:backButtonFrame];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:1.0]
                          forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor colorWithRed:BG_R green:BG_G blue:BG_B alpha:SELECTED_ALPHA] forState:UIControlStateSelected];
        [_backButton setBackgroundColor:[UIColor whiteColor]];
        [[_backButton layer] setCornerRadius:BACK_BUTTON_RADIUS];
        [_backButton setShowsTouchWhenHighlighted:YES];
        [_backButton addTarget:self action:@selector(_goHome:)
              forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:_backButton];
    } else {
        [_backButton setFrame:backButtonFrame];
    }
    
    playerFrame = CGRectMake(playerOriginX, playerOriginY, playerWidth, playerHeight);
    if (!_playerView) {
        _playerView = [[YTPlayerView alloc] initWithFrame:playerFrame];
        [_playerView setDelegate:self];
        
        [_indicator startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [_playerView loadWithVideoId:_videoId playerVars:playerVars];
        [[self view] addSubview:_playerView];
    } else {
        [_playerView setFrame:playerFrame];
    }
    
    urlFrame = CGRectMake(PLAYER_MARGIN, playerOriginY + playerHeight, widthInsideMargins, remainingHeight / 2.0);
    if (!_urlView) {
        _urlView = [[UITextView alloc] initWithFrame:urlFrame];
        [_urlView setFont:[UIFont fontWithName:kScrubFont size:URL_FONTSIZE]];
        [_urlView setTextColor:[UIColor whiteColor]];
        [_urlView setBackgroundColor:[UIColor clearColor]];
        [_urlView setDelegate:self];
        [_urlView setEditable:NO];
        [_urlView setTextAlignment:NSTextAlignmentCenter];
        [_urlView setDataDetectorTypes:UIDataDetectorTypeLink];
        [[self view] addSubview:_urlView];
    } else {
        [_urlView setFrame:urlFrame];
    }
    
    selectedTimestampIndexFrame = CGRectMake(PLAYER_MARGIN + BUTTON_SIDELEN, PLAYER_MARGIN + playerHeight + (remainingHeight / 2.0), widthInsideMargins - (2.0 * BUTTON_SIDELEN), remainingHeight / 2.0);
    if (!_selectedTimestampIndexView) {
        _selectedTimestampIndexView = [[UILabel alloc] initWithFrame:selectedTimestampIndexFrame];
        [_selectedTimestampIndexView setFont:[UIFont fontWithName:kScrubFont
                                                             size:SELECTED_TIMESTAMP_INDEX_FONTSIZE]];
        [_selectedTimestampIndexView setTextColor:[UIColor whiteColor]];
        [_selectedTimestampIndexView setTextAlignment:NSTextAlignmentCenter];
        [_selectedTimestampIndexView setNumberOfLines:1];
        [[self view] addSubview:_selectedTimestampIndexView];
    } else {
        [_selectedTimestampIndexView setFrame:selectedTimestampIndexFrame];
    }
    
    // Rotate 180 degrees to point left
    previousTimestampButtonFrame = CGRectMake(PLAYER_MARGIN, PLAYER_MARGIN + playerHeight + (remainingHeight * (3.0 / 4.0)) - (BUTTON_SIDELEN / 2.0), BUTTON_SIDELEN, BUTTON_SIDELEN);
    if (!_previousTimestampButton) {
        UIImage *previousTimestampImage = [UIImage imageNamed:@"Arrow"];
        _previousTimestampButton = [[UIButton alloc] initWithFrame:previousTimestampButtonFrame];
        [_previousTimestampButton setImage:previousTimestampImage forState:UIControlStateNormal];
        [_previousTimestampButton setBackgroundColor:[UIColor whiteColor]];
        [[_previousTimestampButton layer] setCornerRadius:(BUTTON_SIDELEN / 2.0)];
        [_previousTimestampButton setShowsTouchWhenHighlighted:YES];
        [_previousTimestampButton addTarget:self
                                     action:@selector(_goToPreviousTimestamp:)
                           forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:_previousTimestampButton];
    } else {
        [_previousTimestampButton setTransform:CGAffineTransformIdentity];
        [_previousTimestampButton setFrame:previousTimestampButtonFrame];
    }
    [_previousTimestampButton setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
    
    nextTimestampButtonFrame = CGRectMake(PLAYER_MARGIN + widthInsideMargins - BUTTON_SIDELEN, PLAYER_MARGIN + playerHeight + (remainingHeight * (3.0 / 4.0))  - (BUTTON_SIDELEN / 2.0), BUTTON_SIDELEN, BUTTON_SIDELEN);
    if (!_nextTimestampButton) {
        UIImage *nextTimestampImage = [UIImage imageNamed:@"Arrow"];
        _nextTimestampButton = [[UIButton alloc] initWithFrame:nextTimestampButtonFrame];
        [_nextTimestampButton setImage:nextTimestampImage forState:UIControlStateNormal];
        [_nextTimestampButton setBackgroundColor:[UIColor whiteColor]];
        [[_nextTimestampButton layer] setCornerRadius:(BUTTON_SIDELEN / 2.0)];
        [_nextTimestampButton setShowsTouchWhenHighlighted:YES];
        [_nextTimestampButton addTarget:self
                                 action:@selector(_goToNextTimestamp:)
                       forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:_nextTimestampButton];
    } else {
        [_nextTimestampButton setFrame:nextTimestampButtonFrame];
    }
    
    indicatorFrame = CGRectMake(0.0, 0.0, INDICATOR_SIZE, INDICATOR_SIZE);
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicator setFrame:indicatorFrame];
        [_indicator setCenter:[[self view] center]];
        [[self view] addSubview:_indicator];
        [_indicator bringSubviewToFront:[self view]];
    } else {
        [_indicator setFrame:indicatorFrame];
        [_indicator setCenter:[[self view] center]];
    }
    
    [self _setUpForCurrentTimestamp];
}

@end
