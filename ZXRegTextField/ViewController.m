//
//  ViewController.m
//  ZXRegTextField
//
//  Created by screson on 2018/5/7.
//  Copyright © 2018年 screson. All rights reserved.
//

#import "ViewController.h"
#import "ZXRegTextField.h"

@interface ViewController () <ZXRegTextFieldDelegate>
@property (weak, nonatomic) IBOutlet ZXRegTextField *txtMobile;
@property (weak, nonatomic) IBOutlet ZXRegTextField *txtNumber;
@property (weak, nonatomic) IBOutlet ZXRegTextField *txtAlphabet;
@property (weak, nonatomic) IBOutlet ZXRegTextField *txtChars;
@property (weak, nonatomic) IBOutlet UIView *tagView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.txtMobile.zxType = ZXRegTextFieldTypeMobile;
    [self.txtMobile setLeftOffset:10 color:UIColor.redColor];
    self.txtNumber.zxType = ZXRegTextFieldTypeNumber;
    self.txtNumber.minLength = 6;
    self.txtNumber.zxdelegate = self;
    self.txtAlphabet.zxType = ZXRegTextFieldTypeAlphabet;
    self.txtChars.zxType = ZXRegTextFieldTypeChars;
    self.txtChars.maxLength = 15;
    _tagView.backgroundColor = UIColor.redColor;
}


//MARK: -
- (void)zxRegTextField:(UITextField *)textFiled reachedTheMinLength:(BOOL)reached {
    if (textFiled == self.txtNumber) {
        if (reached) {
            _tagView.backgroundColor = UIColor.greenColor;
        } else {
            _tagView.backgroundColor = UIColor.redColor;
        }
    }
}


@end
