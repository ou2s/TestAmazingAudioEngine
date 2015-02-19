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
    
    // Getting AEAudioController from AppDelegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.audioController = [appDelegate audioController];

    //Starting AEAudioController
    NSError *errorAudioSetup = NULL;
    BOOL result = [self.audioController start:&errorAudioSetup];
    if ( !result ) {
        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
    }
    
    // Creating path for recorded file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    audioPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"audioRecording.aiff"];
}


- (IBAction)startRecording:(id)sender  {
    NSError *error;
    //Creating AERecorder
    recorder = [[AERecorder alloc] initWithAudioController:self.audioController];

    //Starting to record
    if (![recorder beginRecordingToFileAtPath:audioPath fileType:kAudioFileAIFFType error:&error]){
        NSLog(@"\n%@\n", error);
    }
    
    //Adding recorder to Input/Output receiver
    [self.audioController addInputReceiver:recorder];
    [self.audioController addOutputReceiver:recorder];

    //Creating the AudioUnit filter
    AudioComponentDescription pitchComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_FormatConverter, kAudioUnitSubType_NewTimePitch);
    NSError *pitchError;
    pitch = [[AEAudioUnitFilter alloc] initWithComponentDescription:pitchComponent audioController:self.audioController error:&pitchError];
    
    
    //High Voice - max 2400
    AudioUnitSetParameter(pitch.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, 1000, 0);
    
    //Low Voice - max -2400
    //AudioUnitSetParameter(pitch.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, -1000, 0);
    
    //Adding the AudioUnit filter to AEAudioController
    [self.audioController addFilter:pitch];



}

- (IBAction)stopRecording:(id)sender {
    //End the record
    [recorder finishRecording];
    
    //Removing recorder from Input/Output receiver
    [self.audioController removeInputReceiver:recorder];
    [self.audioController removeOutputReceiver:recorder];
    
    //Removing the AudioUnit filter from AEAudioController
    [self.audioController removeFilter:pitch];

    
    //Deleting recorder
    recorder = nil;

}

- (IBAction)playFile:(id)sender {
    //Creating the AEAudioFilePlayer
    NSError *playerError;
    player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL URLWithString:audioPath] audioController:self.audioController error:&playerError];
    [self.audioController addChannels:@[player]];
    
    //Playing the file. It plays the file with the filter applied on it. But the file in the document directory has no filter applied to it.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
