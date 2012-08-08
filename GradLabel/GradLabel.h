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

@property (nonatomic, assign) CGFloat  shadowBlur;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, assign) CGSize   shadowOffset;

@property (nonatomic, assign) UILineBreakMode lineBreakMode;

@end
