//
//  BarChartView.m
//  Copyright (c) chezhian All rights reserved.
//

#import "BarChartThreeView.h"

#define MARGIN_LEFT 50
#define MARGIN_BOTTOM 60
#define MARGIN_TOP 60
#define SHOW_SCALE_NUM 10
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface BarChartThreeView(private)
-(void)drawColumn:(CGContextRef)context rect:(CGRect)_rect;
-(void)drawScale:(CGContextRef)context rect:(CGRect)_rect;
-(void)drawTitle:(CGContextRef)context rect:(CGRect)_rect;
-(void)drawXAxis:(CGContextRef)context rect:(CGRect)_rect;
-(void)drawLegend:(CGContextRef)context rect:(CGRect)_rect;

-(void)calcScales:(CGRect)_rect;
-(CGColorRef)defaultColorForIndex:(NSUInteger)pieSliceIndex;

@end

@implementation BarChartThreeView
@synthesize groupData;
@synthesize groupTitle;
@synthesize xAxisLabel;
@synthesize chartType,columnWidth,columnScaleFactor,marginScaleBetween,xAxisWidth;
@synthesize chartTitle;
@synthesize lastYear,firstColumn,secondColumn,thirdColumn;
@synthesize columnValue;
@synthesize columnView;
@synthesize draggable;
@synthesize lblLegendTitle;
@synthesize labelTitle;
@synthesize lineChartVaxis;
@synthesize chartTypeView;
@synthesize sideCol1,sideCol2,topCol1,topCol2,lineAxis;


static const CGFloat colorLookupTable[10][3] =
{
	{
		1.0, 0.0, 0.0
	},{
		0.0, 1.0, 0.0
	},{
		0.0, 0.0, 1.0
	},{
		1.0, 1.0, 0.0
	},{
		0.25, 0.5, 0.25
	},{
		1.0, 0.0, 1.0
	},{
		0.5, 0.5, 0.5
	},{
		0.25, 0.5, 0.0
	},{
		0.25, 0.25, 0.25
	},{
		0.0, 1.0, 1.0
	}
};

static const CGFloat colorsblue1[8] =
{
    0.07,0.44,0.50,1.0,
    0,0.796,0.796,1.0
};
//0.27,0.99,0.77,1.0
static const CGFloat colorsblue2[8] =
{
    0.039,0.566,0.65,1.0,
    0.058,0.27,0.05,1.0
};


static const CGFloat colorsOrange1[8] =
{
    0.56,0.27,0.05,1.0,
    0.91,0.27,0.027,1.0
};
//0.058,0.27,0.05,1.0
static const CGFloat colorsOrange2[8] =
{
    0.07,0.44,0.50,1.0,
    0.27,0.99,0.77,1.0
};

static const CGFloat colorsPink[8] =
{
    0.95,0.36,0.36,1.0,
    0.95,0.36,0.36,1.0,
};



/** @brief Creates and returns a CPTColor that acts as the default color for that pie chart index.
 *	@param pieSliceIndex The pie slice index to return a color for.
 *	@return A new CPTColor instance corresponding to the default value for this pie slice index.
 **/

