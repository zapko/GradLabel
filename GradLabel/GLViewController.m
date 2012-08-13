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
	label.font = [UIFont fontWithName:@"Helvetica-Bold" size:34.f];
	label.verticalMargin = 2.f;
	label.verticalAlignment = YES;
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	
	label.startColor = [UIColor yellowColor];
	label.endColor	 = [UIColor blueColor];
	
	label.shadowBlur   = 2.f;
	label.shadowOffset = (CGSize) { 3.f, -2.f };
	label.shadowColor  = [UIColor magentaColor];
	
	label.innerShadowColor = [UIColor greenColor];
	label.innerShadowOffset = (CGSize) { 0.f, -1.f };
	label.innerShadowBlur = 3.f;
	
	label.frameColor = [UIColor darkGrayColor];
	label.frameWidth = 1.f;
		
	[view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
