//
//  RevealingCell.m
//  RevealingTableView
//
//  Created by aptiva on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RevealingCell.h"
#import <QuartzCore/QuartzCore.h>

@interface RevealingCell()

@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;


@property (nonatomic, assign) CGFloat initialTouchPositionX;
@property (nonatomic, assign) CGFloat initialHorizontalCenter;

- (CGFloat)originalCenter;

//- (void)setupGestureRecognizers;
- (void)panCell:(UIPanGestureRecognizer *)recognizer;

@end

@implementation RevealingCell

@synthesize delegate = _delegate;
@synthesize panGesture = _panGesture;
@synthesize backView = _backView;
@synthesize initialTouchPositionX = _initialTouchPositionX;
@synthesize initialHorizontalCenter = _initialHorizontalCenter;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        UIView *backgroundView         = [[UIView alloc] initWithFrame:self.contentView.frame];
		backgroundView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
		self.backView                  = backgroundView;
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)] ;
        _panGesture.delegate = self;
		[self addGestureRecognizer:_panGesture];
//            [self setupGestureRecognizers];
    }
    return self;
}
/*
- (void)dealloc
{
	self.panGesture = nil;
	self.backView    = nil;
	[super dealloc];
}
 */


- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self addSubview:self.backView];
	[self addSubview:self.contentView];
	self.backView.frame = self.contentView.frame;
}



/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

//- (void)setupGestureRecognizers
//{
//#ifdef DEBUG
//	NSLog(@">>>>>>%s", __FUNCTION__);
//#endif
//
//    // Setup a right swipe gesture recognizer
//    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
//    panGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:panGestureRecognizer];
//    
//}


- (void)panCell:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation           = [recognizer translationInView:self];
	CGPoint currentTouchPoint     = [recognizer locationInView:self];
//	CGPoint velocity              = [recognizer velocityInView:self];
    
    CGFloat originalCenter        = self.originalCenter;
	CGFloat currentTouchPositionX = currentTouchPoint.x;
	CGFloat panAmount             = self.initialTouchPositionX - currentTouchPositionX;
	CGFloat newCenterPosition     = self.initialHorizontalCenter - panAmount;
//	CGFloat centerX               = self.contentView.center.x;

    
//    NSLog(@"currentTouchPoint:%@|translation:%@|velocity:%@",NSStringFromCGPoint(currentTouchPoint),NSStringFromCGPoint(translation),NSStringFromCGPoint(velocity));

    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
		// Set a baseline for the panning        
		self.initialTouchPositionX = currentTouchPositionX;
		self.initialHorizontalCenter = self.contentView.center.x;
        
        if ([self.delegate respondsToSelector:@selector(cellDidBeginPan:)])
			[self.delegate cellDidBeginPan:self];

        
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"panAmount:%f",panAmount);
        NSLog(@"currentTouchPositionX:%f",currentTouchPositionX);
        NSLog(@"translation :%@",NSStringFromCGPoint(translation));
        BOOL rtlVal = panAmount > 0;
        rtlVal |= self.initialTouchPositionX > self.bounds.size.width*0.8;
//        rtlVal |= -panAmount > 80;
        if (rtlVal) return;
        
                   
        if (panAmount < 0 && self.initialTouchPositionX < self.bounds.size.width*0.8) {
            // swipe right
             NSLog(@"->->");
            
#define KenMaxPanWidth  80.0
            
            if (-1.0 * panAmount > KenMaxPanWidth) {
                return;
            }
            
            if (newCenterPosition < originalCenter) {
                newCenterPosition = originalCenter;
            }
            
            // Don't let you drag past a certain point depending on direction
            CGPoint center = self.contentView.center;
            center.x = newCenterPosition;
            // Let's not go waaay out of bounds
            if (newCenterPosition > self.bounds.size.width + originalCenter)
                newCenterPosition = self.bounds.size.width + originalCenter;
            else if (newCenterPosition < -originalCenter)
                newCenterPosition = -originalCenter;
            
            
//            self.contentView.layer.position = center;
            self.contentView.center = center;

            
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"Ended");
        
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction 
                         animations:^{ self.contentView.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.center.y); } 
                         completion:^(BOOL f) {

                         }];
        
    }
}


- (CGFloat)originalCenter
{
	return ceil(self.bounds.size.width / 2);
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == self.panGesture) {
		UIScrollView *superview = (UIScrollView *)self.superview;
		CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:superview];
		
		// Make sure it is scrolling horizontally
		return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
	}
	return NO;
}


@end
