//
//  TBMChartView.m
//  PieChart
//
//  Created by Chezhian Aurlraj on 17/11/13.
//

#import "PieChartView.h"
#import "PieSlice.h"

#import <QuartzCore/QuartzCore.h>

#define MARGIN 50.
#define GRADIENT_ALPHA .5
#define SHADOW_OFFSET 45.

#define LAYER_FLAT_TRANSFORM .55
#define LAYER_REPLACE_TRANSFORM -105.

//#define MARGIN 30.
//#define GRADIENT_ALPHA .3
//#define SHADOW_OFFSET 40.
//
//#define LAYER_FLAT_TRANSFORM .6
//#define LAYER_REPLACE_TRANSFORM -50.
//
@interface PieChartView (Private)

- (void)_addSlicesLayers;

@end

@interface PieChartView (Drawing)

-(CGPathRef)_slicePathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle;
-(CALayer *)_sliceLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color;

-(CGPathRef)_shadowPathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle;
-(CALayer *)_shadowLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color;

- (void)_styliseLayer;

@end

@implementation PieChartView
@synthesize slices = _slices;

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
	{
		CGSize drawingSize = CGSizeMake(frame.size.width - MARGIN * 2, frame.size.width - MARGIN * 2);
		_center = CGPointMake(drawingSize.width / 2 + MARGIN, drawingSize.height / 2 + MARGIN);
		_radius = drawingSize.width / 2;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

	[self _addSlicesLayers];
	[self _styliseLayer];
}

@end

@implementation PieChartView (Private)

- (void)_addSlicesLayers
{
	CGFloat lastSliceAngle = .0;
	NSArray *slices = self.slices;
	CALayer *chartViewLayer = self.layer;
	for(PieSlice *slice in slices)
	{
        CGFloat sliceAngle = 360 * slice.percentage / 100;
		CGFloat sliceAngleEnd = (lastSliceAngle + sliceAngle);
		
		CALayer *sliceLayer = [self _sliceLayerWithStartAngle:lastSliceAngle endAngle:sliceAngleEnd color:slice.color];
		if((lastSliceAngle >= 0 && lastSliceAngle < 180) || (sliceAngleEnd > 0 && sliceAngleEnd < 180))
		{
			CALayer *shadowLayer = [self _shadowLayerWithStartAngle:lastSliceAngle endAngle:sliceAngleEnd color:slice.color];
			[chartViewLayer addSublayer:shadowLayer];
		}
		
		[chartViewLayer addSublayer:sliceLayer];
//        CATextLayer *label = [[CATextLayer alloc] init];
//        [label setFontSize:20];
//        [label setFrame:sliceLayer.frame];
//        [label setString:@"50"];
//        [label setForegroundColor:[[UIColor blackColor] CGColor]];
//        [chartViewLayer addSublayer:label];
        
		lastSliceAngle += sliceAngle;
	}
}

@end

@implementation PieChartView (Drawing)

- (UIBezierPath *)_cleanBezierPath
{
	return [UIBezierPath bezierPath];
}

- (CAShapeLayer *)_cleanShapeLayer
{
	return [CAShapeLayer layer];
}

- (CAGradientLayer *)_cleanGradientLayer
{
	return [CAGradientLayer layer];
}

- (CGPoint)_sliceStartWithAngle:(CGFloat)angle
{
	return CGPointMake(_center.x + _radius * cosf(DEGREES_TO_RADIANS(angle)), _center.y + _radius * sinf(DEGREES_TO_RADIANS(angle)));
}

-(CGPathRef)_slicePathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle
{
	UIBezierPath *piePath = [self _cleanBezierPath];
	[piePath moveToPoint:_center];
	
	CGPoint sliceStart = [self _sliceStartWithAngle:degStartAngle];
	[piePath addLineToPoint:sliceStart];
	
	[piePath addArcWithCenter:_center radius:_radius startAngle:DEGREES_TO_RADIANS(degStartAngle) endAngle:DEGREES_TO_RADIANS(degEndAngle) clockwise:YES];
	
	[piePath closePath];
	
	return piePath.CGPath;
}

