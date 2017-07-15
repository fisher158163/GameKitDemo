//
//  ViewController.m
//  GameKitDemo
//
//  Created by Liyu on 2017/7/13.
//  Copyright © 2017年 liyu. All rights reserved.
//

#import "ViewController.h"
//导入GameKit
#import <GameKit/GameKit.h>
//导入短信验证SDK
#import <SMS_SDK/SMSSDK.h>
#import "MBProgressHUD.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,GKPeerPickerControllerDelegate>

@property(nonatomic,strong) GKSession *session;

@property (weak, nonatomic) IBOutlet UIImageView *customImageView;

@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
//连接蓝牙
- (IBAction)connect:(UIButton *)sender {
    // 1.创建选择其他蓝牙设备的控制器
    GKPeerPickerController *peerPk = [[GKPeerPickerController alloc] init];
    // 2.成为该控制器的代理
    peerPk.delegate = self;
    // 3.显示蓝牙控制器
    [peerPk show];
}

//选择图片
- (IBAction)selectedPhoto:(UIButton *)sender {
    // 1.创建图片选择控制器
    UIImagePickerController *imagePk = [[UIImagePickerController alloc] init];
    // 2.判断图库是否可用打开
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        // 3.设置打开图库的类型
        imagePk.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePk.delegate = self;
        // 4.打开图片选择控制器
        [self presentViewController:imagePk animated:YES completion:nil];
    }
}

//发送图片
- (IBAction)send:(UIButton *)sender {
    // 利用session发送图片数据即可
    // 1.取出customImageView上得图片, 转换为二进制
    UIImage *image =  self.customImageView.image;
    NSData *data = UIImageJPEGRepresentation(image, 0.4);
    //NSData *data = UIImagePNGRepresentation(image);
    /*
     GKSendDataReliable, 数据安全的发送模式, 慢
     GKSendDataUnreliable, 数据不安全的发送模式, 快
     */
    
    /*
     data: 需要发送的数据
     DataReliable: 是否安全的发送数据(发送数据的模式)
     error: 是否监听发送错误
     */
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

#pragma mark - GKPeerPickerControllerDelegate

/**
 当蓝牙设备连接成功就会调用

 @param picker 触发时的控制器
 @param peerID 连接蓝牙设备的ID
 @param session 连接蓝牙的会话(可用通讯), 以后只要拿到session就可以传输数据
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    NSLog(@"%@", peerID);
    // 1.保存会话
    self.session = session;
    // 2.设置监听接收传递过来的数据
    /*
     Handler: 谁来处理接收到得数据
     withContext: 传递数据
     */
    [self.session setDataReceiveHandler:self withContext:nil];
    
    // 3.关闭显示蓝牙设备控制器
    [picker dismiss];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    // 1.将传递过来的数据转换为图片(注意: 因为发送的时图片, 所以才需要转换为图片)
    UIImage *image = [UIImage imageWithData:data];
    self.customImageView.image = image;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //    NSLog(@"%@", info);
    self.customImageView.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


//获取验证码
- (IBAction)getVerificationCode:(UIButton *)sender {
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.numberTF.text zone:@"86" result:^(NSError *error) {
        if (!error){
            // 请求成功
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSLog(@"请求验证码成功");

        } else {
            NSLog(@"请求验证码失败");
        }
    }];
}

//注册
- (IBAction)userRegister:(UIButton *)sender {
    [SMSSDK commitVerificationCode:self.codeTF.text phoneNumber:self.numberTF.text zone:@"86" result:^(NSError *error) {
        if (!error) {
            // 验证成功
            NSLog(@"验证成功");
        } else {
            // error
            NSLog(@"验证失败");
        }
    }];
}


@end
