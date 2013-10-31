#import <UIKit/UIKit.h>
#import "VDVideoDL.h"

@interface VDDownloadViewController : UIViewController <UITextFieldDelegate, VDVideDLDelegate>

@property  VDVideoDL *video_dl;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progview;

-(void)downloadFromUrl:(NSString *)url;

@end