-(CALayer *)_sliceLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color
{
	CGPathRef slicePath = [self _slicePathWithStartAngle:start endAngle:end];
	
	CAShapeLayer *slice = [self _cleanShapeLayer];
	slice.path = slicePath;
    slice.fillColor=color.CGColor;
	
//	CAGradientLayer *gradientLayer = [self _cleanGradientLayer];
//	gradientLayer.startPoint = CGPointMake(.0, .0);
//	gradientLayer.endPoint = CGPointMake(1., 1.);
//	gradientLayer.frame = CGRectMake(.0, .0, self.frame.size.width, self.frame.size.height);
	
//	CGColorRef startColor = [color CGColor];
//	CGColorRef endColor = CGColorCreateCopyWithAlpha(startColor, GRADIENT_ALPHA);
//	gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)startColor, endColor, nil];
//	[gradientLayer setMask:slice];
    
//    CGColorRef startColor = [color CGColor];
//	CGColorRef startColor1 = CGColorCreateCopyWithAlpha(startColor, 1);
//	CGColorRef endColor = CGColorCreateCopyWithAlpha(startColor, .7);
//	CGColorRef endColor1 = CGColorCreateCopyWithAlpha(startColor, 1);
//	gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)startColor1, endColor , endColor1, nil];
//	[gradientLayer setMask:slice];
//	CFRelease(endColor);
	
	return slice;
}

-(CGPathRef)_shadowPathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle
{
	if(degEndAngle > 180.)
	{
		degEndAngle = 180.;
	}
		
	CGPoint shadowCenter = CGPointMake(_center.x, _center.y + SHADOW_OFFSET);
	
	UIBezierPath *shadowPath = [self _cleanBezierPath];
	
	CGPoint sliceStart = [self _sliceStartWithAngle:degStartAngle];
	[shadowPath moveToPoint:sliceStart];
	
	CGPoint shadowStart = CGPointMake(sliceStart.x, sliceStart.y + SHADOW_OFFSET);
	[shadowPath addLineToPoint:shadowStart];
	
	[shadowPath addArcWithCenter:shadowCenter radius:_radius startAngle:DEGREES_TO_RADIANS(degStartAngle) endAngle:DEGREES_TO_RADIANS(degEndAngle) clockwise:YES];
	
	CGPoint currentPoint = shadowPath.currentPoint;
	CGPoint sliceEnd = CGPointMake(currentPoint.x, currentPoint.y - SHADOW_OFFSET);
	[shadowPath addLineToPoint:sliceEnd];
	
	[shadowPath addArcWithCenter:_center radius:_radius startAngle:DEGREES_TO_RADIANS(degEndAngle) endAngle:DEGREES_TO_RADIANS(degStartAngle) clockwise:NO];
	
	[shadowPath closePath];
	
	return shadowPath.CGPath;
}

-(CALayer *)_shadowLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color
{
	CGPathRef shadowPath = [self _shadowPathWithStartAngle:start endAngle:end];
	
	CAShapeLayer *shadow = [self _cleanShapeLayer];
	shadow.path = shadowPath;
	shadow.fillColor = color.CGColor;
	//shadow.opacity = .7;
	shadow.opacity = 1;
	
	return shadow;
}

- (void)_styliseLayer
{
	CATransform3D scale = CATransform3DMakeScale(1., LAYER_FLAT_TRANSFORM, 1.);
	CATransform3D replace = CATransform3DMakeTranslation(.0, LAYER_REPLACE_TRANSFORM, 0.);
	self.layer.transform = CATransform3DConcat(scale, replace);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int i = 0;
    UITouch *touch   = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    CGRect calibratedRect = CGRectMake(_center.x, _center.y, touchPoint.x - _center.x, touchPoint.y - _center.y);
    float sumOfSquaresOfSize = powf(calibratedRect.size.width, 2.) + powf(calibratedRect.size.height, 2.); // this line and the next line form the pythagoras theorem
    CGFloat touchPointRadius = sqrtf(sumOfSquaresOfSize);
    if(touchPoint.y <= _center.y  ? touchPointRadius > _radius : touchPointRadius > (_radius + SHADOW_OFFSET))
    {
        return;
    }
    else
    {
        CGFloat theta = acosf(calibratedRect.size.width/touchPointRadius); // returns value in radians
        theta = (180*theta)/M_PI; // convert value to degrees
      
        if(touchPoint.y < _center.y)
        {
            theta = 360 - theta;
        }
        
        
        CGFloat lastSliceAngle = .0;
        i = 0;
        for(PieSlice *slice in self.slices)
        {
            CGFloat sliceAngle = 360 * slice.percentage / 100;
            CGFloat sliceAngleEnd = (lastSliceAngle + sliceAngle);
            if(theta > lastSliceAngle && theta <= sliceAngleEnd)
            {
                break;
            }
            lastSliceAngle += sliceAngle;
            i++;
        }
        
    }
    [self.delegate getTheEventPieChart:[(PieSlice *)[self.slices objectAtIndex:i]name]];
    
}


@end
