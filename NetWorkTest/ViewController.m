//
//  ViewController.m
//  LDNetDiagnoServieDemo
//
//  Created by zhaojian on 14-10-29.
//  Copyright (c) 2017年 zhaojian. All rights reserved.
//

#import "ViewController.h"
#import "LDNetDiagnoService.h"
#import "MBProgressHUD.h"
#import "MXDownloadManager.h"
@interface ViewController () <LDNetDiagnoServiceDelegate, UITextFieldDelegate> {
    UITextField *_txtfield_dormain;
    NSString *_logInfo;
    LDNetDiagnoService *_netDiagnoService;
    BOOL _isRunning;
}

@property(strong,nonatomic) UIActivityIndicatorView* indicatorView;
@property(weak,nonatomic) IBOutlet UIButton *startBtn;
@property(weak,nonatomic) IBOutlet UITextView *txtView_log;
@property(strong,nonatomic) NSMutableArray* apiArray;
@property(assign,nonatomic) NSInteger checkCount;
@property (weak, nonatomic) IBOutlet UILabel *task2_progress;

@property (weak, nonatomic) IBOutlet UILabel *task2_speed;
@property (weak, nonatomic) IBOutlet UILabel *task2_size;

@property(strong,nonatomic) NSMutableArray* task2_array;
@property(strong,nonatomic) NSTimer* timer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    _apiArray = [NSMutableArray new];
    [_apiArray addObject:@"api.boxfish.cn"];
    [_apiArray addObject:@"storage.boxfish.cn"];
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.hidden = NO;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    self.navigationItem.rightBarButtonItem = rightItem;
    

    [_startBtn addTarget:self action:@selector(startNetDiagnosis)forControlEvents:UIControlEventTouchUpInside];
    _startBtn.layer.cornerRadius = 40;
    _txtfield_dormain =
    [[UITextField alloc] initWithFrame:CGRectMake(130.0f, 79.0f, 180.0f, 50.0f)];
    _txtfield_dormain.returnKeyType = UIReturnKeyDone;
    _txtfield_dormain.text = _apiArray[0] ;
    _txtfield_dormain.alpha = 0;
    [self.view addSubview:_txtfield_dormain];
    
    _txtView_log.layer.borderWidth = 1.0f;
    _txtView_log.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    // Do any additional setup after loading the view, typically from a nib.
    _netDiagnoService = [[LDNetDiagnoService alloc] initWithAppCode:@"test"
                                                            appName:@"boxfish"
                                                         appVersion:@"1.0.0"
                                                             userID:@"zhaojian@boxfish.cn"
                                                           deviceID:nil
                                                            dormain:_txtfield_dormain.text
                                                        carrierName:nil
                                                     ISOCountryCode:nil
                                                  MobileCountryCode:nil
                                                      MobileNetCode:nil];
    _netDiagnoService.delegate = self;
    _isRunning = NO;
    _txtView_log.text = @"";
    _logInfo = @"";
    
}


- (void)startNetDiagnosis
{
    if (_checkCount == 0) {
        _txtView_log.text = @"";
        _logInfo = @"";
        _startBtn.userInteractionEnabled = NO;
    }
    
    if (_checkCount == _apiArray.count) {
        _startBtn.userInteractionEnabled = YES;
        return ;
    }
    [_txtfield_dormain resignFirstResponder];
   
     _txtfield_dormain.text = _apiArray[_checkCount] ;
    _netDiagnoService.dormain = _txtfield_dormain.text;
    if (!_isRunning) {
        [_indicatorView startAnimating];
        [_startBtn setTitle:@"……" forState:UIControlStateNormal];
        [self add_animation];
        [_startBtn setUserInteractionEnabled:FALSE];
        _isRunning = !_isRunning;
        [_netDiagnoService startNetDiagnosis];
    } else {
        [_indicatorView stopAnimating];
        _isRunning = !_isRunning;
        [_startBtn setTitle:@"Start" forState:UIControlStateNormal];
        [_startBtn setUserInteractionEnabled:FALSE];
        [_netDiagnoService stopNetDialogsis];
    }
}

