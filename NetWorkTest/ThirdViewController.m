//
//  ViewController.m
//  MXDownloadManager
//
//  Created by 谢鹏翔 on 16/3/14.
//  Copyright © 2016年 谢鹏翔. All rights reserved.
//

#import "ThirdViewController.h"
#import "MXDownloadManager.h"

@interface ThirdViewController ()
@property (weak, nonatomic) IBOutlet UILabel *task1_progress;
@property (weak, nonatomic) IBOutlet UILabel *task1_speed;
@property (weak, nonatomic) IBOutlet UILabel *task1_size;

@property (weak, nonatomic) IBOutlet UILabel *task2_progress;

@property (weak, nonatomic) IBOutlet UILabel *task2_speed;
@property (weak, nonatomic) IBOutlet UILabel *task2_size;
@property(strong,nonatomic) NSMutableArray* task1_array;
@property(strong,nonatomic) NSMutableArray* task2_array;
@property(strong,nonatomic) NSTimer* timer;

@end

@implementation ThirdViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)delayMethod{
    
}
- (IBAction)startDownloadTask2:(id)sender {
    NSString *urlStr2 = @"http://apitest.joyoung.com:8089/ia/upload1/2015/12/24/ios.zip";
    __weak typeof(self) weakSelf = self;

    [[MXDownloadManager sharedDataCenter] addDownloadTaskToList:urlStr2 taskName:@"task_two" taskIdentifier:@"task_second"];
    [MXDownloadManager sharedDataCenter].myBlock = ^(NSString* str){
        //NSLog(@"%@",str);
        if ([str isEqualToString:@"ok"]) {
            
            NSLog(@"%@",weakSelf.task2_array);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 2秒后异步执行这里的代码...
                NSLog(@"run-----");
                [_timer invalidate];
                _timer = nil;
            });
            

        }
    };
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCheckTaskStatus) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

- (void)timeCheckTaskStatus
{
  
   
    MXDownloadModel *task2Model = [[MXDownloadManager sharedDataCenter] askForTaskStatusWithTaskIdentifier:@"task_second"];
    if (task2Model) {
        _task2_progress.text = [NSString stringWithFormat:@"已下载： %.1f%%",task2Model.taskProgress*100];
        _task2_speed.text = [NSString stringWithFormat:@"下载速度：%@",task2Model.taskSpeed];
        _task2_size.text = [NSString stringWithFormat:@"任务大小：%@",task2Model.taskSize];
    }
    
}




@end

