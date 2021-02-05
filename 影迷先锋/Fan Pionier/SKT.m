//
//  SKT.m
//  SKT
//
//  Created by rose on 2020/7/23.
//  Copyright © 2020 SK. All rights reserved.
//

#import "SKT.h"
#import <objc/runtime.h>


#pragma mark ################ --SKT扩展-- ################

@implementation UIColor (SKColor)

+ (UIColor *)colorWithHex:(NSString *)string {
    
    NSString *cleanString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (void)colorWithImageUrl:(NSString *)url block:(SKColorBlock)block {
    [[UIImageView new] imageUrl:url block:^(UIImage * _Nullable image, NSString * _Nullable imageUrl) {
        block(image.color);
    }];
}

- (UIColor *)light {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [UIColor colorWithRed:red+0.2 green:green+0.2 blue:blue+0.2 alpha:1];
}

- (UIColor *)dark {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [UIColor colorWithRed:red-0.2 green:green-0.2 blue:blue-0.2 alpha:1];
}

- (UIColor *)checkColor:(UIColor *)color {
    CGFloat red1    = 0.0;
    CGFloat green1  = 0.0;
    CGFloat blue1   = 0.0;
    CGFloat alpha1  = 0.0;
    
    CGFloat red2    = 0.0;
    CGFloat green2  = 0.0;
    CGFloat blue2   = 0.0;
    CGFloat alpha2  = 0.0;
    
    [self getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [color getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];

    if ((fabs(red1-red2) <0.1) && (fabs(green1-green2) <0.1) && (fabs(blue1-blue2) <0.1)) {
        if ((red1+green1+blue1) >= 1.5) {
            return UIColor.blackColor;
        } else {
            return UIColor.whiteColor;
        }
    }
    return self;
}

- (UIColor *)alpha:(CGFloat)alpha {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat beta = 0.0;
    
    [self getRed:&red green:&green blue:&blue alpha:&beta];
    
    return [UIColor colorWithRed:red-0.2 green:green-0.2 blue:blue-0.2 alpha:alpha];
}

- (NSString *)hexString {
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;
    
    return [NSString stringWithFormat:@"%06x", rgb];
}

@end


@implementation UIImage (SKImage)

+ (void)image:(id)sender Path:(NSString *)path {
    if ([path hasPrefix:@"https"]) {
        
        NSString *encodeUrl = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodeUrl];
        if ([sender isKindOfClass:UIImageView.class]) {
            [((UIImageView *)sender) sd_setImageWithURL:url placeholderImage:[[UIImage imageNamed:@"icon-1"] initwithColor:SKCurrentColor]];
        } else {
            [((UIButton *)sender) sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[[UIImage imageNamed:@"launch"] initwithColor:SKCurrentColor]];
        }
    } else {
        NSString *str = path.imageUrl;
        if ([sender isKindOfClass:UIImageView.class]) {
            [((UIImageView *)sender) sd_setImageWithURL:[NSURL fileURLWithPath:(str?str:@"")] placeholderImage:[[UIImage imageNamed:@"icon-1"] initwithColor:SKCurrentColor]];
        } else {
            [((UIButton *)sender) sd_setImageWithURL:[NSURL fileURLWithPath:(str?str:@"")] forState:UIControlStateNormal placeholderImage:[[UIImage imageNamed:@"icon-1"] initwithColor:SKCurrentColor]];
        }
    }
}

+ (NSArray *)images:(NSArray *)urls {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *path in urls) {
        NSString *str = path.imageUrl;
        UIImage *image = [UIImage imageWithContentsOfFile:str];
        if (image) {
            [array addObject:image];
        }
    }
    
    return array.copy;
}

+ (UIImage *)image:(NSString *)path {
    NSString *str = path.imageUrl;
    UIImage *image = [UIImage imageWithContentsOfFile:str];
    
    return image;
}

- (NSString *)imageUrl {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = [SKT skt].color;
    NSArray *paths      = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filename  = [NSString stringWithFormat:@"%ld.png",self.hash];
    NSString *filePath  = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    NSLog(@"%@",filePath);
    BOOL result         = [UIImagePNGRepresentation(self) writeToFile:filePath atomically:NO];
    
    if (!result) {
        NSLog(@"未知错误");
        return nil;
    } else {
        return filename;
    }
}

- (UIImage *)spinImage:(UIImageOrientation)orientation {
    
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate =M_PI_2;
            rect =CGRectMake(0,0,self.size.height, self.size.width);
            translateX=0;
            translateY= -rect.size.width;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
            
        case UIImageOrientationRight:
            
            rotate =3 *M_PI_2;
            rect =CGRectMake(0,0,self.size.height, self.size.width);
            translateX= -rect.size.height;
            translateY=0;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
            
        case UIImageOrientationDown:
            
            rotate =M_PI;
            rect =CGRectMake(0,0,self.size.width, self.size.height);
            translateX= -rect.size.width;
            translateY= -rect.size.height;
            break;
            
        default:
            
            rotate =0.0;
            rect =CGRectMake(0,0,self.size.width, self.size.height);
            translateX=0;
            translateY=0;
            break;
    }
    
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    //做CTM变换
    
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX,translateY);
    CGContextScaleCTM(context, scaleX,scaleY);
    
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0,0,rect.size.width, rect.size.height), self.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
}

- (UIImage *)initwithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
}

- (UIImage *)zoom:(CGFloat)size {
    UIImage *newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size*UIScreen.mainScreen.scale;
    CGFloat targetHeight = targetWidth;
    CGSize zoomsize = CGSizeMake(targetWidth, targetWidth);
//    if (width > height) {
//        zoomsize = CGSizeMake(size, targetHeight/targetWidth*size/2);
//    } else {
//        zoomsize = CGSizeMake(targetWidth, targetHeight/targetWidth*size/2);
//    }
    
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, zoomsize) ==NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) *0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) *0.5;
        }
    }
    UIGraphicsBeginImageContext(zoomsize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [self drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)color:(SKColorBlock)block {

    dispatch_queue_t queue = dispatch_queue_create("com.sk.asyncQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{

        NSMutableArray *colors = [NSMutableArray array];
        NSInteger count = 2;
        while (colors.count<4) {
            for (NSInteger i=0; i<count; i++) {
                for (NSInteger j=0; j<count; j++) {
                    UIColor *color = [self colorAtPixel:CGPointMake(i?(self.size.width/i):2, j?(self.size.height/j):2)];
                    if (color) {
                        [colors addObject:color];
                    }
                }
            }

            count ++;
        }

        UIColor *color = [self mixColors:colors ratio:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(color);
        });
    });
}

- (UIColor *)color {
    NSMutableArray *colors = [NSMutableArray array];
    NSInteger count = 2;
    while (colors.count<4) {
        for (NSInteger i=0; i<count; i++) {
            for (NSInteger j=0; j<count; j++) {
                UIColor *color = [self colorAtPixel:CGPointMake(i?(self.size.width/i):2, j?(self.size.height/j):2)];
                if (color) {
                    [colors addObject:color];
                }
            }
        }

        count ++;
    }

    UIColor *color = [self mixColors:colors ratio:1];
    return color;
}

- (UIColor *)colorAtPixel:(CGPoint)point {
    // 如果点超出图像范围，则退出
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }

    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);

    // 把[0,255]的颜色值映射至[0,1]区间
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    if ((red >=0.88 && green>=0.88 && blue>=0.88) || alpha<=0.1) {
        return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)mixColors:(NSArray *)colors ratio:(CGFloat)ratio {
    
    if(ratio > 1) {
        ratio = 1;
    }
    
    UIColor *destColor = nil;
    for (UIColor *souceColor in colors) {
        if (destColor) {
            const CGFloat * components1 = CGColorGetComponents(destColor.CGColor);
            const CGFloat * components2 = CGColorGetComponents(souceColor.CGColor);
            
            CGFloat r = components1[0]*ratio + components2[0]*(1-ratio);
            CGFloat g = components1[1]*ratio + components2[1]*(1-ratio);
            CGFloat b = components1[2]*ratio + components2[2]*(1-ratio);
            
            destColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
        } else {
            destColor = souceColor;
        }
    }
    
    return destColor;
}

- (UIImage *)combineImage:(UIImage *)upImage DownImage:(UIImage *)downImage {
    
    UIImage * image1 = upImage;
    UIImage * image2 = downImage;
    
    if (image1 == nil) {
        return image2;
    }
    CGFloat width = image1.size.width;
    CGFloat height = image1.size.height  + image2.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    // UIGraphicsBeginImageContext(offScreenSize);用这个重绘图片会模糊
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, [UIScreen mainScreen].scale);
    
    CGRect rectUp = CGRectMake(0, 0, image1.size.width, image1.size.height);
    [image1 drawInRect:rectUp];
    
    CGRect rectDown = CGRectMake((width - image2.size.width)/2, rectUp.origin.y + rectUp.size.height, image2.size.width, image2.size.height);
    [image2 drawInRect:rectDown];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imagez;
}

@end


@implementation UIScrollView (SKScrollView)

- (UIImage *)snapshotScrollView {
    UIScrollView *scrollView = self;
    
    if (!scrollView.contentSize.height) {
        return scrollView.image;
    }
    
    UIView *superView = scrollView.superview;
    
    // 保存原来的偏移量
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(self.frame.origin.y, self.frame.origin.x, superView.frame.size.height-self.frame.size.height-self.frame.origin.y, superView.frame.size.width-self.frame.size.width-self.frame.origin.x);
    
    // 设置截图需要的偏移量和frame
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.contentSize.height);
    // 创建临时view，并且把要截图的view添加到临时view上面
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.contentSize.height)];
    [scrollView removeFromSuperview];
    [tempView addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(tempView);
        
        [superView layoutIfNeeded];
    }];
    
    UIImage * image = scrollView.image;
    
    // 恢复截图view原来的状态
    [scrollView removeFromSuperview];
    [superView addSubview:scrollView];
    [superView sendSubviewToBack: scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView).offset(edgeInsets.top);
        make.left.equalTo(superView).offset(edgeInsets.left);
        make.right.equalTo(superView).offset(-edgeInsets.right);
        make.bottom.equalTo(superView).offset(-edgeInsets.bottom);
        
        [superView layoutIfNeeded];
    }];
    
    return image;
}

