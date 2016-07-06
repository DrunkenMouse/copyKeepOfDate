//
//  ViewController.m
//  根据日期显示不同的View
//
//  Created by 王奥东 on 16/7/5.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"
#import "ButtonOfWeek.h"

#define W   [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

//保存上个月的月数
@property(nonatomic,assign)NSInteger offNum;

//保存星期几的数组
@property(nonatomic,strong)NSArray *weekArr;

//保存总共有多少个按钮
@property(nonatomic,strong)NSArray <ButtonOfWeek *>*buttonArr;

//保存底部显示页面的ScrollV
@property(nonatomic,strong)UIScrollView *bottomScrollV;

//保存显示今日的按钮
@property(nonatomic,strong)ButtonOfWeek *todayButton;

//保存显示按钮的ScrollView
@property(nonatomic,strong)UIScrollView *topScrollV;

//保存标志当前选择是哪个Button的View
@property(nonatomic,strong)UIView *lineView;

@end

@implementation ViewController


//懒加载形式获取数据周几
-(NSArray *)weekArr{
    if (_weekArr == nil) {
         _weekArr = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    }
    return _weekArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    //为了以后的开发适应范围，顶部scrollView的宽度不为屏幕的宽度
    //只是在偏移scrollView的时候计算多了一点
    
    //按钮的状态包括普通、高亮、选中、禁选（enable与userInteractionEnabled,前者会进入disabled状态后者不会）
    //而页面上的按钮状态则分为一下几种：
    //禁选时修改alpha值改变透明度,并修改字体颜色,或通过enable的disabled状态
    //休息日时字体颜色为黑色，背景颜色为白色
    //非休息日时字体颜色为黑色，背景颜色为灰色并切圆，或直接设置一张圆形图片
    //训练结束时按钮添加一个小图标，小图标可通过选中与否切换图片显示
    //或按钮上加一个imageView\Button来显示图标，然后hidden来决定显示与否
    //如果是代表当前日期的按钮，则修改字体颜色为绿色
    
    
    //以下是程序分析
    //我们既需要知道点击的是第几个按钮
    //还需要知道按钮代表的是几号星期几
    //所以写一个自定义类添加一个属性weekday代表周几
    //与一个属性day代表是几号
    
    
   //获取当前月有多少天
    NSInteger num = [self getNumberOfDaysInMonth];
//    NSLog(@"%ld",num);
    
    //获取当前月都是周几
    NSArray *dayArr = [self getAllDaysWithCalender];
 
    //获取一号的时候是周几
    NSInteger day =  [dayArr[0] integerValue];
    
    //用来保存滚动条上所有的按钮
    NSMutableArray *buttonArr = [NSMutableArray array];
    
#pragma mark - 设置显示上个月的按钮
    //获取所需要的上个月的按钮
    for (int i=0; i<day; i++) {
        //因为从周日开始排，所以周几就代表前面有几天
        //获取上个月的天数减去i值即为所需显示的前几天的日期为几号
        //而且是从周日开始排
        //我还以为要再去计算得到周日那天几号，算到这步才醒悟不用算！
        //按钮的frame会在添加时重新设置，所以此处设为0即可
        //我为了能看到按钮的正确生成而保存着
        //创建所需
        ButtonOfWeek *btn = [[ButtonOfWeek alloc]initWithFrame:CGRectMake(i*50, i*30, 50, 30)];
        //设置背景色为随机色
        btn.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256)/256.0) green:(arc4random_uniform(256)/256.0) blue:(arc4random_uniform(256)/256.0) alpha:1];
        //获取上个月的天数
        NSInteger num = [self getNumberOfDaysInYesterMonth];
        //获取显示的前几天的日期
        NSInteger dayNum = num - i;
//        NSLog(@"%ld",dayNum);
      
        //获取上个月的月数跟计算出的几号拼接成weekday值
        //用来识别按钮代表的是几月几号
        NSString *dayNumOfStr = [NSString stringWithFormat:@"%ld%02ld",self.offNum,dayNum];
        
