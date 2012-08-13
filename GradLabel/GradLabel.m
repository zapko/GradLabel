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

@property (nonatomic, readonly) CTLineRef  lineOfText; // retain
@property (nonatomic, readonly) CGImageRef textMask; // retain
@property (nonatomic, retain)	NSString  *truncatedText;
@property (nonatomic, retain)	UIImage	  *gradTextImage;

@end


	// TODO: add gradTextImage resetting

@implementation GradLabel

@synthesize text		  = text_;
@synthesize truncatedText = truncatedText_;

@synthesize textMask	  = textMask_;
@synthesize lineOfText	  = lineOfText_;
@synthesize gradTextImage = gradTextImage_;

@synthesize font		  = font_;
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

@synthesize innerShadowColor  = innerShadowColor_;
@synthesize innerShadowBlur	  = innerShadowBlur_;
@synthesize innerShadowOffset = innerShadowOffset_;

@synthesize frameWidth = frameWidth_;
@synthesize frameColor = frameColor_;

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
	CGImageRelease(textMask_);
	
	self.text		   = nil;
	self.truncatedText = nil;
	
	CGImageRelease(self.textMask);
	self.gradTextImage = nil;
	
	self.font		   = nil;
	self.lineOfText	   = nil;
	
	self.startColor = nil;
	self.endColor	= nil;
	
	self.shadowColor = nil;
	
	self.frameColor = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (CGImageRef)createMaskWithSize:(CGSize)size shape:(void (^)(void))block
{
	UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
	block();
	CGImageRef shape = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
	UIGraphicsEndImageContext();
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(shape),
										CGImageGetHeight(shape),
										CGImageGetBitsPerComponent(shape),
										CGImageGetBitsPerPixel(shape),
										CGImageGetBytesPerRow(shape),
										CGImageGetDataProvider(shape), NULL, false);
	return mask;
}

- (UIImage *)blackSquareOfSize:(CGSize)size
{
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	[[UIColor blackColor] setFill];
	CGContextFillRect(UIGraphicsGetCurrentContext(), (CGRect) { CGPointZero, size });
	UIImage *blackSquare = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return blackSquare;
}

- (CGSize)textSizeAscent:(CGFloat *)ascentRet descent:(CGFloat *)descentRet
{
	CGSize textSize;
	CGFloat ascent, descent;
	textSize.width = CTLineGetTypographicBounds(self.lineOfText, &ascent, &descent, NULL);
	textSize.height = ascent + descent;
	
	if (ascentRet)  { *ascentRet  = ascent;  }
	if (descentRet) { *descentRet = descent; }
	
	return textSize;
}

- (CGPoint)textFrameOriginWithSize:(CGSize)textSize
{
	CGRect selfBounds = self.bounds;
	
	CGPoint textFrameOrigin = CGPointZero;
	
	switch (textAlignment_)
	{
		case UITextAlignmentLeft:
			textFrameOrigin.x = horizontalMargin_;
			break;
		default:
		case UITextAlignmentCenter:
			textFrameOrigin.x = (selfBounds.size.width - textSize.width) / 2.0;
			break;
		case UITextAlignmentRight:
			textFrameOrigin.x = selfBounds.size.width - textSize.width - horizontalMargin_;
			break;
	}
	textFrameOrigin.y = verticalAlignment_ ? (selfBounds.size.height - textSize.height) / 2.f : verticalMargin_;
	
	return textFrameOrigin;
}

- (UIImage *)gradTextImage
{
	if (gradTextImage_) { return gradTextImage_; }
	
	CTLineRef lineOfText = self.lineOfText;
	if (!lineOfText) { return nil; }
	
	CGFloat ascent;
	CGSize	textSize = [self textSizeAscent:&ascent descent:NULL];
	
	UIGraphicsBeginImageContextWithOptions(textSize, NO, [[UIScreen mainScreen] scale]);
	CGContextRef localContext = UIGraphicsGetCurrentContext();
		
		// Drawing text
		//		Clip text
	CGContextSetTextMatrix(localContext, CGAffineTransformMakeScale(1.f, -1.f));
	CGContextSetTextPosition(localContext, 0, ascent);
	CGContextSetTextDrawingMode(localContext, kCGTextClip);
	CTLineDraw(lineOfText, localContext);
	
		//		Draw gradient in clipped area
	[self drawGradientInFrame:(CGRect) { CGPointZero, textSize } context:localContext];
		
	gradTextImage_ = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [gradTextImage_ retain];
}

