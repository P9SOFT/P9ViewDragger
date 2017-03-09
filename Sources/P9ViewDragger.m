//
//  P9ViewDragger.m
//
//
//  Created by Tae Hyun Na on 2016. 3. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9ViewDragger.h"

#define     kTrackingViewKey                @"trackingViewKey"
#define     kStageViewKey                   @"stageViewKey"
#define     kTrackingUnderstudyViewKey      @"trackingUnderstudyViewKey"
#define     kTrackingSnapshotImageKey       @"trackingSnapshotImageKey"
#define     kReadyBlockKey                  @"readyBlockKey"
#define     kTrackingHandlerBlockKey        @"trackingHandlerBlockKey"
#define     kCompletionBlockKey             @"completionBlockKey"
#define     kPanGestureKey                  @"panGestureKey"
#define     kPinchGestureKey                @"pinchGestureKey"
#define     kRotationGestureKey             @"roationGestureKey"
#define     kOriginalUserInteractionKey     @"originalUserInteractionKey"

@interface P9ViewDragger ()
{
    NSMutableDictionary *_trackingViewForKey;
}

- (NSString *)keyForView:(UIView *)view;
- (void)addP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict fromParameters:(NSDictionary *)parameters;
- (void)removeP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict;
- (void)transformTarget:(id)gestureRecognizer;

@end

@implementation P9ViewDragger

- (id)init
{
    if( (self = [super init]) != nil ) {
        if( (_trackingViewForKey = [NSMutableDictionary new]) == nil ) {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self untrackingAllViews];
}

- (NSString *)keyForView:(UIView *)view
{
    if( view == nil ) {
        return nil;
    }
    return [NSString stringWithFormat:@"%p", view];
}

- (void)addP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict fromParameters:(NSDictionary *)parameters
{
    UIView *trackingView = [trackingTargetInfoDict objectForKey:kTrackingViewKey];
    if( [[parameters objectForKey:P9ViewDraggerLockTranslateKey] boolValue] == NO ) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [trackingView addGestureRecognizer:panGestureRecognizer];
        [trackingTargetInfoDict setObject:panGestureRecognizer forKey:kPanGestureKey];
    }
    if( [[parameters objectForKey:P9ViewDraggerLockScaleKey] boolValue] == NO ) {
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        [trackingView addGestureRecognizer:pinchGestureRecognizer];
        [trackingTargetInfoDict setObject:pinchGestureRecognizer forKey:kPinchGestureKey];
    }
    if( [[parameters objectForKey:P9ViewDraggerLockRotateKey] boolValue] == NO ) {
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        [trackingView addGestureRecognizer:rotationGestureRecognizer];
        [trackingTargetInfoDict setObject:rotationGestureRecognizer forKey:kRotationGestureKey];
    }
}

- (void)removeP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict
{
    UIView *trackingView = [trackingTargetInfoDict objectForKey:kTrackingViewKey];
    if( trackingView == nil ) {
        return;
    }
    UIPanGestureRecognizer *panGestureRecognizer = [trackingTargetInfoDict objectForKey:kPanGestureKey];
    if( panGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:panGestureRecognizer];
    }
    UIPinchGestureRecognizer *pinchGestureRecognizer = [trackingTargetInfoDict objectForKey:kPinchGestureKey];
    if( pinchGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:pinchGestureRecognizer];
    }
    UIRotationGestureRecognizer *rotationGestureRecognizer = [trackingTargetInfoDict objectForKey:kRotationGestureKey];
    if( rotationGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:rotationGestureRecognizer];
    }
}

