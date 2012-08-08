//
//  GradLabel.h
//
//  Created by Konstantin Zabelin on 28.01.11.
//  Copyright 2011 Zababako. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface GradLabel : UIView 
{
	CGGradientRef gradient_;
	CGGradientRef shiningGradient_;
	CTLineRef	  lineOfText_;
}

@property (nonatomic, copy)   NSString *text;
@property (nonatomic, retain) UIFont   *font;
@property (nonatomic, assign) UITextAlignment textAlignment;
@property (nonatomic, assign) BOOL	  verticalAlignment; // if YES align text to vertical center, NO – align to top
@property (nonatomic, assign) CGFloat horizontalMargin;
@property (nonatomic, assign) CGFloat verticalMargin;

@property (nonatomic, retain) UIColor *startColor;
@property (nonatomic, retain) UIColor *endColor;
@property (nonatomic, assign) CGRect   gradVector; // vector in relative coordinates { 0..1, 0..1, 0..1, 0..1 }

@property (nonatomic, assign, getter = isShining) BOOL shining;
@property (nonatomic, retain) UIColor *shiningStartColor;
@property (nonatomic, retain) UIColor *shiningEndColor;
@property (nonatomic, assign) CGFloat  shiningBlur;
@property (nonatomic, retain) UIColor *shiningColor;
@property (nonatomic, assign) CGSize   shiningOffset;

	// This shadow is not blured
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, assign) CGSize   shadowOffset;

@property (nonatomic, assign) UILineBreakMode lineBreakMode;

@end
