//
//  SCRResultsViewController.m
//  Scrub
//
//  Created by Andrew Titus on 9/17/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "SCRResultsViewController.h"

#import "AppDelegate.h"
#import "YTPlayerView.h"

#define PLAYER_MARGIN 30.0
#define IMAGE_VIEW_SIDELEN 75.0

@interface SCRResultsViewController () <UITextViewDelegate>

@property (nonatomic) NSArray *urlArray;
@property (nonatomic) NSString *videoId;
@property (nonatomic) NSArray<NSNumber *> *timestamps;

@property (nonatomic) YTPlayerView *playerView;
@property (nonatomic) UITextView *urlView;
@property (nonatomic) UILabel *selectedTimestampView;
@property (nonatomic) UIImageView *previousTimestampImageView;
@property (nonatomic) UIImageView *nextTimestampImageView;

@end

@implementation SCRResultsViewController

- (instancetype)initWithURLArray:(NSArray<NSString *> *)urlArray {
    self = [self init];
    if (self) {
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
        _timestamps = (NSArray *)tmpTimestamps;
        
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

#pragma mark - Private

- (void)_setUpForCurrentTimestamp {
    //
}

- (void)_setUpForSize:(CGSize)size {
    CGRect playerFrame, urlFrame, selectedTimestampFrame, previousTimestampImageViewFrame, nextTimestampImageViewFrame;
    CGFloat widthInsideMargins = size.width - (2.0 * PLAYER_MARGIN);
    CGFloat heightInsideMargins = size.height - (2.0 * PLAYER_MARGIN);
    NSDictionary *playerVars = @{
        @"cc-load-policy": @(1),
        @"theme": @"light"
    };
    
    CGFloat aspectRatio = (size.height > size.width) ? (3.0 / 4.0) : (9.0 / 16.0);
    playerFrame = CGRectMake(PLAYER_MARGIN, PLAYER_MARGIN, widthInsideMargins, widthInsideMargins * aspectRatio);
    _playerView = [[YTPlayerView alloc] initWithFrame:playerFrame];
    [_playerView loadWithVideoId:_videoId playerVars:playerVars];
    [[self view] addSubview:_playerView];
    
    // Set up a bunch of frames relative to the video player and bounds
    CGFloat remainingHeight = heightInsideMargins - (widthInsideMargins * aspectRatio);
    urlFrame = CGRectMake(PLAYER_MARGIN + IMAGE_VIEW_SIDELEN, PLAYER_MARGIN + (widthInsideMargins * aspectRatio), widthInsideMargins - (2.0 * IMAGE_VIEW_SIDELEN), remainingHeight / 2.0);
    selectedTimestampFrame = CGRectMake(PLAYER_MARGIN + IMAGE_VIEW_SIDELEN, PLAYER_MARGIN + (widthInsideMargins * aspectRatio) + (remainingHeight / 2.0), widthInsideMargins - (2.0 * IMAGE_VIEW_SIDELEN), remainingHeight / 2.0);
    previousTimestampImageViewFrame = CGRectMake(PLAYER_MARGIN, PLAYER_MARGIN + (widthInsideMargins * aspectRatio), IMAGE_VIEW_SIDELEN, IMAGE_VIEW_SIDELEN);
    nextTimestampImageViewFrame = CGRectMake(PLAYER_MARGIN + widthInsideMargins - IMAGE_VIEW_SIDELEN, PLAYER_MARGIN + (widthInsideMargins * aspectRatio), IMAGE_VIEW_SIDELEN, IMAGE_VIEW_SIDELEN);
    
    _urlView = [[UITextView alloc] initWithFrame:urlFrame];
    [_urlView setFont:[UIFont fontWithName:kScrubFont size:(remainingHeight / 2.0)]];
    [_urlView setTextColor:[UIColor whiteColor]];
    [_urlView setDelegate:self];
    [_urlView setEditable:NO];
    [_urlView setTextAlignment:NSTextAlignmentCenter];
    [_urlView setDataDetectorTypes:UIDataDetectorTypeLink];
    [[self view] addSubview:_urlView];
    
    _selectedTimestampView = [[UILabel alloc] initWithFrame:selectedTimestampFrame];
    [_selectedTimestampView setFont:[UIFont fontWithName:kScrubFont size:(remainingHeight / 2.0)]];
    [_selectedTimestampView setTextColor:[UIColor whiteColor]];
    [_selectedTimestampView setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:_selectedTimestampView];
    
    // Rotate 180 degrees to point left
    UIImage *previousTimestampImage = [UIImage imageNamed:@"Arrow"];
    _previousTimestampImageView = [[UIImageView alloc] initWithImage:previousTimestampImage];
    [_previousTimestampImageView setFrame:previousTimestampImageViewFrame];
    [_previousTimestampImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 180.0)];
    [[self view] addSubview:_previousTimestampImageView];
    
    UIImage *nextTimestampImage = [UIImage imageNamed:@"Arrow"];
    _nextTimestampImageView = [[UIImageView alloc] initWithImage:nextTimestampImage];
    [_nextTimestampImageView setFrame:nextTimestampImageViewFrame];
    [[self view] addSubview:_nextTimestampImageView];
    
    [self _setUpForCurrentTimestamp];
}

@end
