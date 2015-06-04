//
//  TBMChartView.h
//  PieChart
//
//  Created by Chezhian Arulraj on 17/11/12.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) angle * M_PI/180.0
@protocol PieChartDelegate <NSObject>

- (void)getTheEventPieChart:(NSString *)string;

@end

@interface PieChartView : UIView
{
	CGPoint _center;
	CGFloat _radius;
	NSArray *_slices;
}
@property (nonatomic, retain) NSArray *slices;
@property (nonatomic, assign) id<PieChartDelegate> delegate;

@end
