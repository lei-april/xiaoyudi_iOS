//
//  HAMNodeSelectorViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCategorySelectorViewController.h"


@interface HAMCategorySelectorViewController ()

@end

@implementation HAMCategorySelectorViewController

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
	
	[self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"CategoryCell"];
	self.navigationController.navigationBarHidden = YES;
	
	// the uncategorized category is not created yet
	// TODO: this should be done in DaiYue's part
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	if ([self.categoryIDs indexOfObject:UNCATEGORIZED_ID] == NSNotFound) {
		HAMCard *category = [[HAMCard alloc] initWithID:UNCATEGORIZED_ID];
		NSString *categoryName = @"未分类";
		[self.config newCardWithID:category.UUID name:categoryName type:0 audio:nil image:nil]; // type 0 indicates a category
		category.isRemovable_ = NO;
		
		// insert the new category in to library
		NSInteger numChildren = [self.config childrenCardIDOfCat:LIB_ROOT].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:category.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:LIB_ROOT with:room atIndex:numChildren];
		
		self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	}
	
	// to be used for multiple times
	self.cardSelector = [[HAMCardSelectorViewController alloc] initWithNibName:@"HAMGridViewController" bundle:nil];
	self.cardSelector.config = self.config;
	self.cardSelector.userID = self.parentID;
	self.cardSelector.index = self.index;
	self.cardSelector.cellMode = self.cellMode;
	
	self.categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
	self.categoryEditor.delegate = self;
	self.categoryEditor.config = self.config;
	self.categoryEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

	self.cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
	self.cardEditor.config = self.config;
	self.cardEditor.delegate = self;
	self.cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
	self.cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.index == -1)	// edit mode
		self.cellMode = HAMGridCellModeEdit;
	else	// select mode
		self.cellMode = HAMGridCellModeAdd;
	
	if (self.cellMode == HAMGridCellModeEdit) {
		self.title = @"编辑卡片/分类";
	}
	else {
		self.title = @"选择分类";
		self.rightTopButton.hidden = YES;
	}
	
	// !!!
	[self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self categoryIDs].count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID=@"CategoryCell";
    HAMGridCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

	NSString *categoryID = [self categoryIDs][indexPath.row];
  	HAMCard *category = [self.config card:categoryID]; // only display categories
	
    cell.textLabel.text = category.name;
	cell.frameImageView.image = [UIImage imageNamed:@"classBG.png"];
	
	// show the first card as preview
	NSString *firstCardID = [[self.config childrenCardIDOfCat:categoryID] firstObject];
	if (firstCardID) {
		HAMCard *firstCard = [self.config card:firstCardID];
		UIImage *image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:firstCard.image.localPath]];
		cell.contentImageView.image = image;
	}
	else
		cell.contentImageView.image = [UIImage imageNamed:@"defaultImage.png"];
	
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"+.png"] forState:UIControlStateNormal];
	else { // Mode edit
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
		
		// don't allow editing system-provided categories or cards
		if (! category.isRemovable_)
			cell.rightTopButton.hidden = TRUE;
	}
		
	cell.indexPath = indexPath;
	cell.delegate = self;
	cell.selected = NO; // redundant?
	
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString *categoryID = [self categoryIDs][indexPath.row];
	self.cardSelector.categoryID = categoryID;
	
	[self.navigationController pushViewController:self.cardSelector animated:YES];
}

- (void)rightTopButtonPressed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建分类", @"创建卡片", nil];
	[actionSheet showFromRect:self.rightTopButton.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // create category
		self.categoryEditor.categoryID = nil;
		[self presentViewController:self.categoryEditor animated:YES completion:NULL];
	}
	else if (buttonIndex == 1) { // create card
		
		self.cardEditor.cardID = nil;
		self.cardEditor.categoryID = UNCATEGORIZED_ID;
		
		// a little bit hack
		UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
		[self.cardEditor.view insertSubview:background atIndex:0];
		
		[self presentViewController:self.cardEditor animated:YES completion:NULL];
	}
}

- (void)rightTopButtonPressedForCell:(HAMGridCell*)cell {
	HAMGridCell *gridCell = cell;
	
	if (self.cellMode == HAMGridCellModeAdd) { // Mode Add
		NSString *categoryID = [self categoryIDs][gridCell.indexPath.row];
		
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:categoryID animation:[self.config animationOfCat:self.parentID atIndex:self.index]]; // keep the animation unchanged
		[self.config updateRoomOfCat:self.parentID with:room atIndex:self.index];
		[self.navigationController popViewControllerAnimated:TRUE];
		
		// trace user events
		HAMCard *category = [self.config card:categoryID];
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:category.name, @"分类名称", [NSString stringWithFormat:@"%d", self.index], @"添加位置", nil];
		[MobClick event:@"add_category" attributes:attrs];
	}
	else { // Mode Edit
		self.categoryEditor.categoryID = [self categoryIDs][gridCell.indexPath.row];
		[self presentViewController:self.categoryEditor animated:YES completion:NULL];
	}
}

- (void)categoryEditorDidEndEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
	
	// update the categories displayed
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	[self.collectionView reloadData];
}

- (void)categoryEditorDidCancelEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
