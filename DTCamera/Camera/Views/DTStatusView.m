//
//  DTStatusView.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/11.
//

#import "DTStatusView.h"
#import "UIView+Camera.h"

@interface DTStatusView ()



@end

@implementation DTStatusView

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
    
    
    CGFloat timeWidth = 80;
    CGFloat timeX = self.centerX - timeWidth / 2;
    CGFloat timeY = 10.0 + [self statusBarHight];
    self.recodeTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeWidth, 30)];
    [self addSubview:self.recodeTimeLabel];
    self.recodeTimeLabel.textColor = UIColor.whiteColor;
    self.recodeTimeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.recodeTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.recodeTimeLabel.backgroundColor = UIColor.systemRedColor;
    self.recodeTimeLabel.layer.cornerRadius = 4;
    self.recodeTimeLabel.layer.masksToBounds = YES;
    self.recodeTimeLabel.text = @"00:00:00";
}

- (CGFloat)statusBarHight {
   float statusBarHeight = 0;
   if (@available(iOS 13.0, *)) {
       UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
       statusBarHeight = statusBarManager.statusBarFrame.size.height;
   }
   else {
       statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
   }
   return statusBarHeight;
}


@end
