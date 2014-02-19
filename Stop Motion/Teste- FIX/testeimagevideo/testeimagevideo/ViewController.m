//
//  ViewController.m
//  testeimagevideo
//
//  Created by Mateus de Campos on 27/01/14.
//  Copyright (c) 2014 HatTrick. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *imagesResized;
@property (strong, nonatomic) NSMutableArray *imagesResizedSubs;
@property float width;
@property float height;

@property (nonatomic, strong) AVAssetWriter *videoWriter;

@end

@implementation ViewController


- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)viewDidLoad
{
    NSString *currentTime = [NSString stringWithFormat:@"%@", [NSDate date]];
    
   // NSString *filePath = [NSString stringWithFormat:@"%@/%@.mov", [self applicationDocumentsDirectory], currentTime];
    NSString *filePath = [NSString stringWithFormat:@"/Users/BrunoVargas/Documents/BEPiD/projetoStopMotion/%@.mov", currentTime];
    self.images = [[NSMutableArray alloc]init];
    for (int i=0; i < 5; i++) {
        [self.images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i+1]]];
    }
    NSLog(@"numero de imagens: %d", [self.images count]);
    
    self.imagesResized = [[NSMutableArray alloc]init];
    for (int i=0; i<5; i++) {
        CGSize newSize = CGSizeMake(800, 800);
        [self.imagesResized addObject:[self resizeImageToSize:newSize :self.images[i]]];
    }
    
    self.imagesResizedSubs = [[NSMutableArray alloc]init];
    for (int i=0; i<5; i++) {
        //CGPoint newSize = CGPointMake(0, 0);
        int point = ([self.imagesResized[i] size].height-45);
        [self.imagesResizedSubs addObject:[self drawText:@"12345678901234567890123456789012345" inImage:self.imagesResized[i] atPoint:CGPointMake(10, point)]];
    }
    
    self.width = [self.imagesResizedSubs[0]size].width;
    self.height = [self.imagesResizedSubs[0]size].height;
//    NSLog(@"Width: %.2f - Height: %.2f", self.width, self.height);
//    
//    self.imageOriginal.image = self.images[0];
//    self.widthOriginal.text = [NSString stringWithFormat:@"w %.2f",[self.images[0]size].width];
//    self.heightOriginal.text = [NSString stringWithFormat:@"h %.2f",[self.images[0]size].height];
//    
//    CGSize newSize = CGSizeMake(500, 500);
//    UIImage *imageResized = [self resizeImageToSize:newSize :self.images[0]];
//    self.imageResized.image = imageResized;
//    self.widthResized.text = [NSString stringWithFormat:@"w %.2f",imageResized.size.width];
//    self.heightResized.text = [NSString stringWithFormat:@"h %.2f",imageResized.size.height];
    
    
    NSError *error = Nil;
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:filePath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:self.width], AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:self.height], AVVideoHeightKey,
                                   
                                   nil];
    
    AVAssetWriterInput* videoStream = [AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoStream
                                                     
                                                     sourcePixelBufferAttributes:nil];
    
    [self.videoWriter addInput: videoStream];
    
    [self.videoWriter startWriting];
    
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    CVPixelBufferRef buffer = NULL;
    int frameCount = 0;
    
    for(UIImage *img in self.imagesResizedSubs)
    {
        for (int i = 0; i<=3; i++) {
    
        NSLog(@"Tamanho do array img: %d", [self.imagesResizedSubs count]);
        buffer = [self pixelBufferFromCGImage:[img CGImage] andSize:img.size];

        BOOL append_ok = NO;
        
        while (!append_ok){
            if (adaptor.assetWriterInput.readyForMoreMediaData){
                CMTime frameTime = CMTimeMake(frameCount,(int16_t) 1);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(buffer)
                    //CVBufferRelease(buffer);
                [NSThread sleepForTimeInterval:0.05];
            }else{
                [NSThread sleepForTimeInterval:0.1];
            }
        }
        frameCount++;
        }
    }
    
    [videoStream markAsFinished];
    [self.videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"COMPLETION HANDLER!");
    }];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"FEITO!!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,nil];

    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          //size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,&pxbuffer);
                                          //size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) CFBridgingRetain(options),&pxbuffer);
                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,&pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

- (UIImage *)resizeImageToSize:(CGSize)targetSize :(UIImage*)imageToFit
{
    UIImage *sourceImage = imageToFit;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // make image center aligned
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor > heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    return newImage ;
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(0, (image.size.height-[text sizeWithFont:font].height),
                                 image.size.width, image.size.height));
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
