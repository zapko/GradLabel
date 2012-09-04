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
{
	GradLabel *label_;
}

@end

@implementation GLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIView *view = self.view;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor brownColor];
	
	CGRect bounds = view.bounds;
	label_ = [[GradLabel alloc] initWithFrame:bounds];
	label_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	label_.text = @"Grad Label, Hello!";
	label_.font = [UIFont fontWithName:@"Helvetica-Bold" size:34.f];
	label_.verticalMargin = 2.f;
	label_.verticalAlignment = YES;
	label_.textAlignment = UITextAlignmentCenter;
	label_.backgroundColor = [UIColor clearColor];
	
	label_.startColor = [UIColor yellowColor];
	label_.endColor	 = [UIColor blueColor];
	
	label_.shadowBlur   = 2.f;
	label_.shadowOffset = (CGSize) { 3.f, -2.f };
	label_.shadowColor  = [UIColor magentaColor];
	
	label_.innerShadowColor = [UIColor greenColor];
	label_.innerShadowOffset = (CGSize) { 0.f, -1.f };
	label_.innerShadowBlur = 3.f;
	
	label_.frameColor = [UIColor darkGrayColor];
	label_.frameWidth = 1.f;
		
	[view addSubview:label_];
	
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
	
	label_.shadowColor = [UIColor grayColor];
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
