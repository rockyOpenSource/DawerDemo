//
//  TPDrawerViewController.m
//  TPDrawerViewController
//
//  Created by Tpphha on 16/1/14.
//  Copyright © 2016年 Tpphha. All rights reserved.
//

#import "TPDrawerViewController.h"

const CGFloat kTPDrawerControllerDrawerDepth = 260.0f;
static const CGFloat kTPDrawerControllerLeftViewInitialOffset = -kTPDrawerControllerDrawerDepth;
static const NSTimeInterval kTPDrawerControllerAnimationDuration = 0.5;
static const CGFloat kTPDrawerControllerMaskingViewMaxAlpha = 0.5f;
static const CGFloat kTPDrawerControllerCenterViewVisibelPan = 20.0f;


typedef NS_ENUM(NSUInteger, ICSDrawerControllerState)
{
    TPDrawerControllerStateClosed = 0,
    TPDrawerControllerStateOpening,
    TPDrawerControllerStateOpened,
    TPDrawerControllerStateClosing
};

@interface TPDrawerViewController () <UIGestureRecognizerDelegate>
@property(nonatomic, strong) UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *leftViewController;
@property(nonatomic, strong) UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *centerViewController;

@property(nonatomic, strong) UIView *leftView;
@property(nonatomic, strong) UIView *centerView;


@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, assign) CGPoint panGestureStartLocation;
@property (nonatomic, strong) UIView *maskingView;
@property(nonatomic, assign) ICSDrawerControllerState drawerState;
@property (nonatomic, assign) CGRect lelftViewClosedFinalFrame;
@property (nonatomic, assign) CGRect lelftViewOpenedFinalFrame;
@end

@implementation TPDrawerViewController

- (instancetype)initWithLeftViewController:(UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *)leftViewController
            centerViewController:(UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *)centerViewController
{
    NSParameterAssert(leftViewController);
    NSParameterAssert(centerViewController);
    
    self = [super init];
    if (self) {
        _leftViewController = leftViewController;
        _centerViewController = centerViewController;
        
        if ([_leftViewController respondsToSelector:@selector(setDrawer:)]) {
            _leftViewController.drawer = self;
        }
        if ([_centerViewController respondsToSelector:@selector(setDrawer:)]) {
            _centerViewController.drawer = self;
        }
    }
    
    return self;
}