@end

@implementation UIView (SKView)

- (void)radiusWithRadius:(CGFloat)radius  corner:(UIRectCorner)corner {
    if (@available(iOS 11.0, *)) {
        self.layer.cornerRadius = radius;
        self.layer.maskedCorners = (CACornerMask)corner;
    } else {
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
}

- (void)radian:(UISwipeGestureRecognizerDirection)direction radian:(CGFloat)radian {
    if(radian == 0) return;
    CGFloat t_width = CGRectGetWidth(self.frame); // 宽
    CGFloat t_height = CGRectGetHeight(self.frame); // 高
    CGFloat height = fabs(radian); // 圆弧高度
    CGFloat x = 0;
    CGFloat y = 0;
    
    // 计算圆弧的最大高度
    CGFloat _maxRadian = 0;
    switch (direction) {
        case UISwipeGestureRecognizerDirectionDown:
        case UISwipeGestureRecognizerDirectionUp:
            _maxRadian =  MIN(t_height, t_width / 2);
            break;
        case UISwipeGestureRecognizerDirectionRight:
        case UISwipeGestureRecognizerDirectionLeft:
            _maxRadian =  MIN(t_height / 2, t_width);
            break;
        default:
            break;
    }
    if(height > _maxRadian){
        NSLog(@"圆弧半径过大, 跳过设置。");
        return;
    }
    
    // 计算半径
    CGFloat radius = 0;
    switch (direction) {
        case UISwipeGestureRecognizerDirectionDown:
        case UISwipeGestureRecognizerDirectionUp:
        {
            CGFloat c = sqrt(pow(t_width / 2, 2) + pow(height, 2));
            CGFloat sin_bc = height / c;
            radius = c / ( sin_bc * 2);
        }
            break;
        case UISwipeGestureRecognizerDirectionLeft:
        case UISwipeGestureRecognizerDirectionRight:
        {
            CGFloat c = sqrt(pow(t_height / 2, 2) + pow(height, 2));
            CGFloat sin_bc = height / c;
            radius = c / ( sin_bc * 2);
        }
            break;
        default:
            break;
    }
    
    // 画圆
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
    CGMutablePathRef path = CGPathCreateMutable();
    switch (direction) {
        case UISwipeGestureRecognizerDirectionDown:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, t_width,t_height - height);
                CGPathAddArc(path,NULL, t_width / 2, t_height - radius, radius, asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), NO);
            }else{
                CGPathMoveToPoint(path,NULL, t_width,t_height);
                CGPathAddArc(path,NULL, t_width / 2, t_height + radius - height, radius, 2 * M_PI - asin((radius - height ) / radius), M_PI + asin((radius - height ) / radius), YES);
            }
            CGPathAddLineToPoint(path,NULL, x, y);
            CGPathAddLineToPoint(path,NULL, t_width, y);
        }
            break;
        case UISwipeGestureRecognizerDirectionUp:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, t_width, height);
                CGPathAddArc(path,NULL, t_width / 2, radius, radius, 2 * M_PI - asin((radius - height ) / radius), M_PI + asin((radius - height ) / radius), YES);
            }else{
                CGPathMoveToPoint(path,NULL, t_width, y);
                CGPathAddArc(path,NULL, t_width / 2, height - radius, radius, asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), NO);
            }
            CGPathAddLineToPoint(path,NULL, x, t_height);
            CGPathAddLineToPoint(path,NULL, t_width, t_height);
        }
            break;
        case UISwipeGestureRecognizerDirectionLeft:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, height, y);
                CGPathAddArc(path,NULL, radius, t_height / 2, radius, M_PI + asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), YES);
            }else{
                CGPathMoveToPoint(path,NULL, x, y);
                CGPathAddArc(path,NULL, height - radius, t_height / 2, radius, 2 * M_PI - asin((radius - height ) / radius), asin((radius - height ) / radius), NO);
            }
            CGPathAddLineToPoint(path,NULL, t_width, t_height);
            CGPathAddLineToPoint(path,NULL, t_width, y);
        }
            break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, t_width - height, y);
                CGPathAddArc(path,NULL, t_width - radius, t_height / 2, radius, 1.5 * M_PI + asin((radius - height ) / radius), M_PI / 2 + asin((radius - height ) / radius), NO);
            }else{
                CGPathMoveToPoint(path,NULL, t_width, y);
                CGPathAddArc(path,NULL, t_width  + radius - height, t_height / 2, radius, M_PI + asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), YES);
            }
            CGPathAddLineToPoint(path,NULL, x, t_height);
            CGPathAddLineToPoint(path,NULL, x, y);
        }
            break;
        default:
            break;
    }
    
    CGPathCloseSubpath(path);
    [shapeLayer setPath:path];
    CFRelease(path);
    self.layer.mask = shapeLayer;
}

- (void)gradualLayer:(NSArray *)colors {
    CAGradientLayer *_gradientLayer = [CAGradientLayer layer];
    
    _gradientLayer.startPoint = CGPointMake(0, 1);//第一个颜色开始渐变的位置
    _gradientLayer.endPoint = CGPointMake(1, 0);//最后一个颜色结束的位置
    _gradientLayer.frame = self.bounds;//设置渐变图层的大小
    if (colors == nil) {
        //颜色为空时预置的颜色
        _gradientLayer.colors = @[(__bridge id)[UIColor colorWithHex:@"FF873E"].CGColor,
                                  (__bridge id)[UIColor colorWithHex:@"FF734D"].CGColor,
                                  (__bridge id)[UIColor colorWithHex:@"FF6461"].CGColor
        ];
    }else {
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger index=0; index<colors.count; index++) {
            [array addObject:((__bridge id)[UIColor colorWithHex:colors[index]].CGColor)];
        }
        _gradientLayer.colors = array;
    }
    
    [self.layer insertSublayer:_gradientLayer atIndex:0];
}

- (void)shaw:(BOOL)down {
    
    CAGradientLayer *_gradientLayer = [CAGradientLayer layer];
    if (down) {
        _gradientLayer.startPoint = CGPointMake(1, 1);//第一个颜色开始渐变的位置
        _gradientLayer.endPoint = CGPointMake(0, 0);//最后一个颜色结束的位置
    } else {
        _gradientLayer.startPoint = CGPointMake(0, 0);//第一个颜色开始渐变的位置
        _gradientLayer.endPoint = CGPointMake(1, 1);//最后一个颜色结束的位置
    }
    
    _gradientLayer.frame = self.bounds;//设置渐变图层的大小
    _gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8].CGColor,
                              (__bridge id)[UIColor clearColor].CGColor
    ];
    
    [self.layer insertSublayer:_gradientLayer atIndex:0];
}

- (UIImage *)image {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO,
                                           (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1)?
                                           1:[UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *resultImg = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage, CGRectMake(0,0*[UIScreen mainScreen].scale, [UIScreen mainScreen].scale*UIScreen.mainScreen.bounds.size.width, [UIScreen mainScreen].scale*UIScreen.mainScreen.bounds.size.height))];
    
    return resultImg;
}

@end

@implementation UIImageView(SKImageView)

