//
//  GLViewController.m
//  GradLabel
//
//  Created by Zap on 08.08.12.
//  Copyright (c) 2012 Zababako. All rights reserved.
//

#import "GLViewController.h"
#import "GradLabel.h"

@interface GLViewController ()

@end

@implementation GLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIView *view = self.view;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor brownColor];
	
	CGRect bounds = view.bounds;
	GradLabel *label = [[GradLabel alloc] initWithFrame:bounds];
	label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	label.text = @"Grad Label, Hello!";
	label.font = [UIFont fontWithName:@"Helvetica" size:35.f];
	label.verticalAlignment = YES;
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	
	label.shining = NO;
	label.shiningBlur = 5.f;
	label.shiningOffset = (CGSize) { 3.f, -6.f };
	label.shiningColor		= [UIColor cyanColor];
	label.shiningStartColor = [UIColor yellowColor];
	label.shiningEndColor	= [UIColor magentaColor];
	
	label.shadowColor = [UIColor yellowColor];
	label.shadowOffset = (CGSize) { 4.f, 10.f };
	[label setNeedsDisplay];
	
	[view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
