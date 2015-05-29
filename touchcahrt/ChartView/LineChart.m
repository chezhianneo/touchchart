//
//  LineChart.m
//  WalmartPOC
//
//  Created by Chezhian on 8/2/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import "LineChart.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SHOW_SCALE_NUM 10
#define MARGIN_LEFT 50
#define MARGIN_BOTTOM 65
#define MARGIN_TOP 60

@interface LineChart()
{
    CALayer *linesLayer;
    UIView *popView;
    UILabel *disLabel;
}
@end

@implementation LineChart

@synthesize array;
@synthesize delegate;
@synthesize vInterval;
@synthesize vDesc;
@synthesize lineChartTypeView;
@synthesize chartType,columnWidth,columnScaleFactor,marginScaleBetween,xAxisWidth;
@synthesize xAxisLabel;
@synthesize color1,color2;
@synthesize imageString1,imageString2;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        vInterval = 20;
        
        linesLayer = [[CALayer alloc] init];
        linesLayer.masksToBounds = YES;
        linesLayer.contentsGravity = kCAGravityLeft;
        linesLayer.backgroundColor = [[UIColor clearColor] CGColor];
        buttonArray = [NSMutableArray array];
        [self.layer addSublayer:linesLayer];
        
        
        //PopView
        popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
        [popView setBackgroundColor:[UIColor clearColor]];
        [popView setAlpha:0.0f];
        
        disLabel = [[UILabel alloc]initWithFrame:popView.frame];
        // [disLabel setTextAlignment:UITextAlignmentCenter];
        
        [popView addSubview:disLabel];
        [self addSubview:popView];
    }
    return self;
}

#define ZeroPoint CGPointMake(30,460)

- (void)drawRect:(CGRect)rect
{
    [self setClearsContextBeforeDrawing: YES];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self calcScales:rect];
    
    if (lineChartTypeView == KLineCombinedChartView)
    {
        [self combineLineandBar:context rect:rect];
        [self drawLine:context rect:rect];
    }
    
    else if(lineChartTypeView == KLineScalableView)
    {
        [self drawLine:context rect:rect];
    }
    
    else if(lineChartTypeView == KstaticCombinedAxisView)
    {
        [self combineLineandBar:context rect:rect];
    }
    else if(lineChartTypeView == KLineChartView)
    {
        [self drawScale:context rect:rect];
        [self drawLine:context rect:rect];
        [self drawHorizontalAxis:rect];
    }
    else if(lineChartTypeView == KLineAxisView)
        
    {
        [self drawScale:context rect:rect];
    }
    else if(lineChartTypeView == KLineScalableXaxisView)
    {
        [self drawLine:context rect:rect];
        [self drawHorizontalAxis:rect];
    }
    else if(lineChartTypeView == KLineStaticXaxisView)
    {
        [self drawScale:context rect:rect];
        [self drawHorizontalAxis:rect];
        
        
    }
}