- (void)transformTarget:(id)gestureRecognizer
{
    UIView *targetView = [gestureRecognizer view];
    NSString *key = [self keyForView:targetView];
    if( key == nil ) {
        return;
    }
    P9ViewDraggerBlock ready = nil;
    P9ViewDraggerBlock trackingHandler = nil;
    P9ViewDraggerBlock completion = nil;
    UIView *stageView = nil;
    UIImageView *understudyView = nil;
    UIImage *snapshotImage = nil;
    @synchronized(self) {
        NSMutableDictionary *trackingTargetDictInfo = [_trackingViewForKey objectForKey:key];
        if( trackingTargetDictInfo != nil ) {
            ready = [trackingTargetDictInfo objectForKey:kReadyBlockKey];
            trackingHandler = [trackingTargetDictInfo objectForKey:kTrackingHandlerBlockKey];
            completion = [trackingTargetDictInfo objectForKey:kCompletionBlockKey];
            stageView = [trackingTargetDictInfo objectForKey:kStageViewKey];
            understudyView = [trackingTargetDictInfo objectForKey:kTrackingUnderstudyViewKey];
            snapshotImage = [trackingTargetDictInfo objectForKey:kTrackingSnapshotImageKey];
        }
    }
    UIView *trackingView = (understudyView != nil) ? understudyView : targetView;;
    CATransform3D transform;
    switch( (UIGestureRecognizerState)[gestureRecognizer state] ) {
        case UIGestureRecognizerStateBegan :
            if( stageView != nil ) {
                if( (understudyView = [[UIImageView alloc] init]) != nil ) {
                    understudyView.userInteractionEnabled = NO;
                    understudyView.bounds = targetView.bounds;
                    understudyView.center = [stageView convertPoint:targetView.center fromView:((targetView.superview != nil) ? targetView.superview : targetView)];
                    understudyView.layer.transform = targetView.layer.transform;
                }
                if( snapshotImage == nil ) {
                    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, [UIScreen mainScreen].scale);
                    [targetView drawViewHierarchyInRect:targetView.bounds afterScreenUpdates:YES];
                    snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                understudyView.image = snapshotImage;
                [stageView addSubview:understudyView];
                @synchronized(self) {
                    [[_trackingViewForKey objectForKey:key] setObject:understudyView forKey:kTrackingUnderstudyViewKey];
                }
                trackingView = understudyView;
            }
            if( ready != nil ) {
                ready(trackingView);
            }
            break;
        case UIGestureRecognizerStateChanged :
            if( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] == YES ) {
                CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:targetView.superview];
                trackingView.layer.transform = CATransform3DConcat(trackingView.layer.transform, CATransform3DMakeTranslation(translation.x, translation.y, 0.0));
                [(UIPanGestureRecognizer *)gestureRecognizer setTranslation:CGPointZero inView:targetView.superview];
            } else {
                transform = CATransform3DConcat(trackingView.layer.transform, CATransform3DInvert(trackingView.layer.transform));
                if( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] == YES ) {
                    CGFloat scale = [(UIPinchGestureRecognizer *)gestureRecognizer scale];
                    transform = CATransform3DConcat(transform, CATransform3DMakeScale(scale, scale, 1));
                    ((UIPinchGestureRecognizer *)gestureRecognizer).scale = 1.0;
                } else if( [gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] == YES ) {
                    CGFloat rotation = ((UIRotationGestureRecognizer *)gestureRecognizer).rotation;
                    transform = CATransform3DConcat(transform, CATransform3DMakeRotation(rotation, 0.0, 0.0, 1.0));
                    ((UIRotationGestureRecognizer *)gestureRecognizer).rotation = 0.0;
                }
                transform = CATransform3DConcat(transform, trackingView.layer.transform);
                trackingView.layer.transform = transform;
            }
            if( trackingHandler != nil ) {
                trackingHandler(trackingView);
            }
            break;
        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateFailed :
            if( completion != nil ) {
                completion(trackingView);
            }
            [understudyView removeFromSuperview];
            understudyView.layer.transform = CATransform3DIdentity;
            @synchronized(self) {
                [[_trackingViewForKey objectForKey:key] removeObjectForKey:kTrackingUnderstudyViewKey];
            }
            break;
        default :
            break;
    }
}

