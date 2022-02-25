//
//  DTCameraModeView.h
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/9.
//

#import <UIKit/UIKit.h>
#import "DTCameraControlProtocol.h"


@interface DTCameraModeView : UIView

@property (nonatomic, assign) DTCameraModeType cameraModeType;

@property (nonatomic, weak) id<DTCameraControlProtocol> delegate;


@end


