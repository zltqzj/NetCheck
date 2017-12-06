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
    UIActivityIndicatorView *_indicatorView;
    UIButton *btn;
    UITextView *_txtView_log;
    UITextField *_txtfield_dormain;
    
    NSString *_logInfo;
    LDNetDiagnoService *_netDiagnoService;
    BOOL _isRunning;
}

@property(strong,nonatomic) NSMutableArray* apiArray;
@property(assign,nonatomic) NSInteger checkCount;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _apiArray = [NSMutableArray new];
    [_apiArray addObject:@"api.boxfish.cn"];
    [_apiArray addObject:@"storage.boxfish.cn"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"boxfish net check";
    
    _indicatorView = [[UIActivityIndicatorView alloc]
                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.hidden = NO;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10.0f, 79.0f, 100.0f, 50.0f);
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn.titleLabel setNumberOfLines:2];
    [btn setTitle:@"Start" forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(startNetDiagnosis)
  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    _txtfield_dormain =
    [[UITextField alloc] initWithFrame:CGRectMake(130.0f, 79.0f, 180.0f, 50.0f)];
    _txtfield_dormain.delegate = self;
    _txtfield_dormain.returnKeyType = UIReturnKeyDone;
    _txtfield_dormain.text = _apiArray[0] ; //@"www.baidu.com";
    [self.view addSubview:_txtfield_dormain];
    
    
    _txtView_log = [[UITextView alloc] initWithFrame:CGRectZero];
    _txtView_log.layer.borderWidth = 1.0f;
    _txtView_log.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtView_log.backgroundColor = [UIColor whiteColor];
    _txtView_log.font = [UIFont systemFontOfSize:10.0f];
    _txtView_log.textAlignment = NSTextAlignmentLeft;
    _txtView_log.scrollEnabled = YES;
    _txtView_log.editable = NO;
    _txtView_log.frame =
    CGRectMake(0.0f, 140.0f, self.view.frame.size.width, self.view.frame.size.height - 120.0f);
    [self.view addSubview:_txtView_log];
    
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
        btn.userInteractionEnabled = NO;
    }
    
    if (_checkCount == _apiArray.count) {
        btn.userInteractionEnabled = YES;
        return ;
    }
    [_txtfield_dormain resignFirstResponder];
   
     _txtfield_dormain.text = _apiArray[_checkCount] ; //@"www.baidu.com";
    _netDiagnoService.dormain = _txtfield_dormain.text;
    if (!_isRunning) {
        [_indicatorView startAnimating];
        [btn setTitle:@"停止诊断" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
        [btn setUserInteractionEnabled:FALSE];
//        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
//        _txtView_log.text = @"";
//        _logInfo = @"";
        _isRunning = !_isRunning;
        [_netDiagnoService startNetDiagnosis];
    } else {
        [_indicatorView stopAnimating];
        _isRunning = !_isRunning;
        [btn setTitle:@"Start" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
        [btn setUserInteractionEnabled:FALSE];
//        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        [_netDiagnoService stopNetDialogsis];
    }
}

- (void)delayMethod
{
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setUserInteractionEnabled:TRUE];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            _txtView_log.text = _logInfo;
        });
    });
    
    if (_checkCount == _apiArray.count ) {
        [self  copyToPasteboard];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"tips" message:@"It has been copied to the clipboard" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
      
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"logInfo>>>>>\n%@", allLogInfo);
        //可以保存到文件，也可以通过邮件发送回来
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicatorView stopAnimating];
            [btn setTitle:@"Start" forState:UIControlStateNormal];
            _isRunning = NO;
            _checkCount = 0;
            
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
//             [_netDiagnoService stopNetDialogsis];
        });
    }
    else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startNetDiagnosis];
        });
        
//        [self performSelector:@selector(startNetDiagnosis) withObject:nil afterDelay:2.0f];
      //   [self  startNetDiagnosis];
    }
}


- (void)emailLogInfo
{
    [_netDiagnoService printLogInfo];
}


// 复制到剪切板
- (void)copyToPasteboard{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _txtView_log.text;
}

#pragma mark -
#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end