//        NSLog(@"%@",dayNumOfStr);
//        NSLog(@"%@",dayNumOfStr);
        
        //设置按钮代表第几号,如7月23号的23号
        btn.day = dayNum;
        //设置按钮的weekday值,也就是日期号
        //如:七月一号为701号，七月十三号713号
        btn.weekday = [dayNumOfStr integerValue];
        //将按钮添加到数组
        [buttonArr addObject:btn];
        
    }
    
#pragma mark - 设置显示当前月数的按钮
    //获取当前月的所有按钮
    for (int i = 0; i < num; i++) {

        ButtonOfWeek *btn = [[ButtonOfWeek alloc]initWithFrame:CGRectMake(i%7*50, i/7*30,50, 30)];
        //设置背景颜色随机
        btn.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256)/256.0) green:(arc4random_uniform(256)/256.0) blue:(arc4random_uniform(256)/256.0) alpha:1];

        //设置日期
        NSDate *date = [NSDate date];
        //获取当前的月数
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM"];
        //将获取到的月数转成字符串
        NSString *str = [dateFormatter stringFromDate:date];
     
        //通过月数几号拼接成字符串weekday
        //设置weekday值为701，712这种格式，方便后面判断
        NSString *weekStr = [NSString stringWithFormat:@"%@%02d",str,i+1];
        //注意：转换成integerValue后，0716会变成716
        NSInteger weekday = [weekStr integerValue];
        //设置weekday值
        btn.weekday = weekday;
       
        //设置按钮显示的是几号
        btn.day = i+1;
        
    
//        NSLog(@"%ld",tag);
      //将按钮添加到数组
        [buttonArr addObject:btn];
        
    }
    
#pragma mark - 设置显示下个月的天数
    //获取要显示的下个月的天数
    //当前按钮如果显示到周一，就代表要填充6个按钮为下个月的按钮
    //所以先计算要填充几个按钮
    NSInteger afterNum = 7-buttonArr.count%7;
    //设置要显示的下个月的按钮
    //如果要显示的是七天，就一天也不显示
    if (afterNum != 7) {
        
        for (int i = 0; i<afterNum; i++) {
            ButtonOfWeek *btn = [[ButtonOfWeek alloc]init];
            //设置要显示的日期，如1号，2号
            btn.day = self.buttonArr.count%7+i;
            //背景颜色随机
            btn.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256)/256.0) green:(arc4random_uniform(256)/256.0) blue:(arc4random_uniform(256)/256.0) alpha:1];
            //到此保存了所有的按钮
            [buttonArr addObject:btn];
        }
        
    }
    
#pragma mark - 设置装载显示日期按钮的滚动条
    //设置滚动的ScrollView
    UIScrollView *scrollV  = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 100, 350, 33)];
    //循环遍历保存的按钮，依次取出并设置
    //按钮的设置
    for (int i = 0; i < buttonArr.count; i++) {
        //获取按钮重新设置Frame
        ButtonOfWeek *btn = buttonArr[i];
        
        btn.frame = CGRectMake(i*50, 0, 50, 30);
        
        //按钮上的星期几就是i的值，0为周日，1为周一，依次排列
        //将周几从0、1、2格式转成日、一、二格式
        NSString *weekday = self.weekArr[i%7];
        //设置按钮的显示文字
        //如果按钮代表的日期是今天，就显示几年
        //否则就显示：“日-日期”，如7月6日星期三为：“三-6”，7月3日星期日为：“日-3”
        //先获取今天是几月几号
        NSInteger today = [self getNumberOfToday];
        //根据按钮保存的几月几号与今天日期进行判断
        if (today == btn.weekday) {
            [btn setTitle:[NSString stringWithFormat:@"今日"] forState:UIControlStateNormal];
            //保存代表今日的按钮
            self.todayButton = btn;
        }else{
            [btn setTitle:[NSString stringWithFormat:@"%@-%ld",weekday,btn.day] forState:UIControlStateNormal];
        }
//        NSLog(@"%ld",btn.weekday);
        
        //将按钮添加到ScrollView并延长ScrollV的滚动范围
        [scrollV addSubview:btn];
    
        //用tag保存当前是第几个按钮
        btn.tag = i;
        //添加点击事件
        [btn addTarget:self action:@selector(clickButtoOfDay:) forControlEvents:UIControlEventTouchUpInside];
        //设置偏移量
        scrollV.contentSize = CGSizeMake(scrollV.contentSize.width+btn.frame.size.width, 0);
        
    }
    //开启ScrollV的滚动分页效果
    scrollV.pagingEnabled = YES;
    //保存含有所有按钮的数组
    self.buttonArr = buttonArr;
    //保存显示按钮的ScrollV
    self.topScrollV = scrollV;
    //ScrollV添加到当前View
    [self.view addSubview:scrollV];
    

