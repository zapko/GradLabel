//
//  ZBGradLabel.m
//
//  Created by Konstantin Zabelin on 28.01.11.
//  Copyright 2015 Studio "Zababako". All rights reserved.
//

#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

#import "ZBGradLabel.h"



static NSString *kKVOContext = @"GradLabel KVO Context";

static NSSet *propertiesThatResetTruncatedText;
static NSSet *propertiesThatResetLineOfText;
static NSSet *propertiesThatResetGradTextImage;
static NSSet *propertiesThatResetInnerShadow;
static NSSet *propertiesThatResetGradient;
static NSSet *propertiesThatSetNeedsDisplay;



@interface ZBGradLabel()

@property (nonatomic, retain)	NSString *truncatedText;
@property (nonatomic, readonly) CTLineRef lineOfText; // retain

@property (nonatomic, readonly) CGGradientRef gradient;	  // retain
@property (nonatomic, retain)	UIImage		 *gradTextImage;

@property (nonatomic, retain)	UIImage	*innerShadow;

@end



@implementation ZBGradLabel

@synthesize text		  = _text;
@synthesize truncatedText = _truncatedText;

@synthesize gradient	  = _gradient;
@synthesize lineOfText	  = _lineOfText;
@synthesize gradTextImage = _gradTextImage;
@synthesize innerShadow	  = _innerShadow;

@synthesize font			  = _font;
@synthesize textAlignment	  =	_textAlignment;
@synthesize verticalAlignment = _verticalAlignment;
@synthesize horizontalMargin  =	_horizontalMargin;
@synthesize verticalMargin	  = _verticalMargin;

@synthesize startColor = _startColor;
@synthesize endColor   = _endColor;
@synthesize gradVector = _gradVector;

@synthesize shadowBlur	 = _shadowBlur;
@synthesize shadowColor	 = _shadowColor;
@synthesize shadowOffset = _shadowOffset;

@synthesize innerShadowColor  = _innerShadowColor;
@synthesize innerShadowBlur	  = _innerShadowBlur;
@synthesize innerShadowOffset = _innerShadowOffset;

@synthesize strokeWidth = _strokeWidth;
@synthesize strokeColor = _strokeColor;

@synthesize lineBreakMode = _lineBreakMode;


#pragma mark -
#pragma mark Lifecircle

+ (void)initialize
{
	[super initialize];
	
	propertiesThatResetTruncatedText = [[NSSet alloc] initWithObjects:@"text", @"lineBreakMode", nil];
	propertiesThatResetLineOfText	 = [[NSSet alloc] initWithObjects:@"text", @"font", @"lineBreakMode", nil ];
	propertiesThatResetGradTextImage = [[NSSet alloc] initWithObjects:@"text", @"font", @"gradVector", @"startColor", @"endColor", @"lineBreakMode", nil];
	propertiesThatResetInnerShadow	 = [[NSSet alloc] initWithObjects:@"text", @"font", @"innerShadowColor", @"innerShadowOffset", @"innerShadowBlur", @"lineBreakMode", nil];
	propertiesThatResetGradient		 = [[NSSet alloc] initWithObjects:@"gradVector", @"startColor", @"endColor", nil];

	propertiesThatSetNeedsDisplay	 = [[NSSet alloc] initWithObjects:@"text", @"font",
																	  @"textAlignment", @"verticalAlignment", @"horizontalMargin", @"verticalMargin",
																	  @"gradVector", @"startColor", @"endColor",
																	  @"shadowColor", @"shadowOffset", @"shadowBlur",
																	  @"innerShadowColor", @"innerShadowOffset", @"innerShadowBlur",
																	  @"frameColor", @"frameWidth", @"lineBreakMode", nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self) { return nil; }
	
	[self configure];
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) { return nil; }

	[self configure];

	return self;
}

- (void)configure
{
	self.font		= [UIFont  systemFontOfSize:self.bounds.size.height];
	self.startColor = [UIColor redColor];
	self.endColor	= [UIColor blueColor];
	self.gradVector = (CGRect) { { 0.f, 0.f }, { 0.f, 1.f } };
	
	[self setContentMode:UIViewContentModeRedraw];
	
	_lineBreakMode = UILineBreakModeWordWrap;
	
#if !TARGET_INTERFACE_BUILDER
	for (NSString *propertyKeyPath in propertiesThatSetNeedsDisplay) {
		[self addObserver:self forKeyPath:propertyKeyPath options:0 context:&kKVOContext];
	}
#endif
}

