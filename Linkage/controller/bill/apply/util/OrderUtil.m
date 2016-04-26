//
//  OrderUtil.m
//  Linkage
//
//  Created by lihaijian on 16/4/23.
//  Copyright © 2016年 LA. All rights reserved.
//

#import "OrderUtil.h"
#import "Order.h"
#import "OrderModel.h"
#import "Cargo.h"
#import "Company.h"
#import "SOImage.h"
#import "LoginUser.h"
#import "MTLManagedObjectAdapter.h"
#import <Mantle/Mantle.h>

@implementation OrderUtil

//同步到服务端
+(void)syncToServer:(Order *)order success:(HTTPSuccessHandler)success failure:(HTTPFailureHandler)failure
{
    NSDictionary *paramter = [self jsonFromModel:order];
    if (paramter) {
        if ([order isKindOfClass:[ImportOrder class]]) {
            [[YGRestClient sharedInstance] postForObjectWithUrl:Place4importUrl form:paramter success:success failure:failure];
        }else if([order isKindOfClass:[ExportOrder class]]){
            [[YGRestClient sharedInstance] postForObjectWithUrl:Place4exportUrl form:paramter success:success failure:failure];
        }else if([order isKindOfClass:[SelfOrder class]]){
            [[YGRestClient sharedInstance] postForObjectWithUrl:Place4selfUrl form:paramter success:success failure:failure];
        }
    }
}

//同步到数据库
+(void)syncToDataBase:(Order *)order completion:(MRSaveCompletionHandler)completion;
{
    NSError *error;
    OrderModel *orderModel = [MTLManagedObjectAdapter managedObjectFromModel:order insertingIntoContext:[NSManagedObjectContext MR_defaultContext] error:&error];
    if (orderModel && !error) {
        [[NSManagedObjectContext MR_defaultContext] MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:completion];
    }else{
        NSLog(@"同步到数据库失败 - %@",error);
    }
}

//json转换成对象
+(Order *)modelFromJson:(NSDictionary *)json
{
    NSError *error;
    Order *order = [MTLJSONAdapter modelOfClass:[Order class] fromJSONDictionary:json error:&error];
    if (!error) {
        if (json[@"cargos"] && [json[@"cargos"] isKindOfClass:[NSArray class]]) {
            NSArray *cargos = [MTLJSONAdapter modelsOfClass:[Cargo class] fromJSONArray:json[@"cargos"] error:&error];
            order.cargos = cargos;
        }
        order.userId = [LoginUser shareInstance].userId;
    }else{
        NSLog(@"JSON转换成对象失败 - %@",error);
    }
    return order;
}

//form转换成对象
+(Order *)modelFromXLFormValue:(NSDictionary *)formValues
{
    NSError *error;
    Order *order = [MTLJSONAdapter modelOfClass:[Order class] fromJSONDictionary:formValues error:&error];
    if (!error) {
        order.cargos = formValues[@"cargos"];
        if (formValues[@"company"] && [formValues[@"company"] isKindOfClass:[Company class]]) {
            order.companyId = ((Company *)formValues[@"company"]).companyId;
        }
        order.userId = [LoginUser shareInstance].userId;
        if ([order isKindOfClass:[ExportOrder class]]) {
            ((ExportOrder *)order).soImages = formValues[@"soImages"];
        }
    }else{
        NSLog(@"表单转换成对象失败 - %@",error);
    }
    return order;
}

//数据库对象转换成普通对象
+(Order *)modelFromManagedObject:(OrderModel *)orderModel
{
    NSError *error;
    Order *order;
    if ([orderModel isKindOfClass:[ImportOrderModel class]]) {
        order = [MTLManagedObjectAdapter modelOfClass:[ImportOrder class] fromManagedObject:orderModel error:&error];
    }else if([orderModel isKindOfClass:[ExportOrderModel class]]) {
        order = [MTLManagedObjectAdapter modelOfClass:[ExportOrder class] fromManagedObject:orderModel error:&error];
    }else if([orderModel isKindOfClass:[SelfOrderModel class]]) {
        order = [MTLManagedObjectAdapter modelOfClass:[SelfOrder class] fromManagedObject:orderModel error:&error];
    }else{
        order = [MTLManagedObjectAdapter modelOfClass:[Order class] fromManagedObject:orderModel error:&error];
    }
    if (error) {
        NSLog(@"数据库对象转换对象失败 - %@",error);
    }
    if (order) {
        order.objStatus = Persistent;
    }
    return order;
}