#pragma mark - 设置红色标志条标志当前选择的按钮
    //设置一个红色标志条用来标志当前选择的是哪个Button
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 31, 50, 2)];
    lineView.backgroundColor = [UIColor redColor];
    self.lineView = lineView;
    [scrollV addSubview:lineView];
    

#pragma mark - 设置显示底部View的ScrollView
    //底部显示页面的scrollView
    UIScrollView *bottomScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 141, W, 300)];
    //设置滚动值
    bottomScrollV.contentSize = CGSizeMake(self.buttonArr.count*W, 0);
    //开启分页效果
    bottomScrollV.pagingEnabled = YES;
    
    //给ScrollView的每一页添加一个显示View
    for (int i = 0;i < self.buttonArr.count; i++) {
        //设置显示View
        UIView *baskV = [[UIView alloc]initWithFrame:CGRectMake(i*W, 0, bottomScrollV.frame.size.width, bottomScrollV.frame.size.height)];
        //设置View的颜色为随机颜色
        baskV.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256)/256.0) green:arc4random_uniform(256)/256.0 blue:arc4random_uniform(256)/256.0 alpha:1];
        
        //通过代表今日的按钮的tag值与i比较，得到当前View代表的是今日界面
        if (i == self.todayButton.tag) {
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 150, 100)];
            label.text = @"这里是今日界面！";
            [baskV addSubview:label];
            
        }else{
            
            //给每个View添加一个按钮为回到今天
            UIButton *backToday = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 44)];
            [backToday setTitle:@"回到今日" forState:UIControlStateNormal];
            //回到今日的按钮点击事件
            [backToday addTarget:self action:@selector(clickBackToday:) forControlEvents:UIControlEventTouchUpInside];
            backToday.backgroundColor = [UIColor greenColor];
            //若需要可以设置透明度
            //backToday.alpha = 0.3;
            [baskV addSubview:backToday];
        }
        
        //将View添加到ScrollV上
        [bottomScrollV addSubview:baskV];
        
        
    }
    
    //保存底部ScrollView以便随时使用
    self.bottomScrollV = bottomScrollV;
    
    //添加底部ScrollView
    [self.view addSubview:bottomScrollV];
    
    
    //用于测试上个月的获取是否成功
//    NSInteger yesterNumOfMouth = [self getNumberOfDaysInYesterMonth];
//    NSLog(@"%ld",yesterNumOfMouth);
}

#pragma mark - 点击返回今日的按钮
-(void)clickBackToday:(UIButton *)sender{

    //滚动上面的ScrollView
    //滚动范围X为一页的宽度 * 滚动的页数
    [self.topScrollV setContentOffset:CGPointMake(self.todayButton.tag/7*(7*self.todayButton.frame.size.width), 0) animated:YES];
    //滚动下面的ScrollView
    [self clickButtoOfDay:self.todayButton];
    
}

