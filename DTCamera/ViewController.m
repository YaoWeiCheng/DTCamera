//
//  ViewController.m
//  DTCamera
//
//  Created by ChengYaoWei on 2021/10/8.
//

#import "ViewController.h"
#import "DTCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    DTCameraViewController *vc = [[DTCameraViewController alloc] init];
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
