//
//  ViewController.m
//  GameKitDemo
//
//  Created by 柳焱 on 16/11/13.
//  Copyright © 2016年 liuyan. All rights reserved.
//

#import "ViewController.h"
#import <Gamekit/GameKit.h>
@interface ViewController ()<GKPeerPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
//会话
@property(nonatomic,strong)GKSession *session;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@end

@implementation ViewController
- (IBAction)bulidContent:(id)sender {
    //创建一个附近设备搜索提示框
    GKPeerPickerController *ppc = [[GKPeerPickerController alloc] init];
    ppc.delegate = self;
    [ppc show];
}
//发送数据
- (IBAction)sendData:(id)sender {
    //第一步先判断要发送的数据是否存在
    if (!self.icon.image) {
        return;
    }
    //发送数据
    
//    [self.session sendData:UIImagePNGRepresentation(self.icon.image)
//                   toPeers:self.session//通常传入已经连接的设备
//              withDataMode:(GKSendDataUnReliable)
//                     error:<#(NSError *__autoreleasing *)#>]
    NSError *error  = nil;
    BOOL sendState = [self.session sendDataToAllPeers:UIImagePNGRepresentation(self.icon.image)
                        withDataMode:(GKSendDataReliable)//可靠的传输方式：慢，不会丢包，知道传完  不可靠的传输方式：快，可能会丢包，传递的信息不一定完整
                               error:&error];
    if (!sendState) {
        NSLog(@"send error = %@",error.localizedDescription);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.icon.backgroundColor = [UIColor cyanColor];
    
    
}
//从相册中选择图片
- (IBAction)chooseImaFromLib:(id)sender {
//    判断是否支持相册选择
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"没有相册");
        return;
    }
    //创建选择图片的控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    //设置图片来源
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //设置代理
    ipc.delegate = self;
    //modal出来
    [self presentViewController:ipc animated:YES completion:nil];
}
//UIImagePickerController代理方法
//选择图片完毕调用的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //让选择的图片显示,info
    self.icon.image = info[UIImagePickerControllerOriginalImage];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type{
    
}

/* Notifies delegate that the connection type is requesting a GKSession object.
 
 You should return a valid GKSession object for use by the picker. If this method is not implemented or returns 'nil', a default GKSession is created on the delegate's behalf.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type{
    
    return 0;
}
//最常用的方法
//已经成功连接到某个设备，并且开启了链接会话
/* Notifies delegate that the peer was connected to a GKSession.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker//搜索框
              didConnectPeer:(NSString *)peerID//连接的设备
                   toSession:(GKSession *)session//链接的会话：通过会话可以进行数据传输
{
    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
    //首先让弹框消失
    [picker dismiss];
    //标记会话
    self.session = session;
    //设置接受数据
    //设置完接受者之后，接受数据会触发
    [self.session setDataReceiveHandler:self withContext:nil];
    
}
-(void)receiveData:(NSData *)data//数据
          fromPeer:(NSString *)peer//来自哪个设备
         inSession:(GKSession *)session//链接会话
           context:(void *)context{
    //将数据直接显示在屏幕上
    self.icon.image = [UIImage imageWithData:data];
    //将数据存入相册
    UIImageWriteToSavedPhotosAlbum(self.icon.image, nil, nil, nil);
    
    
}
#pragma clang diagnostic pop

/* Notifies delegate that the user cancelled the picker.
 */
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    
}


@end
