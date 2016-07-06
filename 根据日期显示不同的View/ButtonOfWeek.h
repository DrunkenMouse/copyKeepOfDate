//
//  ButtonOfWeek.h
//  根据日期显示不同的View
//
//  Created by 王奥东 on 16/7/6.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonOfWeek : UIButton

//代表按钮是几月几号
@property(nonatomic,assign)NSInteger weekday;
//代表按钮是几号
@property(nonatomic,assign)NSInteger day;

@end