-(CGColorRef)defaultColorForIndex:(NSUInteger)pieSliceIndex
{
    CGColorRef myColor;
    myColor = [UIColor colorWithRed: colorLookupTable[pieSliceIndex % 10][0] green: colorLookupTable[pieSliceIndex % 10][1] blue:colorLookupTable[pieSliceIndex % 10][2] alpha:1].CGColor;
    return myColor;
}
-(void)drawRect:(CGRect)_rect{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    arrayPoint = [[NSMutableArray alloc]init];
    //	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    //	CGContextFillRect(context, _rect);
    CGFloat locations[] = { 0.0, 1.0 };
    if (chartType ==1)
    {
        chartColumnWidth = 10;
    }
    else if(chartType ==2)
    {
        chartColumnWidth = 30.0;
    }
    else if(chartType ==3)
    {
        chartColumnWidth = 50.0;
    }
    else
    {
        chartColumnWidth = 70.0;
    }
	NSArray *colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, [UIColor clearColor].CGColor, nil];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(_rect), CGRectGetMinY(_rect)-150);
    CGPoint endPoint = CGPointMake(CGRectGetMinX(_rect), CGRectGetMaxY(_rect));
    
    CGContextSaveGState(context);
    
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(_rect), midx = CGRectGetMidX(_rect), maxx = CGRectGetMaxX(_rect);
	CGFloat miny = CGRectGetMinY(_rect), midy = CGRectGetMidY(_rect), maxy = CGRectGetMaxY(_rect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, 0);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, 0);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, 0);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, 0);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
    //	CGContextDrawPath(context, kCGPathFillStroke);
    //	CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    [self calcScales:_rect];
    if (chartTypeView == KBarChartView)
    {
        [self drawScale:context rect:_rect];
        [self drawColumn:context rect:_rect];
        [self drawHorizontalAxis:_rect];
        
    }
    else if(chartTypeView == KcolumnScalableView)
    {
        [self drawColumn:context rect:_rect];
        [self drawHorizontalAxis:_rect];
    }
    else if (chartTypeView == KstaticAxisView)
    {
        [self drawScale:context rect:_rect];
    }
}
-(void)drawScale:(CGContextRef)context rect:(CGRect)_rect{
    
    CGContextSaveGState(context);
    
	CGPoint points[2],pointsa[2];
    pointsa[0] = CGPointMake(MARGIN_LEFT -10, _rect.size.height - MARGIN_BOTTOM + 1);
    pointsa[1] = CGPointMake(_rect.size.width - 10-100, _rect.size.height - MARGIN_BOTTOM + 1);
	CGContextAddLines(context, pointsa, 2);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0Xdddddd).CGColor);
	points[0] = CGPointMake(MARGIN_LEFT - 10, MARGIN_TOP -50);
	points[1] = CGPointMake(MARGIN_LEFT -10, _rect.size.height - MARGIN_BOTTOM + 1);
	//points[2] = CGPointMake(_rect.size.width - 10-100, _rect.size.height - MARGIN_BOTTOM + 1);
    //	CGContextSetAllowsAntialiasing(context, NO);
    //    CGContextSetFillColorWithColor(context, UIColorFromRGB(0X535353).CGColor);
    //  CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0X535353).CGColor);
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0Xdddddd).CGColor);
    CGContextAddLines(context, points, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
    
 	for(int i=0;i<SHOW_SCALE_NUM + 1; i++){
		maxScaleHeight = (_rect.size.height - MARGIN_BOTTOM) * ( i ) / (SHOW_SCALE_NUM + 1);
		float vScal = ceil(1.0 * maxScaleValue / (SHOW_SCALE_NUM ) * (i ));
		float y = (_rect.size.height - MARGIN_BOTTOM) -
        maxScaleHeight;
        
        vScal = (maxScaleValue/10)*i;
        
        CGContextSetFillColorWithColor(context, UIColorFromRGB(0X535353).CGColor);
        
		NSString *scaleStr = (maxValue <10)?[NSString stringWithFormat:@"%.01f",vScal]:[NSString stringWithFormat:@"%.f",vScal];
		[scaleStr
         drawAtPoint:CGPointMake(MARGIN_LEFT - 20 - [scaleStr sizeWithFont:[UIFont fontWithName:@"Arial" size:10]].width, y - 12) withFont:[UIFont fontWithName:@"Arial" size:12]];
        
		CGContextDrawPath(context, kCGPathStroke);
        
        CGPoint points4[2];
		points4[0] = CGPointMake(MARGIN_LEFT - 10, y);
		points4[1] = CGPointMake(_rect.size.width - 10-100 , y);
        
		CGContextAddLines(context, points4, 2);
		CGContextDrawPath(context, kCGPathStroke);
		
	}
	
	CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0Xdddddd).CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	CGContextSetAllowsAntialiasing(context, YES);
	CGContextRestoreGState(context);
}

