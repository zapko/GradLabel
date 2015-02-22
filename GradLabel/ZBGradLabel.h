//
//  ZBGradLabel.h
//
//  Created by Konstantin Zabelin on 28.01.11.
//  Copyright 2015 Studio "Zababako". All rights reserved.
//



#import <UIKit/UIKit.h>

@interface ZBGradLabel : UIView

@property (nonatomic, copy)   IBInspectable NSString *text;
@property (nonatomic, retain) UIFont *font;			// Default: systemFontOfSize:frame.size.height

@property (nonatomic, assign) IBInspectable UILineBreakMode lineBreakMode;

@property (nonatomic, assign) UITextAlignment textAlignment; // horizontal alignment
@property (nonatomic, assign) IBInspectable BOOL verticalAlignment; // if YES align text to vertical center, NO – align to top
@property (nonatomic, assign) IBInspectable CGFloat horizontalMargin;
@property (nonatomic, assign) IBInspectable CGFloat verticalMargin;

@property (nonatomic, assign) IBInspectable CGRect   gradVector; // vector in relative coordinates { { 0..1, 0..1 }, { 0..1, 0..1 } } Default: { { 0, 0 }, { 0, 1 } }
@property (nonatomic, retain) IBInspectable UIColor *startColor; // Default: redColor
@property (nonatomic, retain) IBInspectable UIColor *endColor;	 // Default: blueColor

@property (nonatomic, retain) IBInspectable UIColor *shadowColor;
@property (nonatomic, assign) IBInspectable CGSize   shadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat  shadowBlur;

@property (nonatomic, retain) IBInspectable UIColor *innerShadowColor;
@property (nonatomic, assign) IBInspectable CGSize   innerShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat  innerShadowBlur;

@property (nonatomic, retain) IBInspectable UIColor *strokeColor;
@property (nonatomic, assign) IBInspectable CGFloat  strokeWidth;

@end
