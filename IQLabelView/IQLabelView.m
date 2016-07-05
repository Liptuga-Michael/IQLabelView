//
//  IQLabelView.m
//  Created by kcandr on 17/12/14. Modified Liptuga-Michael

#import "IQLabelView.h"
#import <QuartzCore/QuartzCore.h>
#import "UITextField+DynamicFontSize.h"
#import "IQTextField.h"

CG_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2)
{
    CGFloat fx = (point2.x - point1.x);
    CGFloat fy = (point2.y - point1.y);
    
    return sqrt((fx*fx + fy*fy));
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t)
{
    return atan2(t.b, t.a);
}


CG_INLINE CGSize CGAffineTransformGetScale(CGAffineTransform t)
{
    return CGSizeMake(sqrt(t.a * t.a + t.c * t.c), sqrt(t.b * t.b + t.d * t.d)) ;
}

static IQLabelView *lastTouchedView;

@interface IQLabelView () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@end

@implementation IQLabelView
{
    CGFloat globalInset;

    CGRect initialBounds;
    CGFloat initialDistance;

    CGPoint beginningPoint;
    CGPoint beginningCenter;

    CGPoint touchLocation;
    
    CGFloat deltaAngle;
    CGRect beginBounds;
    
    CAShapeLayer *border;
    IQTextField *labelTextField;
    UIImageView *rotateView;
    UIImageView *closeView;
    
    BOOL isShowingEditingHandles;
}

@synthesize textColor, borderColor;
@synthesize fontName, fontSize;
@synthesize enableClose, enableRotate, enableMoveRestriction, showsContentShadow;
@synthesize delegate;
@synthesize closeImage, rotateImage;

- (void)refresh
{
    if (self.superview) {
        CGSize scale = CGAffineTransformGetScale(self.superview.transform);
        CGAffineTransform t = CGAffineTransformMakeScale(scale.width, scale.height);
        [closeView setTransform:CGAffineTransformInvert(t)];
        [rotateView setTransform:CGAffineTransformInvert(t)];
        
        if (isShowingEditingHandles) {
            if (!self.needToMakeCustomBackground) {
                [labelTextField.layer addSublayer:border];
            } else {
                //labelTextField.background = [[UIImage imageNamed:@"IQLabelView.bundle/text_form_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(24, 20, 24, 20)];
            }
        } else {
            if (!self.needToMakeCustomBackground) {
                [border removeFromSuperlayer];
            } else {
                labelTextField.background = nil;
            }
        }
    }
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self refresh];
}

- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    [self refresh];
}

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.width < 25)     frame.size.width = 25;
    if (frame.size.height < 25)    frame.size.height = 25;
    
    self = [super initWithFrame:frame];
    if (self) {
        globalInset = 12;
        
        self.backgroundColor = [UIColor clearColor];
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        
        if (!self.needToMakeCustomBackground) {
            borderColor = [UIColor redColor];
        }
        
        labelTextField = [[IQTextField alloc] initWithFrame:CGRectInset(self.bounds, globalInset, globalInset)];
        [labelTextField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [labelTextField setClipsToBounds:YES];
        labelTextField.delegate = self;
        labelTextField.backgroundColor = [UIColor clearColor];
        labelTextField.tintColor = [UIColor redColor];
        labelTextField.textColor = [UIColor whiteColor];
        labelTextField.text = @"";
        labelTextField.leftTextIndent = 14.0;
        labelTextField.rightTextIndent = 14.0;
        
        if (!self.needToMakeCustomBackground) {
            border = [CAShapeLayer layer];
            border.strokeColor = borderColor.CGColor;
            border.fillColor = nil;
            border.lineDashPattern = @[@4, @3];
        }
        
        [self insertSubview:labelTextField atIndex:0];
        
        closeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, globalInset * 2, globalInset * 2)];
        [closeView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin)];
        closeView.backgroundColor = [UIColor whiteColor];
        closeView.layer.cornerRadius = globalInset - 5;
        closeView.userInteractionEnabled = YES;
        [self addSubview:closeView];
        
        rotateView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-globalInset*2 + 5, self.bounds.size.height-globalInset*2 + 5, globalInset*2 + 10, globalInset*2 + 10)];
        [rotateView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin)];
        rotateView.backgroundColor = [UIColor clearColor];
        rotateView.layer.cornerRadius = globalInset;
        rotateView.contentMode = UIViewContentModeCenter;
        rotateView.userInteractionEnabled = YES;
        
        [self addSubview:rotateView];        
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UITapGestureRecognizer *singleTapShowHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)];
        [self addGestureRecognizer:singleTapShowHide];
        
        UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
        [closeView addGestureRecognizer:closeTap];
        
        UIPanGestureRecognizer *panRotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewPanGesture:)];
        
        [rotateView addGestureRecognizer:panRotateGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeLabelViewSizePinchGesture:)];
        
        [labelTextField addGestureRecognizer:pinchGesture];
        
        [moveGesture requireGestureRecognizerToFail:closeTap];
        
        [self setEnableMoveRestriction:NO];
        [self setEnableClose:YES];
        [self setEnableRotate:YES];
        [self setShowsContentShadow:YES];
        [self setCloseImage:[UIImage imageNamed:@"IQLabelView.bundle/sticker_close.png"]];
        [self setRotateImage:[UIImage imageNamed:@"IQLabelView.bundle/rotate_point.png"]];
        
        [self showEditingHandles];
        [labelTextField becomeFirstResponder];
     }
    return self;
}

