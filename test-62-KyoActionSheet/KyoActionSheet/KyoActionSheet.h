//
//  KyoActionSheet.h
//  test-62-KyoActionSheet
//
//  Created by Kyo on 7/24/14.
//  Copyright (c) 2014 Kyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KyoActionSheetDelegate;

@interface KyoActionSheet : UIView

@property (nonatomic, strong) NSString *title;  //标题
@property (nonatomic, strong) NSMutableArray *arrayButtonTitle; //所有按钮标题
@property (nonatomic, assign) NSInteger numberOfButton; //按钮总数
@property (nonatomic, assign) NSString *cancelButtonTitle;  //取消按钮显示文字
@property (nonatomic, assign) NSInteger cancelButtonIndex;  //取消按钮index
@property (nonatomic, assign) id<KyoActionSheetDelegate> deleagte;


- (id)initWithTitle:(NSString *)title withButtonTitle:(NSArray *)arrayButtonTitle withCancelButtonTitle:(NSString *)cancelButtonTitle withDelegate:(id<KyoActionSheetDelegate>)delegate;

- (void)showInView:(UIView *)view;

@end

@protocol KyoActionSheetDelegate <NSObject>

- (void)kyoActionSheet:(KyoActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
