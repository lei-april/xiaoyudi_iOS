//
//  HAMCategoryEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCategoryEditorViewController.h"

@interface HAMCategoryEditorViewController ()

@end

@implementation HAMCategoryEditorViewController

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
	if (self.categoryID) // editing
		self.categoryNameField.text = [self.config card:self.categoryID].name;
	else
		self.createCategoryTitleView.hidden = NO;
	
	if (self.categoryID == nil) {
		self.deleteButton.hidden = YES; // don't allow deletion of category being created
		self.finishButton.enabled = NO;
	}
	
	self.preferredContentSize = self.view.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteButtonPressed:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"该分类下所有卡片均会被删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
	[alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1) { // confirm deletion
		// delete all cards under this category
		NSArray *cardIDs = [self.config childrenCardIDOfCat:self.categoryID];
		for (NSUInteger index = 0; index < cardIDs.count; index++) {
			[self.config deleteChildOfCatInLib:self.categoryID atIndex:index];
		}
		
		NSArray *catIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
		NSUInteger catIndex = [catIDs indexOfObject:self.categoryID];
		[self.config deleteChildOfCatInLib:LIB_ROOT atIndex:catIndex];
		
		[self.delegate categoryEditorDidEndEditing:self]; // ask the grid to refresh
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.tempCategoryName = nil;
	
	if (! self.categoryID) { // creating category
		if (! [textField.text isEqualToString:@""])
			self.tempCategoryName = textField.text;
	}
	else { // editting category
		NSString *oldCategoryName = [self.config card:self.categoryID].name;
		if ([textField.text isEqualToString:@""])
			textField.text = oldCategoryName;
		else if (! [textField.text isEqualToString:oldCategoryName])
			self.tempCategoryName = textField.text;
	}
	
	self.finishButton.enabled = self.tempCategoryName ? YES : NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// disable finish button while editing
	self.finishButton.enabled = NO;
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.delegate categoryEditorDidCancelEditing:self];
}

- (IBAction)finishButtonPressed:(id)sender {
	if (self.categoryID) { // editing category
		HAMCard *category = [self.config card:self.categoryID];
		[self.config updateCard:category name:self.tempCategoryName audio:nil image:nil];
	}
	else { // creating category
		
		HAMCard *category = [[HAMCard alloc] initNewCard];
		NSString *categoryName = self.tempCategoryName;
		// type 0 indicates a category
		[self.config newCardWithID:category.UUID name:categoryName type:0 audio:nil image:nil];
		category.isRemovable_ = YES;
		
		NSInteger numChildren = [self.config childrenCardIDOfCat:LIB_ROOT].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:category.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:LIB_ROOT with:room atIndex:numChildren];

		NSDictionary *attrs = [NSDictionary dictionaryWithObject:categoryName forKey:@"分类名称"];
		[MobClick event:@"create_category" attributes:attrs]; // trace event
	}
	
	[self.delegate categoryEditorDidEndEditing:self]; // ask the grid view to refresh
}

@end
