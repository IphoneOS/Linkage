//
//  MainTableViewCell.m
//  Linkage
//
//  Created by lihaijian on 16/3/6.
//  Copyright © 2016年 LA. All rights reserved.
//

#import "MainTableViewCell.h"
#import "BillTypeViewController.h"
#import "Favorite.h"
#import "Company.h"
#import "CompanyInfoViewController.h"
#import "LoginUser.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const CompanyDescriporType = @"CompanyRowType";//厂商样式
NSString *const CompanyInfoDescriporType = @"CompanyInfoRowType";//承运商样式

@implementation MainTableViewCell
@synthesize iconView = _iconView;
@synthesize titleLabel = _titleLabel;

-(void)configure
{
    [super configure];
    [self setupUI];
}

-(void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - 属性
-(UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [UIImageView new];
    }
    return _iconView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = IndexTitleFontColor;
        _titleLabel.font = IndexTitleFont;
    }
    return _titleLabel;
}

@end

@implementation CompanyTableCell
@synthesize subTitleLabel = _subTitleLabel;
@synthesize ratingView = _ratingView;
@synthesize button = _button;

+(void)load
{
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[self class] forKey:CompanyDescriporType];
}

-(void)update
{
    [super update];
    Favorite *favorite = self.rowDescriptor.value;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:favorite.logo] placeholderImage:[UIImage imageNamed:@"building_pic"]];
    self.titleLabel.text = favorite.companyName;
    self.subTitleLabel.text  = [NSString stringWithFormat:@"已接%d单", [favorite.orderNum intValue]];
    self.ratingView.value = MIN(MAX([favorite.score intValue], 0),5);
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 84.0;
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    CompanyInfoViewController *infoController = [[CompanyInfoViewController alloc]init];
    infoController.rowDescriptor = self.rowDescriptor;
    infoController.hidesBottomBarWhenPushed = YES;
    [controller.navigationController pushViewController:infoController animated:YES];
}

-(void)clickAction:(id)sender
{
    UIViewController *controller = [[BillTypeViewController alloc] initWithCompany:self.rowDescriptor.value];
    controller.hidesBottomBarWhenPushed = YES;
    [self.formViewController.navigationController pushViewController:controller animated:YES];
}

-(void)setupUI
{
    [super setupUI];
    [self.contentView addSubview:self.iconView];
    [self.iconView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).offset(12);
        make.centerY.equalTo(self.contentView.centerY);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.right).offset(12);
        make.top.equalTo(self.contentView.top).offset(10);
    }];
    
    [self.contentView addSubview:self.ratingView];
    [self.ratingView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.right).offset(12);
        make.centerY.equalTo(self.contentView.centerY);
    }];
    
    [self.contentView addSubview:self.subTitleLabel];
    [self.subTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.right).offset(12);
        make.bottom.equalTo(self.contentView.bottom).offset(-10);
    }];
    
    //只有通过后台审核才能下单
    if ([LoginUser shareInstance].status == UserStatusActive) {
        [self.contentView addSubview:self.button];
        [self.button makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.right).offset(-12);
            make.centerY.equalTo(self.contentView.centerY);
            make.height.equalTo(@30);
            make.width.equalTo(@88);
        }];
    }
}

#pragma mark - 属性

-(UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.font = IndexDetailFont;
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
        _subTitleLabel.textColor = IndexDetailFontColor;
    }
    return _subTitleLabel;
}

-(AXRatingView *)ratingView
{
    if (!_ratingView) {
        _ratingView = [[AXRatingView alloc]initWithFrame:CGRectZero];
        _ratingView.markImage = [UIImage imageNamed:@"star_off_score"];
        _ratingView.baseColor = [UIColor lightGrayColor];
        _ratingView.enabled = NO;
        _ratingView.value = 0;
    }
    return _ratingView;
}

-(UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"下  单" forState:UIControlStateNormal];
        [_button setTitleColor:IndexButtonColor forState:UIControlStateNormal];
        [_button setBackgroundImage:ButtonFrameImage forState:UIControlStateNormal];
        [_button setBackgroundImage:ButtonFrameImage forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
@end

@implementation CompanyInfoTableCell

+(void)load
{
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[self class] forKey:CompanyInfoDescriporType];
}

-(void)update
{
    [super update];
    Favorite *favorite = self.rowDescriptor.value;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:favorite.logo] placeholderImage:[UIImage imageNamed:@"building_pic"]];
    self.titleLabel.text = favorite.companyName;
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 84.0;
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    CompanyInfoViewController *infoController = [[CompanyInfoViewController alloc]init];
    infoController.rowDescriptor = self.rowDescriptor;
    infoController.hidesBottomBarWhenPushed = YES;
    [controller.navigationController pushViewController:infoController animated:YES];
}


-(void)setupUI
{
    [super setupUI];
    [self.contentView addSubview:self.iconView];
    [self.iconView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).offset(12);
        make.centerY.equalTo(self.contentView.centerY);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.right).offset(12);
        make.centerY.equalTo(self.contentView.centerY);
    }];
}

@end
