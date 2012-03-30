//
//  PTeSpeak.m
//  LinGEO
//
//  Created by Lasha Dolidze on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTeSpeak.h"

/* eSpeak lib */
#import "speak_lib.h"


@implementation PTeSpeak

@synthesize delegate;
@synthesize bufferCount;
@synthesize outputQueue;
@synthesize audioBuffer;


+ (PTeSpeak*)sharedPTeSpeak
{
    static PTeSpeak *sharedPTeSpeak;
    
    @synchronized(self)
    {
        if (sharedPTeSpeak == nil) {
            sharedPTeSpeak = [[PTeSpeak alloc] init];
        }
        
        return sharedPTeSpeak;
    }
}

- (id) init
{    
    if (self = [super init]) {

        NSBundle* myBundle = [NSBundle mainBundle];
        NSString* resourceDir = [myBundle resourcePath];

        sampleRate = espeak_Initialize(AUDIO_OUTPUT_SYNCHRONOUS, kPTeSpeakBufferSize, [resourceDir UTF8String], 0);

	}

    return self; 
}

// AudioQueue output queue callback.
void PTeSpeakAudioEngineOutputBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) 
{
    PTeSpeak *eSpeak = [PTeSpeak sharedPTeSpeak];
    
    AudioQueueFreeBuffer(eSpeak.outputQueue, inBuffer);
    eSpeak.bufferCount--;
    
    if(!eSpeak.bufferCount) {

        AudioQueueStop(eSpeak.outputQueue, YES);
        
        if([eSpeak.delegate respondsToSelector:@selector(speakDidEnd:)] ) {
            [eSpeak.delegate speakDidEnd:eSpeak];
        }
    }
}

static int PTeSpeakSynthCallback(short *buffer, int numsamples, espeak_EVENT *events)
{
    PTeSpeak *eSpeak = [PTeSpeak sharedPTeSpeak];
    AudioQueueBufferRef aBuffer = eSpeak.audioBuffer;
    
    NSLog(@"PTeSpeakSynthCallback: Event type %d, samples=%d\n", events->type, numsamples);
    
    if (events->type == espeakEVENT_LIST_TERMINATED) {
        NSLog(@"PTeSpeakSynthCallback: Speech has completed\n");
        return 0;
    }
    
    eSpeak.bufferCount++;
    
    // Set up stream format fields
    AudioQueueAllocateBuffer(eSpeak.outputQueue, numsamples * sizeof(short), &aBuffer);
    aBuffer->mAudioDataByteSize = numsamples * sizeof(short);
    memcpy(aBuffer->mAudioData, buffer, numsamples * sizeof(short));
    AudioQueueEnqueueBuffer (eSpeak.outputQueue, aBuffer, 0, nil);
    AudioQueueStart(eSpeak.outputQueue, nil);
    
    return 0;  // continue synthesis (1 is to abort)
}


/* Steup voice */
- (NSInteger)setupWithVoice:(NSString*)voiceName volume:(NSInteger)volume rate:(NSInteger)rate pitch:(NSInteger)pitch
{
    int err = EE_OK;
    
    if(espeak_SetVoiceByName([voiceName UTF8String]) != EE_OK) {
        return err;
    }
    
    if(rate >= 80 && rate <= 450 ) { 
        espeak_SetParameter(espeakRATE, rate, 0);
    }
    
    if(volume >= 0 && volume <= 200 ) { 
        espeak_SetParameter(espeakVOLUME, volume, 0);
    }
    
    if(pitch >= 0 && pitch <= 99 ) { 
        espeak_SetParameter(espeakPITCH, pitch, 0);
    }   
    
    espeak_SetSynthCallback(PTeSpeakSynthCallback);
    
    return err;
}

- (void)speak:(NSString*)text
{
    AudioStreamBasicDescription streamFormat;

    if([self isSpeak]) {
        [self stop];
    }
    
    streamFormat.mSampleRate = sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    streamFormat.mBitsPerChannel = 16;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBytesPerPacket = 2 * streamFormat.mChannelsPerFrame;
    streamFormat.mBytesPerFrame = 2 * streamFormat.mChannelsPerFrame;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mReserved = 0;
    
    OSStatus err = AudioQueueNewOutput(&streamFormat, PTeSpeakAudioEngineOutputBufferCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &outputQueue);
    if (err != noErr) {
        if([self.delegate respondsToSelector:@selector(speakWithError:error:)] ) {
            [self.delegate speakWithError:self error:err];
        }
        return;
    }
    
    espeak_Synth( (char*)[text UTF8String], [text length] + 1, 0, POS_CHARACTER, 0, espeakCHARS_AUTO, NULL, NULL);
    espeak_Synchronize();
    
    if([self.delegate respondsToSelector:@selector(speakDidStart:)] ) {
        [self.delegate speakDidStart:self];
    }
}

- (BOOL)isSpeak
{
    return (bufferCount > 0);
}

- (BOOL)stop
{
    AudioQueueStop(self.outputQueue, YES);
    bufferCount = 0;
    
    if([self.delegate respondsToSelector:@selector(speakDidEnd:)] ) {
        [self.delegate speakDidEnd:self];
    }
    
    return YES;
}

- (BOOL)pause
{
    AudioQueuePause(self.outputQueue);
    
    return YES;
}


- (void)dealloc {

    [super dealloc];
}

@end