#pragma mark - 获取当月的天数
- (NSInteger)getNumberOfDaysInMonth
{
    //获取算法为公历的日历
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //给定当前日期
    NSDate * currentDate = [NSDate date];
    //计算当前月有多少天
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit: NSCalendarUnitMonth
                                  forDate:currentDate];
    
    
    return range.length;
}

#pragma mark - 显示日期的按钮的点击事件
//因为偏移量无论如何都要计算
//所以我选择ScrollView方式，不过也可以用CollectionView来写
-(void)clickButtoOfDay:(ButtonOfWeek *)sender{
    
    //改变标志View的frame
    CGSize lineSize = self.lineView.frame.size;
    
    self.lineView.frame = CGRectMake(sender.tag*sender.frame.size.width, self.lineView.frame.origin.y, lineSize.width, lineSize.height);
    
    //滚动底部的ScrollView
    [self.bottomScrollV setContentOffset:CGPointMake(sender.tag*W, 0) animated:YES];
    
}
#pragma mark - 获取今天是几月几号
-(NSInteger)getNumberOfToday{
    
    //MMdd 月日
    NSDate * todayDate = [NSDate date];
    NSDateFormatter *dateForMatter = [[NSDateFormatter alloc]init];
    [dateForMatter setDateFormat:@"MMdd"];
    NSString *todayStr = [dateForMatter stringFromDate:todayDate];
//    NSLog(@"today:%ld",[todayStr integerValue]);
    return [todayStr integerValue];
}

#pragma mark - 获取上个月的天数
-(NSInteger)getNumberOfDaysInYesterMonth{
    
    //先获取算法为公历的日历
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //获取当前日期
    NSDate * mydate = [NSDate date];
    //设置关于日期的算法为上个月
    NSDateComponents *adcomps = [[NSDateComponents alloc]init];
    [adcomps setMonth:-1];
    //设置日期格式为MM 月
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM"];
    //通过指定算法获取上个月，并转换格式
    NSDate *yesterMonDate = [calendar dateByAddingComponents:adcomps toDate:mydate options:0 ];

    NSString *beforeDate = [dateFormatter stringFromDate:yesterMonDate];
//    NSLog(@"%@",beforeDate);
    //保存上个月的月份数
   self.offNum = [beforeDate integerValue];
    
    //获取上个月有多少天
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:yesterMonDate];
    return range.length;
}


#pragma mark - 获取当前月中所有天数是周几
- (NSArray *) getAllDaysWithCalender
{
    //通过自定义方法获取当前月中有多少天
    NSUInteger dayCount = [self getNumberOfDaysInMonth];
    
    //指定日期的显示格式
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSDate * currentDate = [NSDate date];
    
    [formatter setDateFormat:@"yyyy-MM"];
    
    //获取 年 - 月
    NSString * str = [formatter stringFromDate:currentDate];
//    NSLog(@"%@",str);
    //在设置显示格式为年 - 月 - 日
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //保存周几的数组
    NSMutableArray * allDaysArray = [[NSMutableArray alloc] init];
    //当前月有多少天就循环多少次
    for (NSInteger i = 1; i <= dayCount; i++) {
        //获取时间格式如： 年 - 月 - 1 、 年 - 月 - 2
        NSString * sr = [NSString stringWithFormat:@"%@-%ld",str,i];
        NSDate *suDate = [formatter dateFromString:sr];
        //通过时间自定义方法获取第几日为星期几
        [allDaysArray addObject:[self getweekDayWithDate:suDate]];
    }
//    NSLog(@"allDaysArray %@",allDaysArray);
    return allDaysArray;
}




#pragma mark - 获取指定的日期是星期几
- (id) getweekDayWithDate:(NSDate *) date
{
    //指定日历的算法为公历
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    //获取指定日期为周几
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    // 若不减一 则 1 是周日，2是周一 3是周二 以此类推
    // 而减一后 则 0为周日，1为周一，2为周二 以此类推
    return @([comps weekday]-1);
    
}

@end
