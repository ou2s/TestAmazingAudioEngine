//
//  ViewController.m
//  AAE
//
//  Created by Vincent Esselin on 17/02/2015.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController (){
    AERecorder *recorder;
    NSString *audioPath;
    AEAudioFilePlayer *player;
    AEAudioUnitFilter *pitch;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSError *errorAudioSetup = NULL;
    BOOL result = [[appDelegate audioController] start:&errorAudioSetup];
    if ( !result ) {
        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
    }
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    audioPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"audioRecording.aiff"];
    self.audioController = [appDelegate audioController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




- (IBAction)startRecording:(id)sender  {
    NSError *error;
    recorder = [[AERecorder alloc] initWithAudioController:self.audioController];

    if (![recorder beginRecordingToFileAtPath:audioPath fileType:kAudioFileAIFFType error:&error]){
        NSLog(@"\n%@\n", error);
    }
    [self.audioController addInputReceiver:recorder];
    [self.audioController addOutputReceiver:recorder];

    
    AudioComponentDescription pitchComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_FormatConverter, kAudioUnitSubType_NewTimePitch);
    NSError *pitchError;
    pitch = [[AEAudioUnitFilter alloc] initWithComponentDescription:pitchComponent audioController:self.audioController error:&pitchError];
    
    
    //VOIX AIGUE - max 2400
    AudioUnitSetParameter(pitch.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, 1000, 0);
    
    //VOIX GRAVE - max -2400
    //AudioUnitSetParameter(pitch.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, -1000, 0);
    
    
    
    [self.audioController addFilter:pitch];


}

- (IBAction)stopRecording:(id)sender {
    [recorder finishRecording];
    [self.audioController removeInputReceiver:recorder];
   [self.audioController removeOutputReceiver:recorder];
//
//    
    recorder = nil;
    [self.audioController removeInputFilter:pitch];

    if ([player channelIsPlaying]){
        [self.audioController removeChannels:@[player]];
    }
}

- (IBAction)playFile:(id)sender {
    NSError *playerError;
    player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL URLWithString:audioPath] audioController:self.audioController error:&playerError];
    

    
    [self.audioController addChannels:@[player]];
    
}

@end
