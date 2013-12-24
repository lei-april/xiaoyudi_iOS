//
//  HAMCardSelectorViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-10-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMConfig.h"
#import "HAMGridCell.h"
#import "HAMGridViewController.h"
#import "HAMCardEditorViewController.h"

@interface HAMCardSelectorViewController : HAMGridViewController <UICollectionViewDataSource, HAMGridCellDelegate, HAMCardEditorViewControllerDelegate>

@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, weak) HAMConfig *config;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) HAMGridCellMode cellMode;
@property (strong, nonatomic) NSArray *cardIDs;
@property (nonatomic, strong) NSMutableSet *selectedCardIDs;
@property (strong, nonatomic) HAMCardEditorViewController *cardEditor;

@end
