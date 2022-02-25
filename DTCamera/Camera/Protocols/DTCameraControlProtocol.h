//
//  DTCameraControlProtocol.h
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/11.
//


typedef NS_OPTIONS(NSUInteger, DTCameraModeType) {
    DTCameraModeTypeVideo = 1 << 0,
    DTCameraModeTypePhoto = 1 << 1,
};

@protocol DTCameraControlProtocol <NSObject>
@optional;
///
/// 即将改变拍摄模式
/// @param modeType 模式
/// @return 返回NO代表不执行改变模式操作
///
- (BOOL)changeWillCameraMode:(DTCameraModeType)modeType;
///
/// 已改变拍摄模式
/// @param modeType 模式
///
- (void)changeEndCameraMode:(DTCameraModeType)modeType;
///
/// 点击拍摄回调
/// @param modeType 模式
///
- (void)touchEndCaptureWithMode:(DTCameraModeType)modeType isRecording:(BOOL)recording;


@end