- (void)drawInnerShadowInContext:(CGContextRef)context atPoint:(CGPoint)textPoint
{
	CTLineRef lineOfText = self.lineOfText;
	if (!lineOfText) { return; }
	
	CGContextSaveGState(context);
	
	CGFloat ascent;
	CGSize textSize = [self textSizeAscent:&ascent descent:NULL];
	CGRect textBounds = (CGRect) { CGPointZero, textSize };
	
		// Creating mask
	CGImageRef mask = [self createMaskWithSize:textBounds.size shape:^{
		CGContextRef localContext = UIGraphicsGetCurrentContext();
		
		[[UIColor blackColor] setFill];
		CGContextFillRect(localContext, textBounds);
		
		[[UIColor whiteColor] set];
		CGContextSetLineWidth(localContext, 1.5f); // This is made to cut off anti-aliasing one-pixel-width layer from resulting picture
		CGContextSetTextMatrix(localContext, CGAffineTransformMakeScale(1.f, -1.f));
		CGContextSetTextPosition(localContext, 0, ascent);
		CGContextSetTextDrawingMode(localContext, kCGTextFillStroke);
		CTLineDraw(lineOfText, localContext);
	}];
	
	CGImageRef cutOffRef = CGImageCreateWithMask([self blackSquareOfSize:textBounds.size].CGImage, mask);
	CGImageRelease(mask);
	UIImage *cutOff = [UIImage imageWithCGImage:cutOffRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
	CGImageRelease(cutOffRef);
	
	CGImageRef shadedMaskRef = [self createMaskWithSize:textSize shape:^{
		CGContextRef localContext = UIGraphicsGetCurrentContext();
		[[UIColor whiteColor] setFill];
		CGContextFillRect(localContext, textBounds);
		CGContextSetShadowWithColor(localContext, innerShadowOffset_, innerShadowBlur_, [[UIColor colorWithWhite:0 alpha:1.0f] CGColor]);
		[cutOff drawAtPoint:CGPointZero];
	}];
	
		// Creating innerShadowColor negative image
	UIGraphicsBeginImageContextWithOptions(textSize, NO, 0);
	[[UIColor blackColor] setFill];
	CGContextRef localContext = UIGraphicsGetCurrentContext();
	
	[innerShadowColor_ setFill];
	CGContextSetTextMatrix(localContext, CGAffineTransformMakeScale(1.f, -1.f));
	CGContextSetTextPosition(localContext, 0, ascent);
	CGContextSetTextDrawingMode(localContext, kCGTextFill);
	CTLineDraw(lineOfText, localContext);
	
	UIImage *negative = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CGImageRef innerShadowRef = CGImageCreateWithMask(negative.CGImage, shadedMaskRef);
	CGImageRelease(shadedMaskRef);
	UIImage *innerShadow = [UIImage imageWithCGImage:innerShadowRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
	CGImageRelease(innerShadowRef);
	
		// Apply shadow
	[innerShadow drawAtPoint:textPoint];
	
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect
{
	CTLineRef lineOfText = self.lineOfText;
	if (!lineOfText) { return; }
	
	CGRect  textFrame = CGRectZero;
	CGFloat descent = 0.f;
	textFrame.size	 = [self textSizeAscent:NULL descent:&descent];
	textFrame.origin = [self textFrameOriginWithSize:textFrame.size];
	
		// Calculating textFrame with shadow
	CGRect textFrameWithShadow = textFrame;
	if (shadowColor_)
	{
		CGRect shadowFrame;
		shadowFrame = CGRectOffset(textFrame, shadowOffset_.width, shadowOffset_.height);
		shadowFrame	= CGRectInset(shadowFrame, -shadowBlur_, -shadowBlur_);
		textFrameWithShadow = CGRectUnion(textFrame, shadowFrame);
	}
	
	if (CGRectIntersectsRect(rect, textFrameWithShadow))
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSaveGState(context);
		
			// Prepare context for shadow if necessary
		if (shadowColor_) {
			CGContextBeginTransparencyLayer(context, NULL);
			CGContextSetShadowWithColor(context, shadowOffset_, shadowBlur_, [shadowColor_ CGColor]);
		}
		
			// Draw text image with gradient
		CGPoint textPoint = (CGPoint) { textFrame.origin.x, (textFrame.origin.y + descent) };
		[[self gradTextImage] drawAtPoint:textPoint];
		
			// Draw shadow
		if (shadowColor_){
			CGContextEndTransparencyLayer(context);
		}
		
			// Drawing Inner shadow
		if (innerShadowColor_) {
			[self drawInnerShadowInContext:context atPoint:textPoint];
		}
		
			// Draw frame around text
		if ( frameColor_ && frameWidth_ )
		{
			[frameColor_ setStroke];
			CGContextSetLineWidth(context, frameWidth_);
			CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.f, -1.f));
			CGContextSetTextPosition(context, textFrame.origin.x, CGRectGetMaxY(textFrame));
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CTLineDraw(lineOfText, context);
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
	CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorFromContextAttributeName };
	CFTypeRef values[] = { fontForDrawing,		 kCFBooleanTrue };
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

- (CGImageRef)textMask
{
	if (textMask_) { return textMask_; }
	
	CGContextRef mainContext = UIGraphicsGetCurrentContext();
	
	CGRect textFrame = CGRectZero;
	textFrame.size = (CTLineGetImageBounds([self lineOfText], mainContext)).size;

	UIGraphicsBeginImageContextWithOptions(textFrame.size, YES, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
//	[[UIColor blackColor] setFill];
	CGContextFillRect(context, textFrame);

	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.f, 1.f));
	CGContextSetTextDrawingMode(context, kCGTextFillStrokeClip);
	CGContextSetTextPosition(context, 0.f, 0.f);

	[[UIColor whiteColor] setFill];
	[[UIColor whiteColor] setStroke];
	CTLineDraw([self lineOfText], context);
	
	textMask_ = CGBitmapContextCreateImage(context);

	UIGraphicsEndImageContext();
	
	return textMask_;
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
		
		truncatedText_ = [[NSString stringWithString:truncatedString] retain];
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
//	self.g
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
