//
//  ZXRegTextField.m
//  ZXRegTextField
//
//  Created by screson on 2018/5/7.
//  Copyright © 2018年 screson. All rights reserved.
//

#import "ZXRegTextField.h"
#define ZXNUMBERS   @"[0-9]*"
#define ZXALPHABET  @"[a-zA-Z]*"
#define ZXCHARS     @"[0-9a-zA-Z]*"

@interface ZXRegTextField ()
@property (nonatomic, strong) UIView * zxLeftView;
@property (nonatomic, strong) NSString * lastText;

@end

@implementation ZXRegTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialUI];
    }
    return self;
}


- (void)initialUI{
    self.lastText = nil;
    self.maxLength = 0;
    self.minLength = 0;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (BOOL)becomeFirstResponder {
    if (self.zxType != ZXRegTextFieldTypeNone) {
        [self loadNotifiaction];
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [self removeNotifiaction];
    return [super resignFirstResponder];
}


- (void)loadNotifiaction {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zxtextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)zxtextDidChange:(NSNotification *)notification {
    id textF = notification.object;
    if ([textF isKindOfClass:[UITextField class]] && textF == self) {
        NSString * text = self.text;
        if (text && [text length]) {
            if (_zxType == ZXRegTextFieldTypeNone) {
                if (_maxLength > 0) {
                    if (text.length == _maxLength) {
                        if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextFieldDidReachTheMaxLength:)]) {
                            [_zxdelegate zxRegTextFieldDidReachTheMaxLength:self];
                        }
                    } else if (text.length > _maxLength) {
                        self.text = [text substringToIndex:_maxLength];
                    }
                }
                if (_minLength > 0) {
                    if (text.length >= _minLength) {
                        if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                            [_zxdelegate zxRegTextField:self reachedTheMinLength:true];
                        }
                    } else {
                        if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                            [_zxdelegate zxRegTextField:self reachedTheMinLength:false];
                        }
                    }
                }
            } else {
                UITextRange * selectedRange = self.markedTextRange;
                //存在高亮
                if (selectedRange && [self positionFromPosition:selectedRange.start offset:0]) {
                    if (self.lastText) {
                        self.lastText = [self clearText:_lastText];
                    }
                    self.text = self.lastText;
                    if (_minLength > 0) {
                        if (text.length >= _minLength) {
                            if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                                [_zxdelegate zxRegTextField:self reachedTheMinLength:true];
                            }
                        } else {
                            if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                                [_zxdelegate zxRegTextField:self reachedTheMinLength:false];
                            }
                        }
                    }
                    return;
                }
                NSString * newText = text;
                if (self.lastText) {//输入框已有值
                    if (text.length > _lastText.length) {
                        newText = [text substringFromIndex:_lastText.length];
                    } else {
                        if (text && [text length]) {
                            self.lastText = newText;
                        } else {
                            self.lastText = nil;
                        }
                        if (_minLength > 0) {
                            if (text.length >= _minLength) {
                                if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                                    [_zxdelegate zxRegTextField:self reachedTheMinLength:true];
                                }
                            } else {
                                if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                                    [_zxdelegate zxRegTextField:self reachedTheMinLength:false];
                                }
                            }
                        }
                        return;
                    }
                }
                if (newText && [newText length]) {
                    switch (_zxType) {
                        case ZXRegTextFieldTypeNumber:
                        case ZXRegTextFieldTypeMobile:
                            {
                                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ZXNUMBERS];
                                if (![predicate evaluateWithObject:newText]) {
                                    self.text = _lastText;
                                } else {
                                    if (_zxType == ZXRegTextFieldTypeMobile && _lastText == nil && newText.length == 1 && ![newText isEqualToString:@"1"]) {
                                        self.text = nil;
                                        _lastText = nil;
                                    }
                                }
                            }
                            break;
                        case ZXRegTextFieldTypeAlphabet:
                        {
                            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ZXALPHABET];
                            if (![predicate evaluateWithObject:newText]) {
                                self.text = _lastText;
                            }
                        }
                            break;
                        case ZXRegTextFieldTypeChars:
                        {
                            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ZXCHARS];
                            if (![predicate evaluateWithObject:newText]) {
                                self.text = _lastText;
                            }
                        }
                            break;
                        case ZXRegTextFieldTypeCustom:
                        {
                            if (self.customRegString && self.customRegString.length) {
                                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",self.customRegString];
                                if (![predicate evaluateWithObject:newText]) {
                                    self.text = _lastText;
                                }
                            }
                        }
                            break;
                        default:
                            break;
                    }
                } else {
                    self.lastText = nil;
                }
                if (_maxLength > 0) {
                    if (text.length == _maxLength) {
                        if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextFieldDidReachTheMaxLength:)]) {
                            [_zxdelegate zxRegTextFieldDidReachTheMaxLength:self];
                        }
                    } else if (text.length > _maxLength) {
                        self.text = [text substringToIndex:_maxLength];
                    }
                }
                if (_minLength > 0) {
                    if (text.length >= _minLength) {
                        if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                            [_zxdelegate zxRegTextField:self reachedTheMinLength:true];
                        }
                    } else {
                        if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                            [_zxdelegate zxRegTextField:self reachedTheMinLength:false];
                        }
                    }
                }
                if (self.text && self.text.length) {
                    self.lastText = self.text;
                }
            }
        } else {
            self.lastText = nil;
            if (_minLength > 0) {
                if (text.length >= _minLength) {
                    if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                        [_zxdelegate zxRegTextField:self reachedTheMinLength:true];
                    }
                } else {
                    if (_zxdelegate && [_zxdelegate respondsToSelector:@selector(zxRegTextField:reachedTheMinLength:)]) {
                        [_zxdelegate zxRegTextField:self reachedTheMinLength:false];
                    }
                }
            }
        }
    }
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canCopyPaste;
}

