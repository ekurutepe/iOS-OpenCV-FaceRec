//
//  FJFaceRecognitionViewController.m
//  opencvtest
//
//  Created by Engin Kurutepe on 28/01/15.
//  Copyright (c) 2015 Fifteen Jugglers Software. All rights reserved.
//

#import "FJFaceRecognitionViewController.h"
#import "FJFaceRecognizer.h"

@interface FJFaceRecognitionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inputImageView;

@property (nonatomic, strong) FJFaceRecognizer *faceModel;
@end

@implementation FJFaceRecognitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inputImageView.image = _inputImage;
    
    NSURL *modelURL = [self faceModelFileURL];
    self.faceModel = [FJFaceRecognizer faceRecognizerWithFile:[modelURL path]];
    
    double confidence;
    
    if (_faceModel.labels.count == 0) {
        [_faceModel updateWithFace:_inputImage name:@"Person 1"];
    }

    NSString *name = [_faceModel predict:_inputImage confidence:&confidence];
    
    _nameLabel.text = name;
    _confidenceLabel.text = [@(confidence) stringValue];
    
    
}

- (NSURL *)faceModelFileURL {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsURL = [paths lastObject];
    NSURL *modelURL = [documentsURL URLByAppendingPathComponent:@"face-model.xml"];
    return modelURL;
}


- (IBAction)didTapCorrect:(id)sender {
    //Positive feedback for the correct prediction

    [_faceModel updateWithFace:_inputImage name:_nameLabel.text];
    [_faceModel serializeFaceRecognizerParamatersToFile:[[self faceModelFileURL] path]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapWrong:(id)sender {
    //Update our face model with the new person
    NSString *name = [@"Person " stringByAppendingFormat:@"%lu", (unsigned long)_faceModel.labels.count];
    [_faceModel updateWithFace:_inputImage name:name];
    [_faceModel serializeFaceRecognizerParamatersToFile:[[self faceModelFileURL] path]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
