//
//  ViewController.m
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/14.
//  Copyright © 2018年 Clarence. All rights reserved.
//

#import "ViewController.h"
#import "ZYLocalAuthIDManager.h"
#import "UIImage+Resource.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testBtn setTitle:@"faceId/touchId" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(testBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    [testBtn setFrame:CGRectMake(100, 100, 100, 100)];
    // Do any additional setup after loading the view, typically from a nib.
    [self testImage];
    
}

- (void)testImage{
    UIImage *image1 = [UIImage imageNamed:@"coupon_1x.png"];
   UIImage *image2 = [UIImage imageNamed:@"coupon_2x.png"];
   UIImage *image3 = [UIImage imageNamed:@"coupon_3x.png"];
    [self saveBundle];
//[UITraitCollection traitCollectionWithDisplayScale:[[UIScreen mainScreen] scale]]
    
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:@"TestBundle" withExtension:@"bundle"];
    NSBundle *customBundle = [NSBundle bundleWithURL:bundleUrl];
      UIImage *oImage = [UIImage imageNamed:@"coupon" inBundle:customBundle compatibleWithTraitCollection:nil];
        //oImage = [UIImage resourceImageNamed:@"coupon"];
        NSLog(@"oimage %@", oImage);
   
    
    [self saveImageDocuments:image1 name:@"coupon"];
    [self saveImageDocuments:image2 name:@"coupon@2x"];
    [self saveImageDocuments:image3 name:@"coupon@3x"];
    
    UIImage *getImage = [self getDocumentImageWithImageName:@"coupon"];
    NSLog(@"getImage %@", getImage);
    
    UIImageView *oImageView = [[UIImageView alloc] initWithImage:oImage];
    UIImageView *gImageView = [[UIImageView alloc] initWithImage:getImage];
    [self.view addSubview:oImageView];
    [self.view addSubview:gImageView];
    
    oImageView.frame = CGRectMake(300, 300, oImage.size.width, oImage.size.height);
    gImageView.frame = CGRectMake(300, 350, getImage.size.width, getImage.size.height);
    
   
    
    
}


- (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    if (!bundle)
        return [UIImage imageNamed:name];
    
    UIImage *image = [UIImage imageNamed:[self imageName:name forBundle:bundle]];
    return image;
}

- (NSString *)imageName:(NSString *)name forBundle:(NSBundle *)bundle
{
    NSString *bundleName = [[bundle bundlePath] lastPathComponent];
    name = [bundleName stringByAppendingPathComponent:name];
    return name;
}

- (void)saveBundle{
    NSString *path_sandox = NSHomeDirectory();
    
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:@"TestBundle" withExtension:@"bundle"];
    //NSBundle *customBundle = [NSBundle bundleWithURL:bundleUrl];
  
    NSString *savePath = [path_sandox stringByAppendingString:@"/Documents/TestBundle"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:savePath isDirectory:nil]) {
        NSData *bundleData = [NSData dataWithContentsOfURL:bundleUrl];
        [bundleData writeToFile:savePath atomically:YES];
    }else{
        //bundle 已存在
    }
    
}

- (NSBundle *)getBundle{
    NSString *path_sandox = NSHomeDirectory();
    NSString *savePath = [path_sandox stringByAppendingString:@"/Documents/TestBundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:savePath];
    return bundle;
}

//保存图片

-(void)saveImageDocuments:(UIImage *)image name:(NSString *)name{
    NSString *path_sandox = NSHomeDirectory();
    NSString *imagePath = [path_sandox stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png", name]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"PATH %@", imagePath);
    if ([fileManager fileExistsAtPath:imagePath isDirectory:nil]) {
        NSLog(@"文件已存在");
        return;
    }
    //拿到图片
    UIImage *imagesave = image;
    //设置一个图片的存储路径
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(imagesave) writeToFile:imagePath atomically:YES];
     NSLog(@"存储图片完毕");
}

// 读取并存贮到相册

-(UIImage *)getDocumentImageWithImageName:(NSString *)imageName{
    // 读取沙盒路径图片
    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(),imageName];
    // 拿到沙盒路径图片
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
    // 图片保存相册
    //UIImageWriteToSavedPhotosAlbum(imgFromUrl3, self, nil, nil);
    return imgFromUrl3;
}

- (void)testBtnAction{
    ZYLocalAuthIDManager *laId = [[ZYLocalAuthIDManager alloc] init];
    [laId zy_showAuthIDWithDescribe:nil localizedFallbackTitle:nil blockState:^(ZYLAErrorState state, NSError *error) {
        switch (state) {
            case ZYLAErrorStateSuccess:
                NSLog(@"验证成功");
                break;
            case ZYLAErrorStateAppCancel:
                NSLog(@"用户取消验证");
                break;
            case ZYLAErrorStateFallBack:
                NSLog(@"用户选择fall back 操作");
                break;
            default:
                NSLog(@"======authError:%@", error);
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
