#import <UIKit/UIKit.h>
#import "VDVideoDL.h"

@interface VDDownloadViewController : UIViewController <UITextFieldDelegate, VDVideDLDelegate>

@property VDVideoDL *video_dl;
@property UITextField *urlTextField;
@property UILabel *progressLabel;
@property UIProgressView *progview;

-(void)downloadFromUrl:(NSString *)url;

@end
