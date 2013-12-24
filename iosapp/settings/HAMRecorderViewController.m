//
//  HAMVoiceRecorderViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMRecorderViewController.h"

@interface HAMRecorderViewController ()

@property NSString *audioPath;
@property NSString *tempAudioPath;
@property NSString *imagePath;
@property NSString *tempImagePath;

@end

@implementation HAMRecorderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	success = success && [audioSession setActive:YES error:nil];
	if (! success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法启动音频设备" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		
		self.recordButton.hidden = self.playButton.hidden = YES;
	}
	
	if (self.tempCard.audio) { // audio already exists
		// copy the existing audio file to the temporary file
		NSFileManager *manager = [NSFileManager defaultManager];
		success = [manager copyItemAtPath:[HAMFileTools filePath:self.tempCard.audio.localPath] toPath:[HAMFileTools filePath:self.tempAudioPath] error:nil];
		if (! success) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法读取音频文件" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
			[alert show];
			
			self.playButton.enabled = NO;
		}
		
		self.tempCard.audio.localPath = self.tempAudioPath; // point to the temp file
	}
	else {
		self.deleteButton.enabled = NO;
		self.playButton.enabled = NO;
	}
		
	NSMutableDictionary* recordSettings = [[NSMutableDictionary alloc] init];
	[recordSettings setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
	[recordSettings setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
	[recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
	
	self.audioPath = [NSString stringWithFormat:@"%@.caf", self.tempCard.UUID];
	self.tempAudioPath = [NSString stringWithFormat:@"%@-temp.caf", self.tempCard.UUID];
	
	self.imagePath = [NSString stringWithFormat:@"%@.jpg", self.tempCard.UUID];
	self.tempImagePath = [NSString stringWithFormat:@"%@-temp.jpg", self.tempCard.UUID];

	// save audio to the temporary file
	self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[HAMFileTools fileURL:self.tempAudioPath] settings:recordSettings error:NULL];
	if (! self.audioRecorder) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法启动录音设备" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		
		self.recordButton.hidden = YES;
	}
	
	self.imageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:self.tempCard.image.localPath]];
	self.cardNameLabel.text = self.tempCard.name;
	if (! self.isNewCard) // edit mode
		self.editCardTitleView.hidden = NO; // the default state is hidden
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.delegate recorderDidCancelRecording:self];
}

- (IBAction)finishButtonPressed:(id)sender {
	
	// store image and card name
	// ---------------------------
	NSFileManager *manager = [NSFileManager defaultManager];
	// copy and then delete the temporary image file
	BOOL success = YES;
	NSError *error;
	// must delete the original file before writing new data to it
	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.imagePath]]) {
		success = success && [manager removeItemAtPath:[HAMFileTools filePath:self.imagePath] error:&error];
		NSLog(@"error: %@", error.localizedDescription);
	}
	success = success && [manager moveItemAtPath:[HAMFileTools filePath:self.tempImagePath] toPath:[HAMFileTools filePath:self.imagePath] error:&error];
	NSLog(@"temp file exists: %d", [manager fileExistsAtPath:[HAMFileTools filePath:self.tempImagePath]]);
	NSLog(@"error: %@", error.localizedDescription);
	if (! success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法保存图片" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
		[alert show];
		return;
	}
	// switch from temp path to the real path
	self.tempCard.image.localPath = self.imagePath;
	self.tempCard.audio.localPath = self.audioPath;
	[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
		
	// store audio
	// ------------------
	if (self.tempCard.audio) { // has audio, either newly recorded or already existing
		NSFileManager *manager = [NSFileManager defaultManager];
		// copy and then delete the temporary audio file
		BOOL success = YES;
		// must delete the original file before writing new data to it
		if ([manager fileExistsAtPath:[HAMFileTools filePath:self.audioPath]])
			success = success && [manager removeItemAtPath:[HAMFileTools filePath:self.audioPath] error:nil];
		success = success && [manager moveItemAtPath:[HAMFileTools filePath:self.tempAudioPath] toPath:[HAMFileTools filePath:self.audioPath] error:nil];
		if (!success) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法保存音频" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
			[alert show];
			
			return;
		}
		
		// switch from temp path to the real path
		self.tempCard.image.localPath = self.imagePath;
		self.tempCard.audio.localPath = self.audioPath;
		[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
	}
	
	// update category
	// ------------------
	NSInteger numChildren = [self.config childrenCardIDOfCat:self.newCategoryID].count;
	HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation:ROOM_ANIMATION_NONE];
	
	if (self.isNewCard) {
		// if this is a new card, then insert it into a new category
		[self.config updateRoomOfCat:self.newCategoryID with:room atIndex:numChildren];
	}
	else if (! [self.newCategoryID isEqualToString:self.categoryID]) { // category is changed
		// add the card to the new category
		[self.config updateRoomOfCat:self.newCategoryID with:room atIndex:numChildren];
		
		// remove the card from the old category
		NSInteger oldIndex = [[self.config childrenCardIDOfCat:self.categoryID] indexOfObject:self.tempCard.UUID];
		[self.config deleteChildOfCatInLib:self.categoryID atIndex:oldIndex];
	}

	// add the card immediately
	if (self.addCardOnCreation) {
		int animation = [self.config animationOfCat:self.parentID atIndex:self.index]; // keep the animation unchanged
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation:animation];
		[self.config insertChildren:@[room] intoCat:self.parentID atIndex:self.index];
	}
	
	[self.delegate recorderDidEndRecording:self]; // inform the grid view to refresh
}

