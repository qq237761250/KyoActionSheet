//
//  DemoViewController.m
//  test-62-KyoActionSheet
//
//  Created by Kyo on 7/24/14.
//  Copyright (c) 2014 Kyo. All rights reserved.
//

#import "DemoViewController.h"
#import "KyoActionSheet.h"

@interface DemoViewController ()<UIActionSheetDelegate,KyoActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *arrayPay;
- (IBAction)btnSystemActionSheetTouchIn:(id)sender;
- (IBAction)btnKyoActionSheetTouchIN:(id)sender;

@end

@implementation DemoViewController

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
    
    self.arrayPay = [NSMutableArray array];
    [self.arrayPay addObject:@"淘宝支付"];
    [self.arrayPay addObject:@"苹果支付"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----------------
#pragma mark - Events

- (IBAction)btnSystemActionSheetTouchIn:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"支付方式" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for(NSString *title in self.arrayPay) { //添加支付按钮
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:@"取消"]; //添加取消按钮
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];
}

- (IBAction)btnKyoActionSheetTouchIN:(id)sender
{
    KyoActionSheet *actionSheet = [[KyoActionSheet alloc] initWithTitle:@"支付方式" withButtonTitle:self.arrayPay withCancelButtonTitle:@"取消" withDelegate:self];
    [actionSheet showInView:self.view];
}

#pragma mark -----------------
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"击中的是取消按钮:%d",buttonIndex);
        return;
    }
    
    NSLog(@"%d,%@",buttonIndex,self.arrayPay[buttonIndex]);
    
}

#pragma mark -----------------
#pragma mark - KyoActionSheetDelegate

- (void)kyoActionSheet:(KyoActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"击中的是取消按钮:%d",buttonIndex);
        return;
    }
    
    NSLog(@"%d,%@",buttonIndex,self.arrayPay[buttonIndex]);
    
}

@end
