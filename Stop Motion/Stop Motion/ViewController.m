//
//  ViewController.m
//  Stop Motion
//
//  Created by Bruno Vargas Versignassi de Carvalho on 13/02/14.
//  Copyright (c) 2014 Bruno Vargas. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MovieMe.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *frequency;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSTimer *alarm;
@property (nonatomic) float factor;
@property (nonatomic) AVAssetWriter *videoWriter;
@property (nonatomic) MovieMe * movieMaker;

@end

@implementation ViewController
int indice;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    indice = 1;
    self.factor = self.frequency.value;
    self.movieMaker = [[MovieMe alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tradeImage
{
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"garota%d.png",indice]];
    indice = ((indice + 1)% 7) + 1; //nunca será 0 somente neste caso, falha minha
}
-(void)marcarCompasso
{
    //inicializa o timer e comeca a funcionar;
    self.alarm =
    [NSTimer scheduledTimerWithTimeInterval: 1/self.factor
                                     target:self
                                   selector:@selector(tradeImage)
                                   userInfo:nil
                                    repeats:YES];
    
}
-(void) stopAction
{
    [self.alarm invalidate];
    indice = 1;
}
- (IBAction)buttonStop:(id)sender {
    [self stopAction];
}
- (IBAction)buttonBegin:(id)sender {
    [self marcarCompasso];
    [self.movieMaker makeMagicWithFrequecy: 1/self.factor];
}
- (IBAction)buttonFrequency:(id)sender {
    [self stopAction];
    self.factor = self.frequency.value;
}



- (IBAction)buttonBeginVideo:(id)sender {
    [self.videoWriter startWriting];
}


@end