- (void)imageUrl:(NSString *)imageurl block:(_Nullable SKImageBlock)block {
    UIImage *tempImage = [UIImage imageNamed:imageurl];
    if (tempImage) {
        self.image = tempImage;
        if (block) {
            block(tempImage,nil);
        }
    } else {
        if (imageurl) {
            __block UIActivityIndicatorView *activityIndicator;
            activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self addSubview:activityIndicator];
            [activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
            [activityIndicator startAnimating];
            
            if ([imageurl hasPrefix:@"http"]) {
                if ([imageurl hasSuffix:@".gif"]) {
                    [((SDAnimatedImageView *)self) sd_setImageWithURL:[NSURL URLWithString:[imageurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"icon-1"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        [activityIndicator removeFromSuperview];
                        activityIndicator = nil;
                        if (block) {
                            block(image,nil);
                        }
                    }];
                    
                } else {
                    [self sd_setImageWithURL:[NSURL URLWithString:[imageurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"icon-1"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        [activityIndicator removeFromSuperview];
                        activityIndicator = nil;
                        if (block) {
                            block(image,nil);
                        }
                    }];
                }
            } else {
                [self sd_setImageWithURL:[NSURL fileURLWithPath:imageurl.imageUrl] placeholderImage:[UIImage imageNamed:@"icon-1"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    [activityIndicator removeFromSuperview];
                    activityIndicator = nil;
                    if (block) {
                        block(image,nil);
                    }
                }];
            }
        }
    }
}

@end

@implementation NSString (SKString)

/**
 补全图片地址
 */
- (NSString *)imageUrl {
    
    if ([self bundleUrl]) {
        return [self bundleUrl];
    }
    NSArray *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    if (self.length < ((NSString *)[paths objectAtIndex:0]).length) {
        
        NSString *str = [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
        
        NSLog(@"%@",str);
        return str;
    }
    NSLog(@"%@",self);
    return self;
}

- (NSString *)bundleUrl {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:[self stringByDeletingPathExtension] ofType:[self pathExtension]];
    return path;
}

- (NSString *)arrayIndex:(NSInteger)index {
    NSLog(@"%@",self);
    NSArray *GuideArray = [self componentsSeparatedByString:@"\n"];
    
    return GuideArray[index];
}

- (NSString *)stars {
    NSInteger lehth = self.length;
    NSMutableString *string = [NSMutableString string];
    for (NSInteger index=0; index<lehth; index++) {
        [string appendString:@"*"];
    }
    return string;
}

- (NSString *)https {
    if (![self hasPrefix:@"https"]) {
        return [@"https://" stringByAppendingString:self];
    }
    
    return self;
}

- (NSString *)html {
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style type='text/css'>a:link {color: #000000}a:visited {color: #000000}a:hover {color: #000000}a:active {color: #000000}</style></header>";
    
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                                "<head> \n"
                                "<style type=\"text/css\"> \n"
                                "body {font-size:15px;}\n"
                                "</style> \n"
                                "</head> \n"
                                "<body>"
                                "<script type='text/javascript'>"
                                "window.onload = function(){\n"
                                "var $img = document.getElementsByTagName('img');\n"
                                "for(var p in  $img){\n"
                                " $img[p].style.width = '100%%';\n"
                                "$img[p].style.height ='auto'\n"
                                "}\n"
                                "}"
                                "</script>%@"
                                "</body>"
                                "</html>", [headerString stringByAppendingString:self]];
    
    return htmlString;
}

- (NSString *)pinyin {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [NSMutableString new];
    
    int count = 0;
    
    for (int  i = 0; i < pinyinArray.count; i++)
    {
        for(int i = 0; i < pinyinArray.count;i++)
        {
            if (i == count) {
                [allString appendString:@"#"];
                //区分第几个字母
            }
            [allString appendFormat:@"%@",pinyinArray[i]];
        }
        [allString appendString:@","];
        count ++;
    }
    NSMutableString *initialStr = [NSMutableString new];
    //拼音首字母
    for (NSString *s in pinyinArray)
    {
        if (s.length > 0)
        {
            [initialStr appendString:  [s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",self];
    return allString;
}

@end

@implementation NSDate (SKDate)
+ (NSString *)format:(NSString *)format {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];[dateFormatter setDateFormat:format];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
@end

#pragma mark ################ --SKT类别-- ################

@implementation SKView
- (void)drawRect:(CGRect)rect {
    if (self.topLeft || self.bottomLeft || self.topRight || self.bottomRight || self.borderColor || self.borderWidth || self.fill) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(self.bottomLeft?UIRectCornerBottomLeft:0)|(self.bottomRight?UIRectCornerBottomRight:0)|(self.topLeft?UIRectCornerTopLeft:0)|(self.topRight?UIRectCornerTopRight:0) cornerRadii:CGSizeMake(self.radius, 0.f)];
        [self setupRadius:maskPath];
    }
}

- (void)setupRadius:(UIBezierPath *)maskPath {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = self.bounds;
    //设置图形样子
    
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    // 设置线条宽度
    maskPath.lineWidth = self.borderWidth*2;
    [self.borderColor setStroke];
    // 绘制线条
    [maskPath stroke];
    
    if (self.fill) {
        // 如果是实心圆，设置填充颜色
        [self.borderColor setFill];
        // 填充圆形
        [maskPath fill];
    }
}

@end


@interface SKBarButtonItem ()
@property (strong ,nonatomic) SKObjectBlock block;
@end
@implementation SKBarButtonItem

- (void)badgeValue:(NSString *)value block:(SKObjectBlock)block {
    
    self.block = block;
    
    UIView *superView = [[UIView alloc] init];
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"通讯录"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(superView);
    }];
    
    if (value) {
        
        UIView *view = [[UIView alloc] init];
        
        view.backgroundColor = SKBadgeColor;
        
        view.layer.cornerRadius = 8;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = value;
        label.textAlignment = NSTextAlignmentCenter;
        
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(view);
        }];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.offset(16);
            make.width.greaterThanOrEqualTo(@16);
        }];
        
        [superView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superView).offset(-6);
            make.right.equalTo(superView).offset(6);
        }];
    }
    
    self.customView = superView;
}

- (void)action:(UIButton *)sender {
    if (self.block) {
        self.block(sender);
    }
}

@end

@interface SKPicerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@end

@implementation SKPicerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

-(void)initView
{
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    imageview.backgroundColor = [UIColor clearColor];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView = imageview;
    [self.contentView addSubview:_iconImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconImageView.frame = self.contentView.bounds;
}

@end

@interface SKPhotoPicker ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) SKImageBlock block;
@end

@implementation SKPhotoPicker

+ (void)push:(UIViewController *)vc block:(SKImageBlock)block {
    SKPhotoPicker *picker = [SKPhotoPicker new];
    picker.block = block;
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:picker];
    [vc presentViewController:nv animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Limited Album";
    self.photoArray = [NSMutableArray array];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:YES];
        }

        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
    });

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.backgroundView.backgroundColor = self.collectionView.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:SKPicerCell.class forCellWithReuseIdentifier:NSStringFromClass(SKPicerCell.class)];
    [self.view addSubview:self.collectionView];
}

- (void)getThumbnailImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:NO];
        }
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
    });
}

