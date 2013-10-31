#import <UIKit/UIKit.h>

#import "VDVideoDL.h"
#import "VDDownloadViewController.h"
#import "VDVideoBrowser.h"

@interface VDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property VDDownloadViewController *downloadViewController;
@property VDVideoBrowser *videoBrowser;

+(VDVideoDL *)currentVideoDL;

@end
