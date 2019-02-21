//
//  NSDate+Extension.h
//  wallet
//
//  Created by 刘威 on 2017/8/21.
//  Copyright © 2017年 刘威. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECOND	(1)
#define MINUTE	(60 * SECOND)
#define HOUR	(60 * MINUTE)
#define DAY		(24 * HOUR)
#define MONTH	(30 * DAY)
#define YEAR	(12 * MONTH)
#define DATE_FORMAT_STR_DAY_AND_SEC @"yyyy-MM-dd HH:mm:ss"
#define DATE_FORMAT_STR_DAY_AND_MIN @"yyyy-MM-dd HH:mm"
#define DATE_FORMAT_STR_DAY_AND_MIN_WITHOUT_YEAR @"MM-dd HH:mm"
#define CN_DATE_FORMAT_STR_DAY_AND_MIN @"yyyy年MM月dd日 HH时mm分"
#define DATE_FORMAT_STR_DAY @"yyyy-MM-dd"
#define DATE_FORMAT_STR_POINT_DAY @"yyyy.MM.dd"
#define DATE_FORMAT_STR_POINT_SEC @"yyyy.MM.dd HH:mm"
#define CN_DATE_FORMAT_STR_POINT_DAY @"yyyy年MM月dd日"
#define DATE_FORMAT_STR_MON_POINT_DAY @"MM.dd"
#define CN_DATE_FORMAT_STR_MON_POINT_DAY @"MM月dd日"
#define DATE_FORMAT_STR_TIME @"HH:mm"
#define NC_DATE_FORMAT_STR_TIME @"HH时mm分"
#define DATE_FORMAT_STR_DAY_AND_SEC_ZH @"MM月dd日 HH:mm"
#define DATE_SLASH_TIME @"yyyy/MM/dd"


@interface NSDate (Extension)

@property (nonatomic, readonly) NSInteger	year;
@property (nonatomic, readonly) NSInteger	month;
@property (nonatomic, readonly) NSInteger	day;
@property (nonatomic, readonly) NSInteger	hour;
@property (nonatomic, readonly) NSInteger	minute;
@property (nonatomic, readonly) NSInteger	second;
@property (nonatomic, readonly) NSInteger	weekday;

- (NSString *)timeAgo;
- (NSString *)timeLeft;

+ (long long)timeStamp;
+ (NSDate *)now;

- (NSString *)timeFormatting;

/**
 *  根据格式返回日期字符串
 *
 *  @param format 日期格式
 *
 *  @return 转化后的日期字符串
 */
- (NSString *)stringWithDateFormat:(NSString *)format;

/**
 *  根据时间和格式字符串转化为NSDate
 *
 *  @param date   时间字符串
 *  @param format 格式
 *
 *  @return 转化后的NSDate
 */
+ (NSDate *)dateFromString:(NSString *)date format:(NSString*) format;

/**
 *  根据NSDate按照格式转化为字符串
 *
 *  @param date   需转化的date
 *  @param format 格式
 *
 *  @return 转化后的字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString*) format;

@end
