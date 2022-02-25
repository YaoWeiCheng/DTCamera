//
//  DTCaptureButton.h
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/9.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DTCaptureButtonMode) {
    DTCaptureButtonModeVideo = 0,
    DTCaptureButtonModePhoto,
};

@interface DTCaptureButton : UIButton

@property (nonatomic, assign) DTCaptureButtonMode captureButtonMode;


+ (instancetype)caputreButton;
+ (instancetype)captureButtonWithFrame:(CGRect)frame mode:(DTCaptureButtonMode)mode;

@end


