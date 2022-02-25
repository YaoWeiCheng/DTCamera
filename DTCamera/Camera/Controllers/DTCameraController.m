//
//  DTCameraController.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/8.
//

#import <UIKit/UIKit.h>
#import "DTCameraController.h"

@interface DTCameraController ()<AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;

@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput;

@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSURL *outputURL;

@property (nonatomic, assign) NSUInteger cameraCount;




@end

@implementation DTCameraController


- (BOOL)setupSession:(NSError **)error {
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    // 获取一个指向默认视频捕捉设备的指针，一般是返回手机后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        NSLog(@"loading failure");
        return NO;
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    }
    
    // 捕捉静态图片
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    if ([self.imageOutput.connections.lastObject isVideoOrientationSupported]) {
        [self.imageOutput.connections.lastObject setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    
    // 视频输出
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    self.queue = dispatch_queue_create("com.DTCamera.queue", NULL);
    return YES;
}

- (void)startSession {
    
    if (![self.captureSession isRunning]) {
        dispatch_async(self.queue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    
    if ([self.captureSession isRunning]) {
        dispatch_async(self.queue, ^{
            [self.captureSession stopRunning];
        });
    }
}

// MARK: - 设备配置

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {

    NSArray<AVCaptureDeviceType> *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera];
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (NSUInteger)cameraCount {
    NSArray<AVCaptureDeviceType> *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera];
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    return devices.count;
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (BOOL)switchCameras {
    
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    // 获取未激活的摄像头的指针
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            // 如果新的输入无法被添加，则重新添加之前的输入
            [self.captureSession addInput:self.activeVideoInput];
        }
        // 配置完成
        [self.captureSession commitConfiguration];
    } else {
        //
        NSLog(@"device Configureation Failed With Error: %@", error);
        return NO;
    }
    return YES;
}

// MARK: - 图片拍摄

- (void)captureImage {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    [self.imageOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (!error) {
        NSData *data = [photo fileDataRepresentation];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"%@", image);
    }
    
}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
    
}

// MARK: - 视频录制方法

- (BOOL)isRecording {
    return self.movieOutput.recording;
}

/// 开始录制
- (void)startRecording {
    
    if (![self isRecording]) {
        AVCaptureConnection *videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        // 判断是否支持videoOrientation屏幕方向旋转属性，将其设置为当前视频方向。设置视频方向不会物理上旋转像素缓存
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        // 是否支持视频稳定，如果支持，可以显著提升捕捉到的视频质量
        if ([videoConnection isVideoStabilizationSupported]) {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        AVCaptureDevice *device = [self activeCamera];
        // 是否支持平滑对焦
        if (device.isSmoothAutoFocusSupported) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                // 摄像头可以进行平滑对焦模式的操作，即减慢摄像头镜头对焦的速度。通常情况下，当用户移动拍摄时摄像头会尝试快速自动对焦，这会在捕捉的视频中出现脉冲式效果。
                // 当平滑对焦时，会降低对焦操作的速率，从而提供更加自然的视频录制效果
                // 禁用平滑自动对焦更适用于需要快速自动对焦的视频处理，默认值为NO
                // 启用平滑自动对焦适用于电影录制。平滑的自动对焦速度较慢，视觉损伤较小
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            }
        } else {
            // error
        }
        
        self.outputURL = [self uniqueURL];
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
    }

}

/// 停止录制
- (void)stopRecording {
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

- (NSURL *)uniqueURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *dirURL = [fileManager temporaryDirectory];
    NSString *filePath = [dirURL.path stringByAppendingPathComponent:@"camera.mov"];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

// MARK: - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    NSLog(@"%@", self.outputURL.path);
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    NSLog(@"start %@", fileURL);
}
@end
