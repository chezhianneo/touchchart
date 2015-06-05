//
//  BarChartView.h
//  Copyright (c) chezhian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    KBarChartView =0,
    KcolumnScalableView,
    KstaticAxisView
}BarChartTypeView;

@protocol BarChartDelegate <NSObject>

- (void)getTheEventBarChart:(NSString *)string;

@end
@interface BarChartView : UIView
{
	NSArray *chartTitle;
	NSArray *groupData;
    NSArray *groupTitle;
    NSArray *lineChartVaxis;
    NSArray *xAxisLabel;
    UILabel *labelTitle;
    UILabel *lblLegendTitle;
    int chartColumnWidth;
    int columnScaleFactor;
    NSMutableArray *arrayPoint;

	
	float maxValue,minValue,columnWidth,maxScaleValue,maxScaleHeight,sideWidth;
	CGPoint beginPoint,firstPoint;
    BOOL touched,dropped,dropable;
}

@property (nonatomic, assign) id<BarChartDelegate> delegate;
@property(retain, nonatomic) NSArray  *chartTitle;
@property(retain, nonatomic) NSArray  *groupData;
@property(retain, nonatomic) NSArray  *groupTitle;
@property(retain, nonatomic) NSArray  *xAxisLabel;
@property(assign) int chartType,columnScaleFactor,lineAxis,marginScaleBetween;
@property(assign) BOOL lastYear,firstColumn,secondColumn,zoomView;
@property(assign) float columnWidth,xAxisWidth;
@property(nonatomic,assign) BarChartTypeView chartTypeView;
@property(retain,nonatomic) NSString *columnView;
@property(assign) BOOL draggable;
@property(retain, nonatomic) NSNumber *columnValue;
@property(retain, nonatomic) UILabel *labelTitle;
@property(retain, nonatomic) UILabel *lblLegendTitle;
@property(retain,nonatomic)  NSArray *lineChartVaxis;
//@property(nonatomic)  CGFloat colorsblue1[8];
//@property(nonatomic)  CGFloat colorsOrange1[8];
@property(nonatomic,retain) UIColor *sideCol1;
@property(nonatomic,retain) UIColor *topCol1;
@property(nonatomic,retain) UIColor *sideCol2;
@property(nonatomic,retain) UIColor *topCol2;

@end
