//
//  HAMCategoryEditorViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMConfig.h"
#import "MobClick.h"

@class HAMCategoryEditorViewController;
@protocol HAMCategoryEditorViewControllerDelegate <NSObject>

- (void)categoryEditorDidEndEditing: (HAMCategoryEditorViewController*)categoryEditor;
- (void)categoryEditorDidCancelEditing:(HAMCategoryEditorViewController*)categoryEditor;

@end

@interface HAMCategoryEditorViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *categoryID;
@property (weak, nonatomic) HAMConfig *config;
@property (weak, nonatomic) id<HAMCategoryEditorViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *tempCategoryName;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UITextField *categoryNameField;
@property (weak, nonatomic) IBOutlet UIImageView *createCategoryTitleView;

- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)finishButtonPressed:(id)sender;


@end