- (void)paste:(id)sender {
    if (_zxType != ZXRegTextFieldTypeNone) {
        NSString * str = [UIPasteboard generalPasteboard].string;
        [[UIPasteboard generalPasteboard] setString:[self clearText:str]];
    }
    [super paste:sender];
}

- (NSString *)clearText:(NSString *)text {
    NSString * regularString = text;
    switch (_zxType) {
        case ZXRegTextFieldTypeNumber:
        case ZXRegTextFieldTypeMobile:
            regularString = [regularString stringByReplacingOccurrencesOfString:@"[^0-9]*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
            break;
        case ZXRegTextFieldTypeAlphabet:
            regularString = [regularString stringByReplacingOccurrencesOfString:@"[^a-zA-Z]*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
            break;
        case ZXRegTextFieldTypeChars:
            regularString = [regularString stringByReplacingOccurrencesOfString:@"[^0-9a-zA-Z]*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
            break;
        case ZXRegTextFieldTypeCustom:
            regularString = [self customRegStringValue:regularString];
            break;
        default:
            break;
    }
    return regularString;
}

- (NSString *)customRegStringValue:(NSString *)string {
    if (self.customRegString) {
        NSMutableString * str = [NSMutableString string];
        NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:self.customRegString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> * array = [reg matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        if (array) {
            for (NSTextCheckingResult * result in array) {
                [str appendString:[str substringWithRange:result.range]];
            }
        }
        return str;

    }
    return string;
}

- (NSRange)markedNSRange {
    UITextRange * markedRange = self.markedTextRange;
    if (markedRange) {
        UITextPosition * begining = self.beginningOfDocument;
        UITextPosition * start = markedRange.start;
        UITextPosition * end = markedRange.end;
        NSInteger location = [self offsetFromPosition:begining toPosition:start];
        NSInteger length = [self offsetFromPosition:start toPosition:end];
        return NSMakeRange(location, length);
    }
    return NSMakeRange(0, 0);
}

- (void)setZxType:(ZXRegTextFieldType)zxType {
    _zxType = zxType;
    switch (_zxType) {
        case ZXRegTextFieldTypeNone:
        case ZXRegTextFieldTypeCustom:
            self.keyboardType = UIKeyboardTypeDefault;
            break;
        case ZXRegTextFieldTypeNumber:
            self.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case ZXRegTextFieldTypeMobile:
            self.keyboardType = UIKeyboardTypeNumberPad;
            self.maxLength = 11;
            self.minLength = 11;
            break;
        case ZXRegTextFieldTypeChars:
        case ZXRegTextFieldTypeAlphabet:
            self.keyboardType = UIKeyboardTypeASCIICapable;
            break;
        default:
            self.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

- (void)setLeftOffset:(CGFloat)offset color:(UIColor *)color {
    if (offset > 0) {
        self.zxLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, offset, 0)];
        if (color) {
            self.zxLeftView.backgroundColor = color;
        } else {
            self.zxLeftView.backgroundColor = UIColor.clearColor;
        }
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = self.zxLeftView;
    } else {
        self.leftViewMode = UITextFieldViewModeNever;
        self.leftView = nil;
        self.zxLeftView = nil;
    }
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.zxLeftView) {
        CGRect frame = self.zxLeftView.frame;
        frame.size.height = self.frame.size.height;
        self.zxLeftView.frame = frame;
    }
}


- (void)setPlaceHolderColor:(UIColor *)color {
    if (color) {
        [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
    }
}


- (void)removeNotifiaction {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [self removeNotifiaction];
}

@end
