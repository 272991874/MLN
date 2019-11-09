//
//  MLNGalleryMainViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/5.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMainViewController.h"
#import <SDWebImageDownloader.h>
#import "MLNGalleryHomeViewController.h"
#import "MLNGalleryDiscoverViewController.h"
#import "MLNGalleryPlusViewController.h"
#import "MLNGalleryMessageViewController.h"
#import "MLNGalleryMineViewController.h"
#import "UIImage+MLNResize.h"
#import <UIView+Toast.h>

@interface MLNGalleryMainViewController ()<UITabBarControllerDelegate>

@end

@implementation MLNGalleryMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupTabbarItems];
}

- (void)setupTabbarItems
{
    UIViewController *homeNavi = [self createControllerWithClass:@"MLNGalleryHomeViewController" normalImage:self.normalImage[0] selectedImage:self.selectedImage[0]];
    [self addChildViewController:homeNavi];
    
    UIViewController *discoverNav = [self createControllerWithClass:@"MLNGalleryDiscoverViewController" normalImage:self.normalImage[1] selectedImage:self.selectedImage[1]];
    [self addChildViewController:discoverNav];

    UIViewController *plusNavi = [self createControllerWithClass:@"MLNGalleryPlusViewController" normalImage:self.normalImage[2] selectedImage:self.selectedImage[2]];
    [self addChildViewController:plusNavi];

    UIViewController *messageNavi = [self createControllerWithClass:@"MLNGalleryMessageViewController" normalImage:self.normalImage[3] selectedImage:self.selectedImage[3]];
    [self addChildViewController:messageNavi];

    UIViewController *mineNavi = [self createControllerWithClass:@"MLNGalleryMineViewController" normalImage:self.normalImage[4] selectedImage:self.selectedImage[4]];
    [self addChildViewController:mineNavi];
}

- (UIViewController *)createControllerWithClass:(NSString *)clazzString normalImage:(NSString *)normalImageString selectedImage:(NSString *)selectedImageString
{
    UIViewController *controller = [NSClassFromString(clazzString) new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navigationController setNavigationBarHidden:YES];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:normalImageString] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
        navigationController.tabBarItem.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:selectedImageString] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
        navigationController.tabBarItem.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    return navigationController;
}

#pragma mark -
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[MLNGalleryPlusViewController class]]) {
        [self.view makeToast:@"打开照相机📷" duration:1.0 position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}

#pragma mark -
- (NSArray *)normalImage {
    return @[@"https://s.momocdn.com/w/u/others/2019/08/27/1566877829621-hom.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829567-disc.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829827-plus.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829551-msg.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877767583-min.png"];
}

- (NSArray *)selectedImage {
    return @[@"https://s.momocdn.com/w/u/others/2019/08/27/1566877829589-hom_d.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829612-disc_d.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829827-plus.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829774-msg_d.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877767564-min_d.png"];
}




@end
