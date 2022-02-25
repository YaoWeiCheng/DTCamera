//
//  DTCameraController.h
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/8.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface DTCameraController : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, assign, readonly) NSUInteger cameraCount;

/// 设置session配置
- (BOOL)setupSession:(NSError **)error;
/// 开始
- (void)startSession;
/// 结束
- (void)stopSession;
/// 拍摄支持
- (BOOL)canSwitchCameras;
/// 切换拍摄
- (BOOL)switchCameras;
/// 拍摄
- (void)captureImage;
/// 开始录制
- (void)startRecording;
/// 停止录制
- (void)stopRecording;
/// 录制时间
- (CMTime)recordedDuration;
@end

