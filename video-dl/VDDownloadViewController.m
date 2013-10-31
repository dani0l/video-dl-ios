#import "VDDownloadViewController.h"

@implementation VDDownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.urlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.urlTextField.enablesReturnKeyAutomatically = YES;
	self.urlTextField.keyboardType = UIKeyboardTypeURL;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO: finalize the python interpreter?
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"%@", textField.text);
	[textField resignFirstResponder];
	[self downloadFromUrl:textField.text];
	return NO;
}

-(void)downloadFromUrl:(NSString *)url
{
	if (self.video_dl == nil) {
		self.video_dl = [[VDVideoDL alloc] init];
		self.video_dl.delegate = self;
	}
	[self.video_dl performSelectorInBackground:@selector(downloadFromUrl:) withObject:url];

}

-(void)reportProgress:(NSArray *)payload
{
	NSDictionary *progress = [payload objectAtIndex:0];
	VDVideo *video = [payload objectAtIndex:1];
	id _down = [progress objectForKey:@"downloaded_bytes"];
	id _total = [progress objectForKey:@"total_bytes"];
	if ((_total != [NSNull null]) && (_down != [NSNull null])) {
		float percent = [_down floatValue] / [_total floatValue];
		[self.progview setProgress:percent];
	}
}

-(void)startedDownloadingVideo:(VDVideo *)video
{
	[self.progview setProgress:0];
	[self.progview setHidden:NO];
	[self.progressLabel setText:[NSString stringWithFormat:@"Downloading: \"%@\"",video.title,nil]];
	[self.progressLabel setHidden:NO];
}

#pragma mark VDVideDLDelegate

-(void)videoDL:(VDVideoDL *) videodl startedDownloadForVideo:(VDVideo *)video
{
	[self performSelectorOnMainThread:@selector(startedDownloadingVideo:) withObject:video waitUntilDone:NO];
}

-(void)videoDL: videodl reportsDownloadProgress:(NSDictionary *)progress forVideo:(VDVideo *)video;
{
	NSArray *payload = @[progress, video];
	[self performSelectorOnMainThread:@selector(reportProgress:) withObject:payload waitUntilDone:NO];
}

@end