+ (P9ViewDragger *)defaultTracker
{
    static dispatch_once_t once;
    static P9ViewDragger *sharedInstance;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

- (BOOL)trackingView:(UIView *)trackingView parameters:(NSDictionary *)parameters ready:(P9ViewDraggerBlock)ready trackingHandler:(P9ViewDraggerBlock)trackingHandler completion:(P9ViewDraggerBlock)completion
{
    if( trackingView == nil ) {
        return NO;
    }
    BOOL userInteraction = trackingView.userInteractionEnabled;
    trackingView.userInteractionEnabled = YES;
    
    NSString *key = [self keyForView:trackingView];
    NSMutableDictionary *trackingTargetInfoDict = [NSMutableDictionary new];
    if( (key == nil) || (trackingTargetInfoDict == nil) ) {
        return NO;
    }
    
    [trackingTargetInfoDict setObject:trackingView forKey:kTrackingViewKey];
    [trackingTargetInfoDict setObject:@(userInteraction) forKey:kOriginalUserInteractionKey];
    [self addP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict fromParameters:parameters];
    if( ready != nil ) {
        [trackingTargetInfoDict setObject:ready forKey:kReadyBlockKey];
    }
    if( trackingHandler != nil ) {
        [trackingTargetInfoDict setObject:trackingHandler forKey:kTrackingHandlerBlockKey];
    }
    if( completion != nil ) {
        [trackingTargetInfoDict setObject:completion forKey:kCompletionBlockKey];
    }
    
    @synchronized(self) {
        [_trackingViewForKey setObject:trackingTargetInfoDict forKey:key];
    }
    
    return YES;
}

- (BOOL)trackingDecoyView:(UIView *)trackingView stageView:(UIView *)stageView parameters:(NSDictionary *)parameters ready:(P9ViewDraggerBlock)ready trackingHandler:(P9ViewDraggerBlock)trackingHandler completion:(P9ViewDraggerBlock)completion
{
    UIView *currentStageView = (stageView != nil) ? stageView : self.defaultStageView;
    if( (currentStageView == nil) || (trackingView == nil) ) {
        return NO;
    }
    BOOL userInteraction = trackingView.userInteractionEnabled;
    trackingView.userInteractionEnabled = YES;
    
    NSString *key = [self keyForView:trackingView];
    NSMutableDictionary *trackingTargetInfoDict = [NSMutableDictionary new];
    if( (key == nil) || (trackingTargetInfoDict == nil) ) {
        return NO;
    }
    
    [trackingTargetInfoDict setObject:trackingView forKey:kTrackingViewKey];
    [trackingTargetInfoDict setObject:@(userInteraction) forKey:kOriginalUserInteractionKey];
    [trackingTargetInfoDict setObject:currentStageView forKey:kStageViewKey];
    if( [parameters objectForKey:P9ViewDraggerSnapshotImageKey] != nil ) {
        [trackingTargetInfoDict setObject:[parameters objectForKey:P9ViewDraggerSnapshotImageKey] forKey:kTrackingSnapshotImageKey];
    }
    [self addP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict fromParameters:parameters];
    if( ready != nil ) {
        [trackingTargetInfoDict setObject:ready forKey:kReadyBlockKey];
    }
    if( trackingHandler != nil ) {
        [trackingTargetInfoDict setObject:trackingHandler forKey:kTrackingHandlerBlockKey];
    }
    if( completion != nil ) {
        [trackingTargetInfoDict setObject:completion forKey:kCompletionBlockKey];
    }
    
    @synchronized(self) {
        [_trackingViewForKey setObject:trackingTargetInfoDict forKey:key];
    }
    
    return YES;
}

- (void)untrackingView:(UIView *)trackingView
{
    NSString *key = [self keyForView:trackingView];
    if( key == nil ) {
        return;
    }
    NSMutableDictionary *trackingTargetInfoDict = nil;
    @synchronized(self) {
        if( (trackingTargetInfoDict = [_trackingViewForKey objectForKey:key]) != nil ) {
            [_trackingViewForKey removeObjectForKey:key];
        }
    }
    [[trackingTargetInfoDict objectForKey:kTrackingViewKey] setUserInteractionEnabled:[[trackingTargetInfoDict objectForKey:kOriginalUserInteractionKey] boolValue]];
    [self removeP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict];
}

- (void)untrackingAllViews
{
    NSArray *allTargets = nil;
    @synchronized(self) {
        if( (allTargets = [_trackingViewForKey allValues]) != nil ) {
            [_trackingViewForKey removeAllObjects];
        }
    }
    for( NSMutableDictionary *trackingTargetInfoDict in allTargets ) {
        [[trackingTargetInfoDict objectForKey:kTrackingViewKey] setUserInteractionEnabled:[[trackingTargetInfoDict objectForKey:kOriginalUserInteractionKey] boolValue]];
        [self removeP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict];
    }
}

@end