- (void)layoutSubviews
{
    if (labelTextField) {
        if (!self.needToMakeCustomBackground) {
            border.path = [UIBezierPath bezierPathWithRect:labelTextField.bounds].CGPath;
            border.frame = labelTextField.bounds;
            return;
        }
    }
}

#pragma mark - Set Control Buttons

- (void)setEnableClose:(BOOL)value
{
    enableClose = value;
    [closeView setHidden:!enableClose];
    [closeView setUserInteractionEnabled:enableClose];
}

- (void)setEnableRotate:(BOOL)value
{
    enableRotate = value;
    [rotateView setHidden:!enableRotate];
    [rotateView setUserInteractionEnabled:enableRotate];
}

- (void)setShowsContentShadow:(BOOL)showShadow
{
    showsContentShadow = showShadow;
    
    if (showsContentShadow) {
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0, 5)];
        [self.layer setShadowOpacity:1.0];
        [self.layer setShadowRadius:4.0];
    } else {
        [self.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.layer setShadowOffset:CGSizeZero];
        [self.layer setShadowOpacity:0.0];
        [self.layer setShadowRadius:0.0];
    }
}

- (void)setCloseImage:(UIImage *)image
{
    closeImage = image;
    [closeView setImage:closeImage];
}

- (void)setRotateImage:(UIImage *)image
{
    rotateImage = image;
    rotateView.contentMode = UIViewContentModeScaleAspectFit;
    [rotateView setImage:rotateImage];
}

#pragma mark - Set Text Field

- (void)setFontName:(NSString *)name
{
    fontName = name;
    labelTextField.font = [UIFont fontWithName:fontName size:fontSize];
    [labelTextField adjustsWidthToFillItsContentsWithMinumWidth:self.minimumWidth andNeedCustomBackGround:self.needToMakeCustomBackground];
}

- (void)setFontSize:(CGFloat)size
{
    fontSize = size;
    labelTextField.font = [UIFont fontWithName:fontName size:fontSize];
}

- (void)setTextColor:(UIColor *)color
{
    textColor = color;
    labelTextField.textColor = textColor;
}

- (void)setBorderColor:(UIColor *)color
{
    borderColor = color;
    border.strokeColor = borderColor.CGColor;
}

- (void)setTextAlpha:(CGFloat)alpha
{
    labelTextField.alpha = alpha;
}

- (CGFloat)textAlpha
{
    return labelTextField.alpha;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    [labelTextField setAttributedPlaceholder:attributedPlaceholder];
    [labelTextField adjustsWidthToFillItsContentsWithMinumWidth:self.minimumWidth andNeedCustomBackGround:self.needToMakeCustomBackground];
}

#pragma mark - Bounds

- (void)hideEditingHandles
{
    
    isShowingEditingHandles = NO;
    
    if (enableClose)       closeView.hidden = YES;
    if (enableRotate)      rotateView.hidden = YES;
    
    [labelTextField resignFirstResponder];
    
    [self refresh];
    
    lastTouchedView = nil;
    
    [delegate labelViewDidEndEditing:self];
}

- (void)showEditingHandles
{
    if (lastTouchedView != nil) {
         [lastTouchedView hideEditingHandles];
    }
    
    isShowingEditingHandles = YES;
    
    lastTouchedView = self;
    
    if (enableClose)       closeView.hidden = NO;
    if (enableRotate)      rotateView.hidden = NO;
    
    [self refresh];
    [labelTextField adjustsWidthToFillItsContentsWithMinumWidth: self.minimumWidth andNeedCustomBackGround: self.needToMakeCustomBackground];

    [delegate labelViewDidBeginEditing:self];
}

#pragma mark - Gestures

