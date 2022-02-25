//
//  DTCameraModeView.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/9.
//

#import "DTCameraModeView.h"
#import "DTCaptureButton.h"
#import "UIView+Camera.h"


#define MODE_STACK_WIDTH  110
#define MODE_STACK_HEIGHT 40

@interface DTCameraModeView ()

@property (nonatomic, strong) UIStackView *modeStackView;

@property (nonatomic, strong) UIButton *videoBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) DTCaptureButton *captureButton;

@property (nonatomic, assign) BOOL maxLeft;

@property (nonatomic, assign) BOOL maxRight;

@end

@implementation DTCameraModeView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _buildUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _buildUI];
    }
    return self;
}

- (void)_buildUI {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    self.videoBtn = [self buildButtonWithName:@"视频"];
    self.videoBtn.tag = DTCameraModeTypeVideo;
    self.photoBtn = [self buildButtonWithName:@"照片"];
    self.photoBtn.tag = DTCameraModeTypePhoto;
    self.modeStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.videoBtn, self.photoBtn]];
    [self addSubview:self.modeStackView];
    CGFloat width = MODE_STACK_WIDTH;
    self.modeStackView.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - width / 4, 0, width, MODE_STACK_HEIGHT);
    self.modeStackView.axis = UILayoutConstraintAxisHorizontal;
    self.modeStackView.distribution = UIStackViewDistributionFillEqually;
    self.modeStackView.backgroundColor = UIColor.clearColor;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureClickAction:)];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureClickAction:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.modeStackView addGestureRecognizer:leftSwipe];
    [self.modeStackView addGestureRecognizer:rightSwipe];
    CGFloat circleWidth = 68;
    self.captureButton = [DTCaptureButton captureButtonWithFrame:CGRectMake(CGRectGetMidX(self.frame) - circleWidth / 2, MODE_STACK_HEIGHT + 20, circleWidth, circleWidth) mode:DTCaptureButtonModeVideo];
    [self addSubview:self.captureButton];
    [self.captureButton addTarget:self action:@selector(captureOrRecord:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraModeType = DTCameraModeTypeVideo;
    self.maxLeft = NO;
    self.maxRight = YES;
    

}

- (UIButton *)buildButtonWithName:(NSString *)name {
    UIButton *btn = [UIButton new];
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemYellowColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(modeClickAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    return btn;
}

- (void)swipeModeWithDirection:(UISwipeGestureRecognizerDirection)direction {
    CGRect frame = self.modeStackView.frame;
    if (direction == UISwipeGestureRecognizerDirectionLeft && self.maxLeft != YES) {
        frame.origin.x = CGRectGetMinX(frame) - CGRectGetWidth(frame) / 2;
        [UIView animateWithDuration:0.25 animations:^{
            self.modeStackView.frame = frame;
        } completion:^(BOOL finished) {
            self.maxLeft = YES;
            self.maxRight = NO;
        }];
    } else if (direction == UISwipeGestureRecognizerDirectionRight && self.maxRight != YES) {
        frame.origin.x = CGRectGetWidth(self.frame) / 2 - MODE_STACK_WIDTH / 4;
        [UIView animateWithDuration:0.25 animations:^{
            self.modeStackView.frame = frame;
        } completion:^(BOOL finished) {
            self.maxLeft = NO;
            self.maxRight = YES;
        }];
    }
}

- (void)recodeVideoStatusWithIsSelected:(BOOL)isSelected {
    UIColor *color = [UIColor colorWithWhite:0 alpha:0.3];
    CGFloat alpha = 1.0f;
    BOOL modeEnabled = YES;
    if (isSelected) {
        color = [UIColor colorWithWhite:0 alpha:0];
        alpha = 0.0;
        modeEnabled = NO;
    }
    self.modeStackView.userInteractionEnabled = modeEnabled;
    [UIView animateWithDuration:0.25 animations:^{
        self.modeStackView.alpha = alpha;
        self.backgroundColor = color;
    }];
}

// MARK: - Action

- (void)captureOrRecord:(UIButton *)btn {
    BOOL isRecording = YES;
    if (self.cameraModeType == DTCameraModeTypeVideo) {
        btn.selected = !btn.selected;
        isRecording = btn.isSelected;
        [self recodeVideoStatusWithIsSelected:btn.selected];
    }
    if ([self.delegate respondsToSelector:@selector(touchEndCaptureWithMode:isRecording:)]) {
        [self.delegate touchEndCaptureWithMode:self.cameraModeType isRecording:isRecording];
    }
}

- (void)modeClickAction:(UIButton *)btn {
    if (self.cameraModeType == btn.tag) {
        return;
    }
    self.cameraModeType = btn.tag;
}

- (void)swipeGestureClickAction:(UISwipeGestureRecognizer *)swipe {
    self.cameraModeType = swipe.direction == UISwipeGestureRecognizerDirectionLeft ? DTCameraModeTypePhoto : DTCameraModeTypeVideo;
}

// MARK: - setter/getter

- (void)setCameraModeType:(DTCameraModeType)cameraModeType {
    if (_cameraModeType == cameraModeType) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(changeWillCameraMode:)]) {
        if (![self.delegate changeWillCameraMode:_cameraModeType]) {
            return;
        }
    }
    
    _cameraModeType = cameraModeType;
    if (cameraModeType == DTCameraModeTypeVideo) {
        self.captureButton.captureButtonMode = DTCaptureButtonModeVideo;
    } else {
        self.captureButton.captureButtonMode = DTCaptureButtonModePhoto;
    }
    if (cameraModeType == DTCameraModeTypeVideo) {
        [self swipeModeWithDirection:UISwipeGestureRecognizerDirectionRight];
    } else {
        [self swipeModeWithDirection:UISwipeGestureRecognizerDirectionLeft];
    }
    self.videoBtn.selected = cameraModeType == DTCameraModeTypeVideo;
    self.photoBtn.selected = !self.videoBtn.selected;
    
    if ([self.delegate respondsToSelector:@selector(changeEndCameraMode:)]) {
        [self.delegate changeEndCameraMode:_cameraModeType];
    }
}
@end