- (void)delayMethod
{
    [_startBtn setUserInteractionEnabled:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NetDiagnosisDelegate
- (void)netDiagnosisDidStarted
{
    NSLog(@"Start～～～");
}

- (void)netDiagnosisStepInfo:(NSString *)stepInfo
{
//    NSLog(@"----------------%@", stepInfo);
    _logInfo = [_logInfo stringByAppendingString:stepInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        _txtView_log.text = _logInfo;
    });
}


- (void)netDiagnosisDidEnd:(NSString *)allLogInfo;
{
     _checkCount ++ ;
    dispatch_async(dispatch_get_main_queue(), ^{
        _isRunning = NO;
        _logInfo = [_logInfo stringByAppendingString:@"--------------"];
        _txtView_log.text = _logInfo;
    });
    
    if (_checkCount == _apiArray.count ) {
        //可以保存到文件，也可以通过邮件发送回来
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startDownloadTask2];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startNetDiagnosis];
        });
    }
}


// 复制到剪切板
- (void)copyToPasteboard{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"tips" message:@"It has been copied to the clipboard" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _txtView_log.text;
}

-(void)add_animation{
    CABasicAnimation* animation = [CABasicAnimation  animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithInt:1];
    animation.toValue = [NSNumber numberWithInt:0];
    animation.autoreverses = YES;
    animation.duration = 3.0;
    animation.repeatCount = MAXFLOAT;
    animation.fillMode = kCAFillModeForwards;
    [_startBtn.layer addAnimation:animation forKey:@"aAlpha"];
}

-(void)remove_animation{
    [_startBtn.layer removeAllAnimations];
}


- (void)startDownloadTask2 {
    if (_task2_array == nil) {
        _task2_array = [NSMutableArray new];
    }
    NSString *urlStr2 = @"http://apitest.joyoung.com:8089/ia/upload1/2015/12/24/ios.zip";
    __weak typeof(self) weakSelf = self;
    
    [[MXDownloadManager sharedDataCenter] addDownloadTaskToList:urlStr2 taskName:@"task_two" taskIdentifier:@"task_second"];
    [MXDownloadManager sharedDataCenter].myBlock = ^(NSString* str){
        NSLog(@"%@",str);
        if ([str isEqualToString:@"ok"]) {
            
           
//            NSLog(@"%@",weakSelf.task2_array);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _txtView_log.text  = [_txtView_log.text stringByAppendingString:@"下载完成"];
                // 2秒后异步执行这里的代码...
                NSLog(@"run-----");
                [_timer invalidate];
                _timer = nil;
                [_task2_array removeAllObjects];
                [_indicatorView stopAnimating];
                [_startBtn setTitle:@"Start" forState:UIControlStateNormal];
                _isRunning = NO;
                _checkCount = 0;
                [self  copyToPasteboard];
                [self remove_animation];
                [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
            });
            
            
        }
    };
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCheckTaskStatus) userInfo:nil repeats:YES];
        [_timer fire];
    }
}


- (void)timeCheckTaskStatus{
    MXDownloadModel *task2Model = [[MXDownloadManager sharedDataCenter] askForTaskStatusWithTaskIdentifier:@"task_second"];
    if (task2Model) {
        _task2_progress.text = [NSString stringWithFormat:@"已下载： %.1f%%",task2Model.taskProgress*100];
        _task2_speed.text = [NSString stringWithFormat:@"下载速度：%@",task2Model.taskSpeed];
        _task2_size.text = [NSString stringWithFormat:@"任务大小：%@",task2Model.taskSize];
//         [_task2_array addObject:task2Model.taskSpeed];
        _txtView_log.text  = [_txtView_log.text stringByAppendingString:[NSString stringWithFormat:@"\n下载速度：%@\n",task2Model.taskSpeed]];
    }
    
}



@end