-(void)drawLine:(CGContextRef)context rect:(CGRect)rect
{
    //CGContextSaveGState(context);

    CGContextSetStrokeColorWithColor(context,  [UIColor grayColor].CGColor);
    
    CGColorRef pointColorRef = [UIColor grayColor].CGColor;
    CGFloat pointLineWidth = 5.5f;
    CGFloat pointMiterLimit = 5.0f;
    
    CGContextSetLineWidth(context, pointLineWidth);
    CGContextSetMiterLimit(context, pointMiterLimit);
    
    CGContextSetShadowWithColor(context, CGSizeMake(3, 5), 5, pointColorRef);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetLineCap(context, kCGLineCapRound );
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetStrokeColorWithColor(context,  UIColorFromRGB(0Xb8b8b8).CGColor);


    int baseGroundY = rect.size.height - MARGIN_BOTTOM, baseGroundX = MARGIN_LEFT;
	for(int i=0;i<SHOW_SCALE_NUM + 1; i++)
    {
		maxScaleHeight = (rect.size.height - MARGIN_BOTTOM) * ( i ) / (SHOW_SCALE_NUM + 1);
        
    }


   	for(int gNumber = 0;gNumber<[array count];gNumber++)
    {

        CGContextSaveGState(context);
		NSArray *g  = [array objectAtIndex:gNumber];
        
		for(int vNumber = 0; vNumber < [g count]; vNumber++)
        {

            NSNumber *v = [g objectAtIndex:vNumber];
            float columnHeight = [v floatValue] / maxScaleValue * maxScaleHeight ;
         
            if (vNumber == 0)
            {
    CGContextMoveToPoint(context, vNumber*chartColumnWidth + baseGroundX + (columnWidth+chartType) * vNumber + columnWidth +columnScaleFactor *vNumber, baseGroundY - columnHeight -0.5);

            }

            if ((color1== nil)&&(color2 == nil))
                
                CGContextSetStrokeColorWithColor(context,  UIColorFromRGB(0Xb8b8b8).CGColor);
            
            
            else if(gNumber == 0)
            {
                CGContextSetStrokeColorWithColor(context,  color1.CGColor);
            }
            else if(gNumber == 1)
            {
                CGContextSetStrokeColorWithColor(context,  color2.CGColor);

            }


        CGRect tempRect =  CGRectMake(vNumber*chartColumnWidth + baseGroundX + (columnWidth+chartType) * vNumber + columnWidth +columnScaleFactor *vNumber
                                      , baseGroundY - columnHeight -0.5
                                      , columnWidth
                                      , columnHeight);
        
        CGPoint goPoint = CGPointMake(tempRect.origin.x,tempRect.origin.y);
        // CGPoint goPoint = CGPointMake(p1.x,320-p1.y*1.6);
		CGContextAddLineToPoint(context, goPoint.x, goPoint.y);
        
        bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.tag = vNumber;
            
        if ((imageString1 == nil)&&(imageString2 == nil))
        {
        [bt setBackgroundImage:[UIImage imageNamed:@"csgraph_pointer_normal"]  forState:UIControlStateNormal];
        [bt setBackgroundImage:[UIImage imageNamed:@"csgraph_pointer_normal"]  forState:UIControlStateHighlighted];
        }
        else if(gNumber == 0)
            [bt setBackgroundImage:[UIImage imageNamed:imageString1]  forState:normal];
        else if(gNumber == 1)
            [bt setBackgroundImage:[UIImage imageNamed:imageString2]  forState:normal];
            
            
        [bt setFrame:CGRectMake(0, 0, 20, 20)];
        
        [bt setCenter:goPoint];
        [bt addTarget:self
               action:@selector(btAction:)
     forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:bt];
        [buttonArray addObject:bt];
            if (self.zoomView) {
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                
                NSString *valueStr = [numberFormatter stringFromNumber:v];
                [valueStr
                 drawAtPoint:CGPointMake(vNumber * chartColumnWidth + baseGroundX + columnWidth * vNumber + columnWidth *gNumber+columnScaleFactor *vNumber + 45, baseGroundY - columnHeight - [valueStr sizeWithFont:[UIFont fontWithName:@"Arial" size:12]].height -24) withFont:[UIFont fontWithName:@"Arial" size:12]];
                
            }


}
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
}
}

- (void)btAction:(id)sender{
    
    if ([xAxisLabel count]>0)
    {   NSString *string = [NSString stringWithFormat:@"%@",[xAxisLabel objectAtIndex:((UIButton*)sender).tag]];
        [self.delegate getTheEventBarChart:string];
    }
}

-(void)calcScales:(CGRect)_rect{
	
        int columnCount = 0;
        for(NSArray *g in array){
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
        //if (maxValue <10)
        maxScaleValue =tempvalue +1 ;
        
    }
    else if(maxScaleValue <100)
    {
        maxScaleValue = (tempvalue+1) * pow(10,counter-1);
    }
    else
        maxScaleValue = (tempvalue+1) * pow(10,counter-1);
}

