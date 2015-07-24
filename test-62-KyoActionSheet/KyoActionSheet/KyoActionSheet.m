//
//  KyoActionSheet.m
//  test-62-KyoActionSheet
//
//  Created by Kyo on 7/24/14.
//  Copyright (c) 2014 Kyo. All rights reserved.
//

#import "KyoActionSheet.h"
#import "UIImage+Blur.h"

#define kKyoPhoneActionSheetTitleHeight  48.0f   //标题高度
#define kKyoPhoneActionSheetButtonHeight 42.0f   //按钮高度
#define kKyoPhoneActionSheetBroderSpace  6.0f    //边框间距
#define kKyoPhoneActionSheetButtonSpace  1.0f    //按钮间距

#define kKyoPadActionSheetTitleHeight  80.0f   //标题高度
#define kKyoPadActionSheetButtonHeight 72.0f   //按钮高度
#define kKyoPadActionSheetBroderSpace  12.0f    //边框间距
#define kKyoPadActionSheetButtonSpace  1.0f    //按钮间距

#define kKyoPhoneMaskCornerRadii CGSizeMake(4, 4)    //圆角
#define kKyoPadMaskCornerRadii CGSizeMake(8, 8)    //圆角

#define kKyoBlurRadius  10.0f
#define kKyoDeltaFactor 2.0f
#define kKyoNormalClickColor        [UIColor colorWithWhite:1.0f alpha:0.9f]
#define kKyoHightlightClickColor    [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:0.9f]

#define kKyoSystemMoreThan7 [[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0

@interface KyoActionSheet()
{
    CGFloat _buttonViewWidth;    //存放button的view的宽度
    CGFloat _buttonViewHeight;   //存放button的view的高度
}

@property (nonatomic, strong) UIView *buttonView;   //存放button的view
@property (nonatomic, strong) UIButton *btnBackgrounp;  //背景button

@property (nonatomic, strong) UILabel *lblTitle;    //标题
@property (nonatomic, strong) UIButton *btnCancel;  //取消按钮
@property (nonatomic, strong) NSMutableArray *arrayOrtherButton;    //其他按钮

@property (nonatomic, strong) UIImage *imgSupview;  //父视图的图像截图

- (void)appearAnimation:(void(^)())completed;    //显示动画
- (void)disappearAnimation:(void(^)())completed; //隐藏动画

- (void)reGetSupviewImage;  //得到父视图的图像
- (void)reSetMask; //重新设置button的mask
- (void)reSetBlur;  //设置毛玻璃效果

@end

@implementation KyoActionSheet

#pragma mark -----------------------
#pragma mark - CycLife

- (void)dealloc
{
#if DEBUG
    NSLog(@"KyoActionSheet弹框释放");
#endif
}

- (id)initWithTitle:(NSString *)title withButtonTitle:(NSArray *)arrayButtonTitle withCancelButtonTitle:(NSString *)cancelButtonTitle withDelegate:(id<KyoActionSheetDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        self.cancelButtonIndex = -1;
        self.title = title;
        self.arrayButtonTitle = [arrayButtonTitle isKindOfClass:[NSMutableArray class]] ? arrayButtonTitle : [arrayButtonTitle mutableCopy];
        self.numberOfButton = self.arrayButtonTitle.count;
        self.cancelButtonTitle = cancelButtonTitle;
        self.deleagte = delegate;
    }
    
    return self;
    
}

#pragma mark --------------------
#pragma mark - Settings

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
#if DEBUG
    NSLog(@"%@",NSStringFromCGRect(self.frame));
#endif
    
    if (self && [self superview]) { //如果已经显示出来了
        [self reSetMask];  //重新设置mask
        if (kKyoSystemMoreThan7) {
            [self performSelector:@selector(reSetBlur) withObject:nil afterDelay:0];
        }
    }
    
}

#pragma mark --------------------
#pragma mark - Events

- (void)btnTouchIn:(UIButton *)btn
{
    if (!kKyoSystemMoreThan7) {
        btn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
    
    [self disappearAnimation:^{
        if (self.deleagte && [self.deleagte respondsToSelector:@selector(kyoActionSheet:clickedButtonAtIndex:)]) {
            [self.deleagte kyoActionSheet:self clickedButtonAtIndex:btn.tag];
        }
        [self removeFromSuperview];
    }];
}

- (void)btnTouchDwon:(UIButton *)btn
{
    if (!kKyoSystemMoreThan7) {
        btn.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:0.8];
    }
}

