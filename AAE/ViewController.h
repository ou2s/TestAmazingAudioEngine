//
//  ViewController.h
//  AAE
//
//  Created by Vincent Esselin on 17/02/2015.
//

#import <UIKit/UIKit.h>
#import "TheAmazingAudioEngine.h"
#import "AERecorder.h"


@class AEAudioController;
@interface ViewController : UIViewController
@property (strong, nonatomic) AEAudioController *audioController;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)playFile:(id)sender;
- (id)initWithAudioController:(AEAudioController*)audioController;
@end

