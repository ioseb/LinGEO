//
//  PTeSpeak.h
//  LinGEO
//
//  Created by Lasha Dolidze on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#define kPTeSpeakBufferSize         4096

@protocol PTeSpeakDelegate;

@interface PTeSpeak : NSObject
{
    id                  delegate;
    AudioQueueRef       outputQueue;
    AudioQueueBufferRef audioBuffer;
    
    NSInteger           sampleRate;
    NSInteger           bufferCount;
}

@property (nonatomic, assign) NSInteger bufferCount;
@property (nonatomic, assign) AudioQueueRef outputQueue;
@property (nonatomic, assign) AudioQueueBufferRef audioBuffer;
@property (nonatomic, assign) id delegate;


+ (PTeSpeak*)sharedPTeSpeak;

- (NSInteger)setupWithVoice:(NSString*)voiceName volume:(NSInteger)volume rate:(NSInteger)rate pitch:(NSInteger)pitch;
- (void)speak:(NSString*)text;
- (BOOL)isSpeak;
- (BOOL)stop;
- (BOOL)pause;

@end


    
@protocol PTeSpeakDelegate <NSObject>
- (void)speakDidStart:(PTeSpeak *)espeak;
- (void)speakDidEnd:(PTeSpeak *)espeak;
- (void)speakWithError:(PTeSpeak *)espeak error:(OSStatus)error;
@end