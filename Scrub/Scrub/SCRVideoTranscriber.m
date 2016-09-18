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

- (NSArray<NSURL *> *)transcribeVideoAtURL:(NSURL *)assetURL {
    SFSpeechRecognitionRequest *currentRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:assetURL];
    //[currentRequest setShouldReportPartialResults:NO];
    [_recognizer recognitionTaskWithRequest:currentRequest resultHandler:^(SFSpeechRecognitionResult * __nullable result, NSError * __nullable error) {
        if (!error) {
            for (SFTranscription *transcription in [result transcriptions]) {
                for (SFTranscriptionSegment *segment in [transcription segments]) {
                    [_substrings addObject:[segment substring]];
                    [_timestamps addObject:@([segment timestamp])];
                }
            }
        }
        
        NSLog(@"%@", _substrings);
        NSLog(@"%@", _timestamps);
    }];
    
    // TODO
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
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

@end
