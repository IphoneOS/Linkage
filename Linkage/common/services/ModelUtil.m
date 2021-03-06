//
//  ModelUtil.m
//  Linkage
//
//  Created by lihaijian on 16/4/30.
//  Copyright © 2016年 LA. All rights reserved.
//

#import "ModelUtil.h"
#import "MTLManagedObjectAdapter.h"
#import "LoginUser.h"

@implementation ModelUtil
+(Class)modelClass{ MustOverride(); }
+(Class)managedObjectClass{ MustOverride(); }

+(id<MTLJSONSerializing>)modelFromJson:(NSDictionary *)json
{
    NSError *error;
    if ([LoginUser shareInstance]) {
        json = [json mtl_dictionaryByAddingEntriesFromDictionary:@{@"userId":[LoginUser shareInstance].cid}];
    }
    id model = [MTLJSONAdapter modelOfClass:self.modelClass fromJSONDictionary:json error:&error];
    if (error) {
        NSLog(@"Json转成对象失败 - %@",error);
    }
    return model;
}

+(id<MTLJSONSerializing>)modelFromXLFormValue:(NSDictionary *)formValues
{
    NSError *error;
    NSDictionary *json = [formValues mtl_dictionaryByAddingEntriesFromDictionary:@{@"userId":[LoginUser shareInstance].cid}];
    id model = [MTLJSONAdapter modelOfClass:self.modelClass fromJSONDictionary:json error:&error];
    if (error) {
        NSLog(@"Form转对象失败 - %@",error);
    }
    return model;
}

+(id<MTLJSONSerializing>)modelFromManagedObject:(NSManagedObject *)managedObject
{
    NSError *error;
    id model = [MTLManagedObjectAdapter modelOfClass:self.modelClass fromManagedObject:managedObject error:&error];
    if (error) {
        NSLog(@"Manager转换对象失败 - %@",error);
    }
    return model;
}

+(NSDictionary *)jsonFromModel:(id<MTLJSONSerializing>)model
{
    NSError *error;
    NSDictionary *dic = [MTLJSONAdapter JSONDictionaryFromModel:model error:&error];
    if ([LoginUser shareInstance]) {
        dic = [dic mtl_dictionaryByAddingEntriesFromDictionary:@{@"userId":[LoginUser shareInstance].cid}];
    }
    if (error) {
        NSLog(@"对象转换字典失败 - %@",error);
    }
    return dic;
}

//数据库查询
+(void)queryModelsFromDataBase:(void(^)(NSArray *models))completion
{
    NSArray *managerObjects = [self.managedObjectClass MR_findByAttribute:@"userId" withValue:[LoginUser shareInstance].cid inContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithCapacity:managerObjects.count];
    for (NSManagedObject *manageObj in managerObjects) {
        id<MTLJSONSerializing> model = [self modelFromManagedObject:manageObj];
        [mutableArray addObject:model];
    }
    if (completion) {
        completion([mutableArray copy]);
    }
}

+ (void)truncateAll
{
    @try {
        [self.managedObjectClass MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    }
    @catch (NSException *exception) {
        NSLog(@"error - %@", exception.reason);
    }
}

@end
