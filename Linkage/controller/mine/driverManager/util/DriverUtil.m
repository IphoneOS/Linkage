//
//  DriverUtil.m
//  Linkage
//
//  Created by Mac mini on 16/4/27.
//  Copyright © 2016年 LA. All rights reserved.
//

#import "DriverUtil.h"
#import "Driver.h"
#import "DriverModel.h"
#import "LoginUser.h"
#import <Mantle/Mantle.h>

@implementation DriverUtil

+(void)syncToServer:(id<MTLJSONSerializing>)model success:(HTTPSuccessHandler)success failure:(HTTPFailureHandler)failure
{
    NSDictionary *paramter = [self jsonFromModel:model];
    if (paramter) {
        [[YGRestClient sharedInstance] postForObjectWithUrl:AddDriverUrl form:paramter success:success failure:failure];
    }
}

+(void)syncToDataBase:(id<MTLJSONSerializing>)model completion:(void(^)())completion
{
    NSError *error;
    Driver *driver = (Driver *)model;
    if (driver.driverId) {
        DriverModel *existModel = [DriverModel MR_findFirstByAttribute:@"driverId" withValue:driver.driverId inContext:[NSManagedObjectContext MR_defaultContext]];
        if (existModel) {
            [existModel MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        }
        driver.userId = [LoginUser shareInstance].userId;
        DriverModel *driverModel = [MTLManagedObjectAdapter managedObjectFromModel:driver insertingIntoContext:[NSManagedObjectContext MR_defaultContext] error:&error];
        if (driverModel && !error) {
            if (completion) {
                completion();
            }
        }else{
            NSLog(@"同步到数据库失败 - %@",error);
        }
    }
}

+(void)deleteFromServer:(id<MTLJSONSerializing,ModelHttpParameter>)model success:(HTTPSuccessHandler)success failure:(HTTPFailureHandler)failure
{
    if (model.httpParameterForDetail) {
        [[YGRestClient sharedInstance] postForObjectWithUrl:DelDriverUrl form:model.httpParameterForDetail success:success failure:failure];
    }
}

+(id<MTLJSONSerializing>)modelFromJson:(NSDictionary *)json
{
    NSError *error;
    Driver *driver = [MTLJSONAdapter modelOfClass:[Driver class] fromJSONDictionary:json error:&error];
    return driver;
}

+(id<MTLJSONSerializing>)modelFromXLFormValue:(NSDictionary *)formValues
{
    NSError *error;
    Driver *driver = [MTLJSONAdapter modelOfClass:[Driver class] fromJSONDictionary:formValues error:&error];
    return driver;
}

+(id<MTLJSONSerializing>)modelFromManagedObject:(NSManagedObject *)managedObject
{
    NSError *error;
    Driver *driver = [MTLManagedObjectAdapter modelOfClass:[Driver class] fromManagedObject:managedObject error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return driver;
}

+(NSDictionary *)jsonFromModel:(id<MTLJSONSerializing>)model
{
    NSError *error;
    NSDictionary *dic = [MTLJSONAdapter JSONDictionaryFromModel:model error:&error];
    if (error) {
        NSLog(@"对象转换字典失败 - %@",error);
    }
    return dic;
}

//数据库查询
+(void)queryModelsFromDataBase:(void(^)(NSArray *models))completion
{
    NSArray *managerObjects = [DriverModel MR_findByAttribute:@"userId" withValue:[LoginUser shareInstance].userId inContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithCapacity:managerObjects.count];
    for (NSManagedObject *manageObj in managerObjects) {
        id<MTLJSONSerializing> model = [self modelFromManagedObject:manageObj];
        [mutableArray addObject:model];
    }
    if (completion) {
        completion([mutableArray copy]);
    }
}

+(void)queryModelsFromServerWithModel:(id<ModelHttpParameter>)parameter completion:(void(^)(NSArray *models))completion
{
    [[YGRestClient sharedInstance] postForObjectWithUrl:DriversUrl form:[parameter baseHttpParameter] success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSError *error;
            NSArray *array = [MTLJSONAdapter modelsOfClass:[Driver class] fromJSONArray:responseObject error:&error];
            if (completion) {
                completion(array);
            }
        }else{
            completion(nil);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

+(void)queryModelFromServer:(id<MTLJSONSerializing, ModelHttpParameter>)parameter completion:(void(^)(id<MTLJSONSerializing> result))completion
{
    if (parameter.httpParameterForDetail) {
        Driver *(^mergeOrder)(id responseObject) = ^(id responseObject) {
            Driver *result = (Driver *)[DriverUtil modelFromJson:responseObject];
            [result mergeValueForKey:@"driverId" fromModel:parameter];
            return result;
        };
        
        [[YGRestClient sharedInstance] postForObjectWithUrl:DriverDetailUrl form:parameter.httpParameterForDetail success:^(id responseObject) {
            Driver *result = mergeOrder(responseObject);
            if (completion) {
                completion(result);
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

@end