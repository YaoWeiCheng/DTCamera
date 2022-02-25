//
//  DTOverlayView.h
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/8.
//

#import <UIKit/UIKit.h>
#import "DTCameraControlProtocol.h"


@interface DTOverlayView : UIView

@property (nonatomic, weak) id<DTCameraControlProtocol> delegate;

- (void)updateTimerDisplayWithDuration:(NSString *)duration;
@end

