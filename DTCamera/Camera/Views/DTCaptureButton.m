//
//  DTCaptureButton.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/9.
//

#import "DTCaptureButton.h"

#define LINE_WIDTH 6.0f

@interface DTCaptureButton ()

@property (nonatomic, strong) CALayer *circleLayer;

@end

@implementation DTCaptureButton

+ (instancetype)caputreButton {
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 68, 68) mode:DTCaptureButtonModeVideo];
}

+ (instancetype)captureButtonWithFrame:(CGRect)frame mode:(DTCaptureButtonMode)mode {
    return [[self alloc] initWithFrame:frame mode:mode];
}

- (instancetype)initWithFrame:(CGRect)frame mode:(DTCaptureButtonMode)mode {
    self = [super initWithFrame:frame];
    if (self) {
        self.captureButtonMode = mode;
        [self _buildUI];
    }
    return self;
}

- (void)_buildUI {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    UIColor *circleColor = (self.captureButtonMode == DTCaptureButtonModeVideo) ? UIColor.systemRedColor : UIColor.whiteColor;
    _circleLayer = [CALayer layer];
    _circleLayer.backgroundColor = circleColor.CGColor;
    _circleLayer.bounds = CGRectInset(self.bounds, 8.0, 8.0);
    _circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _circleLayer.cornerRadius = _circleLayer.bounds.size.width / 2.0f;
    [self.layer addSublayer:_circleLayer];
}

- (void)setCaptureButtonMode:(DTCaptureButtonMode)captureButtonMode {
    if (_captureButtonMode != captureButtonMode) {
        _captureButtonMode = captureButtonMode;
        UIColor *circleColor = (captureButtonMode == DTCaptureButtonModeVideo) ? UIColor.systemRedColor : UIColor.whiteColor;
        _circleLayer.backgroundColor = circleColor.CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeAnimation.duration = 0.2f;
    if (highlighted) {
        fadeAnimation.toValue = @0.0f;
    } else {
        fadeAnimation.toValue = @1.0f;
    }
    self.circleLayer.opacity = [fadeAnimation.toValue floatValue];
    [self.circleLayer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.captureButtonMode == DTCaptureButtonModeVideo) {
        [CATransaction disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        if (selected) {
            scaleAnimation.toValue = @0.6f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 4.0f);
        } else {
            scaleAnimation.toValue = @1.0f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 2.0f);
        }
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, radiusAnimation];
        animationGroup.beginTime = CACurrentMediaTime() + 0.2f;
        animationGroup.duration = 0.35f;
        [self.circleLayer setValue:radiusAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
        [self.circleLayer addAnimation:animationGroup forKey:@"scaleAndRadiusAnimation"];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGRect insetRect = CGRectInset(rect, LINE_WIDTH / 2.0f, LINE_WIDTH / 2.0f);
    CGContextStrokeEllipseInRect(context, insetRect);
}


@end
