//
//  GradLabel.m
//
//  Created by Konstantin Zabelin on 28.01.11.
//  Copyright 2011 Zababako. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "GradLabel.h"

@interface GradLabel()

- (CGGradientRef)gradient;

@property (nonatomic, readonly) CTLineRef lineOfText; // retain
@property (nonatomic, retain)	NSString *truncatedText;

@end



@implementation GradLabel

@synthesize text		  = text_;
@synthesize font		  = font_;
@synthesize truncatedText = truncatedText_;

@synthesize textAlignment	  =	textAlignment_;
@synthesize verticalAlignment = verticalAlignment_;
@synthesize horizontalMargin  =	horizontalMargin_;
@synthesize verticalMargin	  = verticalMargin_;

@synthesize startColor = startColor_;
@synthesize endColor   = endColor_;
@synthesize gradVector = gradVector_;

@synthesize shadowBlur	 = shadowBlur_;
@synthesize shadowColor	 = shadowColor_;
@synthesize shadowOffset = shadowOffset_;

@synthesize lineBreakMode = lineBreakMode_;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.font		= [UIFont  systemFontOfSize:frame.size.height];
		self.startColor = [UIColor redColor];
		self.endColor	= [UIColor blueColor];
		self.gradVector = (CGRect) { { 0.f, 0.f }, { 0.f, 1.f } };
		
		[self setContentMode:UIViewContentModeRedraw];
		
		lineBreakMode_ = UILineBreakModeWordWrap;
	}
	return self;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc 
{
	CGGradientRelease(gradient_);
	
	[self setText:nil];
	[self setTruncatedText:nil];
	[self setFont:nil];
	[self setLineOfText:nil];
	
	[self setStartColor:nil];
	[self setEndColor:nil];
	
	[self setShadowColor:nil];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect 
{
	if (self.lineOfText == nil) {
		return;
	}
	
	CGRect selfBounds = [self bounds];
	CGRect textFrame = selfBounds;

	CGContextRef context = UIGraphicsGetCurrentContext();
	textFrame.size = (CTLineGetImageBounds([self lineOfText], context)).size;
	
	switch (self.textAlignment) 
	{
		case UITextAlignmentLeft:
			textFrame.origin.x = horizontalMargin_;
			break;
		default:
		case UITextAlignmentCenter:
			textFrame.origin.x = (selfBounds.size.width - textFrame.size.width) / 2.0;
			break;
		case UITextAlignmentRight:
			textFrame.origin.x = selfBounds.size.width - textFrame.size.width - horizontalMargin_;
			break;
	}
	textFrame.origin.y = self.verticalAlignment ? (int)(selfBounds.size.height - [font_ capHeight]) / 2.f : self.verticalMargin;
	textFrame = CGRectIntegral(textFrame);
	if (CGRectIntersectsRect(rect,textFrame)) 
	{
		CGContextSaveGState(context);

			// Prepare context for shadow if necessary
		if ([self shadowColor]) {
			CGContextSetShadowWithColor(context, self.shadowOffset, [self shadowBlur], [[self shadowColor] CGColor]);
			CGContextBeginTransparencyLayer(context, NULL);
		}
		
			// Drawing text
		CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.f, -1.f));
		CGFloat xForText = textFrame.origin.x;
		CGFloat yForText = self.verticalAlignment ? selfBounds.size.height - (int)((selfBounds.size.height - [font_ capHeight]) / 2.f)
												  :	textFrame.origin.y + font_.capHeight;
		
			//		Clip text
		CGContextSetTextPosition(context, xForText, yForText);
		CGContextSetTextDrawingMode(context, kCGTextClip);
		CTLineDraw([self lineOfText], context);

			//		Draw gradient in clipped area
		[self drawGradientInFrame:textFrame context:context];

			//		Draw shining using shadow
		if ([self shadowColor]){
			CGContextEndTransparencyLayer(context);
		}
		
		CGContextRestoreGState(context);
	}
}

- (void)drawGradientInFrame:(CGRect)textFrame context:(CGContextRef)context
{
		//		Calculate start and end points for gradients
	CGPoint gradStartPoint = textFrame.origin;
	gradStartPoint.x += gradVector_.origin.x * textFrame.size.width;
	gradStartPoint.y += gradVector_.origin.y * textFrame.size.height;
	
	CGPoint gradEndPoint = gradStartPoint;
	gradEndPoint.x += gradVector_.size.width * textFrame.size.width;
	gradEndPoint.y += gradVector_.size.height * textFrame.size.height;
	
		//		Draw gradient
	CGContextDrawLinearGradient(context,
								[self gradient],
								gradStartPoint,
								gradEndPoint,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation );
}

- (CGGradientRef)gradient
{
	if (gradient_ != NULL) { return gradient_; }

	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CFArrayRef colorArray = NULL;
	CGColorRef colors[2]  = { [startColor_ CGColor], [endColor_ CGColor] }; 
	colorArray = CFArrayCreate( kCFAllocatorDefault, (const void **)colors,	sizeof(colors)/sizeof(CGColorRef), &kCFTypeArrayCallBacks );
	gradient_ = CGGradientCreateWithColors(rgb, colorArray, NULL);
	if (colorArray) { CFRelease(colorArray); }
	CGColorSpaceRelease(rgb);
	
	return gradient_;
}

- (void)setLineOfText:(CTLineRef)lineOfText
{
	if (lineOfText_) {
		CFRelease(lineOfText_);
	}
	if (lineOfText) {
		CFRetain(lineOfText);
	}
	lineOfText_ = lineOfText;
}