- (void)btnTouchOut:(UIButton *)btn
{
    if (!kKyoSystemMoreThan7) {
        btn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

- (void)btnTouchCancel:(UIButton *)btn
{
    if (!kKyoSystemMoreThan7) {
        btn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

- (void)btnTouchDragExit:(UIButton *)btn
{
    if (!kKyoSystemMoreThan7) {
        btn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

#pragma mark --------------------
#pragma mark - Methods

- (void)showInView:(UIView *)view
{
    if (!view) return;
    if (self.numberOfButton <= 0) return;
    
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:self];
    
    //背景button
    self.btnBackgrounp = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnBackgrounp.tag = self.cancelButtonIndex;
    self.btnBackgrounp.frame = self.bounds;
    self.btnBackgrounp.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    self.btnBackgrounp.alpha = 0;
    self.btnBackgrounp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.btnBackgrounp];
    
    //存放button的view
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _buttonViewHeight = kKyoPhoneActionSheetBroderSpace*2+kKyoPhoneActionSheetTitleHeight+(self.arrayButtonTitle.count)*kKyoPhoneActionSheetButtonSpace + self.arrayButtonTitle.count*kKyoPhoneActionSheetButtonHeight +kKyoPhoneActionSheetButtonHeight;   //得到view的高度
        _buttonViewWidth = self.bounds.size.width - kKyoPhoneActionSheetBroderSpace*2;  //得到view的宽度
    } else {
        _buttonViewHeight = kKyoPadActionSheetBroderSpace*2+kKyoPadActionSheetTitleHeight+(self.arrayButtonTitle.count)*kKyoPadActionSheetButtonSpace + self.arrayButtonTitle.count*kKyoPadActionSheetButtonHeight +kKyoPadActionSheetButtonHeight;   //得到view的高度
        _buttonViewWidth = self.bounds.size.width - kKyoPadActionSheetBroderSpace*2;  //得到view的宽度
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(kKyoPhoneActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight)];
    } else {
        self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(kKyoPadActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight)];
    }
    self.buttonView.backgroundColor = [UIColor clearColor];
    self.buttonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.buttonView];
    
    //添加取消按钮到buttonView
    self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCancel.tag = self.cancelButtonIndex;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.btnCancel.frame = CGRectMake(0, _buttonViewHeight-kKyoPhoneActionSheetButtonHeight-kKyoPhoneActionSheetBroderSpace, _buttonViewWidth, kKyoPhoneActionSheetButtonHeight);
        self.btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    } else {
        self.btnCancel.frame = CGRectMake(0, _buttonViewHeight-kKyoPadActionSheetButtonHeight-kKyoPadActionSheetBroderSpace, _buttonViewWidth, kKyoPadActionSheetButtonHeight);
        self.btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    }
    self.btnCancel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    [self.btnCancel setTitleColor:[UIColor colorWithRed:28.0/255.0 green:130.0/255.0 blue:231.0/255.0 alpha:1] forState:UIControlStateNormal];
    [self.btnCancel setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    self.btnCancel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.btnCancel addTarget:self action:@selector(btnTouchIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCancel addTarget:self action:@selector(btnTouchDwon:) forControlEvents:UIControlEventTouchDown];
    [self.btnCancel addTarget:self action:@selector(btnTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    [self.btnCancel addTarget:self action:@selector(btnTouchOut:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnCancel addTarget:self action:@selector(btnTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self.buttonView addSubview:self.btnCancel];
    
    //添加标题
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _buttonViewWidth, kKyoPhoneActionSheetTitleHeight)];
        self.lblTitle.font = [UIFont systemFontOfSize:13];
    } else {
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _buttonViewWidth, kKyoPadActionSheetTitleHeight)];
        self.lblTitle.font = [UIFont systemFontOfSize:20];
    }
    self.lblTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    self.lblTitle.text = self.title;
    self.lblTitle.textColor = [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1];
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.buttonView addSubview:self.lblTitle];
    
    
    //添加其他按钮
    for (int i = 0; i < self.arrayButtonTitle.count; i++) {
        NSString *buttonTitle = self.arrayButtonTitle[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        CGFloat y = 0.0f;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            y = kKyoPhoneActionSheetTitleHeight+kKyoPhoneActionSheetButtonSpace+(kKyoPhoneActionSheetButtonHeight+kKyoPhoneActionSheetButtonSpace)*i;   //得到按钮的y坐标位置
            btn.frame = CGRectMake(0, y, _buttonViewWidth, kKyoPhoneActionSheetButtonHeight);
            btn.titleLabel.font = [UIFont systemFontOfSize:21];
        } else {
            y = kKyoPadActionSheetTitleHeight+kKyoPadActionSheetButtonSpace+(kKyoPadActionSheetButtonHeight+kKyoPadActionSheetButtonSpace)*i;   //得到按钮的y坐标位置
            btn.frame = CGRectMake(0, y, _buttonViewWidth, kKyoPadActionSheetButtonHeight);
            btn.titleLabel.font = [UIFont systemFontOfSize:30];
        }
        btn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
        [btn setTitleColor:[UIColor colorWithRed:28.0/255.0 green:130.0/255.0 blue:231.0/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitle:buttonTitle forState:UIControlStateNormal];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [btn addTarget:self action:@selector(btnTouchIn:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(btnTouchDwon:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(btnTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [btn addTarget:self action:@selector(btnTouchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [btn addTarget:self action:@selector(btnTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
        
        if (!self.arrayOrtherButton) {
            self.arrayOrtherButton = [NSMutableArray array];
        }
        [self.arrayOrtherButton addObject:btn];
        
        [self.buttonView addSubview:btn];
    }
    
    //设置按钮和标题的mask，既设置圆角
    [self reSetMask];
    
    //动画显示出，显示完成后设置背景按钮的击中事件,以及如果是ios7以上，显示毛玻璃
    [self appearAnimation:^{
        [self.btnBackgrounp addTarget:self action:@selector(btnTouchIn:) forControlEvents:UIControlEventTouchUpInside];
        if (kKyoSystemMoreThan7) {
            [self reSetBlur];
        }
    }];
}

//显示动画
- (void)appearAnimation:(void(^)())completed
{
    if (kKyoSystemMoreThan7) {
        [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:5.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.buttonView.frame = CGRectMake(kKyoPhoneActionSheetBroderSpace, self.bounds.size.height-_buttonViewHeight, _buttonViewWidth, _buttonViewHeight);
            } else {
                self.buttonView.frame = CGRectMake(kKyoPadActionSheetBroderSpace, self.bounds.size.height-_buttonViewHeight, _buttonViewWidth, _buttonViewHeight);
            }
            self.btnBackgrounp.alpha = 1;
        } completion:^(BOOL finished) {
            if (completed) {
                completed();
            }
        }];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.buttonView.frame = CGRectMake(kKyoPhoneActionSheetBroderSpace, self.bounds.size.height-_buttonViewHeight, _buttonViewWidth, _buttonViewHeight);
            } else {
                self.buttonView.frame = CGRectMake(kKyoPadActionSheetBroderSpace, self.bounds.size.height-_buttonViewHeight, _buttonViewWidth, _buttonViewHeight);
            }
            self.btnBackgrounp.alpha = 1;
        } completion:^(BOOL finished) {
            if (completed) {
                completed();
            }
        }];
    }
}

//隐藏动画
- (void)disappearAnimation:(void(^)())completed
{
//    if (kKyoSystemMoreThan7) {
//        [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:10.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//                self.buttonView.frame = CGRectMake(kKyoPhoneActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight);
//            } else {
//                self.buttonView.frame = CGRectMake(kKyoPadActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight);
//            }
//            self.btnBackgrounp.alpha = 0;
//        } completion:^(BOOL finished) {
//            if (completed) {
//                completed();
//            }
//        }];
//    } else {
//        [UIView animateWithDuration:1.0f animations:^{
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//                self.buttonView.frame = CGRectMake(kKyoPhoneActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight);
//            } else {
//                self.buttonView.frame = CGRectMake(kKyoPadActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight);
//            }
//            self.btnBackgrounp.alpha = 0;
//        } completion:^(BOOL finished) {
//            if (completed) {
//                completed();
//            }
//        }];
//    }
    
    [UIView animateWithDuration:0.3f animations:^{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.buttonView.frame = CGRectMake(kKyoPhoneActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight);
        } else {
            self.buttonView.frame = CGRectMake(kKyoPadActionSheetBroderSpace, self.bounds.size.height, _buttonViewWidth, _buttonViewHeight);
        }
        self.btnBackgrounp.alpha = 0;
    } completion:^(BOOL finished) {
        if (completed) {
            completed();
        }
    }];
}

//重新设置的mask
- (void)reSetMask
{
    CGSize cornerRadiiSize = CGSizeZero;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _buttonViewWidth = self.bounds.size.width - kKyoPhoneActionSheetBroderSpace*2;  //得到view的宽度
        cornerRadiiSize = kKyoPhoneMaskCornerRadii;
    } else {
        _buttonViewWidth = self.bounds.size.width - kKyoPadActionSheetBroderSpace*2;  //得到view的宽度
        cornerRadiiSize = kKyoPadMaskCornerRadii;
    }
    
    //设置取消按钮的
    CAShapeLayer *cancelMaskLayer = [CAShapeLayer layer];
    cancelMaskLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.btnCancel.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadiiSize] CGPath];
    self.btnCancel.layer.mask = cancelMaskLayer;
    
    //设置标题的
    CAShapeLayer *titleMaskLayer = [CAShapeLayer layer];
    titleMaskLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.lblTitle.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:cornerRadiiSize] CGPath];
    self.lblTitle.layer.mask = titleMaskLayer;
    
    //设置其他按钮的最后一个按钮
    UIButton *btnLast = [self.arrayOrtherButton lastObject];
    CAShapeLayer *ortherMaskLayer = [CAShapeLayer layer];
    ortherMaskLayer.path = [[UIBezierPath bezierPathWithRoundedRect:btnLast.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:cornerRadiiSize] CGPath];
    btnLast.layer.mask = ortherMaskLayer;
    
    //设置其他按钮除了最后一个按钮
    for (int i = 0; i < self.arrayOrtherButton.count-1; i++) {
        UIButton *btn = self.arrayOrtherButton[i];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = CGPathCreateWithRect(btn.bounds, NULL);
        btn.layer.mask = maskLayer;
    }
    
}

