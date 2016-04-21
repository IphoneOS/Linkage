//
//  FormDescriptorCell.h
//  Linkage
//
//  Created by lihaijian on 16/3/27.
//  Copyright © 2016年 LA. All rights reserved.
//
#import <XLForm/XLFormDescriptorCell.h>
@protocol FormViewController <NSObject>
@optional
@property (nonatomic,weak,readonly) XLFormDescriptor *form;
@property (nonatomic) UITableView *tableView;
-(void)performFormSelector:(SEL)selector withObject:(id)sender;
@end

@protocol FormDescriptorCell<XLFormDescriptorCell>
@optional
-(void)formDescriptorCellDidSelectedWithViewController:(UIViewController<FormViewController> *)controller;
@end
