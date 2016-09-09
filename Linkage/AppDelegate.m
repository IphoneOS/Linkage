//
//  AppDelegate.m
//  Linkage
//
//  Created by lihaijian on 16/2/21.
//  Copyright © 2016年 LA. All rights reserved.
//

#import "AppDelegate.h"
#import "TutorialController.h"
#import "LATabBarController.h"
#import "UIColor+BFPaperColors.h"
#import "MobClick.h"
#import "UIImage+ImageWithColor.h"
#import "LoginUser.h"
#import "LoginViewController.h"
#import <IQKeyboardManager/KeyboardManager.h>
#import <XLFormViewController.h>
#import <PgyUpdate/PgyUpdateManager.h>

#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import "UMSocialData.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialYixinHandler.h"

#import "Message.h"
#import "MessageUtil.h"

static NSString *const kStoreName = @"linkage.sqlite";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:kPgyerAppKey];
    [[PgyUpdateManager sharedPgyManager] checkUpdate];
    
    [self setupDataBase];
    [self registerJPushWithOptions:launchOptions];
    
    [self umengTrack];
    [self setupSocialConfig];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *rooViewController;
    if (kNeedShowIntroduce) {
        rooViewController = [TutorialController shareViewController];
    }else{
        if ([LoginUser shareInstance]) {
            rooViewController = [[LATabBarController alloc]init];
        }else{
            rooViewController = [[LoginViewController alloc]init];
        }
    }
    self.window.rootViewController = rooViewController;
    
    [self.window makeKeyAndVisible];
    [self setupGlobalAppearance];
    [[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[XLFormViewController class]];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupGlobalAppearance) name:kTRThemeChangeNofication object:nil];
    
    return YES;
}

/*
 * 初始化数据库
 */
-(void)setupDataBase
{
    NSLog(@"数据库路径-%@", [self applicationDocumentsDirectory]);
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kStoreName];
}

/*
 * 数据库路径
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 * 注册极光推送
 */
-(void)registerJPushWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    //不需要用到advertisingIndentifier
    //NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppKey
                          channel:@"web"
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

//友盟sdk
- (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion];
    [MobClick startWithAppkey:kUmengSocialAppKey reportPolicy:BATCH channelId:@"web"];
    [MobClick updateOnlineConfig];  //在线参数配置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

/**
 *  设置社交App的Key
 */
-(void)setupSocialConfig
{
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:kUmengSocialAppKey];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:kWXAppId appSecret:kWXAppSecret url:kAppIndexHtml];
    
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
    [UMSocialQQHandler setQQWithAppId:kQQAppId appKey:kQQAppkey url:kAppIndexHtml];
    
    //设置易信Appkey和分享url地址,注意需要引用头文件 #import UMSocialYixinHandler.h
    [UMSocialYixinHandler setYixinAppKey:kYixinAppkey url:kAppIndexHtml];
    
    [UMSocialData defaultData].extConfig.wechatSessionData.title = kSocialTitle;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = kSocialTitle;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.title = kSocialTitle;
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    NSDictionary *onlineDic = note.userInfo;
    if (onlineDic && [onlineDic[@"available"] isEqualToString:@"0"]) {
        UIViewController *rooViewController = [[UIViewController alloc]init];
        self.window.rootViewController = rooViewController;
        [self.window makeKeyAndVisible];
    }
}

- (void)setupGlobalAppearance
{
    //设置导航标题属性
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = HeaderColor;
    [UINavigationBar appearance].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:18],NSFontAttributeName, nil];
    [UINavigationBar appearance].translucent = NO;
    UIImage *image = [UIImage imageWithColor:HeaderColor];
    [[UINavigationBar appearance] setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    //设置tabBar属性
    [[UITabBar appearance] setSelectedImageTintColor:HeaderColor];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UMOnlineConfigDidFinishedNotification object:nil];
}

//JPush service
- (void)applicationWillResignActive:(UIApplication *)application {
    //    [APService stopLogPageView:@"aa"];
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];//这句注释掉，依然可收到消息
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
    NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
    NSLog(@"收到通知:%@", [self logDic:userInfo]);
    
    // 取得Extras字段内容
    NSString *customizeField1 = [userInfo valueForKey:@"customizeExtras"]; //服务端中Extras字段，key是自己定义的
    NSLog(@"content =[%@], badge=[%ld], sound=[%@], customize field  =[%@]",content, (long)badge,sound,customizeField1);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];//这句注释掉，依然可收到消息
    NSLog(@"收到通知:%@", [self logDic:userInfo]);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

//获取自定义消息推送内容
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    @try {
        NSDictionary * userInfo = [notification userInfo];
        NSString *content = [userInfo valueForKey:@"content"];
        NSData *tempData = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableContainers error:nil];
        Message *message = (Message *)[MessageUtil modelFromJson:dic];
        [JPUSHService setLocalNotification:[NSDate date] alertBody:message.content badge:0 alertAction:@"打开" identifierKey:message.messageId userInfo:nil soundName:nil];
    }
    @catch (NSException *exception) {
        
    }
}

@end