- (void)addCenterViewController
{
    NSParameterAssert(self.centerViewController);
    NSParameterAssert(self.centerView);
    
    [self.centerViewController willMoveToParentViewController:self];
    [self addChildViewController:self.centerViewController];
    self.centerViewController.view.frame = self.centerView.bounds;
    [self.centerView addSubview:self.centerViewController.view];
    [self.centerViewController didMoveToParentViewController:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Initialize left , center view containers and masking view
    self.leftView = [UIView new];
    self.centerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.leftView.autoresizingMask = self.view.autoresizingMask;
    self.centerView.autoresizingMask = self.view.autoresizingMask;
    
    self.maskingView = [UIView new];
    self.maskingView.userInteractionEnabled = NO;
    self.maskingView.backgroundColor = [UIColor blackColor];
    self.maskingView.alpha = 0.0f;

    //default state closed
    self.drawerState = TPDrawerControllerStateClosed;
    
    self.lelftViewClosedFinalFrame = CGRectMake(kTPDrawerControllerLeftViewInitialOffset, 0, kTPDrawerControllerDrawerDepth, self.view.bounds.size.height);
    self.lelftViewOpenedFinalFrame = CGRectMake(0, 0, kTPDrawerControllerDrawerDepth, self.view.bounds.size.height);
    
    // Add the center view container
    [self.view addSubview:self.centerView];
    
    // Add the center view controller to the container
    [self addCenterViewController];
    
    [self setupGestureRecognizers];

}


#pragma mark - Gesture recognizers

- (void)setupGestureRecognizers
{
    NSParameterAssert(self.centerView);
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    
    [self.centerView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)addClosingGestureRecognizers
{
    NSParameterAssert(self.centerView);
    NSParameterAssert(self.panGestureRecognizer);
    
    [self.centerView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)removeClosingGestureRecognizers
{
    NSParameterAssert(self.centerView);
    NSParameterAssert(self.panGestureRecognizer);
    
    [self.centerView removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Configuring the view’s layout behavior

- (UIViewController *)childViewControllerForStatusBarHidden
{
    NSParameterAssert(self.leftViewController);
    NSParameterAssert(self.centerViewController);
    
    if (self.drawerState == TPDrawerControllerStateOpening) {
        return self.leftViewController;
    }
    return self.centerViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    NSParameterAssert(self.leftViewController);
    NSParameterAssert(self.centerViewController);

    if (self.drawerState == TPDrawerControllerStateOpening) {
        return self.leftViewController;
    }
    return self.centerViewController;
}


#pragma mark - Pan to open/close the drawer
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSParameterAssert([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
    
    if (location.x > kTPDrawerControllerCenterViewVisibelPan && self.drawerState == TPDrawerControllerStateClosed) {
        return NO;
    }
    
    if (self.drawerState == TPDrawerControllerStateClosed && velocity.x > 0.0f) {
        return YES;
    }
    else if (self.drawerState == TPDrawerControllerStateOpened && velocity.x < 0.0f) {
        return YES;
    }
    
    return NO;
}


- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSParameterAssert(self.leftView);
    NSParameterAssert(self.centerView);
    
    UIGestureRecognizerState state = panGestureRecognizer.state;
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    switch (state) {
            
        case UIGestureRecognizerStateBegan:
            self.panGestureStartLocation = location;
            if (self.drawerState == TPDrawerControllerStateClosed) {
                [self willOpen];
            }
            else {
                [self willClose];
            }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat delta = 0.0f;
            CGFloat maskingViewAlpha = self.maskingView.alpha;
            
            if (self.drawerState == TPDrawerControllerStateOpening) {
                delta = location.x - self.panGestureStartLocation.x;
            }
            else if (self.drawerState == TPDrawerControllerStateClosing) {
                delta = kTPDrawerControllerDrawerDepth - (self.panGestureStartLocation.x - location.x);
            }
            
            CGRect l = self.leftView.frame;
            if (delta > kTPDrawerControllerDrawerDepth) {
                l.origin.x = 0.0f;
                maskingViewAlpha = kTPDrawerControllerMaskingViewMaxAlpha;
            }
            else if (delta < 0.0f) {
                l.origin.x = kTPDrawerControllerLeftViewInitialOffset;
                maskingViewAlpha = 0.0f;
            }
            else {
                // While the centerView can move up to kICSDrawerControllerDrawerDepth points, to achieve a parallax effect
                // the leftView has move no more than kICSDrawerControllerLeftViewInitialOffset points
                l.origin.x = kTPDrawerControllerLeftViewInitialOffset
                - (delta * kTPDrawerControllerLeftViewInitialOffset) / kTPDrawerControllerDrawerDepth;
                maskingViewAlpha = (kTPDrawerControllerMaskingViewMaxAlpha * delta) / kTPDrawerControllerDrawerDepth;
            }
            

            self.maskingView.alpha = maskingViewAlpha;
            self.leftView.frame = l;
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            if (self.drawerState == TPDrawerControllerStateOpening) {
                CGFloat leftViewMaxX = CGRectGetMaxX(self.leftView.frame);
                if (leftViewMaxX == kTPDrawerControllerDrawerDepth) {
                    // Open the drawer without animation, as it has already being dragged in its final position
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self didOpen];
                }
                else if (leftViewMaxX > self.view.bounds.size.width / 3
                         && velocity.x > 0.0f) {
                    // Animate the drawer opening
                    [self animateOpening];
                }
                else {
                    // Animate the drawer closing, as the opening gesture hasn't been completed or it has
                    // been reverted by the user
                    [self didOpen];
                    [self willClose];
                    [self animateClosing];
                }
                
            } else if (self.drawerState == TPDrawerControllerStateClosing) {
                CGFloat leftViewMaxX = CGRectGetMaxX(self.leftView.frame);
                if (leftViewMaxX == 0.0f) {
                    // Close the drawer without animation, as it has already being dragged in its final position
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self didClose];
                }
                else if (leftViewMaxX < (2 * self.view.bounds.size.width) / 3
                         && velocity.x < 0.0f) {
                    // Animate the drawer closing
                    [self animateClosing];
                }
                else {
                    // Animate the drawer opening, as the opening gesture hasn't been completed or it has
                    // been reverted by the user
                    [self didClose];
                    
                    // Here we save the current position for the leftView since
                    // we want the opening animation to start from the current position
                    // and not the one that is set in 'willOpen'
                    CGRect l = self.leftView.frame;
                    [self willOpen];
                    self.leftView.frame = l;
                    
                    [self animateOpening];
                }
            }
            break;
            
        default:
            break;
  
    }
}

#pragma mark Tap to close the drawer
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self close];
    }
}