- (void)dealloc 
{
	self.text = nil;
	self.font = nil;
	
	CGGradientRelease(_gradient);
	self.lineOfText	   = nil;
	self.truncatedText = nil;
	self.gradTextImage = nil;
	self.innerShadow   = nil;
	
	self.startColor = nil;
	self.endColor	= nil;
	
    self.shadowColor      = nil;
    self.innerShadowColor = nil;
    self.strokeColor      = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Drawing

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
	if (_shadowColor)
	{
		CGRect shadowFrame;
		shadowFrame = CGRectOffset(textFrame, _shadowOffset.width, _shadowOffset.height);
		shadowFrame	= CGRectInset(shadowFrame, -_shadowBlur, -_shadowBlur);
		textFrameWithShadow = CGRectUnion(textFrame, shadowFrame);
	}
	
	if (CGRectIntersectsRect(rect, textFrameWithShadow))
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSaveGState(context);
		
			// Prepare context for shadow if necessary
		if (_shadowColor) {
			CGContextBeginTransparencyLayer(context, NULL);
			CGContextSetShadowWithColor(context, _shadowOffset, _shadowBlur, [_shadowColor CGColor]);
		}
		
			// Draw text image with gradient
		CGPoint textPoint = (CGPoint) { textFrame.origin.x, (textFrame.origin.y + descent) };
		[self.gradTextImage drawAtPoint:textPoint];

			// Draw shadow
		if (_shadowColor){
			CGContextEndTransparencyLayer(context);
		}
		
			// Drawing Inner shadow
		if (_innerShadowColor) {
			[self.innerShadow drawAtPoint:textPoint];
		}
		
			// Drawing text stroke
		if ( _strokeColor && _strokeWidth )
		{
			[_strokeColor setStroke];
			CGContextSetLineWidth(context, _strokeWidth);
			CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.f, -1.f));
			CGContextSetTextPosition(context, textFrame.origin.x, CGRectGetMaxY(textFrame));
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CTLineDraw(lineOfText, context);
		}
		
		CGContextRestoreGState(context);
	}
}


#pragma mark Elements on Demand

- (UIImage *)gradTextImage
{
	if (_gradTextImage) { return _gradTextImage; }
	
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
	
	_gradTextImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [_gradTextImage retain];
}

- (UIImage *)innerShadow
{
	if (_innerShadow) { return _innerShadow; }
	
	CTLineRef lineOfText = self.lineOfText;
	if (!lineOfText) { return nil; }
	
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
		CGContextSetShadowWithColor(localContext, _innerShadowOffset, _innerShadowBlur, [[UIColor colorWithWhite:0 alpha:1.0f] CGColor]);
		[cutOff drawAtPoint:CGPointZero];
	}];
	
		// Creating innerShadowColor negative image
	UIGraphicsBeginImageContextWithOptions(textSize, NO, 0);
	
	CGContextRef localContext = UIGraphicsGetCurrentContext();
	[_innerShadowColor setFill];
	CGContextSetTextMatrix(localContext, CGAffineTransformMakeScale(1.f, -1.f));
	CGContextSetTextPosition(localContext, 0, ascent);
	CGContextSetTextDrawingMode(localContext, kCGTextFill);
	CTLineDraw(lineOfText, localContext);
	UIImage *negative = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	CGImageRef innerShadowRef = CGImageCreateWithMask(negative.CGImage, shadedMaskRef);
	CGImageRelease(shadedMaskRef);
	_innerShadow = [UIImage imageWithCGImage:innerShadowRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
	CGImageRelease(innerShadowRef);
	
	return [_innerShadow retain];
}

- (CGGradientRef)gradient
{
	if (_gradient != NULL) { return _gradient; }

	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CFArrayRef colorArray = NULL;
	CGColorRef colors[2]  = { [_startColor CGColor], [_endColor CGColor] }; 
	colorArray = CFArrayCreate( kCFAllocatorDefault, (const void **)colors,	sizeof(colors)/sizeof(CGColorRef), &kCFTypeArrayCallBacks );
	_gradient = CGGradientCreateWithColors(rgb, colorArray, NULL);
	if (colorArray) { CFRelease(colorArray); }
	CGColorSpaceRelease(rgb);
	
	return _gradient;
}

- (void)setGradient:(CGGradientRef)gradient
{
	CGGradientRetain(gradient);
	CGGradientRelease(_gradient);
	_gradient = gradient;
}

- (CTLineRef)lineOfText
{
	if (!_text.length) { return nil; }
	if (_lineOfText)   { return _lineOfText; }

	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithNameAndSize((CFStringRef)[_font fontName], [_font pointSize]);
	if (!fontDescriptor) { return nil; }
		
	CTFontRef fontForDrawing = CTFontCreateWithFontDescriptor(fontDescriptor, [_font pointSize], NULL);
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
	_lineOfText = CTLineCreateWithAttributedString(attrString);
	CFRelease(fontForDrawing);
	CFRelease(attributes);
	CFRelease(attrString);
	
	return _lineOfText;
}

- (void)setLineOfText:(CTLineRef)lineOfText
{
	if (lineOfText)	 { CFRetain(lineOfText);   }
	if (_lineOfText) { CFRelease(_lineOfText); }
	_lineOfText = lineOfText;
}

