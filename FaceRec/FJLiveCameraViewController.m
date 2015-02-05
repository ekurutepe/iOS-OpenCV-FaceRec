//
//  ViewController.m
//  opencvtest
//
//  Created by Engin Kurutepe on 16/01/15.
//  Copyright (c) 2015 Fifteen Jugglers Software. All rights reserved.
//

#import "FJLiveCameraViewController.h"
#import "FJFaceDetector.h"
#import "FJFaceRecognitionViewController.h"
@interface FJLiveCameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;

@property (nonatomic, strong) FJFaceDetector *faceDetector;


@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation FJLiveCameraViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.faceDetector = [[FJFaceDetector alloc] initWithCameraView:_cameraView scale:2.0];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.faceDetector startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.faceDetector stopCapture];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    NSArray *detectedFaces = [self.faceDetector.detectedFaces copy];
    CGSize windowSize = self.view.bounds.size;
    for (NSValue *val in detectedFaces) {
        CGRect faceRect = [val CGRectValue];
        
        CGPoint tapPoint = [tapGesture locationInView:nil];
        //scale tap point to 0.0 to 1.0
        CGPoint scaledPoint = CGPointMake(tapPoint.x/windowSize.width, tapPoint.y/windowSize.height);
        if(CGRectContainsPoint(faceRect, scaledPoint)){
            NSLog(@"tapped on face: %@", NSStringFromCGRect(faceRect));
            UIImage *img = [self.faceDetector faceWithIndex:[detectedFaces indexOfObject:val]];
            [self performSegueWithIdentifier:@"RecognizeFace" sender:img];
        }
        else {
            NSLog(@"tapped on no face");
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"RecognizeFace"]) {
        NSAssert([sender isKindOfClass:[UIImage class]],@"RecognizeFace segue MUST be sent with an image");
        FJFaceRecognitionViewController *frvc = segue.destinationViewController;
        frvc.inputImage = sender;

    }
}


@end
