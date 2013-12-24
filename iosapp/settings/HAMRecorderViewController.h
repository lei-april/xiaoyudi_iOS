//
//  HAMVoiceRecorderViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HAMConfig.h"

@class HAMRecorderViewController;
@protocol HAMRecorderViewControllerDelegate <NSObject>

- (void)recorderDidEndRecording:(HAMRecorderViewController*)recorder;
- (void)recorderDidCancelRecording:(HAMRecorderViewController*)recorder;

@end


@interface HAMRecorderViewController : UIViewController <AVAudioPlayerDelegate>

@property (weak, nonatomic) HAMConfig *config;
@property (strong, nonatomic) HAMCard *tempCard; // !!!: don't pass changes back to card editor
@property (weak, nonatomic) NSString *categoryID;
@property (weak, nonatomic, getter = theNewCategoryID) NSString *newCategoryID;
@property BOOL isNewCard;
@property (weak, nonatomic) id<HAMRecorderViewControllerDelegate> delegate;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *cardNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *editCardTitleView;

// for use by Day Yue, not necessarily initialized
@property BOOL addCardOnCreation;
@property (strong, nonatomic) NSString *parentID;
@property int index;


- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)finishButtonPressed:(id)sender;
- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@end
