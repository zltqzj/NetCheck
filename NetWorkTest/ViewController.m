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
#import "FCFileManager.h"
static const NSString* downloadUrl = @"";

@interface ViewController () <LDNetDiagnoServiceDelegate, UITextFieldDelegate> {
    UITextField *_txtfield_dormain;
   
    LDNetDiagnoService *_netDiagnoService;
}

@property(strong,nonatomic)NSString* logInfo;
@property(strong,nonatomic) UIActivityIndicatorView* indicatorView;
@property(weak,nonatomic) IBOutlet UIButton *startBtn;
@property(weak,nonatomic) IBOutlet UITextView *txtView_log;
@property(strong,nonatomic) NSMutableArray* apiArray;
@property(assign,nonatomic) NSInteger apiCheckCount;

@property(strong,nonatomic) NSTimer* timer;
@property(assign,nonatomic) BOOL isRunning;
@property(strong,nonatomic) NSMutableArray* cdnArray;
@property(assign,nonatomic) NSInteger cdnCheckCount;
//cn  中国  us_west 美国西部  us_east 美国东部 sg 新加坡  au 澳大利亚 de 德国
@end

@implementation ViewController


-(void)fileShow{
    NSString * cachePath = [FCFileManager pathForCachesDirectory];
    NSLog(@"%@",cachePath);
    NSArray* filenames = [FCFileManager listFilesInDirectoryAtPath:cachePath];
    NSLog(@"%@",filenames);
    
    [filenames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* filename = [NSString stringWithFormat:@"\n%lu:,%@\n",(unsigned long)idx,[[obj componentsSeparatedByString:@"/"] lastObject]];
        _logInfo = [_logInfo stringByAppendingString:filename];
    }];
    _logInfo = [_logInfo stringByAppendingString:@"下载完成"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
 
 
    _apiArray = [NSMutableArray new];
    [_apiArray addObject:@"api.boxfish.cn"];
    [_apiArray addObject:@"storage.boxfish.cn"];
    _cdnArray = [[NSMutableArray alloc] initWithObjects:@"cn",@"us_west",@"us_east",@"sg",@"au",@"de", nil];
    
    
    NSArray* filename = [FCFileManager listFilesInDirectoryAtPath:[FCFileManager pathForCachesDirectory]];
 
    [filename enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [FCFileManager removeItemAtPath:obj error:nil];
    }];
    
    
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.hidden = NO;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"copy" style:UIBarButtonItemStylePlain target:self action:@selector(copyToPasteboard)];
    
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
    if (_apiCheckCount == 0) {
        _txtView_log.text = @"";
        _logInfo = @"";
        _startBtn.userInteractionEnabled = NO;
    }
    
    if (_apiCheckCount == _apiArray.count) {
        _startBtn.userInteractionEnabled = YES;
        return ;
    }
    [_txtfield_dormain resignFirstResponder];
   
     _txtfield_dormain.text = _apiArray[_apiCheckCount] ;
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
     _apiCheckCount ++ ;
    dispatch_async(dispatch_get_main_queue(), ^{
        _isRunning = NO;
        _logInfo = [_logInfo stringByAppendingString:@"--------------"];
        _txtView_log.text = _logInfo;
    });
    
    if (_apiCheckCount == _apiArray.count ) {
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
    
    for (NSString* region in _cdnArray){
        NSString *urlStr2 = [NSString stringWithFormat:@"%@%@",@"http://api.boxfish.cn/data/7729ea6237db7d8d03df36875c1263b7?server=",region];
        NSLog(@"urlStr2-----%@",urlStr2);
        __weak typeof(self) weakSelf = self;
        
             [[MXDownloadManager sharedDataCenter] addDownloadTaskToList:urlStr2 taskName:region taskIdentifier:region];
             [MXDownloadManager sharedDataCenter].myBlock = ^(NSString* str){
                // NSLog(@"%@",str);
                 if ([str isEqualToString:@"ok"]) {
                     [weakSelf fileShow];
                     dispatch_async(dispatch_get_main_queue(), ^(){
                         weakSelf.txtView_log.text  = weakSelf.logInfo;
                     });
                     weakSelf.cdnCheckCount ++;
                    
                     if (weakSelf.cdnCheckCount == weakSelf.cdnArray.count) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              [weakSelf allClear];
                         });
                       
                     }
 
                 }
             };
        
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCheckTaskStatus) userInfo:nil repeats:YES];
            [_timer fire];
        }
    }
}


- (void)timeCheckTaskStatus{
    MXDownloadModel *task2Model = [[MXDownloadManager sharedDataCenter] askForTaskStatusWithTaskIdentifier:@"task_second"];
    if (task2Model) {
        _logInfo = [_logInfo stringByAppendingString:[NSString stringWithFormat:@"\nspeed:%@,已下载：%.1f%%",task2Model.taskSpeed,task2Model.taskProgress*100]];
        _txtView_log.text  =  _logInfo;
    }
}


-(void)allClear{
    NSLog(@"end-----");
    [self.timer invalidate];
    self.timer = nil;
    [self.indicatorView stopAnimating];
    [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
    self.isRunning = NO;
    self.apiCheckCount = 0;
    self.cdnCheckCount = 0;
    [self  copyToPasteboard];
    [self remove_animation];
    [self.startBtn setUserInteractionEnabled:TRUE];
}
@end

