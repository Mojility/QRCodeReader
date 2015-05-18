//
//  ViewController.h
//  QRCodeReader
//
//  Created by Stacey Vetzal on 15-05-18.
//  Copyright (c) 2015 Mojility Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;

- (IBAction)toggleActive:(id)sender;

@end