- (NSString *)truncatedText
{
	if (_truncatedText) {
		return _truncatedText;
	}
		
	if( !( _lineBreakMode & ( UILineBreakModeHeadTruncation | UILineBreakModeMiddleTruncation | UILineBreakModeTailTruncation ) ) ) {
		_truncatedText = [_text retain];
		return _truncatedText;
	}
	
	CGSize size = self.bounds.size;
	if( [_text sizeWithFont: _font].width <= size.width ) {
		_truncatedText = [_text retain];
		return _truncatedText;
	}
	
	NSString *ellipsis = @"…";
	
	// Note that this code will find the first occurrence of any given anchor,
	// so be careful when choosing anchor characters/strings...
	NSInteger  start = 0;
	NSUInteger end	 = [_text length];
	
	NSUInteger targetLength = end - start;

	NSMutableString *truncatedString = [[NSMutableString alloc] initWithString: _text];
	
	switch(_lineBreakMode) {
		case UILineBreakModeHeadTruncation:
			while( targetLength > [ellipsis length] + 1 && [truncatedString sizeWithFont: _font].width > size.width) {
				// Replace our ellipsis and one additional following character with our ellipsis
				NSRange range = NSMakeRange( start, [ellipsis length] + 1 );
				[truncatedString replaceCharactersInRange: range withString: ellipsis];
				targetLength--;
			}
			break;
			
		case UILineBreakModeMiddleTruncation: {
			NSUInteger leftEnd = start + ( targetLength / 2 );
			NSUInteger rightStart = leftEnd + 1;
			
			if ( leftEnd + 1 <= rightStart - 1 )
				break;
			
			// leftPre and rightPost consist of any characters before and beyond
			// any specified anchor(s).
			// left and right are the two halves of the string to be truncated - although
			// the initial split is still performed based upon the length of the
			// (sub)string to be truncated, so we could still make a bad initial split given
			// a short string with predominantly narrow characters on one side and wide
			// characters on the other.
			NSString *leftPre = @"";
			NSMutableString *left  = [NSMutableString stringWithString: [truncatedString substringWithRange: NSMakeRange(start, leftEnd - start)]];
			NSMutableString *right = [NSMutableString stringWithString: [truncatedString substringWithRange: NSMakeRange( rightStart, end - rightStart )]];
			NSString *rightPost = @"";
			
			// Reassemble substrings
			[truncatedString setString: [NSString stringWithFormat: @"%@%@%@%@%@", leftPre, left, ellipsis, right, rightPost]];
			
			while( leftEnd > start + 1 && rightStart < end + 1 && [truncatedString sizeWithFont: _font].width > size.width) {
				CGFloat leftLength = [left sizeWithFont: _font].width;
				CGFloat rightLength = [right sizeWithFont: _font].width;
				
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
			while( targetLength > [ellipsis length] + 1 && [truncatedString sizeWithFont: _font].width > size.width) {
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
	
	_truncatedText = [[NSString stringWithString:truncatedString] retain];
	[truncatedString release];
	
	return _truncatedText;
}


#pragma mark Utilites

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

- (void)drawGradientInFrame:(CGRect)textFrame context:(CGContextRef)context
{
		//		Calculate start and end points for gradients
	CGPoint gradStartPoint = textFrame.origin;
	gradStartPoint.x += _gradVector.origin.x * textFrame.size.width;
	gradStartPoint.y += _gradVector.origin.y * textFrame.size.height;
	
	CGPoint gradEndPoint = gradStartPoint;
	gradEndPoint.x += _gradVector.size.width * textFrame.size.width;
	gradEndPoint.y += _gradVector.size.height * textFrame.size.height;
	
		//		Draw gradient
	CGContextDrawLinearGradient(context,
								self.gradient,
								gradStartPoint,
								gradEndPoint,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation );
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
	
	switch (_textAlignment)
	{
		case UITextAlignmentLeft:
			textFrameOrigin.x = _horizontalMargin;
			break;
		default:
		case UITextAlignmentCenter:
			textFrameOrigin.x = (selfBounds.size.width - textSize.width) / 2.0;
			break;
		case UITextAlignmentRight:
			textFrameOrigin.x = selfBounds.size.width - textSize.width - _horizontalMargin;
			break;
	}
	textFrameOrigin.y = _verticalAlignment ? (selfBounds.size.height - textSize.height) / 2.f : _verticalMargin;
	
	return textFrameOrigin;
}


#pragma mark -
#pragma mark Changing Appearance

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context != &kKVOContext) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
	if ([propertiesThatResetTruncatedText containsObject:keyPath]) { self.truncatedText = nil; }
	if ([propertiesThatResetLineOfText	  containsObject:keyPath]) { self.lineOfText	= nil; }
	if ([propertiesThatResetGradTextImage containsObject:keyPath]) { self.gradTextImage = nil; }
	if ([propertiesThatResetGradient	  containsObject:keyPath]) { self.gradient		= nil; }
	if ([propertiesThatResetInnerShadow   containsObject:keyPath]) { self.innerShadow	= nil; }

	[self setNeedsDisplay];
}

@end