//设置毛玻璃效果
- (void)reSetBlur
{
    [self reGetSupviewImage];   //先截图
    
    //设置取消按钮的毛玻璃
    __block UIImage *imgCancelBlurNormal = nil;
    __block UIImage *imgCancelBlurHighlight = nil;
    CGRect cancelRectConverParent = [[self superview] convertRect:self.btnCancel.bounds fromView:self.btnCancel];   //对应到父视图的坐标
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        imgCancelBlurNormal = [self.imgSupview applyBlurWithCrop:cancelRectConverParent resize:cancelRectConverParent.size blurRadius:kKyoBlurRadius tintColor:kKyoNormalClickColor saturationDeltaFactor:kKyoDeltaFactor maskImage:nil];
        imgCancelBlurHighlight = [self.imgSupview applyBlurWithCrop:cancelRectConverParent resize:cancelRectConverParent.size blurRadius:kKyoBlurRadius tintColor:kKyoHightlightClickColor saturationDeltaFactor:kKyoDeltaFactor maskImage:nil];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.btnCancel setBackgroundImage:imgCancelBlurNormal forState:UIControlStateNormal];
            [self.btnCancel setBackgroundImage:imgCancelBlurHighlight forState:UIControlStateHighlighted];
        });
    });
    
    //设置标题的毛玻璃
    __block UIImage *imgTitleBlur = nil;
    CGRect titleRectConverParent = [[self superview] convertRect:self.lblTitle.bounds fromView:self.lblTitle];   //对应到父视图的坐标
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        imgTitleBlur = [self.imgSupview applyBlurWithCrop:titleRectConverParent resize:titleRectConverParent.size blurRadius:kKyoBlurRadius tintColor:kKyoNormalClickColor saturationDeltaFactor:kKyoDeltaFactor maskImage:nil];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.lblTitle.backgroundColor = [UIColor colorWithPatternImage:imgTitleBlur];
        });
    });
    
    //设置其他按钮的毛玻璃
    for (int i = 0; i < self.arrayOrtherButton.count; i++) {
        UIButton *btn = self.arrayOrtherButton[i];
        __block UIImage *imgBtnBlurNormal = nil;
        __block UIImage *imgBtnBlurHighlight = nil;
        CGRect btnRectConverParent = [[self superview] convertRect:btn.bounds fromView:btn];   //对应到父视图的坐标
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            imgBtnBlurNormal = [self.imgSupview applyBlurWithCrop:btnRectConverParent resize:btnRectConverParent.size blurRadius:kKyoBlurRadius tintColor:kKyoNormalClickColor saturationDeltaFactor:kKyoDeltaFactor maskImage:nil];
            imgBtnBlurHighlight = [self.imgSupview applyBlurWithCrop:btnRectConverParent resize:btnRectConverParent.size blurRadius:kKyoBlurRadius tintColor:kKyoHightlightClickColor saturationDeltaFactor:kKyoDeltaFactor maskImage:nil];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [btn setBackgroundImage:imgBtnBlurNormal forState:UIControlStateNormal];
                [btn setBackgroundImage:imgBtnBlurHighlight forState:UIControlStateHighlighted];
            });
        });
    }
}

//得到父视图的图像
- (void)reGetSupviewImage
{
    //ios7的截屏发现不适用,原因是afterScreenUpdates:YES才能更新self.hidden,但是graphics也有局限性，看情况来吧
//    CGRect supviewRect = [self superview].bounds;
//    CGSize supviewSize = CGSizeMake([self superview].bounds.size.width, [self superview].bounds.size.height);
//    
//    UIGraphicsBeginImageContextWithOptions(supviewSize, NO, 1);
//    [[self superview] drawViewHierarchyInRect:supviewRect afterScreenUpdates:NO];
//    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    self.hidden = YES;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([self superview].bounds.size.width, [self superview].bounds.size.height), NO, 1);
    [[self superview].layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.hidden = NO;
    self.imgSupview = snapshot;
}

@end