#pragma mark -
-(void)drawHorizontalAxis:(CGRect)_rect
{
    UITextView *label2;
    if (!xAxisWidth)
    {
        xAxisWidth = columnWidth;
    }
    for(int i=0;i<[[groupData objectAtIndex:0] count]+1; i++){
  
		float x = MARGIN_LEFT-10 +columnWidth *i + columnScaleFactor *i +i*chartColumnWidth;
        label2 = [[UITextView alloc] initWithFrame:CGRectMake(x, _rect.size.height - 65.0, xAxisWidth*chartType+marginScaleBetween+chartColumnWidth+20, 40)];
        [label2 setUserInteractionEnabled:NO];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont fontWithName:@"Arial" size:12];
        //    label.transform = CGAffineTransformMakeRotation(0.1);
        if (i<[xAxisLabel count])
        {
            label2.text = [xAxisLabel objectAtIndex:i];
        }
        label2.textColor = UIColorFromRGB(0X535353);
        [self addSubview:label2];
	}
    
}
-(void)drawColumn:(CGContextRef)context rect:(CGRect)_rect{
    
    maxScaleHeight = (_rect.size.height - MARGIN_BOTTOM) * ( 10 ) / (SHOW_SCALE_NUM + 1);
	CGPoint points[4];
    CGContextSaveGState(context);
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient;

    float columnHeight;
	int baseGroundY = _rect.size.height - MARGIN_BOTTOM+2, baseGroundX = MARGIN_LEFT;
	for(int gNumber = 0;gNumber<[groupData count];gNumber++)
    {
        NSArray *g  = [groupData objectAtIndex:gNumber];
        //NSLog(@"%@",g);
		for(int vNumber = 0; vNumber < [g count]; vNumber++){
            
            //UIColor *columnColor;
            NSNumber *v = [g objectAtIndex:vNumber];
            columnHeight = 0;
            gradient = CGGradientCreateWithColorComponents(baseSpace,NULL,NULL,2);
            if ((gNumber==0 && !lastYear && !firstColumn ))
            {
                
                gradient = CGGradientCreateWithColorComponents(baseSpace, colorsPink, NULL, 2);
                columnHeight = [v floatValue] / maxScaleValue * maxScaleHeight ;
            }
            else if ((gNumber==1 && !lastYear && !secondColumn))
            {
               

                gradient = CGGradientCreateWithColorComponents(baseSpace, colorsblue1, NULL, 2);
                columnHeight = [v floatValue] / maxScaleValue * maxScaleHeight ;
                if(firstColumn &&!secondColumn)baseGroundX = MARGIN_LEFT - columnWidth;
            }
            else if ((gNumber==2 && !lastYear && !thirdColumn))
            //else if ((gNumber==0 && lastYear)||(gNumber==2 && chartType))
            {
//                columnColor = [UIColor colorWithRed:0.99 green:0.64 blue:0.24 alpha:1];
//                CGContextSetFillColorWithColor(context, columnColor.CGColor);
//                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.99 green:0.64 blue:0.24 alpha:1].CGColor);
               

                gradient = CGGradientCreateWithColorComponents(baseSpace, colorsOrange1, NULL, 2);
                columnHeight = [v floatValue] / maxScaleValue * maxScaleHeight ;
                if(firstColumn &&!secondColumn)baseGroundX = MARGIN_LEFT - columnWidth;
                
            }
            
//            else if ((gNumber==1 && lastYear)||(gNumber==3 && chartType))
//            {
//                columnColor = [UIColor colorWithRed:0.63 green:0.66 blue:0.69 alpha:1];
//                CGContextSetFillColorWithColor(context, columnColor.CGColor);
//                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.63 green:0.66 blue:0.69 alpha:1].CGColor);
//            }
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            

           
            
            CGContextSaveGState(context);
            CGRect tempRect =  CGRectMake(vNumber*chartColumnWidth + baseGroundX + columnWidth * vNumber + columnWidth *gNumber+columnScaleFactor *vNumber
                                          , baseGroundY - columnHeight -0.5
                                          , columnWidth
                                          , columnHeight);
            
            CGContextAddRect(context,tempRect);
            CGContextClip(context);
            CGPoint startPoint = CGPointMake(tempRect.origin.x, tempRect.origin.y + tempRect.size.height);
            CGPoint endPoint = CGPointMake(tempRect.origin.x,tempRect.origin.y);
            
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
            CGContextRestoreGState(context);
            [arrayPoint addObject:[NSValue valueWithCGRect:tempRect]];
            if(columnHeight == 0 ){
                continue;
            }
            
            if((gNumber==0 && !lastYear && !firstColumn))
            {
                CGContextSetFillColorWithColor(context, UIColorFromRGB(0Xa63030).CGColor);
            }
            else if((gNumber==1 && !lastYear &&!secondColumn))
            {
                CGContextSetFillColorWithColor(context, UIColorFromRGB(0X035462).CGColor);
            }
            else if ((gNumber==2 && !lastYear && !thirdColumn))
            //else if((gNumber==0 && lastYear)||(gNumber==2 && chartType))
            {
                CGContextSetFillColorWithColor(context, UIColorFromRGB(0X974607).CGColor);
            }
            else if((gNumber==1 && lastYear)||(gNumber==3 && chartType))
            {
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor);
            }
            
            points[0] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + columnWidth+columnScaleFactor*vNumber, baseGroundY - columnHeight);
            points[1] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + columnWidth + marginScaleBetween+columnScaleFactor*vNumber, baseGroundY - columnHeight -marginScaleBetween );
            points[2] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + columnWidth + marginScaleBetween+columnScaleFactor*vNumber, baseGroundY - marginScaleBetween );
            points[3] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + columnWidth+columnScaleFactor*vNumber, baseGroundY );
            
            CGContextAddLines(context, points, 4);
            CGContextDrawPath(context, kCGPathFill);
            
            if ((gNumber==0 && !lastYear && !firstColumn))
            {
                CGContextSetFillColorWithColor(context, UIColorFromRGB(0Xe04c4c).CGColor);
            }
            else if((gNumber==1 && !lastYear && !secondColumn))
            {
                CGContextSetFillColorWithColor(context, UIColorFromRGB(0X45b4c8).CGColor);
            }
            else if((gNumber==0 && lastYear)||(gNumber==2 && chartType))
            {
                CGContextSetFillColorWithColor(context, UIColorFromRGB(0Xef8e42).CGColor);
            }
            else if((gNumber==1 && lastYear)||(gNumber==3 && chartType))
            {
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor);
                
            }
            
            points[0] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber+columnScaleFactor*vNumber , baseGroundY - columnHeight );
            points[1] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + marginScaleBetween+columnScaleFactor*vNumber, baseGroundY - columnHeight -marginScaleBetween );
            points[2] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + columnWidth + marginScaleBetween+columnScaleFactor*vNumber, baseGroundY - columnHeight -marginScaleBetween );
            points[3] = CGPointMake(vNumber*chartColumnWidth + columnWidth *gNumber+ baseGroundX + columnWidth * vNumber + columnWidth+columnScaleFactor*vNumber, baseGroundY - columnHeight );
            
            CGContextAddLines(context, points, 4);
            CGContextDrawPath(context, kCGPathFill);
            if (self.zoomView) {
                NSString *valueStr = [numberFormatter stringFromNumber:v];
                
                int sec;
                sec =(gNumber ==1 )?10:0;
                [valueStr
                 drawAtPoint:CGPointMake(vNumber * chartColumnWidth + baseGroundX + columnWidth * vNumber + columnWidth *gNumber+columnScaleFactor *vNumber + 10 + sec, baseGroundY - columnHeight - [valueStr sizeWithFont:[UIFont fontWithName:@"Arial" size:12]].height -24) withFont:[UIFont fontWithName:@"Arial" size:12]];
                
            }
		}
	}

}
#pragma mark -

