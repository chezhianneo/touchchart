//
//  TBMSlice.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "TBMSlice.h"

@implementation TBMSlice

@synthesize color = _color;
@synthesize percentage = _percentage;
@synthesize name = _name;

+ (TBMSlice *)sliceWithColor:(UIColor *)color percentage:(CGFloat)percentage name:(NSString *)name
{
	TBMSlice *newSlice = [[TBMSlice alloc] init];
//	newSlice->_color = [color retain];
//	newSlice->_percentage = percentage;
//	newSlice->_name = [name retain];
//	return [newSlice autorelease];
	newSlice->_color = color;
	newSlice->_percentage = percentage;
	newSlice->_name = name;
	return newSlice;
}

- (void)dealloc
{
}

@end
