//
//  DTCameraViewController.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/8.
//

#import "DTCameraViewController.h"
#import "DTCameraController.h"
#import "DTPreviewView.h"
#import "DTOverlayView.h"
#import "DTCameraControlProtocol.h"

@interface DTCameraViewController ()<DTCameraControlProtocol>

@property (nonatomic, strong) DTPreviewView *previewView;

@property (nonatomic, strong) DTOverlayView *overlayView;

@property (nonatomic, strong) DTCameraController *cameraController;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DTCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self _initData];
}


- (void)setupView {
    
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.previewView = [[DTPreviewView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.previewView];
    
    self.overlayView = [[DTOverlayView alloc] initWithFrame:self.view.bounds];
    self.overlayView.delegate = self;
    [self.view addSubview:self.overlayView];
    self.overlayView.delegate = self;
}

- (void)_initData {
    
    self.cameraController = [[DTCameraController alloc] init];
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        [self.previewView setSession:self.cameraController.captureSession];
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTimeDisplay) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self.overlayView updateTimerDisplayWithDuration:@"00:00:00"];
}

- (void)updateTimeDisplay {
    CMTime duration = self.cameraController.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    [self.overlayView updateTimerDisplayWithDuration:timeString];
}

// MARK: - DTCameraControlProtocol

- (void)touchEndCaptureWithMode:(DTCameraModeType)modeType isRecording:(BOOL)recording {
    if (modeType == DTCameraModeTypePhoto) {
        [self.cameraController captureImage];
    } else {
        if (recording) {
            [self.cameraController startRecording];
            [self startTimer];
        } else {
            [self.cameraController stopRecording];
            [self stopTimer];
        }
    }
}

- (void)changeEndCameraMode:(DTCameraModeType)modeType {
//    [self.cameraController switchCameras];
}

- (BOOL)changeWillCameraMode:(DTCameraModeType)modeType {
    return YES;
}

@end