-(void)calcScales:(CGRect)_rect{
	int columnCount = 0;
	for(NSArray *g in groupData){
        if (!columnCount) {
            columnCount = [g count];
        }
		for(NSNumber *v in g){
			if(maxValue<[v floatValue]) maxValue = [v floatValue];
			if(minValue>[v floatValue]) minValue = [v floatValue];
		}
	}
    [self calculateAxis];
}

-(void)calculateAxis
{
    maxScaleValue = ((int)ceil(maxValue) + (SHOW_SCALE_NUM - (int)ceil(maxValue) % SHOW_SCALE_NUM));
    int counter,tempvalue;
    NSString *tempMaxString = [NSString stringWithFormat:@"%d",(int)maxValue];
    counter = [tempMaxString length];
    tempvalue =  [[NSString stringWithFormat:@"%c",[tempMaxString characterAtIndex:0]] intValue];
    if(maxValue < 10)
    {
        maxScaleValue =tempvalue +1 ;
        
        
    }
    else if(maxScaleValue <100)
    {
        maxScaleValue = (tempvalue+1) * pow(10,counter-1);
    }
    else
        maxScaleValue = (tempvalue+1) * pow(10,counter-1);
}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    int columnCount,labelCount;
//    UITouch *touch = [touches anyObject];
//    beginPoint = [touch locationInView:self];
//
//    columnCount = [arrayPoint count];
//    labelCount =  [xAxisLabel count];
//    for (int i=0;i<[arrayPoint count];i++)
//    {
//        float xAxisMinPoint =([[arrayPoint objectAtIndex:i] CGRectValue].origin.x);
//        float xAxisMaxPoint =([[arrayPoint objectAtIndex:i] CGRectValue].origin.x) + ([[arrayPoint objectAtIndex:i] CGRectValue]).size.width;
//        float yAxisMinPoint =([[arrayPoint objectAtIndex:i] CGRectValue].origin.y);
//        float yAxisMaxPoint =([[arrayPoint objectAtIndex:i] CGRectValue].origin.y) + ([[arrayPoint objectAtIndex:i] CGRectValue]).size.height;
//        
//        if ( beginPoint.x >xAxisMinPoint && beginPoint.x < xAxisMaxPoint && beginPoint.y>yAxisMinPoint && beginPoint.y <yAxisMaxPoint )
//        {
//            NSString *string;
//            if (i<labelCount)
//            {
//                string = [NSString stringWithFormat:@"%@",[xAxisLabel objectAtIndex:i]];
//            }
//            else if (i >= labelCount)
//            {
//                string = [NSString stringWithFormat:@"%@",[xAxisLabel objectAtIndex:i-labelCount]];
//            }
//            [self.delegate getTheEventBarThreeChart:string];
//            break;
//        }
//    }
//}
@end

