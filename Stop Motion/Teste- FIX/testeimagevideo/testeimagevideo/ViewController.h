//
//  ViewController.h
//  testeimagevideo
//
//  Created by Mateus de Campos on 27/01/14.
//  Copyright (c) 2014 HatTrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController
//- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size;
@property (strong, nonatomic) IBOutlet UILabel *widthOriginal;
@property (strong, nonatomic) IBOutlet UILabel *heightOriginal;
@property (strong, nonatomic) IBOutlet UILabel *widthResized;
@property (strong, nonatomic) IBOutlet UILabel *heightResized;
@property (strong, nonatomic) IBOutlet UIImageView *imageOriginal;
@property (strong, nonatomic) IBOutlet UIImageView *imageResized;
@end
