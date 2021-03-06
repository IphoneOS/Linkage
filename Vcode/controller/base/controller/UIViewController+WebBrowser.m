//
//  UIViewController+WebBrowser.m
//  Linkage
//
//  Created by lihaijian on 2017/1/7.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "UIViewController+WebBrowser.h"
#import "KINWebBrowserViewController.h"
#import "VCWebBrowserViewController.h"

@implementation UIViewController (WebBrowser)

-(void)presentWebBrowser:(NSString *)url
{
    UINavigationController *webBrowserNavigationController = [VCWebBrowserViewController navigationControllerWithWebBrowser];
    [self presentViewController:webBrowserNavigationController animated:YES completion:nil];
    
    KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowser];
    webBrowser.actionButtonHidden = YES;
    webBrowser.showsURLInNavigationBar = NO;
    webBrowser.showsPageTitleInNavigationBar = NO;
    [webBrowser loadURLString:url];
}

@end
