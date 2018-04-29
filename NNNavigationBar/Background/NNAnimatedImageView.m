//
//  NNAnimatedImageView.m
//  NNAnimatedImageView
//
//  Created by GuHaijun on 2018/4/27.
//  Copyright © 2018年 GuHaijun. All rights reserved.
//

#import "NNAnimatedImageView.h"
#import "UIImage+NNImageTransition.h"
#import "NSLayoutConstraint+NNVisualFormat.h"

@interface NNAnimatedImageView() <CAAnimationDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CADisplayLink *nn_displayLink;
@property (nonatomic, assign) NSTimeInterval nn_frameTimeCount;
@property (nonatomic, assign) dispatch_queue_t queue;

@end

@implementation NNAnimatedImageView

- (instancetype)init {
    self = [super init];

    self.contentView = [UIView new];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.contentView];
    return self;
}


- (void)setNn_image:(UIImage *)nn_image {
    _nn_image = nn_image == nil ? [UIImage new] : nn_image;
    _nn_fromImage = _nn_image;
    [self createAnimation];
}

- (void)setNn_fromImage:(UIImage *)nn_fromImage {
    _nn_fromImage = nn_fromImage == nil ? [UIImage new] : nn_fromImage;
    _nn_image = _nn_fromImage;
    [self createAnimation];
}

- (void)setNn_toImage:(UIImage *)nn_toImage {
    _nn_toImage = nn_toImage == nil ? [UIImage new] : nn_toImage;
    [self createAnimation];
}

- (void)setNn_animationProcess:(CGFloat)nn_animationProcess {
    _nn_animationProcess = nn_animationProcess;
    self.nn_animating = false;
    self.nn_animationProcessing = _nn_animationProcess;
//    self.image = [UIImage imageTransitionFromImage:self.nn_fromImage
//                                           toImage:self.nn_toImage
//                                           process:self.nn_animationProcessing];
    self.contentView.layer.timeOffset = _nn_animationProcess;
}

- (void)setNn_animating:(BOOL)nn_animating {
    
    if (nn_animating == true &&
        self.nn_displayLink == nil &&
        self.nn_animationDuration != 0 &&
        self.nn_frameDuration != 0) {
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(transitionImage)];
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.nn_displayLink = link;
        _nn_animating = nn_animating;
        return;
    }
    
    if (nn_animating == false &&
        self.nn_displayLink != nil) {
        CADisplayLink *link = self.nn_displayLink;
        link.paused = true;
        [link invalidate];
        self.nn_frameTimeCount = .0f;
        self.nn_displayLink = nil;
//        self.nn_toImage = self.nn_image;
//        [self createAnimation];
    }
    
    _nn_animating = false;
}

- (void)transitionImage {
    
    self.nn_frameTimeCount += self.nn_displayLink.duration;
    if (self.nn_frameTimeCount < self.nn_frameDuration) {
        return;
    }
    
    CGFloat deltaProcess = self.nn_frameTimeCount / self.nn_animationDuration;
    self.nn_animationProcessing += (self.nn_isReversed ? (-deltaProcess) : deltaProcess);
    self.nn_frameTimeCount = 0.0;
    
    
    if (self.nn_animationProcessing >= 1.0f) {
        self.nn_animating = false;
        self.nn_animationProcessing = 1.0f;
//        return;
    }
    if (self.nn_animationProcessing < 0.0f) {
        self.nn_animating = false;
        self.nn_animationProcessing = 0.0f;
//        return;
    }
    
    
    NSLog(@"%lf", self.nn_animationProcessing);

    self.contentView.layer.timeOffset = self.nn_animationProcessing;
//    [self refreshImage];
}

- (void)refreshImage {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [UIImage imageTransitionFromImage:self.nn_fromImage
                                                   toImage:self.nn_toImage
                                                   process:self.nn_animationProcessing];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.nn_image = image;
        });
    });
}

- (void)createAnimation {
    [self.contentView.layer removeAnimationForKey:@"_nn_contentsAnimation"];
    
        NSLog(@"%@", @"createAnimation");
//        UIImage *fromImage = [UIImage imageNamed:@"image1"];
//        UIImage *toImage = [UIImage imageNamed:@"image2"];

    UIImage *fromImage = self.nn_image == nil ? [UIImage new] : self.nn_image;
    UIImage *toImage = self.nn_toImage == nil ? [UIImage new] : self.nn_toImage;
//        self.contentView.layer.contents = (__bridge id)(fromImage.CGImage);
        // 创建淡入/淡出的切换动画
    
    
        CABasicAnimation *contentsAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    contentsAnimation.fromValue =  self.contentView.layer.contents ? : (__bridge id)(fromImage.CGImage);
        contentsAnimation.toValue = (__bridge id)(toImage.CGImage);
        contentsAnimation.duration = 1.0f;
    __weak typeof(self) weakSelf = self;
    contentsAnimation.delegate = weakSelf;
        // 将动画添加到图层
        [self.contentView.layer addAnimation:contentsAnimation forKey:@"_nn_contentsAnimation"];
        self.contentView.layer.speed = 0;
        // 修改 contents，触发动画
        self.contentView.layer.contents = (__bridge id)(toImage.CGImage);
    self.contentView.layer.masksToBounds = true;
}




@end