/*  遍历相簿中的全部图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"%@", result);
            if (result) {
                original ? [weakSelf.photoArray addObject:result] : [weakSelf.photoArray addObject:result];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.view.frame) / 4, CGRectGetWidth(self.view.frame) / 4);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = self.photoArray[indexPath.item];
    SKPicerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SKPicerCell.class) forIndexPath:indexPath];
    cell.iconImageView.image = image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.block) {
        self.block(self.photoArray[indexPath.item],@"");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation SKNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    if (self.viewControllers.count <= 2) {
        self.viewControllers.firstObject.hidesBottomBarWhenPushed = NO;
    }
    
    return [super popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.viewControllers.firstObject.hidesBottomBarWhenPushed = NO;
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.viewControllers indexOfObject:viewController]) {
        self.viewControllers.firstObject.hidesBottomBarWhenPushed = NO;
    }
    return [super popToViewController:viewController animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    self.viewControllers.firstObject.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

- (void)gradualLayer:(NSArray *)colors {
    
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationBar setTranslucent:NO];
    
    UIView *_barBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, SKNavBarHeight)];
    
    [_barBackgroundView gradualLayer:colors];
    
    [self.navigationBar setBackgroundImage:_barBackgroundView.image forBarMetrics:UIBarMetricsDefault];
}

@end

@interface SKTabBarController ()<UITabBarControllerDelegate>
@property (nonatomic,assign) NSInteger  indexFlag;
@end

@implementation SKTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary* attributes = @{NSFontAttributeName:SKTitleFont(20)};
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];
}

+ (void)initialize {
    
    // 通过appearance统一设置所有UITabBarItem的文字属性
    // 后面带有UI_APPEARANCE_SELECTOR的方法,都可以通过appearance对象来统一设置
    // 正常情况下的属性
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = SKTitleFont(10);
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:attrs forState:UIControlStateSelected];
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (self.clickAnimal) {
        NSInteger index = [self.tabBar.items indexOfObject:item];
        if (index != self.indexFlag) {
            //执行动画
            NSMutableArray *arry = [NSMutableArray array];
            NSMutableArray *temp = [NSMutableArray array];
            for (UIView *btn in self.tabBar.subviews) {
                if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                    [arry addObject:btn];
                    for (UIView *imageView in btn.subviews) {
                        if ([imageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                            [temp addObject:imageView];
                        }
                    }
                }
            }
            //添加动画
            //放大效果，并回到原位
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            //速度控制函数，控制动画运行的节奏
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = 0.2;       //执行时间
            animation.repeatCount = 1;      //执行次数
            animation.autoreverses = YES;    //完成动画后会回到执行动画之前的状态
            animation.fromValue = [NSNumber numberWithFloat:0.8];   //初始伸缩倍数
            animation.toValue = [NSNumber numberWithFloat:1.2];     //结束伸缩倍数
            
            UIView *GuideView = arry[index];
            if (temp.count == arry.count) {
                GuideView = temp[index];
            }
            
            [GuideView.layer addAnimation:animation forKey:nil];
            
            self.indexFlag = index;
        }
    }
}

- (void)gradualLayer:(NSArray *)colors {
    
//    [self.tabBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    [self.tabBar setShadowImage:[[UIImage alloc] init]];
    [self.tabBar setTranslucent:NO];
    
    UIView *_barBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SKTabBarHeight)];
    
    [_barBackgroundView gradualLayer:colors];
    [self.tabBar setBackgroundImage:_barBackgroundView.image];
//    [self.tabBar setBackgroundImage:_barBackgroundView.image forBarMetrics:UIBarMetricsDefault];
}

@end


#pragma mark ################ --SKT工具-- ################

#define SKSheetCellMIN   2
#define SKSheetCellMAX   6

#define SKSheetCellHeight   60
#define SKSheetDefaultHeight   128

#define isiPhoneX (SKHeight/SKWidth > 2)

// home indicator
#define bottom_height (isiPhoneX ? 34.f : 10.f)

@interface SKSheetCell : UITableViewCell

@property (strong ,nonatomic) UILabel *SKTitle;
@property (strong ,nonatomic) UIImageView *SKImage;

@end

@implementation SKSheetCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(8, 8, [UIScreen mainScreen].bounds.size.width-24-16, 60-16)];
        
        self.SKImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        self.SKImage.clipsToBounds                    = YES;
        self.SKImage.layer.cornerRadius               = 5;
        self.SKImage.layer.borderWidth                = 1;
        self.SKImage.layer.borderColor                = SKCurrentColor.CGColor;
        self.SKImage.contentMode                      = UIViewContentModeScaleAspectFill;
        [view addSubview:self.SKImage];
        
        [self.contentView addSubview:view];
        
        view.layer.cornerRadius      = 5;
        if (@available(iOS 13.0, *)) {
            view.backgroundColor     = UIColor.systemBackgroundColor;
        } else {
            view.backgroundColor     = UIColor.whiteColor;
        }
        view.layer.shadowColor       = SKCurrentColor.CGColor;
        view.layer.shadowOffset      = CGSizeMake(0,0);
        view.layer.shadowOpacity     = 0.5;
        view.layer.shadowRadius      = 2;
        
        self.SKTitle = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, [UIScreen mainScreen].bounds.size.width-24-16-88, 60-16)];
        self.SKTitle.textAlignment = NSTextAlignmentCenter;
        self.SKTitle.textColor = self.textLabel.textColor;
        self.SKTitle.font = SKTitleFont(15);
        [view addSubview:self.SKTitle];
    }
    
    return self;
}

@end
@interface SKSheetView ()
@property (strong ,nonatomic) SKSheetBlock block;
@property (strong ,nonatomic) NSArray *data;
@property (strong ,nonatomic) UIView *backView;
@property (strong ,nonatomic) UIView *contentView;
@property (strong ,nonatomic) UIView *contentBack;
@property (strong ,nonatomic) UITableView *tableView;
@property (assign ,nonatomic) CGFloat height;
@property (assign ,nonatomic) BOOL isColor;



@end

@implementation SKSheetView

+ (void)show:(NSString *)title sheets:(NSArray *)array isColor:(BOOL)IsColor block:(SKSheetBlock)block {
    SKSheetView *superView = [[SKSheetView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:superView];
    superView.backView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    [superView.backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:superView action:@selector(dismiss)]];
    superView.backView.userInteractionEnabled = YES;
    superView.backView.backgroundColor = UIColor.blackColor;
    superView.backView.alpha = 0;
    [superView addSubview:superView.backView];
    
    CGFloat top         = 0;
    superView.height    = 0;
    superView.data      = array;
    superView.block     = block;
    superView.isColor   = IsColor;
    
    if (array.count > SKSheetCellMIN) {
        superView.height = SKSheetCellHeight*((array.count >SKSheetCellMAX)?SKSheetCellMAX:array.count) + 60;
        top = (SKSheetDefaultHeight + SKSheetCellHeight*((array.count >SKSheetCellMAX)?SKSheetCellMAX:array.count))+SKBottom-60;
    } else {
        superView.height = SKSheetCellHeight*SKSheetCellMIN + 60;
        top = (SKSheetDefaultHeight + SKSheetCellHeight*SKSheetCellMIN)+SKBottom-60;
    }
    superView.contentBack = [[UIView alloc] initWithFrame:CGRectMake(0, SKHeight, SKWidth, superView.height+62)];
    [superView addSubview:superView.contentBack];
    
    superView.contentView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, SKWidth-24, superView.height)];
    superView.contentView .layer.cornerRadius = 10;
    superView.contentView .clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        superView.contentView.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        superView.contentView.backgroundColor = UIColor.whiteColor;
    }
    [superView.contentBack addSubview:superView.contentView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 16, SKWidth-48, 20)];
    label.font = SKTitleFont(17);
    label.text = title;
    label.textColor = SKCurrentColor.dark;
    label.textAlignment = NSTextAlignmentCenter;
    [superView.contentView addSubview:label];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, 32+label.frame.size.height, SKWidth-48, 1)];
    line.backgroundColor = [SKCurrentColor alpha:0.3];
    [superView.contentView addSubview:line];
    
    superView.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, SKWidth-24, superView.height-60)];
    superView.tableView.showsVerticalScrollIndicator   = NO;
    superView.tableView.showsHorizontalScrollIndicator = NO;
    superView.tableView.delegate        = superView;
    superView.tableView.dataSource      = superView;
    superView.tableView.separatorStyle  = UITableViewCellSelectionStyleNone;
    [superView.tableView registerClass:SKSheetCell.class forCellReuseIdentifier:@"SKSheetCell"];
    [superView.contentView addSubview:superView.tableView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(12, superView.height+12, SKWidth-24, 50)];
    if (@available(iOS 13.0, *)) {
        button.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        button.backgroundColor = UIColor.whiteColor;
    }
    
    button.titleLabel.font = SKTitleFont(17);
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:SKCurrentColor forState:UIControlStateNormal];
    [button addTarget:superView action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 10;
    [superView.contentBack addSubview:button];
    
    [UIView animateWithDuration:0.3 animations:^{
        superView.backView.alpha = 0.3;
        superView.contentBack.frame = CGRectMake(0, SKHeight-top-60, SKWidth, superView.height+62);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSheetCell" forIndexPath:indexPath];
    if ([self.data[indexPath.row] isKindOfClass:NSString.class]) {
        cell.SKTitle.text = self.data[indexPath.row];
    } else {
        cell.SKTitle.text = self.data[indexPath.row][1];
        [cell.SKImage imageUrl:self.data[indexPath.row][0] block:nil];
    }
    
    
//    if (self.isColor) {
//        cell.SKImage.image  = [[UIImage imageNamed:[self.data[indexPath.row] lastObject]] initwithColor:SKCurrentColor];
//    } else {
//        [cell.SKImage imageUrl:self.data[indexPath.row] block:nil];
//    }
//
    cell.SKImage.hidden = (!cell.SKImage.image);
//    cell.SKImage.layer.borderColor = SKCurrentColor.CGColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.block) {
        if ([self.data[indexPath.row] isKindOfClass:NSString.class]) {
            self.block(indexPath.row, self.data[indexPath.row]);
        } else {
            self.block(indexPath.row, self.data[indexPath.row][1]);
        }
        
    }
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        self.contentBack.frame = CGRectMake(0, SKHeight, SKWidth, self.frame.size.height+62);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end

@implementation SKBannerSubiew

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self addSubview:self.mainImageView];
        [self addSubview:self.coverView];
        [self addSubview:self.shawView];
        
        [self addSubview:self.mainContent];
        
        [self.mainContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.right.bottom.equalTo(self).offset(-8);
        }];
        [self.shawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self.mainContent).offset(4);
            make.left.top.equalTo(self.mainContent).offset(-4);
        }];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCellTapAction:)];
        [self addGestureRecognizer:singleTap];
    }
    
    return self;
}

- (void)singleCellTapAction:(UIGestureRecognizer *)gesture {
    if (self.didSelectCellBlock) {
        self.didSelectCellBlock(self.tag, self);
    }
}

- (void)setSubviewsWithSuperViewBounds:(CGRect)superViewBounds {
    
    if (CGRectEqualToRect(self.mainImageView.frame, superViewBounds)) {
        return;
    }
    
    self.mainImageView.frame = superViewBounds;
    self.coverView.frame = superViewBounds;
    self.mainContent.frame = superViewBounds;
}

- (UIImageView *)mainImageView {
    
    if (_mainImageView == nil) {
        _mainImageView = [[UIImageView alloc] init];
        _mainImageView.userInteractionEnabled = YES;
    }
    return _mainImageView;
}

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
    }
    return _coverView;
}

- (UILabel *)mainContent {
    if (_mainContent == nil) {
        _mainContent = [[UILabel alloc] init];
    }
    return _mainContent;
}

- (UIView *)shawView {
    if (_shawView == nil) {
        _shawView = [[UIView alloc] init];
        _shawView.layer.cornerRadius = 6;
        _shawView.backgroundColor = [UIColor.blackColor alpha:0.3];
    }
    return _shawView;
}

@end

@interface SKBannerView ()
@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic,assign) CGSize pageSize;
@property (nonatomic,strong) SKIndexBlock block;
@property (nonatomic,strong) NSArray *images;
@property (nonatomic,strong) NSArray *contents;
@end

static NSString *subviewClassName;

@implementation SKBannerView

+ (UIView *)banner:(NSArray *)images contents:(NSArray * _Nullable)contents block:(SKIndexBlock)block {
    if (images.count) {
        UIView *View = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SKWidth, SKWidth/2)];
        
        SKBannerView *bannerView = [[SKBannerView alloc] initWithFrame:View.frame];
        bannerView.block = block;
        bannerView.images = images;
        bannerView.contents = contents;
        bannerView.delegate = bannerView;
        bannerView.dataSource = bannerView;
        bannerView.minimumPageAlpha = 0.1;
        bannerView.isCarousel = YES;
        bannerView.orientation = SKBannerViewOrientationHorizontal;
        bannerView.isOpenAutoScroll = YES;
        
        [View addSubview:bannerView];
        [bannerView reloadData];
        
        return View;
    } else {
        return nil;
    }
}

+ (UIView *)banner:(NSArray *)images contents:(NSArray * _Nullable)contents orientation:(SKBannerViewOrientation)orientation autoTime:(CGFloat)autoTime frame:(CGRect)frame block:(SKIndexBlock)block {
    if (images.count) {
        UIView *View = [[UIView alloc] initWithFrame:frame];
        
        SKBannerView *bannerView = [[SKBannerView alloc] initWithFrame:View.frame];
        bannerView.block = block;
        bannerView.images = images;
        bannerView.contents = contents;
        bannerView.delegate = bannerView;
        bannerView.dataSource = bannerView;
        bannerView.minimumPageAlpha = 0.1;
        bannerView.isCarousel = YES;
        bannerView.autoTime = autoTime;
        bannerView.orientation = orientation;
        bannerView.isOpenAutoScroll = YES;
        
        [View addSubview:bannerView];
        [bannerView reloadData];
        
        return View;
    } else {
        return nil;
    }
}

#pragma mark SKBannerView Delegate
- (CGSize)sizeForPageInFlowView:(SKBannerView *)flowView {
    return CGSizeMake(self.frame.size.width *0.9, self.frame.size.height *0.9);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    self.block(subIndex);
}

#pragma mark SKBannerView Datasource
- (NSInteger)numberOfPagesInFlowView:(SKBannerView *)flowView {
    
    if (self.images.count < 5) {
        return self.images.count;
    }
    return 5;
}

- (SKBannerSubiew *)flowView:(SKBannerView *)flowView cellForPageAtIndex:(NSInteger)index{
    SKBannerSubiew *bannerView = [flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[SKBannerSubiew alloc] init];
        bannerView.tag = index;
        bannerView.layer.cornerRadius = 6;
        bannerView.layer.shadowColor = SKThemeColor.dark.CGColor;
        bannerView.layer.shadowRadius = 3;
        bannerView.layer.shadowOpacity = 0.7;
        bannerView.layer.shadowOffset = CGSizeMake(0, 0);
        bannerView.backgroundColor = SKThemeColor;
        bannerView.mainImageView.layer.cornerRadius = 6;
        bannerView.mainImageView.layer.masksToBounds = YES;
        bannerView.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        bannerView.mainContent.font = SKTitleFont(20);
        bannerView.mainContent.textColor = UIColor.whiteColor;
        bannerView.mainContent.contentMode = UIViewContentModeBottom;
        bannerView.mainContent.numberOfLines = 2;
        if (self.contents.count > index) {
            bannerView.mainContent.hidden = NO;
            bannerView.shawView.hidden = NO;
            bannerView.mainContent.text = self.contents[index];
        } else {
            bannerView.mainContent.hidden = YES;
            bannerView.shawView.hidden = YES;
        }
    }
    //在这里下载网络图片
    [bannerView.mainImageView imageUrl:self.images[index] block:nil];
    return bannerView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
- (void)initialize{
    self.clipsToBounds = YES;
    
    self.needsReload = YES;
    self.pageCount = 0;
    self.isOpenAutoScroll = YES;
    self.isCarousel = YES;
    self.leftRightMargin = 20;
    self.topBottomMargin = 30;
    _currentPageIndex = 0;
    
    _minimumPageAlpha = 1.0;
    _autoTime = 5.0;
    
    self.visibleRange = NSMakeRange(0, 0);
    
    self.reusableCells = [[NSMutableArray alloc] initWithCapacity:0];
    self.cells = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    subviewClassName = @"SKBannerSubiew";
    
    [self addSubview:self.scrollView];
}

- (void)setLeftRightMargin:(CGFloat)leftRightMargin {
    _leftRightMargin = leftRightMargin * 0.5;
    
}

- (void)setTopBottomMargin:(CGFloat)topBottomMargin {
    _topBottomMargin = topBottomMargin * 0.5;
}

- (void)startTimer {
    
    if (self.orginPageCount > 1 && self.isOpenAutoScroll && self.isCarousel) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoTime target:self selector:@selector(autoNextPage) userInfo:nil repeats:YES];
        self.timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)adjustCenterSubview {
    if (self.isOpenAutoScroll && self.orginPageCount > 0) {
        [_scrollView setContentOffset:CGPointMake(_pageSize.width * self.page, 0) animated:NO];
    }
}

#pragma mark --自动轮播
- (void)autoNextPage {
    
    self.page ++;

    switch (self.orientation) {
        case SKBannerViewOrientationHorizontal:{
            
            [_scrollView setContentOffset:CGPointMake(self.page * _pageSize.width, 0) animated:YES];
            break;
        }
        case SKBannerViewOrientationVertical:{
            
            [_scrollView setContentOffset:CGPointMake(0, self.page * _pageSize.height) animated:YES];
            
            break;
        }
        default:
            break;
    }
}


- (void)queueReusableCell:(SKBannerSubiew *)cell{
    [_reusableCells addObject:cell];
}

- (void)removeCellAtIndex:(NSInteger)index{
    SKBannerSubiew *cell = [_cells objectAtIndex:index];
    if ((NSObject *)cell == [NSNull null]) {
        return;
    }
    
    [self queueReusableCell:cell];
    
    if (cell.superview) {
        [cell removeFromSuperview];
    }
    
    [_cells replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)refreshVisibleCellAppearance{
    
    if (_minimumPageAlpha == 1.0 && self.leftRightMargin == 0 && self.topBottomMargin == 0) {
        return;//无需更新
    }
    switch (self.orientation) {
        case SKBannerViewOrientationHorizontal:{
            CGFloat offset = _scrollView.contentOffset.x;
            
            for (NSInteger i = self.visibleRange.location; i < self.visibleRange.location + _visibleRange.length; i++) {
                SKBannerSubiew *cell = [_cells objectAtIndex:i];
                subviewClassName = NSStringFromClass([cell class]);
                CGFloat origin = cell.frame.origin.x;
                CGFloat delta = fabs(origin - offset);
                
                CGRect originCellFrame = CGRectMake(_pageSize.width * i, 0, _pageSize.width, _pageSize.height);//如果没有缩小效果的情况下的本该的Frame
                
                if (delta < _pageSize.width) {
                    
                    cell.coverView.alpha = (delta / _pageSize.width) * _minimumPageAlpha;
                    
                    CGFloat leftRightInset = self.leftRightMargin * delta / _pageSize.width;
                    CGFloat topBottomInset = self.topBottomMargin * delta / _pageSize.width;
                    
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-leftRightInset*2)/_pageSize.width,(_pageSize.height-topBottomInset*2)/_pageSize.height, 1.0);
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));

                } else {
                    cell.coverView.alpha = _minimumPageAlpha;
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-self.leftRightMargin*2)/_pageSize.width,(_pageSize.height-self.topBottomMargin*2)/_pageSize.height, 1.0);
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.topBottomMargin, self.leftRightMargin, self.topBottomMargin, self.leftRightMargin));
                }
            }
            break;
        }
        case SKBannerViewOrientationVertical:{
            CGFloat offset = _scrollView.contentOffset.y;
            
            for (NSInteger i = self.visibleRange.location; i < self.visibleRange.location + _visibleRange.length; i++) {
                SKBannerSubiew *cell = [_cells objectAtIndex:i];
                subviewClassName = NSStringFromClass([cell class]);
                CGFloat origin = cell.frame.origin.y;
                CGFloat delta = fabs(origin - offset);
                
                CGRect originCellFrame = CGRectMake(0, _pageSize.height * i, _pageSize.width, _pageSize.height);//如果没有缩小效果的情况下的本该的Frame
                
                if (delta < _pageSize.height) {
                    cell.coverView.alpha = (delta / _pageSize.height) * _minimumPageAlpha;
                    
                    CGFloat leftRightInset = self.leftRightMargin * delta / _pageSize.height;
                    CGFloat topBottomInset = self.topBottomMargin * delta / _pageSize.height;
                    
                    cell.layer.transform = CATransform3DMakeScale((_pageSize.width-leftRightInset*2)/_pageSize.width,(_pageSize.height-topBottomInset*2) / _pageSize.height, 1.0);
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
                    cell.mainImageView.frame = cell.bounds;
                } else {
                    cell.coverView.alpha = _minimumPageAlpha;
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.topBottomMargin, self.leftRightMargin, self.topBottomMargin, self.leftRightMargin));
                    cell.mainImageView.frame = cell.bounds;
                }
            }
        }
        default:
            break;
    }
}

- (void)setPageAtIndex:(NSInteger)pageIndex{
    NSParameterAssert(pageIndex >= 0 && pageIndex < [_cells count]);
    
    SKBannerSubiew *cell = [_cells objectAtIndex:pageIndex];
    
    if ((NSObject *)cell == [NSNull null]) {
        cell = [_dataSource flowView:self cellForPageAtIndex:pageIndex % self.orginPageCount];
        NSAssert(cell!=nil, @"datasource must not return nil");
        [_cells replaceObjectAtIndex:pageIndex withObject:cell];
        
        cell.tag = pageIndex % self.orginPageCount;
        [cell setSubviewsWithSuperViewBounds:CGRectMake(0, 0, _pageSize.width, _pageSize.height)];
        
        __weak __typeof(self) weakSelf = self;
        cell.didSelectCellBlock = ^(NSInteger tag, SKBannerSubiew *cell) {
            [weakSelf singleCellTapAction:tag withCell:cell];
        };
        
        switch (self.orientation) {
            case SKBannerViewOrientationHorizontal:
                cell.frame = CGRectMake(_pageSize.width * pageIndex, 0, _pageSize.width, _pageSize.height);
                break;
            case SKBannerViewOrientationVertical:
                cell.frame = CGRectMake(0, _pageSize.height * pageIndex, _pageSize.width, _pageSize.height);
                break;
            default:
                break;
        }
        
        if (!cell.superview) {
            [_scrollView addSubview:cell];
        }
    }
}


- (void)setPagesAtContentOffset:(CGPoint)offset{
    //计算_visibleRange
    CGPoint startPoint = CGPointMake(offset.x - _scrollView.frame.origin.x, offset.y - _scrollView.frame.origin.y);
    CGPoint endPoint = CGPointMake(startPoint.x + self.bounds.size.width, startPoint.y + self.bounds.size.height);
    
    switch (self.orientation) {
        case SKBannerViewOrientationHorizontal:{
            NSInteger startIndex = 0;
            for (int i =0; i < [_cells count]; i++) {
                if (_pageSize.width * (i +1) > startPoint.x) {
                    startIndex = i;
                    break;
                }
            }
            
            NSInteger endIndex = startIndex;
            for (NSInteger i = startIndex; i < [_cells count]; i++) {
                //如果都不超过则取最后一个
                if ((_pageSize.width * (i + 1) < endPoint.x && _pageSize.width * (i + 2) >= endPoint.x) || i+ 2 == [_cells count]) {
                    endIndex = i + 1;//i+2 是以个数，所以其index需要减去1
                    break;
                }
            }
            
            //可见页分别向前向后扩展一个，提高效率
            startIndex = MAX(startIndex - 1, 0);
            endIndex = MIN(endIndex + 1, [_cells count] - 1);
            
            //            self.visibleRange.location = startIndex;
            //            self.visibleRange.length = endIndex - startIndex + 1;
            self.visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1);
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (int i = 0; i < startIndex; i ++) {
                [self removeCellAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < [_cells count]; i ++) {
                [self removeCellAtIndex:i];
            }
            break;
        }
        case SKBannerViewOrientationVertical:{
            NSInteger startIndex = 0;
            for (int i =0; i < [_cells count]; i++) {
                if (_pageSize.height * (i +1) > startPoint.y) {
                    startIndex = i;
                    break;
                }
            }
            
            NSInteger endIndex = startIndex;
            for (NSInteger i = startIndex; i < [_cells count]; i++) {
                //如果都不超过则取最后一个
                if ((_pageSize.height * (i + 1) < endPoint.y && _pageSize.height * (i + 2) >= endPoint.y) || i+ 2 == [_cells count]) {
                    endIndex = i + 1;//i+2 是以个数，所以其index需要减去1
                    break;
                }
            }
            
            //可见页分别向前向后扩展一个，提高效率
            startIndex = MAX(startIndex - 1, 0);
            endIndex = MIN(endIndex + 1, [_cells count] - 1);
            
            _visibleRange.location = startIndex;
            _visibleRange.length = endIndex - startIndex + 1;
            
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i ++) {
                [self removeCellAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < [_cells count]; i ++) {
                [self removeCellAtIndex:i];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

#pragma mark -
#pragma mark SKBannerView API

- (void)reloadData {
    _needsReload = YES;
    
    //移除所有self.scrollView的子控件
    for (UIView *view in self.scrollView.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:subviewClassName] || [view isKindOfClass:[SKBannerSubiew class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self stopTimer];

    if (_needsReload) {
        //如果需要重新加载数据，则需要清空相关数据全部重新加载
        //重置pageCount
        if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInFlowView:)]) {
            
            //原始页数
            self.orginPageCount = [_dataSource numberOfPagesInFlowView:self];
            
            //总页数
            if (self.isCarousel) {
                _pageCount = self.orginPageCount == 1 ? 1: [_dataSource numberOfPagesInFlowView:self] * 3;
            }else {
                _pageCount = self.orginPageCount == 1 ? 1: [_dataSource numberOfPagesInFlowView:self];
            }
            
            //如果总页数为0，return
            if (_pageCount == 0) {
                
                return;
            }
            
            if (self.pageControl && [self.pageControl respondsToSelector:@selector(setNumberOfPages:)]) {
                [self.pageControl setNumberOfPages:self.orginPageCount];
            }
        }
        
        //重置pageWidth
        _pageSize = CGSizeMake(self.bounds.size.width - 4 * self.leftRightMargin,(self.bounds.size.width - 4 * self.leftRightMargin) * 9 /16);
        if (self.delegate && self.delegate && [self.delegate respondsToSelector:@selector(sizeForPageInFlowView:)]) {
            _pageSize = [self.delegate sizeForPageInFlowView:self];
        }
        
        [_reusableCells removeAllObjects];
        _visibleRange = NSMakeRange(0, 0);
        
        //填充cells数组
        [_cells removeAllObjects];
        for (NSInteger index=0; index<_pageCount; index++)
        {
            [_cells addObject:[NSNull null]];
        }
        
        // 重置_scrollView的contentSize
        switch (self.orientation) {
            case SKBannerViewOrientationHorizontal://横向
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width * _pageCount,0);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                
                if (self.orginPageCount > 1) {
                    
                    if (self.isCarousel) {
                        
                        //滚到第二组
                        [_scrollView setContentOffset:CGPointMake(_pageSize.width * self.orginPageCount, 0) animated:NO];
                        
                        self.page = self.orginPageCount;
                        
                        //启动自动轮播
                        [self startTimer];
                        
                    }else {
                        //滚到开始
                        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                        
                        self.page = self.orginPageCount;
                    }
                }
                
                break;
            case SKBannerViewOrientationVertical:{
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(0 ,_pageSize.height * _pageCount);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                
                if (self.orginPageCount > 1) {
                    
                    if (self.isCarousel) {
                        //滚到第二组
                        [_scrollView setContentOffset:CGPointMake(0, _pageSize.height * self.orginPageCount) animated:NO];
                        
                        self.page = self.orginPageCount;
                        
                        //启动自动轮播
                        [self startTimer];
                    }else {
                        //滚到第二组
                        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                        
                        self.page = self.orginPageCount;
                        
                    }
                }
                
                break;
            }
            default:
                break;
        }
        
        _needsReload = NO;
    }
    
    [self setPagesAtContentOffset:_scrollView.contentOffset];//根据当前scrollView的offset设置cell
    
    [self refreshVisibleCellAppearance];//更新各个可见Cell的显示外貌
}

- (SKBannerSubiew *)dequeueReusableCell{
    SKBannerSubiew *cell = [_reusableCells lastObject];
    if (cell)
    {
        [_reusableCells removeLastObject];
    }
    
    return cell;
}

- (void)scrollToPage:(NSUInteger)pageNumber {
    if (pageNumber < _pageCount) {
        
        //首先停止定时器
        [self stopTimer];
        
        if (self.isCarousel) {
            
            self.page = pageNumber + self.orginPageCount;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
            [self performSelector:@selector(startTimer) withObject:nil afterDelay:0.5];
            
        }else {
            self.page = pageNumber;
        }
        
        switch (self.orientation) {
            case SKBannerViewOrientationHorizontal:
                [_scrollView setContentOffset:CGPointMake(_pageSize.width * self.page, 0) animated:YES];
                break;
            case SKBannerViewOrientationVertical:
                [_scrollView setContentOffset:CGPointMake(0, _pageSize.height * self.page) animated:YES];
                break;
        }
        [self setPagesAtContentOffset:_scrollView.contentOffset];
        [self refreshVisibleCellAppearance];
    }
}

#pragma mark -
#pragma mark hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x;
        newPoint.y = point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y;
        if ([_scrollView pointInside:newPoint withEvent:event]) {
            return [_scrollView hitTest:newPoint withEvent:event];
        }
        
        return _scrollView;
    }
    
    return nil;
}


#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.orginPageCount == 0) {
        return;
    }
    
    NSInteger pageIndex;
    
    switch (self.orientation) {
        case SKBannerViewOrientationHorizontal:
            pageIndex = (int)round(_scrollView.contentOffset.x / _pageSize.width) % self.orginPageCount;
            break;
        case SKBannerViewOrientationVertical:
            pageIndex = (int)round(_scrollView.contentOffset.y / _pageSize.height) % self.orginPageCount;
            break;
        default:
            break;
    }
    
    if (self.isCarousel) {
        
        if (self.orginPageCount > 1) {
            switch (self.orientation) {
                case SKBannerViewOrientationHorizontal:
                {
                    if (scrollView.contentOffset.x / _pageSize.width >= 2 * self.orginPageCount) {
                        
                        [scrollView setContentOffset:CGPointMake(_pageSize.width * self.orginPageCount, 0) animated:NO];
                        
                        self.page = self.orginPageCount;
                    }
                    
                    if (scrollView.contentOffset.x / _pageSize.width <= self.orginPageCount - 1) {
                        [scrollView setContentOffset:CGPointMake((2 * self.orginPageCount - 1) * _pageSize.width, 0) animated:NO];
                        
                        self.page = 2 * self.orginPageCount;
                    }
                }
                    break;
                case SKBannerViewOrientationVertical:
                {
                    if (scrollView.contentOffset.y / _pageSize.height >= 2 * self.orginPageCount) {
                        
                        [scrollView setContentOffset:CGPointMake(0, _pageSize.height * self.orginPageCount) animated:NO];
                        
                        self.page = self.orginPageCount;
                        
                    }
                    
                    if (scrollView.contentOffset.y / _pageSize.height <= self.orginPageCount - 1) {
                        [scrollView setContentOffset:CGPointMake(0, (2 * self.orginPageCount - 1) * _pageSize.height) animated:NO];
                        self.page = 2 * self.orginPageCount;
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }else {
            
            pageIndex = 0;
        }
    }
    
    [self setPagesAtContentOffset:scrollView.contentOffset];
    [self refreshVisibleCellAppearance];
    
    if (self.pageControl && [self.pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        
        [self.pageControl setCurrentPage:pageIndex];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didScrollToPage:inFlowView:)] && _currentPageIndex != pageIndex && pageIndex >= 0) {
        [_delegate didScrollToPage:pageIndex inFlowView:self];
    }
    
    _currentPageIndex = pageIndex;
}

#pragma mark --将要开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

#pragma mark --结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

#pragma mark --将要结束拖拽
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (self.orginPageCount > 1 && self.isOpenAutoScroll && self.isCarousel) {
        
        switch (self.orientation) {
            case SKBannerViewOrientationHorizontal:
            {
                if (self.page == floor(_scrollView.contentOffset.x / _pageSize.width)) {
                    
                    self.page = floor(_scrollView.contentOffset.x / _pageSize.width) + 1;
                    
                }else {
                    
                    self.page = floor(_scrollView.contentOffset.x / _pageSize.width);
                }
            }
                break;
            case SKBannerViewOrientationVertical:
            {
                if (self.page == floor(_scrollView.contentOffset.y / _pageSize.height)) {
                    
                    self.page = floor(_scrollView.contentOffset.y / _pageSize.height) + 1;
                    
                }else {
                    
                    self.page = floor(_scrollView.contentOffset.y / _pageSize.height);
                }
            }
                break;
            default:
                break;
        }
    }
}

//点击了cell
- (void)singleCellTapAction:(NSInteger)selectTag withCell:(SKBannerSubiew *)cell {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCell:withSubViewIndex:)]) {
        
        [self.delegate didSelectCell:cell withSubViewIndex:selectTag];
        
    }
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stopTimer];
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _scrollView.delegate = nil;
}

@end

@interface SKT ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong ,nonatomic) id sender;
@property (copy ,nonatomic) SKImageBlock imageBlock;
@property (strong ,nonatomic) UIImagePickerController *picker;
@property (assign ,nonatomic) BOOL isFinish;
@end
@implementation SKT

+ (instancetype)skt {
    static SKT *skt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        skt = [[SKT alloc] init];
    });
    
    return skt;
}

+ (UINavigationController *)currentNav {
    UIViewController *rootVC = [UIApplication sharedApplication].windows[0].rootViewController;
    UIViewController *cureVC = [self currentViewControllerFrom:rootVC];
    
    return cureVC.navigationController;
}

+ (UIViewController *)currentVC {
    if ([UIApplication sharedApplication].windows.count) {
        UIViewController *rootVC = [UIApplication sharedApplication].windows[0].rootViewController;
        UIViewController *cureVC = [self currentViewControllerFrom:rootVC];
        
        if (cureVC.navigationController) {
            if (cureVC.navigationController.tabBarController) {
                return cureVC.navigationController.tabBarController;
            }
            
            if (cureVC.tabBarController) {
                return cureVC.tabBarController;
            }
            
            return cureVC.navigationController;
        }
        
        return cureVC;
    }
    
    return nil;
}

+ (UIViewController *)currentViewControllerFrom:(UIViewController *)currentVC{
    if([currentVC isKindOfClass:[UINavigationController class]]){
        UINavigationController*nav = (UINavigationController *)currentVC;
        return [self currentViewControllerFrom:nav.viewControllers.lastObject];
    }else if ([currentVC isKindOfClass:[UITabBarController class]]){
        UITabBarController *tab = (UITabBarController *)currentVC;
        return [self currentViewControllerFrom:tab.selectedViewController];
    }else if (currentVC.presentedViewController != nil){
        return [self currentViewControllerFrom:currentVC.presentedViewController];
    }else{
        return currentVC;
    }
}

#pragma mark 选择图片
+ (void)selectImage:(id _Nullable)sender Block:(__nullable SKImageBlock)block {
    
    [SKT skt].imageBlock    = block;
    [SKT skt].sender        = sender;
    
    SCLAlertView *alert     = [[SCLAlertView alloc] init];
    alert.customViewColor   = [SKT skt].color;
    [alert addButton:@"相册" actionBlock:^{
        [[SKT skt] getAblumImage];
    }];
    
    [alert addButton:@"相机" actionBlock:^{
        [[SKT skt] getCameraImage];
    }];
    
    [alert showCustom:[SKT currentVC] image:[[UIImage imageNamed:@"icon-1"] initwithColor:UIColor.systemBackgroundColor] color:SKCurrentColor title:@"提醒" subTitle:@"请选择获取图片的方式" closeButtonTitle:@"取消" duration:0.0f];
}

- (void)getAblumImage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (@available(iOS 14.0, *)) {
            PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
            config.filter = [PHPickerFilter imagesFilter];
            PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
            
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
            if (status == PHAuthorizationStatusLimited) {
                [SKPhotoPicker push:[SKT currentVC] block:^(UIImage * _Nullable image, NSString * _Nullable imageUrl) {
                    if ([self.sender isKindOfClass:[UIImageView class]]) {
                        ((UIImageView *)self.sender).image = image;
                    } else if ([self.sender isKindOfClass:[UIButton class]]) {
                        [((UIButton *)self.sender) setImage:image forState:UIControlStateNormal];
                    }
                    
                    ((UIView *)self.sender).tag = 1;
                    if (self.imageBlock) {
                        self.imageBlock(image,imageUrl);
                    }
                }];
            } else if (status == PHAuthorizationStatusAuthorized) {
                picker.delegate = self;
                [[SKT currentVC] presentViewController:picker animated:YES completion:nil];
            } else if (status == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized ||
                        status == PHAuthorizationStatusLimited) {
                        [self getAblumImage];
                    }
                }];
            } else {
                [self tips:YES];
            }
        } else {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusAuthorized) {
                
                self.picker = [[UIImagePickerController alloc] init];
                self.picker.delegate = self;
                [[SKT currentVC] presentViewController:self.picker animated:YES completion:nil];
                
            } else if (status == PHAuthorizationStatusNotDetermined) {
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        [self getAblumImage];
                    }
                }];
                
            } else {
                [self tips:YES];
            }
        }
    });
}

- (void)getCameraImage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self checkCameraError]) {
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if (status == AVAuthorizationStatusAuthorized) {
                
                self.picker = [[UIImagePickerController alloc] init];
                self.picker.delegate = self;
                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [[SKT currentVC] presentViewController:self.picker animated:YES completion:nil];
                
            } else if (status == AVAuthorizationStatusNotDetermined) {
                
                [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                    if (granted) {
                        [self getCameraImage];
                    }
                }];
                
            } else {
                [self tips:NO];
            }
        }
    });
}

- (void)tips:(BOOL)isAblum {
    
    NSString *content = isAblum ? @"相册权限获取失败，请跳至系统进行授权":@"摄像机权限获取失败，请跳至系统授权";
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = self.color;
    [alert addButton:@"去设置" actionBlock:^{
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [alert setHorizontalButtons:YES];
    [alert showCustom:[SKT currentVC] image:[UIImage imageNamed:@"icon-1"] color:SKCurrentColor title:@"提醒" subTitle:content closeButtonTitle:@"取消" duration:0.0f];
}

- (BOOL)checkCameraError {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = self.color;
    if (![self isCameraAvailable]) {
        [alert showError:[SKT currentVC] title:@"提醒"
                subTitle:@"你的设备没有发现摄像头"
        closeButtonTitle:@"好的" duration:2.0f];
        return NO;
    }
    if (![self isFrontCameraAvailable]) {
        [alert showError:[SKT currentVC] title:@"提醒"
                subTitle:@"你的设备摄像头不可用"
        closeButtonTitle:@"好的" duration:2.0f];
        return NO;
    }
    
    return YES;
}

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    if ([@"public.image" isEqualToString:info[UIImagePickerControllerMediaType]]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        if (self.sender) {
            if ([self.sender isKindOfClass:[UIImageView class]]) {
                ((UIImageView *)self.sender).image = image;
            } else if ([self.sender isKindOfClass:[UIButton class]]) {
                [((UIButton *)self.sender) setImage:image forState:UIControlStateNormal];
            }
            
            ((UIView *)self.sender).tag = 1;
        }
        if (self.imageBlock) {
            self.imageBlock(image, nil);
        }
    }
    [[SKT currentVC] dismissViewControllerAnimated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results  API_AVAILABLE(ios(14)){
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (!results || !results.count) {
        return;
    }
    NSItemProvider *itemProvider = results.firstObject.itemProvider;
    if ([itemProvider canLoadObjectOfClass:UIImage.class]) {
        [itemProvider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:UIImage.class]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = (UIImage *)object;
                    if (self.sender) {
                        if ([self.sender isKindOfClass:[UIImageView class]]) {
                            ((UIImageView *)self.sender).image = image;
                        } else if ([self.sender isKindOfClass:[UIButton class]]) {
                            [((UIButton *)self.sender) setImage:image forState:UIControlStateNormal];
                        }
                        
                        ((UIView *)self.sender).tag = 1;
                    }
                    if (self.imageBlock) {
                        self.imageBlock(image, nil);
                    }
                });
            }
        }];
    }
}

#pragma mark 为空判断
+ (BOOL)checkError:(id)sender Content:(NSString *)content {
    BOOL isOK  = YES;
    if (!sender) {
        isOK = NO;
    }
    if ([sender isKindOfClass:UIImageView.class] || [sender isKindOfClass:UIButton.class]) {
        isOK   = (((UIView *)sender).tag || ((UIView *)sender).hidden);
    }
    if ([sender isKindOfClass:UITextField.class] || [sender isKindOfClass:UITableView.class]) {
        isOK   = (((UITextField *)sender).text.length || ((UITextField *)sender).hidden);
    }
    if ([sender isKindOfClass:NSString.class]) {
        isOK   = ((NSString *)sender).length;
    }
    if ([sender isKindOfClass:NSArray.class]) {
        isOK   = ((NSArray *)sender).count;
    }
    
    if (!isOK) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.customViewColor = [SKT skt].color;
        [alert showError:[SKT currentVC] title:@"提醒" subTitle:[content stringByAppendingString:@"不能为空"] closeButtonTitle:@"好的" duration:2.0f];
    }
    
    return isOK;
}

+ (BOOL)checkError:(NSArray *)senders Contents:(NSArray *)contents {
    for (NSInteger i=0; i<senders.count; i++) {
        if (![self checkError:senders[i] Content:contents[i]]) {
            return NO;
        }
    }
    
    return YES;
}

+ (void)checkError:(NSArray *)senders Title:(NSString *)title Contents:(NSArray *)contents ReInfo:(BOOL)reInfo Block:(SKObjectBlock)block {
    NSMutableDictionary *dic  = [NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i=0; i<senders.count; i++) {
        id sender      = senders[i];
        if (([sender isKindOfClass:UIView.class] && ![sender isHidden]) ||
            ![sender isKindOfClass:UIView.class]) {
            
            BOOL isOK  = YES;
            if ([sender isKindOfClass:UIImageView.class] || [sender isKindOfClass:UIButton.class]) {
                
                if ([sender isKindOfClass:UIImageView.class]) {
                    NSString *temp = ((UIImageView *)sender).image.imageUrl;
                    [arr addObject:temp];
                    dic[[NSString stringWithFormat:@"%@%@",@"FanPionier",contents[i]]] = temp;
                    isOK   = (((UIView *)sender).tag || ((UIView *)sender).hidden);
                } else {
                    if (((UIButton *)sender).titleLabel.text && ((UIButton *)sender).selected) {
                        dic[[NSString stringWithFormat:@"%@%@",@"FanPionier",contents[i]]] = ((UIButton *)sender).titleLabel.text;
                        if (((UIButton *)sender).tag) {
                            [arr addObject:@(((UIButton *)sender).tag).stringValue];
                        } else {
                            [arr addObject:((UIButton *)sender).titleLabel.text];
                        }
                        
                        isOK = ((UIButton *)sender).selected;
                    } else {
                        NSString *temp = ((UIButton *)sender).imageView.image.imageUrl;
                        [arr addObject:temp];
                        dic[[NSString stringWithFormat:@"%@%@",@"FanPionier",contents[i]]] = ((UIButton *)sender).imageView.image.imageUrl;
                    }
                }
            }
            if ([sender isKindOfClass:UITextField.class] || [sender isKindOfClass:UITextView.class] || [sender isKindOfClass:UILabel.class]) {
                isOK   = (((UITextField *)sender).text.length || ((UITextField *)sender).hidden);
                [arr addObject:((UITextField *)sender).text];
                dic[[NSString stringWithFormat:@"%@%@",@"FanPionier",contents[i]]]    = ((UITextField *)sender).text;
            }
            if ([sender isKindOfClass:NSString.class]) {
                isOK   = ((NSString *)sender).length;
                [arr addObject:sender];
                dic[[NSString stringWithFormat:@"%@%@",@"FanPionier",contents[i]]]    = sender;
            }
            if ([sender isKindOfClass:NSArray.class]) {
                isOK   = ((NSArray *)sender).count;
                [arr addObject:sender];
//                for (NSInteger j=0; j<((NSArray *)sender).count; j++) {
//                    if (![self checkError:((NSArray *)sender)[j] Content:contents[i][j]]) {
//                        return;
//                    }
//                }
//                if ([((NSArray *)sender)[0] isKindOfClass:UIImageView.class]) {
//                    NSMutableArray *arra = [NSMutableArray array];
//                    for (UIImageView *imageView in ((NSArray *)sender)) {
//                        [arra addObject:imageView.image.imageUrl];
//                    }
//                    [arr addObject:arra];
//                }
            }
            
            if (!isOK) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                alert.customViewColor = [SKT skt].color;
                [alert showError:[SKT currentVC] title:@"提醒" subTitle:[((NSString *)contents[i]) isEqualToString:@"类型"]?
                 [NSString stringWithFormat:@"%@ %@ 必须要选择",title,contents[i]]:[NSString stringWithFormat:@"%@ %@ 不能为空",title,contents[i]] closeButtonTitle:@"好的" duration:2.0f];
                return;
            }
        }
    }
    
    if (block) {
        if (reInfo) {
            block(dic);
        } else {
            block(arr);
        }
    }
}

#pragma mark 保存数据
+ (void)save:(id)value Key:(NSString *)key {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:SKUserGet(key)];
    [array removeObject:value];
    [array insertObject:value atIndex:0];
    SKUserSet(key, array.copy);
}

+ (void)remove:(id)value Key:(NSString *)key {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:SKUserGet(key)];
    [array removeObject:value];
    SKUserSet(key, array);
}

+ (BOOL)update:(id)value Key:(NSString *)key {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:SKUserGet(key)];
    
    if ([array containsObject:value]) {
        [array removeObject:value];
        SKUserSet(key, array.copy);
        return NO;
    } else {
        [array insertObject:value atIndex:0];
        SKUserSet(key, array.copy);
        return YES;
    }
}

+ (void)update:(id)value1 value2:(id)value2 Key:(NSString *)key {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:SKUserGet(key)];
    [array replaceObjectAtIndex:[array indexOfObject:value1] withObject:value2];
    SKUserSet(key, array);
}

+ (BOOL)contains:(id)value Key:(NSString *)key {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:SKUserGet(key)];
    return [array containsObject:value];
}

+ (void)showInfo:(SKInfoType)type content:(NSString * _Nullable)content block:(SKBoolBlock _Nullable)block {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = SKCurrentColor;
    
    CGFloat duration = 0;
    
    switch (type) {
        case SKInfoTypeInfo: {
            [alert showInfo:[SKT currentVC] title:@"提醒" subTitle:content closeButtonTitle:nil duration:1.5f];
        }
            break;
        case SKInfoTypeNotice: {
            [alert showNotice:[SKT currentVC] title:@"提醒" subTitle:content closeButtonTitle:nil duration:1.5f];
        }
            break;
        case SKInfoTypeLoding: {
            
            [alert showWaiting:[SKT currentVC] title:@"提醒" subTitle:@"正在处理.." closeButtonTitle:nil duration:1.5f];
            if (content) {
                duration += 2;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert showSuccess:[SKT currentVC] title:@"提醒" subTitle:content closeButtonTitle:nil duration:duration];
                });
            }
        }
            break;
        case SKInfoTypeError: {
            [alert showError:[SKT currentVC] title:@"提醒" subTitle:content closeButtonTitle:nil duration:1.5f];
        }
            break;
        case SKInfoTypeSuccess: {
            [alert showSuccess:[SKT currentVC] title:@"提醒" subTitle:content closeButtonTitle:nil duration:1.5f];
        }
            break;
            
        default:
            break;
    }
    
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1.8+(duration+0.3)) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            block(YES);
        });
    }
}

+ (void)showClick:(NSString *)title content:(NSString *)content clicks:(NSArray *)clicks block:(SKIndexBlock)block {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = SKCurrentColor;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger index=0; index<clicks.count; index++) {
        [array addObject:[alert addButton:clicks[index] actionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                block(index);
            });
        }]];
    }
    
    [alert showCustom:[SKT currentVC] image:[[UIImage imageNamed:@"icon-1"] initwithColor:UIColor.systemBackgroundColor] color:SKCurrentColor title:title subTitle:content closeButtonTitle:@"取消" duration:0.0f];
}

+ (void)showEdit:(NSArray *)contents content:(NSString *)title block:(SKDataBlock)block {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = SKCurrentColor;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger index=0; index<contents.count; index++) {
        SCLTextView *textView = [alert addTextField:contents[index]];
        textView.textAlignment = NSTextAlignmentCenter;
        [array addObject:textView];
    }
    
    [alert addButton:@"确认" actionBlock:^{
        [self checkError:array Title:title Contents:contents ReInfo:NO Block:^(id  _Nullable object) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                block(object);
            });
        }];
    }];
    
    [alert showEdit:[SKT currentVC] title:@"提醒" subTitle:title closeButtonTitle:@"取消" duration:0.0f];
}

#pragma mark 分享评论
+ (void)shareOrRate:(NSString *)appid Shared:(BOOL)shared  {
    
    if (shared) {
        if (@available(iOS 10.3, *)) {
            [SKStoreReviewController requestReview];
        } else {
            [[SKT skt] loadAppStoreControllerWithAppID:appid];
        }
    } else {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString * shareText = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        UIImage * shareImage = [UIImage imageNamed:@"logo"];
        NSURL * shareURL = [NSURL URLWithString:[@"itms-apps://itunes.apple.com/app/id" stringByAppendingString:appid]];
        NSArray * activityItems = [[NSArray alloc] initWithObjects:shareText, shareImage, shareURL, nil];
        UIActivityViewController * activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            NSLog(@"%@",activityType);
            if (completed) {
                NSLog(@"分享成功");
            } else {
                NSLog(@"分享失败");
            }
            [activityVC dismissViewControllerAnimated:YES completion:nil];
        };
        activityVC.completionWithItemsHandler = myBlock;
        [[SKT currentVC] presentViewController:activityVC animated:YES completion:nil];
    }
}

/** 加载App Store评论页 */
- (void)loadAppStoreControllerWithAppID:(NSString *)appID {
    // 初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    
    // 设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    
    // 加载对应的APP详情页
    [storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appID} completionBlock:^(BOOL result, NSError * _Nullable error) {
        if(error) {
        } else {
            // 模态弹出appstore
            [[SKT currentVC] presentViewController:storeProductViewContorller animated:YES completion:nil];
        }
    }];
}

