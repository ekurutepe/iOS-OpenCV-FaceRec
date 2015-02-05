//
//  FaceRecognizer.mm
//  opencvtest
//
//  Created by Engin Kurutepe on 21/01/15.
//  Copyright (c) 2015 Fifteen Jugglers Software. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import "FJFaceRecognizer.h"
#import "UIImage+OpenCV.h"

using namespace cv;

@interface FJFaceRecognizer () {
    Ptr<FaceRecognizer> _faceClassifier;
}

@property (nonatomic, strong) NSMutableDictionary *labelsDictionary;

@end

@implementation FJFaceRecognizer

+ (FJFaceRecognizer *)faceRecognizerWithFile:(NSString *)path {
    FJFaceRecognizer *fr = [FJFaceRecognizer new];
    
    fr->_faceClassifier = createLBPHFaceRecognizer();
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (path && [fm fileExistsAtPath:path isDirectory:nil]) {
        fr->_faceClassifier->load(path.UTF8String);
        
        NSDictionary *unarchivedNames = [NSKeyedUnarchiver
                                    unarchiveObjectWithFile:[path stringByAppendingString:@".names"]];
        
        fr.labelsDictionary = [NSMutableDictionary dictionaryWithDictionary:unarchivedNames];

    }
    else {
        fr.labelsDictionary = [NSMutableDictionary dictionary];
        NSLog(@"could not load paramaters file: %@", path);
    }

    return fr;
}



- (BOOL)serializeFaceRecognizerParamatersToFile:(NSString *)path {
    
    self->_faceClassifier->save(path.UTF8String);
     
    [NSKeyedArchiver archiveRootObject:_labelsDictionary toFile:[path stringByAppendingString:@".names"]];
    
    return YES;
}


- (NSString *)predict:(UIImage*)img confidence:(double *)confidence {
    
    cv::Mat src = [img cvMatRepresentationGray];
    int label;
    
    self->_faceClassifier->predict(src, label, *confidence);
    
    return _labelsDictionary[@(label)];
}

- (void)updateWithFace:(UIImage *)img name:(NSString *)name {
    cv::Mat src = [img cvMatRepresentationGray];
    
    
    NSSet *keys = [_labelsDictionary keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([name isEqual:obj]);
    }];
    
    NSInteger label;
    
    if (keys.count) {
        label = [[keys anyObject] integerValue];
    }
    else {
        label = _labelsDictionary.allKeys.count;
        _labelsDictionary[@(label)] = name;
    }

    vector<cv::Mat> images = vector<cv::Mat>();
    images.push_back(src);
    vector<int> labels = vector<int>();
    labels.push_back((int)label);
    
    self->_faceClassifier->update(images, labels);
    [self labels];
}

- (NSArray *)labels {
    cv::Mat labels = _faceClassifier->getMat("labels");
    
    if (labels.total() == 0) {
        return @[];
    }
    else {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (MatConstIterator_<int> itr = labels.begin<int>(); itr != labels.end<int>(); ++itr ) {
            int lbl = *itr;
            [mutableArray addObject:@(lbl)];
        }
        return [NSArray arrayWithArray:mutableArray];
    }
}
@end
