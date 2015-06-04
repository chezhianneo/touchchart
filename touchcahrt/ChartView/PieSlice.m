//
//  TBMSlice.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "PieSlice.h"

@implementation PieSlice

@synthesize color = _color;
@synthesize percentage = _percentage;
@synthesize name = _name;

+ (PieSlice *)sliceWithColor:(UIColor *)color percentage:(CGFloat)percentage name:(NSString *)name
{
	PieSlice *newSlice = [[PieSlice alloc] init];
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