- (IBAction)recordButtonPressed:(id)sender {
	if (self.audioRecorder.recording) { // stop recording
		[self.audioRecorder stop];
		if (! self.tempCard.audio)
			self.tempCard.audio = [[HAMResource alloc] initWithPath:self.tempAudioPath];
		
		[self.recordButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
		self.statusLabel.text = @"录音结束";
		
		// re-enable other views
		self.playButton.enabled = YES;
		self.deleteButton.enabled = YES;
		self.cancelButton.enabled = YES;
		self.finishButton.enabled = YES;
	}
	else { // start recording
		BOOL success = [self.audioRecorder record];
		if (! success) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法开始录音" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
			[alert show];
			return;
		}
		[self.recordButton setImage:[UIImage imageNamed:@"recordDOWN.png"] forState:UIControlStateNormal];
		self.statusLabel.text = @"录音中...";
		
		// disable all other views while recording
		self.playButton.enabled = NO;
		self.deleteButton.enabled = NO;
		self.cancelButton.enabled = NO;
		self.finishButton.enabled = NO;
	}
}

- (IBAction)playButtonPressed:(id)sender {
	NSString *audioToPlayPath = self.tempAudioPath;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[HAMFileTools fileURL:audioToPlayPath] error:NULL];
	if (! self.audioPlayer) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法播放音频" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		
		self.playButton.hidden = YES;
	}
	self.audioPlayer.delegate = self; // !!!

	[self.audioPlayer play];
	// temporarily disable the play button while playing audio
	self.playButton.enabled = NO;
	self.statusLabel.text = @"播放中...";
	
	// disable all other views while playing audio
	self.recordButton.enabled = NO;
	self.deleteButton.enabled = NO;
	self.cancelButton.enabled = NO;
	self.finishButton.enabled = NO;
}

- (IBAction)deleteButtonPressed:(id)sender {
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL success = YES;
	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.audioPath]])
		success = success && [manager removeItemAtPath:[HAMFileTools filePath:self.audioPath] error:nil];

	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.tempAudioPath]])
		success = success && [manager removeItemAtPath:[HAMFileTools filePath:self.tempAudioPath] error:nil];
	
	if (! success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法删除音频文件" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	// set the audio path to nil
	self.tempCard.audio = nil;
	// no audio to play or delete now
	self.deleteButton.enabled = NO;
	self.playButton.enabled = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (! flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"音频解码失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
	}
	
	self.playButton.enabled = YES;
	self.statusLabel.text = @"播放结束";
	
	// re-enable other views
	self.recordButton.enabled = YES;
	self.deleteButton.enabled = YES;
	self.cancelButton.enabled = YES;
	self.finishButton.enabled = YES;
}

@end
