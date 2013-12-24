//
//  HAMCardSelectorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-10-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardSelectorViewController.h"

@interface HAMCardSelectorViewController ()

@end

@implementation HAMCardSelectorViewController

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
	self.title = @"选择卡片";
	[self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"CardCell"];
	
	self.cardIDs = [self.config childrenCardIDOfCat:self.categoryID];
	self.selectedCardIDs = [[NSMutableSet alloc] init];

	// to be used for multiple times
	self.cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
	self.cardEditor.delegate = self;
	self.cardEditor.config = self.config;
	self.cardEditor.categoryID = self.categoryID;
	self.cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
	self.cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// cannot alter the name of unclassified category
	return (self.cellMode == HAMGridCellModeEdit) && self.categoryID;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// determine which mode we're in
	self.cellMode = (self.index == -1) ? HAMGridCellModeEdit : HAMGridCellModeAdd;
	
	if (self.cellMode == HAMGridCellModeEdit) {
		[self.rightTopButton setImage:[UIImage imageNamed:@"addnew.png"] forState:UIControlStateNormal];
	}
	else {
		self.bottomButton.hidden = NO;
		self.rightTopButton.hidden = YES;
		[self.bottomButton setImage:[UIImage imageNamed:@"confirm.png"] forState:UIControlStateNormal];
		// must select some cards before conforming
		self.bottomButton.enabled = NO;
	}
	
	[self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	return self.cardIDs.count;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString* cellID = @"CardCell";
	HAMGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
	
	// load the text
	HAMCard *card = [self.config card:[self cardIDs][indexPath.row]];
	cell.textLabel.text = card.name;
	
	cell.contentImageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
	cell.frameImageView.image = [UIImage imageNamed:@"cardBG.png"];
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"box.png"]forState:UIControlStateNormal];
	else { // Mode edit
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
		
		// don't allow editing system-provided categories or cards
		if (! card.isRemovable_)
			cell.rightTopButton.hidden = TRUE;
	}
	
	cell.indexPath = indexPath;
	cell.selected = NO;
	cell.delegate = self;
	
	return cell;
}

// create card
- (void)rightTopButtonPressed:(id)sender {
	
	self.cardEditor.cardID = nil;
	
	// !!!
	UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
	[self.cardEditor.view insertSubview:background atIndex:NO];
	
	[self presentViewController:self.cardEditor animated:YES completion:NULL];
}

// add the selected cards
- (void)bottomButtonPressed:(id)sender {
	
	int animation = [self.config animationOfCat:self.userID atIndex:self.index]; // keep the animation unchanged
	NSMutableArray *rooms = [[NSMutableArray alloc] initWithCapacity:self.selectedCardIDs.count];
	
	// for statistics recording
	HAMCard *category = [self.config card:self.categoryID];
	NSInteger index = self.index;
	
	// retain the order of selection
	for (NSString *cardID in [self cardIDs])
		if ([self.selectedCardIDs containsObject:cardID]) {
			[rooms addObject:[[HAMRoom alloc] initWithCardID:cardID animation:animation]];
			
			// trace user events
			HAMCard *card = [self.config card:cardID];
			NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:card.name, @"卡片名称", category.name, @"分类名称", [NSString stringWithFormat:@"%d", index++], @"添加位置", nil];
			[MobClick event:@"add_card" attributes:attrs];
		}
	
	// insert all the selected cards
	[self.config insertChildren:rooms intoCat:self.userID atIndex:self.index];
	
	NSArray *viewsInStack = self.navigationController.viewControllers;
	// pop out two views from the navigation stack, including the current one
	[self.navigationController popToViewController:viewsInStack[viewsInStack.count - 3] animated:TRUE];

}

- (void)rightTopButtonPressedForCell:(HAMGridCell*)cell {
	HAMGridCell *gridCell = cell;
	NSString *cardID = [self cardIDs][gridCell.indexPath.row];
	
	if (self.cellMode == HAMGridCellModeAdd) {
		if (gridCell.selected) {
			[self.selectedCardIDs removeObject:cardID];
			
			gridCell.selected = NO;
			[gridCell.rightTopButton setImage:[UIImage imageNamed:@"box.png"] forState:UIControlStateNormal];
			
			// remove the button on the right of top bar
			if (self.selectedCardIDs.count == 0)
				self.bottomButton.enabled = NO;
		}
		else { // unselected
			// activate the button on the right of top bar
			if (self.selectedCardIDs.count == 0)
				self.bottomButton.enabled = YES;
			
			NSString *cardID = self.cardIDs[gridCell.indexPath.row];
			[self.selectedCardIDs addObject:cardID];
			
			gridCell.selected = YES;
			[gridCell.rightTopButton setImage:[UIImage imageNamed:@"checkedbox.png"] forState:UIControlStateNormal];
		}
	}
	else { // Mode Edit
		
		self.cardEditor.cardID = cardID;
			
		// !!!
		UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
		[self.cardEditor.view insertSubview:background atIndex:NO];
		
		[self presentViewController:self.cardEditor animated:YES completion:NULL];
	}
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
	// update the cards displayed
	self.cardIDs = [self.config childrenCardIDOfCat:self.categoryID];
	[self.collectionView reloadData];
}

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
