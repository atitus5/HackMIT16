//
//  SCRVideoTranscriber.m
//  Scrub
//
//  Created by Andrew Titus on 9/18/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "SCRVideoTranscriber.h"

@import Speech;

@interface SCRVideoTranscriber ()

@property (nonatomic) SFSpeechRecognizer *recognizer;
@property (nonatomic) BOOL inProgress;
@property (nonatomic) NSMutableArray<NSString *> *substrings;
@property (nonatomic) NSMutableArray<NSNumber *> *timestamps;
@property (nonatomic) dispatch_semaphore_t syncSemaphore, exportSemaphore;

@end

@implementation SCRVideoTranscriber

+ (instancetype)sharedInstance {
    static SCRVideoTranscriber *sharedTranscriber = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTranscriber = [[SCRVideoTranscriber alloc] init];
    });
    return sharedTranscriber;
}

- (void)transcribeVideoAtURL:(NSURL *)assetURL substringsResult:(NSArray<NSString *> **)substrings timestampsResult:(NSArray<NSNumber *> **)timestamps {
    NSURL *audioURL = [self _extractAudioFromVideoWithURL:assetURL];
    
    SFSpeechRecognitionRequest *currentRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:audioURL];
    [currentRequest setShouldReportPartialResults:NO];
    
    _substrings = [[NSMutableArray alloc] init];
    _timestamps = [[NSMutableArray alloc] init];
    
    [_recognizer recognitionTaskWithRequest:currentRequest resultHandler:^(SFSpeechRecognitionResult * __nullable result, NSError * __nullable error) {
        if (!error) {
            SFTranscription *bestGuess = [[result transcriptions] objectAtIndex:0];
            for (SFTranscriptionSegment *segment in [bestGuess segments]) {
                [_substrings addObject:[segment substring]];
                [_timestamps addObject:@([segment timestamp])];
            }
        }
        
        dispatch_semaphore_signal(_syncSemaphore);
    }];
    
    dispatch_semaphore_wait(_syncSemaphore, DISPATCH_TIME_FOREVER);
    
    /*
    NSLog(@"%@", _substrings);
    NSLog(@"%@", _timestamps);
     */
    
    *substrings = _substrings;
    *timestamps = _timestamps;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _syncSemaphore = dispatch_semaphore_create(0);
        _exportSemaphore = dispatch_semaphore_create(0);
        
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    _recognizer = [[SFSpeechRecognizer alloc] init];
                    [_recognizer setDefaultTaskHint:SFSpeechRecognitionTaskHintUnspecified];
                    break;
                default:
                    // Nothing to do yet
                    break;
            }
        }];
    }
    return self;
}

#pragma mark - Private

- (NSURL *)_extractAudioFromVideoWithURL:(NSURL *)videoURL {
    AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetAppleM4A];
    [exportSession setShouldOptimizeForNetworkUse:YES];
    [exportSession setOutputFileType:AVFileTypeAppleM4A];
    
    // Create a base file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    basePath = [basePath stringByAppendingPathComponent:@"videos"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSURL *audioURL = [NSURL fileURLWithPath:basePath];
    NSString *filename = [NSString stringWithFormat:@"%ld.m4a", (long)[[NSDate date] timeIntervalSince1970]];
    audioURL = [audioURL URLByAppendingPathComponent:filename];
    [exportSession setOutputURL:audioURL];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_semaphore_signal(_exportSemaphore);
    }];
    dispatch_semaphore_wait(_exportSemaphore, DISPATCH_TIME_FOREVER);
    return audioURL;
}

@end
