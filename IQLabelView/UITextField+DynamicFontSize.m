//
//  UITextField+DynamicFontSize.m
//  Created by kcandr on 16/12/14.

#import <Foundation/Foundation.h>
#import "UITextField+DynamicFontSize.h"
#import "IQLabelView.h"

@implementation UITextField (DynamicFontSize)

static const NSUInteger IQLVMaximumFontSize = 160;
static const NSUInteger IQLVMinimumFontSize = 20.0;

- (void)adjustsFontSizeToFillRect:(CGRect)newBounds
{
    NSString *text = (![self.text isEqualToString:@""] || !self.placeholder) ? self.text : self.placeholder;
    
    for (NSUInteger i = IQLVMaximumFontSize; i > IQLVMinimumFontSize; i--) {
        UIFont *font = [UIFont fontWithName:self.font.fontName size:(CGFloat)i];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                             attributes:@{ NSFontAttributeName : font }];
        
        CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(CGRectGetWidth(newBounds)-24, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
        
        if (CGRectGetHeight(rectSize) <= CGRectGetHeight(newBounds)) {
            ((IQLabelView *)self.superview).fontSize = (CGFloat)i-2;
            break;
        }
    }
}

- (void)adjustsWidthToFillItsContentsWithMinumWidth: (CGFloat) minWidth andNeedCustomBackGround: (BOOL) needCustomBackground andString : (NSString*) currentString
{
    
    
    //    CGSize newSize = [self intrinsicContentSize : currentString];
    //
    //    NSLog(@"%@", NSStringFromCGSize([self intrinsicContentSize : currentString]));
    //
    //    CGRect viewFrame = self.superview.bounds;
    //        viewFrame.size.width = newSize.width + 30;
    //        viewFrame.size.height = newSize.height  + 60.0;
    //
    //        if (needCustomBackground) {
    //            self.background = [[UIImage imageNamed:@"IQLabelView.bundle/text_form_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(24, 20, 24, 20)];
    //        }
    //
    //    NSLog(@"New width = %f",  viewFrame.size.width);
    //
    //    self.superview.bounds = viewFrame;
    
    NSString *currentText = [NSString stringWithFormat: @"%@%@", self.text, currentString];
    
    if ([self.text isEqualToString:@""] && currentString.length > 0) {
        currentText = currentString;
    }
    
    NSString *text = (![currentText isEqualToString:@""] || !self.placeholder) ? currentText : self.placeholder;
    
    UIFont *font = [UIFont fontWithName:self.font.fontName size: self.font.pointSize];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{ NSFontAttributeName : font }];
    
    CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame)-24)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    
    if (needCustomBackground) {
        self.background = [[UIImage imageNamed:@"IQLabelView.bundle/text_form_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(24, 20, 24, 20)];
    }
    
    CGRect viewFrame = self.superview.bounds;
    viewFrame.size.width = ceilf(rectSize.size.width) + 30;
    viewFrame.size.height = ceilf(rectSize.size.height) + 50;
    
    self.superview.bounds = viewFrame;
}

-(CGSize) intrinsicContentSize : (NSString*) currentString {
    if (self.editing) {
        
        NSString *currentText = [NSString stringWithFormat: @"%@%@", self.text, currentString];
        
        if ([self.text isEqualToString:@""] && currentString.length > 0) {
            currentText = currentString;
        }
        
        UIFont *font = [UIFont fontWithName:self.font.fontName size: self.font.pointSize];
        
        NSString *text = (![currentText isEqualToString:@""] || !self.placeholder) ? currentText : self.placeholder;
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                             attributes:@{ NSFontAttributeName : font }];
        
        
        return [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame)-30)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
    } else {
        return [super intrinsicContentSize];
    }
}


@end