- (CTLineRef)lineOfText
{
	if (!text_.length) { return nil; }
	if (lineOfText_) { return lineOfText_; }

	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithNameAndSize((CFStringRef)[font_ fontName], [font_ pointSize]);
	if (!fontDescriptor) { return nil; }
	
	CTFontRef fontForDrawing = CTFontCreateWithFontDescriptor(fontDescriptor, [font_ pointSize], NULL);
	CFRelease(fontDescriptor);
	CFStringRef keys[] = { kCTFontAttributeName }; 
	CFTypeRef values[] = { fontForDrawing };
	CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, 
													(const void**)&keys,
													(const void**)&values, 
													sizeof(keys) / sizeof(keys[0]), 
													&kCFTypeDictionaryKeyCallBacks, 
													&kCFTypeDictionaryValueCallBacks);		
	
	CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)self.truncatedText, attributes);
	lineOfText_ = CTLineCreateWithAttributedString(attrString);
	CFRelease(fontForDrawing);
	CFRelease(attributes);
	CFRelease(attrString);
	
	return lineOfText_;
}

- (NSString *) truncatedText {
	if (!truncatedText_) {
		if( !( lineBreakMode_ & ( UILineBreakModeHeadTruncation | UILineBreakModeMiddleTruncation | UILineBreakModeTailTruncation ) ) ) {
			truncatedText_ = [text_ retain];;
			return truncatedText_;
		}
		
		CGSize size = self.bounds.size;
		if( [text_ sizeWithFont: font_].width <= size.width ) {
			truncatedText_ = [text_ retain];
		return truncatedText_;
		}
		
		NSString *ellipsis = @"…";
		
		// Note that this code will find the first occurrence of any given anchor,
		// so be careful when choosing anchor characters/strings...
		NSInteger start;
		start = 0;
		
		NSUInteger end;
		end = [text_ length];
		
		NSUInteger targetLength = end - start;

		NSMutableString *truncatedString = [[NSMutableString alloc] initWithString: text_];
		
		switch(lineBreakMode_) {
			case UILineBreakModeHeadTruncation:
				while( targetLength > [ellipsis length] + 1 && [truncatedString sizeWithFont: font_].width > size.width) {
					// Replace our ellipsis and one additional following character with our ellipsis
					NSRange range = NSMakeRange( start, [ellipsis length] + 1 );
					[truncatedString replaceCharactersInRange: range withString: ellipsis];
					targetLength--;
				}
				break;
				
			case UILineBreakModeMiddleTruncation: {
				NSUInteger leftEnd = start + ( targetLength / 2 );
				NSUInteger rightStart = leftEnd + 1;
				
				if( leftEnd + 1 <= rightStart - 1 )
					break;
				
				// leftPre and rightPost consist of any characters before and beyond
				// any specified anchor(s).
				// left and right are the two halves of the string to be truncated - although
				// the initial split is still performed based upon the length of the
				// (sub)string to be truncated, so we could still make a bad initial split given
				// a short string with predominantly narrow characters on one side and wide
				// characters on the other.
				NSString *leftPre = @"";
				NSMutableString *left = [NSMutableString stringWithString: [truncatedString substringWithRange: NSMakeRange(start, leftEnd - start)]];
				NSMutableString *right = [NSMutableString stringWithString: [truncatedString substringWithRange: NSMakeRange( rightStart, end - rightStart )]];
				NSString *rightPost = @"";
				
				// Reassemble substrings
				[truncatedString setString: [NSString stringWithFormat: @"%@%@%@%@%@", leftPre, left, ellipsis, right, rightPost]];
				
				while( leftEnd > start + 1 && rightStart < end + 1 && [truncatedString sizeWithFont: font_].width > size.width) {
					CGFloat leftLength = [left sizeWithFont: font_].width;
					CGFloat rightLength = [right sizeWithFont: font_].width;
					
					// Shorten string of longest width
					if( leftLength > rightLength ) {
						[left deleteCharactersInRange: NSMakeRange( [left length] - 1, 1 )];
						leftEnd--;
					} else { /* ( leftLength <= rightLength ) */
						[right deleteCharactersInRange: NSMakeRange( 0, 1 )];
						rightStart++;
					}
					
					/* NSLog( @"pre '%@', left '%@', right'%@', post '%@'", leftPre, left, right, rightPost ); */
					[truncatedString setString: [NSString stringWithFormat: @"%@%@%@%@%@", leftPre, left, ellipsis, right, rightPost]];
				}
			}
				break;
				
			case UILineBreakModeTailTruncation:
				while( targetLength > [ellipsis length] + 1 && [truncatedString sizeWithFont: font_].width > size.width) {
					// Remove last character
					NSRange range = NSMakeRange( --end, 1);
					[truncatedString deleteCharactersInRange: range];
					// Replace original last-but-one (now last) character with our ellipsis...
					range = NSMakeRange( end - [ellipsis length], [ellipsis length] );
					[truncatedString replaceCharactersInRange: range withString: ellipsis];
					targetLength--;
				}
				break;
			default:
				break;
				
		}
		
		truncatedText_ = [[NSString stringWithString: truncatedString] retain];
		[truncatedString release];
	}
	
	return truncatedText_;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
	if (shadowColor == shadowColor_) { return; }
	
	[shadowColor retain];
	[shadowColor_ release];
	shadowColor_ = shadowColor;
	
	[self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
	if ((text_ && [text_ isEqualToString:text]) || (text == text_)) { return; }
	
	[text_ release];
	text_ = [text copy];
	
	self.lineOfText = nil;
	self.truncatedText = nil;
	[self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
	if (font_ == font) { return; }

	[font retain];
	[font_ release];
	font_ = font;
	self.lineOfText	   = nil;
	self.truncatedText = nil;
}

@end