#pragma mark - Animations
#pragma mark Opening animation
- (void)animateOpening
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateOpening);
    NSParameterAssert(self.leftView);
    NSParameterAssert(self.centerView);
    
    // Calculate the final frames for the container views
    CGRect leftViewFinalFrame = self.lelftViewOpenedFinalFrame;
    CGRect centerViewFinalFrame = self.view.bounds;
    centerViewFinalFrame.origin.x = kTPDrawerControllerDrawerDepth;
    
    [UIView animateWithDuration:kTPDrawerControllerAnimationDuration
                     animations:^{
                         self.leftView.frame = leftViewFinalFrame;
                         self.maskingView.alpha = kTPDrawerControllerMaskingViewMaxAlpha;
                         [self setNeedsStatusBarAppearanceUpdate];
                     }
                     completion:^(BOOL finished) {
                         [self didOpen];
                     }];
    
}

#pragma mark Closing animation
- (void)animateClosing
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateClosing);
    NSParameterAssert(self.leftView);
    NSParameterAssert(self.centerView);
    
    // Calculate final frames for the container views
    CGRect leftViewFinalFrame = self.lelftViewClosedFinalFrame;
    leftViewFinalFrame.origin.x = kTPDrawerControllerLeftViewInitialOffset;
    
    [UIView animateWithDuration:kTPDrawerControllerAnimationDuration
                     animations:^{
                         self.leftView.frame = leftViewFinalFrame;
                         self.maskingView.alpha = 0.0f;
                         [self setNeedsStatusBarAppearanceUpdate];
    }
                     completion:^(BOOL finished) {
         [self didClose];
    }];
    
}

#pragma mark - Opening the drawer

- (void)open
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateClosed);
    
    [self willOpen];
    
    [self animateOpening];
}

- (void)willOpen
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateClosed);
    NSParameterAssert(self.leftView);
    NSParameterAssert(self.centerView);
    NSParameterAssert(self.leftViewController);
    NSParameterAssert(self.centerViewController);
    
    // Keep track that the drawer is opening
    self.drawerState = TPDrawerControllerStateOpening;
    
    // Position the left view
    
    CGRect f = self.lelftViewClosedFinalFrame;
    NSParameterAssert(f.origin.x < 0.0f);
    self.leftView.frame = f;
    
    // Start adding the left view controller to the container
    [self addChildViewController:self.leftViewController];
    self.leftViewController.view.frame = self.leftView.bounds;
    [self.leftView addSubview:self.leftViewController.view];
    
    //Add the masking view
    self.maskingView.frame = self.centerView.bounds;
    [self.view insertSubview:self.maskingView aboveSubview:self.centerView];
    
    // Add the left view to the view hierarchy
    [self.view insertSubview:self.leftView aboveSubview:self.maskingView];
    
    // Notify the child view controllers that the drawer is about to open
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerWillOpen:)]) {
        [self.leftViewController drawerControllerWillOpen:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerWillOpen:)]) {
        [self.centerViewController drawerControllerWillOpen:self];
    }
}

