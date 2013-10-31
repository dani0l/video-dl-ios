#import <UIKit/UIKit.h>

#import "VDVideo.h"

@interface VDVideoBrowser : UITableViewController
{
	NSMutableArray *videos_folders;
	NSMutableDictionary *videos;
}

-(VDVideo *)videoInfoForVideo:(NSString *)videoFolder;

-(void)addVideo:(VDVideo *)video;

@end
