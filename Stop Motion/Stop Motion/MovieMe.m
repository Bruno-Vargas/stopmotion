//
//  MovieMe.m
//  Stop Motion
//
//  Created by Bruno Vargas Versignassi de Carvalho on 17/02/14.
//  Copyright (c) 2014 Bruno Vargas. All rights reserved.
//

#import "MovieMe.h"


@interface MovieMe ()
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *imagesResized;
@property (strong, nonatomic) NSMutableArray *imagesResizedSubs;
@property float width;
@property float height;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@end


@implementation MovieMe

-(id)init
{
    self = [super init];
    if (self)
    {
        self.images = [[NSMutableArray alloc] init];
        self.imagesResized = [[NSMutableArray alloc] init];
        self.imagesResizedSubs = [[NSMutableArray alloc] init];
    } else {
        NSLog(@"Erro ao inicializar");
    }
    
    return self;
}
- (NSString *)applicationDocumentsDirectory {
    //this method pick the directory used by app.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void) makeMagicWithFrequecy:(float) frequency
{
    NSString *currentTime = [NSString stringWithFormat:@"%@", [NSDate date]];
    // NSString *filePath = [NSString stringWithFormat:@"%@/%@.mov", [self applicationDocumentsDirectory], currentTime];
    NSString *filePath = [NSString stringWithFormat:@"/Users/BrunoVargas/Documents/BEPiD/projetoStopMotion/%@.mov", currentTime];
    [self creatImageArray];
    [self receizeArrayImage:self.images];
    
    self.images = [self.imagesResized copy];
    
    self.width = [self.imagesResized[0]size].width;
    self.height = [self.imagesResized[0]size].height;
//
//    self.width = [self.images[0]size].width;
//    self.height = [self.images[0]size].height;
    
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
    
    //for(UIImage *img in self.imagesResizedSubs)
    for(UIImage *img in self.images)
    {
            buffer = [self pixelBufferFromCGImage:[img CGImage] andSize:img.size];
        BOOL append_ok = NO;
        
        while (!append_ok){
            if (adaptor.assetWriterInput.readyForMoreMediaData){
                CMTime frameTime = CMTimeMake(frameCount,(int16_t) 16); //aqui mudar o tempo em que cada quadro aparece no video, convencional 16 por segundo
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


    [videoStream markAsFinished];
    [self.videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"COMPLETION HANDLER!");
    }];
    	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"FEITO!!");
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

-(void) receizeArrayImage: (NSMutableArray *) arrayImages
{
    self.imagesResized = [[NSMutableArray alloc]init];
    UIImage * convetedImage;
    for (convetedImage in self.images)
    {
        CGSize newSize = CGSizeMake(800, 600);
        [self.imagesResized addObject:[self resizeImageToSize:newSize :convetedImage]];
    }
    
//    for (int i=0; i<5; i++) {
//            CGSize newSize = CGSizeMake(800, 800);
//            [self.imagesResized addObject:[self resizeImageToSize:newSize :arrayImages[i]]];
//        }
}
-(void) subitleMovie: (NSMutableArray *) arrayImages
{
    self.imagesResizedSubs = [[NSMutableArray alloc]init];
        for (int i=0; i<[arrayImages count]; i++) {
            //CGPoint newSize = CGPointMake(0, 0);
            int point = ([arrayImages[i] size].height-45);
            [self.imagesResizedSubs addObject:[self drawText:@"Teste Legenda Bruno Varagas" inImage:arrayImages[i] atPoint:CGPointMake(10, point)]];
    }
}

-(void)creatImageArray
{
//    for (int i=1; i < 57; i++) {
//        [self.images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i]]];
//    }
//    NSLog(@"numero de imagens: %d", [self.images count]);
    for (int i = 1; i<= 8; i ++)
    {
            [self.images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"garota%d",i]]];
    }

}
@end
