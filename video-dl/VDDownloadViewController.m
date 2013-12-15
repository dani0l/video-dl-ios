#import "VDDownloadViewController.h"
#import "VDAppDelegate.h"


@implementation VDDownloadViewController
@synthesize urlTextField, progressLabel, progview;

-(void)setupView
{
	[self.view setBackgroundColor:[UIColor whiteColor]]; // otherwise parts of the view are gray
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.text = @"Enter the url to download:";
	urlTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	[urlTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[urlTextField setDelegate:self];
	progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	progview = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	progressLabel.hidden = progview.hidden = YES;


	// Start to build the constraints
	NSArray *subViews = @[urlTextField, label, progressLabel, progview];
	for (UIView *subView in subViews) {
		// otherwise we'll get a message saying that not all the constraints could be satisfied
		subView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:subView];
	}
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(label, urlTextField, progressLabel, progview);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[urlTextField]-|" options:0 metrics:nil views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progressLabel]-|" options:0 metrics:nil views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progview]-|" options:0 metrics:nil views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[label(==20)]-[urlTextField(==20)]-(>=100)-[progressLabel(==20)]-[progview]" options:0 metrics:nil views:viewsDictionary]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupView];
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

-(void)finishedDownloadingVideo:(VDVideo *)video
{
	[self.progressLabel setText:[NSString stringWithFormat:@"Finished: \"%@\"",video.title,nil]];
	[self.progview setHidden:YES];
	VDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.videoBrowser addVideo:video];
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

-(void)videoDL:(VDVideoDL *)videodl finishedDownloadForVideo:(VDVideo *)video
{
	[self performSelectorOnMainThread:@selector(finishedDownloadingVideo:) withObject:video waitUntilDone:NO];
}

@end
