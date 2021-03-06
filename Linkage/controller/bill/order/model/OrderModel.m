//
//  OrderModel.m
//  Linkage
//
//  Created by Mac mini on 16/4/22.
//  Copyright © 2016年 LA. All rights reserved.
//

#import "OrderModel.h"

@implementation CargoModel
@dynamic cargoCount;
@dynamic cargoId;
@dynamic cargoType;
@dynamic cargoNo;
@dynamic cargoName;
@end

@implementation SOImageModel
@dynamic imageName;
@dynamic imageUrl;
@dynamic createDate;
@end

@implementation CommentModel
@dynamic comment;
@dynamic commentId;
@dynamic score;
@end

@implementation OrderModel
@dynamic orderId;
@dynamic companyId;
@dynamic userId;
@dynamic type;
@dynamic transporterId;
@dynamic manufactureId;
@dynamic manufactureContactName;
@dynamic manufactureContactTel;
@dynamic transporterContactName;
@dynamic transporterContractTel;
@dynamic takeAddress;
@dynamic takeTime;
@dynamic deliveryAddress;
@dynamic deliverTime;
@dynamic cargosRentExpire;
@dynamic memo;
@dynamic createTime;
@dynamic updateTime;
@dynamic status;
@dynamic cargos;
@dynamic isTransferPort;
@dynamic comment;
@end

@implementation ImportOrderModel
@dynamic billNo;
@dynamic cargoNo;
@dynamic customsHouseContact;
@dynamic customsBroker;
@dynamic cargoCompany;
@end

@implementation ExportOrderModel
@dynamic so;
@dynamic customsIn;
@dynamic shipCompany;
@dynamic shipName;
@dynamic shipScheduleNo;
@dynamic isBookCargo;
@dynamic port;
@dynamic soImages;
@end

@implementation SelfOrderModel
@dynamic isCustomsDeclare;
@dynamic customsIn;
@dynamic cargoTakeTime;
@end
