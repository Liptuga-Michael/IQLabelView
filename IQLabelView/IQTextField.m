//
//  IQTextField.m
//  IQLabelViewDemo
//
//  Created by User on 04.07.16.
//
//

#import "IQTextField.h"

@implementation IQTextField


// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.leftTextIndent, bounds.origin.y, bounds.size.width - self.rightTextIndent, bounds.size.height);
    //return CGRectInset(bounds, 10, 0);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.leftTextIndent, bounds.origin.y, bounds.size.width - self.rightTextIndent, bounds.size.height);
    //return CGRectInset(bounds, 10, 0);
}


@end
