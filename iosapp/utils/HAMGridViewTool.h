//
//  HAMGridViewTool.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "HAMViewInfo.h"
#import "HAMTools.h"
#import "HAMConfig.h"

@interface HAMGridViewTool : NSObject <UIScrollViewDelegate> {
    HAMViewInfo* viewInfo;
    HAMConfig* config;
    
    UIScrollView* scrollView_;
    int totalPageNum_;
    int currentPage_;
    NSMutableArray* pageViews_;
    
    UIViewController* viewController_;
    NSMutableArray* cardViewArray_;
    NSString* currentUUID_;
}

@property NSMutableArray* cardViewArray_;

-(id)initWithView:(UIScrollView*)_view viewInfo:(HAMViewInfo*)_viewInfo config:(HAMConfig*)_config delegate:(id)_viewController edit:(Boolean)_edit;
-(void)prepareRefreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage;
-(void)refreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage;
-(void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum;

//for sub class
- (UIButton*)addButtonWithi:(int)i j:(int)j onPage:(int)pageIndex picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType;
- (void)addLabelWithi:(int)i j:(int)j onPage:(int)pageIndex text:(NSString*)text color:(UIColor*)color tag:(int)index;
- (void)addCardAtPos:(int)pos onPage:(int)pageIndex cardID:(NSString*)cardID index:(int)index;

@end