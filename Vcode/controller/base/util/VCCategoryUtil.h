//
//  VCCategoryUtil.h
//  Linkage
//
//  Created by lihaijian on 2017/1/3.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "ModelUtil.h"

@interface VCCategoryUtil : ModelUtil

+(void)syncCategory:(void(^)(NSArray *models))completion;
+(void)queryAllCategoryTitles:(void(^)(NSArray *titles))completion;
+(void)queryAllCategories:(void(^)(NSArray *models))completion;
+(void)getModelByIndex:(NSInteger)index completion:(void(^)(id<MTLJSONSerializing> model))completion;
+(void)getModelByTitle:(NSString *)title completion:(void(^)(id<MTLJSONSerializing> model))completion;
+(void)getModelByCode:(NSString *)code completion:(void(^)(id<MTLJSONSerializing> model))completion;
+(void)getVisibleCategories:(void(^)(NSArray *models))completion;
+(void)getFavorCategories:(void(^)(NSArray *models))completion;
+(void)getHiddenCategories:(void(^)(NSArray *models))completion;
+(void)updateCategory:(NSString *)title sort:(NSInteger)sort visible:(BOOL)visible;
@end
