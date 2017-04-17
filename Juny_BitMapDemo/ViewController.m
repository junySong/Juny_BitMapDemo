 //
//  ViewController.m
//  Juny_BitMapDemo
//
//  Created by 宋俊红 on 17/4/7.
//  Copyright © 2017年 Juny_song. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ImageDecoder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(50, 100, 50, 50);
    [self.view addSubview:imageView];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"retrive.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    UIImage *image3 = [UIImage decodedImageWithImage:image];
    NSData *imageData3 = UIImageJPEGRepresentation(image3, 1.0);

    
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image1 = [UIImage imageWithData:imageData];
    
    UIImage *image2 = [UIImage imageNamed:@"retrive.jpg"];
    NSData *imageData2 = UIImageJPEGRepresentation(image2, 1.0);
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIImage *endImage = [UIImage decodedImageWithImage:image];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            imageView.image = endImage;
//        });
//    });
//   
    UIImageView *imageView1 = [[UIImageView alloc]init];
    imageView1.frame = CGRectMake(50, 200, 50, 50);
    [self.view addSubview:imageView1];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
