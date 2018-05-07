//
//  ZXRegTextField.h
//  ZXRegTextField
//
//  Created by screson on 2018/5/7.
//  Copyright © 2018年 screson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZXRegTextFieldTypeNone      =   0,
    ZXRegTextFieldTypeNumber    =   1,
    ZXRegTextFieldTypeMobile,
    ZXRegTextFieldTypeAlphabet,
    ZXRegTextFieldTypeChars,
    ZXRegTextFieldTypeCustom
} ZXRegTextFieldType;

@protocol ZXRegTextFieldDelegate <NSObject>

@optional

- (void)zxRegTextFieldDidReachTheMaxLength:(UITextField *)textFiled;
- (void)zxRegTextField:(UITextField *)textFiled reachedTheMinLength:(BOOL)reached;

@end

IB_DESIGNABLE
@interface ZXRegTextField : UITextField

@property (nonatomic,assign) IBInspectable NSInteger maxLength;
@property (nonatomic,assign) IBInspectable NSInteger minLength;
@property (nonatomic,strong) IBInspectable NSString * customRegString;
@property (nonatomic,assign) IBInspectable BOOL  canCopyPaste;
@property (nonatomic,assign) ZXRegTextFieldType zxType;
@property (nonatomic,weak) id<ZXRegTextFieldDelegate> zxdelegate;

- (void)setLeftOffset:(CGFloat)offset color:(UIColor *) color;
- (void)setPlaceHolderColor:(UIColor *)color;

@end
