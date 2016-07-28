//
//  IQLabelView.h
//  Created by kcandr on 17/12/14.

#import <UIKit/UIKit.h>
#import "IQTextField.h"

@protocol IQLabelViewDelegate;

@interface IQLabelView : UIView


@property (nonatomic, strong) IQTextField *labelTextField;
/**
 * Text color.
 *
 * Default: white color.
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 * Border stroke color.
 *
 * Default: red color.
 */
@property (nonatomic, strong) UIColor *borderColor;
/**
 * Custom background for IQLabelView.
 */
@property (nonatomic, assign) BOOL needToMakeCustomBackground;
/**
 *Need to set minimum width for IQLabelView
 */
@property (nonatomic, assign) CGFloat minimumWidth;
/**
 * Name of text field font.
 *
 * Default: current system font
 */
@property (nonatomic, copy) NSString *fontName;

/**
 * Size of text field font.
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 * Minimum size of text field font.
 */
@property (nonatomic, assign) CGFloat minFontSize;
/**
 * Maximum size of text field font.
 */
@property (nonatomic, assign) CGFloat maxFontSize;

/**
 * Image for close button.
 *
 * Default: sticker_close.png from IQLabelView.bundle.
 */
@property (nonatomic, strong) UIImage *closeImage;

/**
 * Image for rotation button.
 *
 * Default: sticker_resize.png from IQLabelView.bundle.
 */
@property (nonatomic, strong) UIImage *rotateImage;

/**
 * Placeholder.
 *
 * Default: nil
 */
@property (nonatomic, copy) NSAttributedString *attributedPlaceholder;


@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) BOOL enableToEditing;

@property (nonatomic, assign) BOOL isAlreadyAdded;

@property (nonatomic, assign) BOOL isLabelTextFieldEmpty;

/*
 * Base delegate protocols.
 */
@property (nonatomic, weak) id <IQLabelViewDelegate> delegate;

/**
 *  Shows content shadow.
 *
 *  Default: YES.
 */
@property (nonatomic) BOOL showsContentShadow;

/**
 *  Shows close button.
 *
 *  Default: YES.
 */
@property (nonatomic, getter=isEnableClose) BOOL enableClose;

/**
 *  Shows rotate/resize butoon.
 *
 *  Default: YES.
 */
@property (nonatomic, getter=isEnableRotate) BOOL enableRotate;

/**
 *  Resticts movements in superview bounds.
 *
 *  Default: NO.
 */
@property (nonatomic, getter=isEnableMoveRestriction) BOOL enableMoveRestriction;

/**
 *  Hides border and control buttons.
 */
- (void)hideEditingHandles;

/**
 *  Shows border and control buttons.
 */
- (void)showEditingHandles;

/** Sets the text alpha.
 *
 * @param alpha     A value of text transparency.
 */
- (void)setTextAlpha:(CGFloat)alpha;

/** Returns text alpha.
 *
 * @return  A value of text transparency.
 */
- (CGFloat)textAlpha;








- (void)rotateViewPanGesture:(UIRotationGestureRecognizer *)recognizer;

//- (void)moveGesture:(UIPanGestureRecognizer *)recognizer;

- (void) changeLabelViewSizePinchGesture : (UIPinchGestureRecognizer*) recognizer;




@end

@protocol IQLabelViewDelegate <NSObject>

@optional

/**
 *  Occurs when a touch gesture event occurs on close button.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidClose:(IQLabelView *)label;

/**
 *  Occurs when border and control buttons was shown.
 *
 *  @param label    A label object informing the delegate about showing.
 */
- (void)labelViewDidShowEditingHandles:(IQLabelView *)label;

/**
 *  Occurs when border and control buttons was hidden.
 *
 *  @param label    A label object informing the delegate about hiding.
 */
- (void)labelViewDidHideEditingHandles:(IQLabelView *)label;

/**
 *  Occurs when label become first responder.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidStartEditing:(IQLabelView *)label;


/**
 *  Occurs when label continues move or rotate.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidChangeEditing:(IQLabelView *)label;



@required
- (void)labelViewBeganRotating:(IQLabelView*)label;
- (void)labelViewRotatingChanged: (IQLabelView*)label;
- (void)labelViewStopRotating:(IQLabelView*)label;

- (void)labelViewStartZooming: (IQLabelView*)label;
- (void)labelViewEndZooming: (IQLabelView*)label;

- (void)labelViewBeganMoving: (IQLabelView*)label currentLocation : (CGPoint) location;
- (void)labelViewMovingChanged: (IQLabelView*)label currentLocation : (CGPoint) location;
- (void)labelViewEndMoving: (IQLabelView*)label currentLocation : (CGPoint) location;

/**
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidEndEditing: (IQLabelView *)label;

- (void)labelDidEditing: (IQLabelView*)label;


/**
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidBeginEditing:(IQLabelView *)label;

@end

