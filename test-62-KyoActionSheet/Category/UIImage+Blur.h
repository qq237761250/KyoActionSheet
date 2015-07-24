//
//  UIImage+Blur.h
//  test-62-KyoActionSheet
//
//  Created by Kyo on 7/25/14.
//  Copyright (c) 2014 Kyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

- (UIImage *)applyBlurWithCrop:(CGRect) bounds resize:(CGSize) size blurRadius:(CGFloat) blurRadius tintColor:(UIColor *) tintColor saturationDeltaFactor:(CGFloat) saturationDeltaFactor maskImage:(UIImage *) maskImage;

@end