#pragma mark - AppStore取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController {
    [[SKT currentVC] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 发送邮件
+ (void)sendEmail:(NSArray *)titles Images:(NSArray *)images {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = [SKT skt].color;
    SCLTextView *text = [alert addTextField:@"邮箱账号"];
    text.textAlignment = NSTextAlignmentCenter;
    [alert addButton:@"确认" actionBlock:^{
        if (text.text.length) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSString * shareText = [infoDictionary objectForKey:@"CFBundleName"];
                
                if (NO == [MFMailComposeViewController canSendMail]) {
                    [[SKT skt] noConfigured];
                    return;
                }
                
                // 如果没有配置邮箱的话，创建出来的对象为nil,弹出会crash
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                
                // 设置picker的委托方法，完成之后会自动调用成功或失败的方法
                picker.mailComposeDelegate = [SKT skt];
                // 添加主题
                [picker setSubject:[NSString stringWithFormat:@"此邮件信息来自 『%@』",shareText]];
                // 添加收件人
                NSArray *toRecipients = [NSArray arrayWithObject:text.text];
                
                [picker setToRecipients:toRecipients];
                
                for (NSInteger i=0; i<images.count; i++) {
                    id image = images[i];
                    if ([image isKindOfClass:UIImage.class]) {
                        [picker addAttachmentData:UIImageJPEGRepresentation(image, 0.9) mimeType:@"image/jpeg" fileName:titles[i]];
                    } else if ([image isKindOfClass:NSString.class]){
                        [picker addAttachmentData:[NSData dataWithContentsOfFile:((NSString *)image).imageUrl] mimeType:@"image/jpeg" fileName:titles[i]];
                    }
                }
                
                [[SKT currentVC] presentViewController:picker animated:YES completion:nil];
            });
        } else {
            SCLAlertView *alert1 = [[SCLAlertView alloc] init];
            alert1.customViewColor = [SKT skt].color;
            [alert1 showError:[self currentVC] title:@"提醒"
                     subTitle:@"请输入邮箱账号"
             closeButtonTitle:@"好的" duration:2.0f];
        }
    }];
    [alert showEdit:[self currentVC] title:@"发送邮件"
           subTitle:@"请输入邮箱账号"
   closeButtonTitle:@"取消" duration:0.0f];
}

