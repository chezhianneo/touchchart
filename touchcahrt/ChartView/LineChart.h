//
//  LineChart.h
//  WalmartPOC
//
//  Created by Chezhian on 8/2/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>


typedef enum
{
    KLineCombinedChartView =0,
    KLineScalableView,
    KstaticCombinedAxisView,
    KLineChartView,
    KLineAxisView,
    KLineScalableXaxisView,
    KLineXaxisView,
    KLineStaticXaxisView
}LineChartTypeView;

@protocol LineChartDelegate <NSObject>

- (void)getTheEventBarChart:(NSString *)string;

@end
@interface LineChart : UIView
{
    float maxScaleValue,maxValue,minValue;
    int maxScaleHeight;
    int chartColumnWidth;
    UIButton *bt;
    NSMutableArray *buttonArray;
    
    
}
@property (assign) NSInteger hInterval;
@property (assign) NSInteger vInterval;
@property (nonatomic, assign) id<LineChartDelegate> delegate;

@property (nonatomic, strong) NSArray *xAxisLabel;
@property (nonatomic, strong) NSArray *vDesc;
@property (nonatomic,assign) LineChartTypeView lineChartTypeView;
@property (nonatomic, strong) NSArray *array;
@property(assign) int chartType,lineAxis;
@property(nonatomic,retain)NSString *imageString1,*imageString2;
@property(nonatomic,retain)UIColor *color1,*color2;
@property(nonatomic,assign)BOOL secondLinechart,zoomView;
@property(assign) float columnWidth,columnScaleFactor,marginScaleBetween,xAxisWidth;
@end