- (void)didOpen
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateOpening);
    NSParameterAssert(self.leftViewController);
    NSParameterAssert(self.centerViewController);
    
    self.maskingView.alpha = kTPDrawerControllerMaskingViewMaxAlpha;
    // Complete adding the left controller to the container
    [self.leftViewController didMoveToParentViewController:self];
    
    [self addClosingGestureRecognizers];
    
    // Keep track that the drawer is open
    self.drawerState = TPDrawerControllerStateOpened;
    
    // Notify the child view controllers that the drawer is open
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerDidOpen:)]) {
        [self.leftViewController drawerControllerDidOpen:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerDidOpen:)]) {
        [self.centerViewController drawerControllerDidOpen:self];
    }
}

#pragma mark - Closing the drawer

- (void)close
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateOpened);
    
    [self willClose];
    
    [self animateClosing];
    
}

- (void)willClose
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateOpened);
    NSParameterAssert(self.leftViewController);
    NSParameterAssert(self.centerViewController);
    
    // Start removing the left controller from the container
    [self.leftViewController willMoveToParentViewController:nil];
    
    // Keep track that the drawer is closing
    self.drawerState = TPDrawerControllerStateClosing;
    
    // Notify the child view controllers that the drawer is about to close
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerWillClose:)]) {
        [self.leftViewController drawerControllerWillClose:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerWillClose:)]) {
        [self.centerViewController drawerControllerWillClose:self];
    }
}

- (void)didClose
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateClosing);
    NSParameterAssert(self.leftView);
    NSParameterAssert(self.centerView);
    NSParameterAssert(self.leftViewController);
    NSParameterAssert(self.centerViewController);
    
    // Complete removing the left view controller from the container
    [self.leftViewController.view removeFromSuperview];
    [self.leftViewController removeFromParentViewController];
    [self.leftViewController didMoveToParentViewController:nil];
    
    // Remove the left view from the view hierarchy and masking view
    [self.leftView removeFromSuperview];
    [self.maskingView removeFromSuperview];
    
    [self removeClosingGestureRecognizers];
    
    // Keep track that the drawer is closed
    self.drawerState = TPDrawerControllerStateClosed;
    
    // Notify the child view controllers that the drawer is closed
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerDidClose:)]) {
        [self.leftViewController drawerControllerDidClose:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerDidClose:)]) {
        [self.centerViewController drawerControllerDidClose:self];
    }
}


- (void)reloadCenterViewControllerUsingBlock:(void (^)(void))reloadBlock
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateOpened);
    NSParameterAssert(self.centerViewController);
    
    [self willClose];
    

    if (reloadBlock) {
     reloadBlock();
    }
    // Finally, close the drawer
    [self animateClosing];

}

- (void)replaceCenterViewControllerWithViewController:(UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *)viewController
{
    NSParameterAssert(self.drawerState == TPDrawerControllerStateOpened);
    NSParameterAssert(viewController);
    NSParameterAssert(self.centerView);
    NSParameterAssert(self.centerViewController);
    
    [self willClose];
    
    CGRect f = self.centerView.frame;
    f.origin.x = self.view.bounds.size.width;
    
    [self.centerViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration: kTPDrawerControllerAnimationDuration / 2
                     animations:^{
                         self.centerView.frame = f;
                     }
                     completion:^(BOOL finished) {
                         // The center view controller is now out of sight
                         
                         // Remove the current center view controller from the container
                         if ([self.centerViewController respondsToSelector:@selector(setDrawer:)]) {
                             self.centerViewController.drawer = nil;
                         }
                         [self.centerViewController.view removeFromSuperview];
                         [self.centerViewController removeFromParentViewController];
                         
                         // Set the new center view controller
                         self.centerViewController = viewController;
                         if ([self.centerViewController respondsToSelector:@selector(setDrawer:)]) {
                             self.centerViewController.drawer = self;
                         }
                         
                         // Add the new center view controller to the container
                         [self addCenterViewController];
                         
                         // Finally, close the drawer
                         [self animateClosing];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
