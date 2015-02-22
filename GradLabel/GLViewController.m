//
//  GLViewController.m
//  GradLabel
//
//  Created by Zap on 08.08.12.
//  Copyright (c) 2012 Zababako. All rights reserved.
//

#import "GLViewController.h"
#import "ZBGradLabel.h"

@interface GLViewController ()
{
	ZBGradLabel *_label;
}

@end

@implementation GLViewController

- (void)loadView
{
	self.view = [[UIView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIView *view = self.view;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor brownColor];
	
	CGRect bounds = view.bounds;
	_label = [[ZBGradLabel alloc] initWithFrame:bounds];
	_label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_label.text = @"Grad Label, Hello!";
	_label.font = [UIFont fontWithName:@"Helvetica-Bold" size:34.f];
	_label.verticalMargin = 2.f;
	_label.verticalAlignment = YES;
	_label.textAlignment = UITextAlignmentCenter;
	_label.backgroundColor = [UIColor clearColor];
	
	_label.startColor = [UIColor yellowColor];
	_label.endColor	 = [UIColor blueColor];
	
	_label.shadowBlur   = 2.f;
	_label.shadowOffset = (CGSize) { 3.f, -2.f };
	_label.shadowColor  = [UIColor magentaColor];
	
	_label.innerShadowColor = [UIColor greenColor];
	_label.innerShadowOffset = (CGSize) { 0.f, -1.f };
	_label.innerShadowBlur = 3.f;
	
	_label.strokeColor = [UIColor darkGrayColor];
	_label.strokeWidth = 1.f;
		
	[view addSubview:_label];
	
	UIButton *testButton = [[UIButton alloc] initWithFrame:(CGRect){{ 200.f, 400.f }, { 100.f, 100.f }}];
	testButton.backgroundColor = [UIColor redColor];
	testButton.titleLabel.text = @"Test";
	[testButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:testButton];
	[testButton release];
}

- (void)buttonPressed
{
//	label_.text = @"Changed Text!";
//	label_.font = [UIFont fontWithName:@"Helvetica" size:20];

//	label_.textAlignment = UITextAlignmentRight;
//	label_.verticalAlignment = NO;

//	label_.gradVector = (CGRect){{ 0.f, 0.f }, { 1.f, 1.f }};
//	label_.startColor = [UIColor blackColor];
//	label_.endColor = [UIColor blackColor];
	
	_label.shadowColor = [UIColor grayColor];
//	label_.shadowOffset = CGSizeMake(10, 10);
//	label_.shadowBlur = 10;
	
//	label_.innerShadowColor = [UIColor redColor];
//	label_.innerShadowOffset = CGSizeMake(10, 10);
//	label_.innerShadowBlur = 10;
	
//	label_.frameColor = [UIColor redColor];
//	label_.frameWidth = 4;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
