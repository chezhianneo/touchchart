//
//  TBMSlice.h
//  PieChart
//
//

#import <UIKit/UIKit.h>


@interface PieSlice : NSObject
{
	UIColor *_color;
	CGFloat _percentage;
	NSString *_name;
}
+ (PieSlice *)sliceWithColor:(UIColor *)color percentage:(CGFloat)percentage name:(NSString *)name;

@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) CGFloat percentage;
@property (nonatomic, readonly) NSString *name;

@end
