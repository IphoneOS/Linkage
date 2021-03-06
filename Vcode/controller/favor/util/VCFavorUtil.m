//
//  VCFavorUtil.m
//  Linkage
//
//  Created by lihaijian on 2017/1/7.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "VCFavorUtil.h"
#import "VCFavor.h"
#import "VCFavorModel.h"

@implementation VCFavorUtil
+(Class)modelClass{ return [VCFavor class]; }
+(Class)managedObjectClass{ return [VCFavorModel class];}

+(void)syncToDataBase:(id<MTLJSONSerializing>)model completion:(void(^)())completion
{
    NSError *error;
    VCFavor *favor = (VCFavor *)model;
    if (favor.title) {
        VCFavorModel *existModel = [self.managedObjectClass MR_findFirstByAttribute:@"title" withValue:favor.title inContext:[NSManagedObjectContext MR_defaultContext]];
        if (existModel) {
            [existModel MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        }
        VCFavorModel *addModel = [MTLManagedObjectAdapter managedObjectFromModel:favor insertingIntoContext:[NSManagedObjectContext MR_defaultContext] error:&error];
        if (addModel && !error) {
            if (completion) {
                completion();
            }
        }else{
            NSLog(@"同步到数据库失败 - %@",error);
        }
    }
}

//数据库查询
+(void)queryModelsFromDataBase:(void(^)(NSArray *models))completion
{
    NSArray *managerObjects = [VCFavorModel MR_findAllSortedBy:@"createdDate" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithCapacity:managerObjects.count];
    for (NSManagedObject *manageObj in managerObjects) {
        id<MTLJSONSerializing> model = [self modelFromManagedObject:manageObj];
        [mutableArray addObject:model];
    }
    if (completion) {
        completion([mutableArray copy]);
    }
}

+(void)getModelByUrl:(NSString *)url completion:(void(^)(id<MTLJSONSerializing> model))completion
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"url", url];
    [self queryModelFromDataBase:predicate completion:completion];
}

+(void)queryModelFromDataBase:(NSPredicate *)predicate completion:(void(^)(id<MTLJSONSerializing> model))completion
{
    VCFavorModel *manageObj = [VCFavorModel MR_findFirstWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    id<MTLJSONSerializing> result = [self modelFromManagedObject:manageObj];
    completion(result);
}

+(void)deleteFromDataBase:(id<MTLJSONSerializing>)model completion:(void(^)())completion
{
    VCFavor *favor = (VCFavor *)model;
    if (favor.url) {
        VCFavorModel *existModel = [VCFavorModel MR_findFirstByAttribute:@"url" withValue:favor.url inContext:[NSManagedObjectContext MR_defaultContext]];
        if (existModel) {
            [existModel MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        }
        if (completion) {
            completion();
        }
    }
}

@end
