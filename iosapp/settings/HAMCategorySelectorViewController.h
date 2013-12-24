//
//  HAMNodeSelectorViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewTool.h"
#import "HAMConfig.h"
#import "HAMCardSelectorViewController.h"
#import "HAMCategoryEditorViewController.h"
#import "HAMGridCell.h"
#import "HAMGridViewController.h"

@interface HAMCategorySelectorViewController : HAMGridViewController <UICollectionViewDataSource, UICollectionViewDelegate, HAMGridCellDelegate, UIActionSheetDelegate, HAMCategoryEditorViewControllerDelegate, HAMCardEditorViewControllerDelegate>
{
}

@property (weak, nonatomic) HAMConfig* config;
@property NSString* parentID;
// 1	 - edit
// other - replace
@property int index;
@property HAMGridCellMode cellMode;
@property (strong, nonatomic) NSArray *categoryIDs;
@property (strong, nonatomic) HAMCardSelectorViewController *cardSelector;
@property (strong, nonatomic) HAMCategoryEditorViewController *categoryEditor;
@property (strong, nonatomic) HAMCardEditorViewController *cardEditor;

@end
