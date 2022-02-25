//
//  DTOverlayView.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/8.
//

#import "DTOverlayView.h"
#import "DTCameraModeView.h"
#import "DTStatusView.h"
#import "UIView+Camera.h"

@interface DTOverlayView ()<DTCameraControlProtocol>

@property (nonatomic, strong) DTCameraModeView *modeView;

@property (nonatomic, strong) DTStatusView *statusView;

@end

@implementation DTOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _buildUI];
    }
    return self;
}

- (void)_buildUI {
    
    self.backgroundColor = UIColor.clearColor;
    
    CGFloat modeViewH = 150;
    CGFloat modeViewY = self.frame.size.height - modeViewH;
    self.modeView = [[DTCameraModeView alloc] initWithFrame:CGRectMake(0, modeViewY, self.frame.size.width, modeViewY)];
    [self addSubview:self.modeView];
    self.modeView.delegate = self;
    CGFloat top = UIApplication.sharedApplication.windows.lastObject.safeAreaInsets.top;
    self.statusView = [[DTStatusView alloc] initWithFrame:CGRectMake(0, 0, self.width, 60 + top)];
    [self addSubview:self.statusView];
}

- (void)updateTimerDisplayWithDuration:(NSString *)duration {
    self.statusView.recodeTimeLabel.text = duration;
}


// MARK: - DTCameraControlProtocol

- (BOOL)changeWillCameraMode:(DTCameraModeType)modeType {
    if ([self.delegate respondsToSelector:@selector(changeWillCameraMode:)]) {
        return [self.delegate changeWillCameraMode:modeType];
    }
    return YES;
}

- (void)changeEndCameraMode:(DTCameraModeType)modeType {
    
    CGFloat alpha = 1.0;
    if (modeType == DTCameraModeTypePhoto) {
        alpha = 0.0;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.statusView.alpha = alpha;
    }];
    
    if ([self.delegate respondsToSelector:@selector(changeEndCameraMode:)]) {
        [self.delegate changeEndCameraMode:modeType];
    }
}

- (void)touchEndCaptureWithMode:(DTCameraModeType)modeType isRecording:(BOOL)recording {
    if ([self.delegate respondsToSelector:@selector(touchEndCaptureWithMode:isRecording:)]) {
        [self.delegate touchEndCaptureWithMode:modeType isRecording:recording];
    }
}




@end
