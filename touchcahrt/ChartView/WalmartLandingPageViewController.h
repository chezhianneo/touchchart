//
//  WalmartLandingPageViewController.h
//  Walmart
//
//  Created by Rizwan on 8/23/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverView.h"
#import "StatePopOverView.h"
#import "TBMChartView.h"
#import "TBMSlice.h"
#import <QuartzCore/QuartzCore.h>
#import <QuickLook/QuickLook.h>
#import "BarChartView.h"
#import "LineChart.h"
#import "OBShapedButton.h"
#import "BusinessUnitViewController.h"
#import "WalmartFooterView.h"
#import "WalmartSelectionHeader.h"
#import "SettingsViewController.h"
#import "DisplayImageViewController.h"
#import "SelectionHeaderSingleton.h"
#import "SamsClubBUViewController.h"
#import "ScriblingView.h"


@interface WalmartLandingPageViewController : UIViewController<PopoverViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,BarChartDelegate,PieChartDelegate,LineChartDelegate>{
    //for popover
    PopoverView *pv;
    CGPoint point;
    UIButton *button;
    EGODatabase* database;
    BarChartView *barchartView;
    NSArray *dataArray1;
    NSArray *dataArray2;
    NSArray *g;
    NSArray *xisLabel;
    BusinessUnitViewController *businessUnitObj;
    SamsClubBUViewController *samsBusinessUnitObj;
    LineChart *lineChartView;
    WalmartFooterView *footerView;
    NSMutableArray    *pointArr;
    __weak IBOutlet UILabel *clickOnEachLabel;
    __weak IBOutlet UILabel *sateWiseCumSalesLAbel;
    __weak IBOutlet UILabel *cumulativeTSSharesLabel;
    __weak IBOutlet UILabel *cumulativeSalesLabel;
    __weak IBOutlet UILabel *totalEventSaleLabel;
    //PDF Content
    NSURL *fileURL;
    CGSize pageSize;
    WalmartSelectionHeader *headerView;
    SelectionHeaderSingleton *singletonTableSelection;
	ScriblingView *objScribble;
    BOOL snap;
}
@property (weak, nonatomic) IBOutlet UIImageView *salesClubImageView;
@property (weak, nonatomic) IBOutlet UIImageView *dotComImageView;
@property (weak, nonatomic) IBOutlet UILabel *totalEventSaleDotCom;
@property (weak, nonatomic) IBOutlet UIImageView *walmartImageView;
@property (weak, nonatomic) IBOutlet UILabel *totalEventSaleSamsClub;
@property (weak, nonatomic) IBOutlet UILabel *totalEventSaleWalmart;
@property (weak, nonatomic) IBOutlet UIImageView *pieChartView;
@property (weak, nonatomic) IBOutlet UILabel *totalSalesCount;
@property (weak,nonatomic)  IBOutlet UIImageView *barChartImageView;
@property (weak, nonatomic) IBOutlet UIImageView *entireBackGroundview;
@property (strong, nonatomic) NSDictionary *buCumSalesDict;
@property(nonatomic,retain) NSURL *fileURL;
- (IBAction)stateSelected:(id)sender;
- (IBAction)businessUnitClicked:(id)sender;
- (IBAction)displayIndividualYearSales:(id)sender;
-(UIImage *) ChangeViewToImage : (UIView *) view;

@end



