- (void)noConfigured {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = self.color;
    [alert showEdit:[SKT currentVC] title:@"提醒"
           subTitle:@"您尚未配置电子邮件帐户"
   closeButtonTitle:@"好的" duration:2.0f];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

+ (void)callPhone:(NSString *)phone {
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phone];
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:str];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        //OpenSuccess=选择 呼叫 为 1  选择 取消 为0
        NSLog(@"OpenSuccess=%d",success);
    }];
}

+ (void)playAudio:(NSInteger)soundID {
    AudioServicesPlaySystemSound(soundID);
    // 震动 只有iPhone才能震动而且还得在设置里开启震动才行,其他的如touch就没有震动功能
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)async:(SKNormalBlockBlock)asyncBlock main:(SKNormalBlock)mainBlock {
    if (![SKT skt].isFinish) {
        [SKT skt].isFinish = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            asyncBlock(^(){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SKT skt].isFinish = NO;
                    mainBlock();
                });
            });
        });
    }
}

+ (void)saveData:(NSArray *)data name:(NSString *)name {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"plist"]];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:filePath error:nil];
    [manager createFileAtPath:filePath contents:nil attributes:nil];
    [data writeToFile:filePath atomically:YES];
    [self copy:filePath notice:@"保存成功"];
}

+ (void)copy:(NSString *)content notice:(NSString *)notice {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = content;
    SCLAlertView *alert = [[SCLAlertView  alloc] init];
    alert.showAnimationType = 0;
    alert.customViewColor = SKThemeColor;
    if (notice) {
        [SKT showInfo:SKInfoTypeNotice content:notice block:nil];
    }
}

@end
