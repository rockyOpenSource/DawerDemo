//
//  TPDrawerViewController.h
//  TPDrawerViewController
//
//  Created by Tpphha on 16/1/14.
//  Copyright © 2016年 Tpphha. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPDrawerViewController;
@protocol TPDrawerControllerChild;
@protocol TPDrawerControllerPresenting;
extern const CGFloat kTPDrawerControllerDrawerDepth;

@interface TPDrawerViewController : UIViewController
- (instancetype)initWithLeftViewController:(UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *)leftViewController
                      centerViewController:(UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *)centerViewController;


/**
 @name Drawer functionality
 */

/**
 Opens the drawer.
 
 Typically, you call this method as a result of tapping on a button in your center view controller.
 */
- (void)open;
/**
 Closes the drawer.
 
 Call this method when you want to programmatically close the drawer.
 Typically, this is the case of a tap in the left view controller leading to exactly the same center view controller currently shown.
 
 From the user's point of view, the result of calling this method is the same of tapping on the center view controller to close it.
 */
- (void)close;
/**
 Reloads the current center view controller and then closes the drawer.
 
 Call this method when you need to reload the contents of the current center view controller. The center view controller will be moved
 out of the right edge of the screen and the given `reloadBlock` will be then invoked. Finally, the drawer will be closed.
 
 @param reloadBlock The reload block
 */
- (void)reloadCenterViewControllerUsingBlock:(void (^)(void))reloadBlock;
/**
 Replaces the current center view controller with the given `viewController` and then closes the drawer.
 
 @param viewController The view controller object that will replace the current center view controller.
 */
- (void)replaceCenterViewControllerWithViewController:(UIViewController<TPDrawerControllerChild, TPDrawerControllerPresenting> *)viewController;

@end


@protocol TPDrawerControllerChild <NSObject>
@property(nonatomic, weak) TPDrawerViewController *drawer;
@end


@protocol TPDrawerControllerPresenting <NSObject>
@optional
/**
 Tells the child controller that the drawer controller is about to open.
 
 @param drawerController The drawer object that is about to open.
 */
- (void)drawerControllerWillOpen:(TPDrawerViewController *)drawerController;
/**
 Tells the child controller that the drawer controller has completed the opening phase and is now open.
 
 @param drawerController The drawer object that is now open.
 */
- (void)drawerControllerDidOpen:(TPDrawerViewController *)drawerController;
/**
 Tells the child controller that the drawer controller is about to close.
 
 @param drawerController The drawer object that is about to close.
 */
- (void)drawerControllerWillClose:(TPDrawerViewController *)drawerController;
/**
 Tells the child controller that the drawer controller has completed the closing phase and is now closed.
 
 @param drawerController The drawer object that is now closed.
 */
- (void)drawerControllerDidClose:(TPDrawerViewController *)drawerController;



@end