//转换成json
+(NSDictionary *)jsonFromModel:(Order *)order
{
    NSError *error;
    NSDictionary *dic = [MTLJSONAdapter JSONDictionaryFromModel:order error:&error];
    if (error) {
        NSLog(@"对象转换字典失败 - %@",error);
    }
    if (dic) {
        NSMutableDictionary *mutableDic = [dic mutableCopy];
        mutableDic[@"cid"] = [LoginUser shareInstance].cid;
        mutableDic[@"token"] = [LoginUser shareInstance].token;
        mutableDic[@"company_id"] = order.companyId;
        mutableDic[@"cargo"] = [order.cargos cargosStringValue];
        if ([order isKindOfClass:[ExportOrder class]]) {
            mutableDic[@"so"] = @"so";
            mutableDic[@"so_images"] = [((ExportOrder *)order).soImages soImageStringValue];
        }
        return [mutableDic copy];
    }else{
        return nil;
    }
}

//服务端查询
+(void)queryOrdersFromServer:(void(^)(NSArray *orders))completion
{
    NSDictionary *paramter = @{
                               @"cid":[LoginUser shareInstance].cid,
                               @"token":[LoginUser shareInstance].token,
                               @"type":@(-1),
                               @"status":@(0),
                               @"pagination":@(0),
                               @"offset":@(0),
                               @"size":@(100)
                               };
    [[YGRestClient sharedInstance] postForObjectWithUrl:ListByStatusUrl form:paramter success:^(id responseObject) {
        if (responseObject[@"orders"] && [responseObject[@"orders"] isKindOfClass:[NSArray class]]) {
            NSError *error;
            NSArray *array = [MTLJSONAdapter modelsOfClass:[Order class] fromJSONArray:responseObject[@"orders"] error:&error];
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

//数据库查询
+(void)queryOrdersFromDataBase:(void(^)(NSArray *orders))completion
{
    NSArray *orderModelArray = [OrderModel MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    NSArray *orders = [orderModelArray modelsFromManagedObject];
    if (completion) {
        completion(orders);
    }
}

//查询详情
+(void)queryOrderFromServer:(Order *)order completion:(void(^)(Order *result))completion
{
    NSDictionary *paramter = @{
                               @"cid":[LoginUser shareInstance].cid,
                               @"token":[LoginUser shareInstance].token,
                               @"order_id":order.orderId
                               };
    
    Order *(^mergeOrder)(id responseObject) = ^(id responseObject) {
        Order *result = [OrderUtil modelFromJson:responseObject];
        [result mergeValueForKey:@"orderId" fromModel:order];
        [result mergeValueForKey:@"type" fromModel:order];
        [result mergeValueForKey:@"status" fromModel:order];
        return result;
    };
    if ([order isKindOfClass:[ImportOrder class]]) {
        [[YGRestClient sharedInstance] postForObjectWithUrl:Detail4importUrl form:paramter success:^(id responseObject) {
            Order *result = mergeOrder(responseObject);
            if (completion) {
                completion(result);
            }
        } failure:^(NSError *error) {
            
        }];
    }else if([order isKindOfClass:[ExportOrder class]]){
        [[YGRestClient sharedInstance] postForObjectWithUrl:Detail4exportUrl form:paramter success:^(id responseObject) {
            Order *result = mergeOrder(responseObject);
            if (completion) {
                completion(result);
            }
        } failure:^(NSError *error) {
            
        }];
    }else if([order isKindOfClass:[SelfOrder class]]){
        [[YGRestClient sharedInstance] postForObjectWithUrl:Detail4selfUrl form:paramter success:^(id responseObject) {
            Order *result = mergeOrder(responseObject);
            if (completion) {
                completion(result);
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

@end

@implementation NSArray (OrderModel)
//对象转换
-(NSArray *)modelsFromManagedObject
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithCapacity:self.count];
    for (OrderModel *manageObj in self) {
        Order *order = [OrderUtil modelFromManagedObject:manageObj];
        [mutableArray addObject:order];
    }
    return [mutableArray copy];
}

@end