- (void)contentTapped:(UITapGestureRecognizer*)tapGesture
{
    if (isShowingEditingHandles) {
        [self hideEditingHandles];
        [self.superview bringSubviewToFront:self];
    } else {
        [self showEditingHandles];
    }
}

- (void)closeTap:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
    
    if([delegate respondsToSelector:@selector(labelViewDidClose:)]) {
        [delegate labelViewDidClose:self];
    }
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (!isShowingEditingHandles) {
        [self showEditingHandles];
    }
    touchLocation = [recognizer locationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        beginningPoint = touchLocation;
        beginningCenter = self.center;
        
        [self setCenter:[self estimatedCenter]];
        beginBounds = self.bounds;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self setCenter:[self estimatedCenter]];
        [delegate labelViewStartMoving:self];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self setCenter:[self estimatedCenter]];
        [delegate labelViewEndMoving:self];
    }
}

- (CGPoint)estimatedCenter
{
    CGPoint newCenter;
    CGFloat newCenterX = beginningCenter.x + (touchLocation.x - beginningPoint.x);
    CGFloat newCenterY = beginningCenter.y + (touchLocation.y - beginningPoint.y);
    if (enableMoveRestriction) {
        if (!(newCenterX - 0.5 * CGRectGetWidth(self.frame) > 0 &&
            newCenterX + 0.5 * CGRectGetWidth(self.frame) < CGRectGetWidth(self.superview.bounds))) {
             newCenterX = self.center.x;
        }
        if (!(newCenterY - 0.5 * CGRectGetHeight(self.frame) > 0 &&
            newCenterY + 0.5 * CGRectGetHeight(self.frame) < CGRectGetHeight(self.superview.bounds))) {
            newCenterY = self.center.y;
        }
        newCenter = CGPointMake(newCenterX, newCenterY);
    } else {
        newCenter = CGPointMake(newCenterX, newCenterY);
    }
    return newCenter;
}

- (void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self.superview];
    
    CGPoint center = CGRectGetCenter(self.frame);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        deltaAngle = atan2(touchLocation.y-center.y, touchLocation.x-center.x)-CGAffineTransformGetAngle(self.transform);
        
        initialBounds = self.bounds;
        initialDistance = CGPointGetDistance(center, touchLocation);
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        float ang = atan2(touchLocation.y-center.y, touchLocation.x-center.x);
        
        float angleDiff = deltaAngle - ang;
        [self setTransform:CGAffineTransformMakeRotation(-angleDiff)];
        [self setNeedsDisplay];
        [delegate labelViewStartRotating: self];
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        [delegate labelViewStopRotating: self];
    }
    [labelTextField adjustsWidthToFillItsContentsWithMinumWidth:self.minimumWidth andNeedCustomBackGround: self.needToMakeCustomBackground];
}


- (void) changeLabelViewSizePinchGesture : (UIPinchGestureRecognizer*) recognizer {
    if ((recognizer.state == UIGestureRecognizerStateEnded
        || recognizer.state == UIGestureRecognizerStateChanged) && rotateView.hidden == NO) {
        
        CGFloat currentFontSize = labelTextField.font.pointSize;
        CGFloat newScale = currentFontSize * recognizer.scale;
        
        if (newScale < 10.0) {
            newScale = 10.0;
        }
        if (newScale > 60.0) {
            newScale = 60.0;
        }
        
        labelTextField.font = [UIFont fontWithName:labelTextField.font.fontName size:newScale];
        [labelTextField adjustsWidthToFillItsContentsWithMinumWidth:self.minimumWidth andNeedCustomBackGround: self.needToMakeCustomBackground];
        recognizer.scale = 1;
        
        
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            [delegate labelViewStartZooming :self];
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [delegate labelViewEndZooming :self];
        }
    }
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        rotateView.hidden = YES;
    }

    if (isShowingEditingHandles) {
        return YES;
    }
    [self contentTapped:nil];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([delegate respondsToSelector:@selector(labelViewDidStartEditing:)]) {
        [delegate labelViewDidStartEditing:self];
    }
    
    [textField adjustsWidthToFillItsContentsWithMinumWidth: self.minimumWidth andNeedCustomBackGround: self.needToMakeCustomBackground];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!isShowingEditingHandles) {
        [self showEditingHandles];
    }
    
    if (textField.text.length == 1 && [string isEqualToString:@""]) {
        labelTextField.text = @"";
        rotateView.hidden = YES;
        NSLog(@"press Backspace.");
    } else {
        rotateView.hidden = NO;
    }

    [textField adjustsWidthToFillItsContentsWithMinumWidth: self.minimumWidth andNeedCustomBackGround: self.needToMakeCustomBackground];
    [delegate labelDidEditing: self];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}


@end
