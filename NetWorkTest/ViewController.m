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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
 
    
  //  [GetIPAddress getIPAddress:YES]
    
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
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"tips" message:@"It has been copied to the clipboard" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
      
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"logInfo>>>>>\n%@", allLogInfo);
        //可以保存到文件，也可以通过邮件发送回来
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicatorView stopAnimating];
            [_startBtn setTitle:@"Start" forState:UIControlStateNormal];
            _isRunning = NO;
            _checkCount = 0;
            [self  copyToPasteboard];
            [self remove_animation];
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];

        });
    }
    else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startNetDiagnosis];
        });
 
    }
}


//- (void)emailLogInfo
//{
//    [_netDiagnoService printLogInfo];
//}

// 复制到剪切板
- (void)copyToPasteboard{
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

@end

