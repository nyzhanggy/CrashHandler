//
//  DDCrashContentViewController.m
//  DebugTool
//
//  Created by 张桂杨 on 2017/3/22.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDCrashContentViewController.h"
#import "DDCatchCrash.h"

@interface DDCrashContentViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DDCrashContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = [DDCatchCrash contentWithFileName:self.title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