-(void)drawScale:(CGContextRef)context rect:(CGRect)_rect
{
    CGContextSaveGState(context);
    CGPoint points[2],pointsa[2];
    pointsa[0] = CGPointMake(MARGIN_LEFT , _rect.size.height - MARGIN_BOTTOM + 1);
    pointsa[1] = CGPointMake(_rect.size.width - 10-100, _rect.size.height - MARGIN_BOTTOM + 1);
	CGContextAddLines(context, pointsa, 2);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0Xdddddd).CGColor);
	points[0] = CGPointMake(MARGIN_LEFT , MARGIN_TOP -50);
	points[1] = CGPointMake(MARGIN_LEFT , _rect.size.height - MARGIN_BOTTOM + 1);
    
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
		NSString *scaleStr = (maxValue <10)?[NSString stringWithFormat:@"%.01f %%",vScal]:[NSString stringWithFormat:@"%.f %%",vScal];
		[scaleStr
         drawAtPoint:CGPointMake(MARGIN_LEFT - 10 - [scaleStr sizeWithFont:[UIFont fontWithName:@"Arial" size:10]].width, y - 12) withFont:[UIFont fontWithName:@"Arial" size:12]];
        
        CGPoint points4[2];
		points4[0] = CGPointMake(MARGIN_LEFT - 10, y);
		points4[1] = CGPointMake(_rect.size.width - 10-100 , y);
		CGContextAddLines(context, points4, 2);
		CGContextDrawPath(context, kCGPathStroke);
		
	}
	CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0X535353).CGColor);
    
	CGContextDrawPath(context, kCGPathStroke);
	CGContextSetAllowsAntialiasing(context, YES);
    
	CGContextRestoreGState(context);
}
-(void)combineLineandBar:(CGContextRef)context rect:(CGRect)_rect
{
    CGContextSaveGState(context);
    int vScal;
    for(int i=0;i<SHOW_SCALE_NUM + 1; i++){
		maxScaleHeight = (_rect.size.height - MARGIN_BOTTOM) * ( i ) / (SHOW_SCALE_NUM + 1);
		float y = (_rect.size.height - MARGIN_BOTTOM) -
        maxScaleHeight;
        vScal = i* maxScaleValue/10;
        CGContextSetFillColorWithColor(context, UIColorFromRGB(0X535353).CGColor);
		NSString *scaleStr = [NSString stringWithFormat:@"%d %%",vScal];
		[scaleStr
         drawAtPoint:CGPointMake(_rect.size.width - 10- 60 - [scaleStr sizeWithFont:[UIFont fontWithName:@"Arial" size:10]].width, y - 10) withFont:[UIFont fontWithName:@"Arial" size:12]];
    }
    CGContextRestoreGState(context);
}
-(void)drawHorizontalAxis:(CGRect)_rect
{ if (chartType ==1)
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
    for(int i=0;i<[xAxisLabel count]; i++){
		
		float x = MARGIN_LEFT +xAxisWidth *i + columnScaleFactor *i +i*chartColumnWidth;
        UITextView *label2 = [[UITextView alloc] initWithFrame:CGRectMake(x, _rect.size.height - 65.0, xAxisWidth*chartType+marginScaleBetween+chartColumnWidth+20, 40)];
        [label2 setUserInteractionEnabled:NO];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont fontWithName:@"Arial" size:12];
        label2.text = [xAxisLabel objectAtIndex:i];
        label2.textColor = UIColorFromRGB(0X535353);
        
        [self addSubview:label2];
		
	}
    
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for ( int i=0; i<[buttonArray count];i++)
    {
        if (CGRectContainsPoint(((UIButton *)[buttonArray objectAtIndex:i]).frame, point))
        {
            return YES;
        }
    }

    
    return NO;
}


@end
