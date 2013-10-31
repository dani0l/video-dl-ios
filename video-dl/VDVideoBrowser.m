#import <MediaPlayer/MediaPlayer.h>

#import "VDVideoBrowser.h"
#import "VDVideoDL.h"

@implementation VDVideoBrowser

-(id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
	self = [super initWithNibName:name bundle:bundle];
	if (self) {
		NSArray *all_folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[VDVideoDL videosFolder] error:nil];

		videos_folders = [NSMutableArray array];
		for (NSString *folder in all_folders) {
			// The Finder tends to add this file, which would break the process
			// TODO: remove paths that are not directories
			if (![folder hasSuffix:@".DS_Store"]) [videos_folders addObject:folder];
		}
		videos = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"Videos";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// TODO: separate in groups sorted alphabetically
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videos_folders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"video-cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

	VDVideo *info = [self videoInfoForIndexPath:indexPath];
	cell.textLabel.text = info.title;
	cell.detailTextLabel.text = info.description;
	cell.imageView.image = [UIImage imageWithContentsOfFile:info.thumbnailPath];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	VDVideo *video = [self videoInfoForIndexPath:indexPath];
	NSURL *url = [NSURL fileURLWithPath:video.videoPath];
	MPMoviePlayerViewController *player =
	[[MPMoviePlayerViewController alloc] initWithContentURL:url];
	[self presentMoviePlayerViewControllerAnimated:player];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self removeVideoAtIndexPath:indexPath];
	}
}


#pragma mark Custom methods
-(NSString *)videoFolderForIndexPath:(NSIndexPath *)indexPath
{
	return [videos_folders objectAtIndex:indexPath.row];
}

-(VDVideo *)videoInfoForIndexPath:(NSIndexPath *)indexPath
{
	return [self videoInfoForVideo:[self videoFolderForIndexPath:indexPath]];
}

-(VDVideo *)videoInfoForVideo:(NSString *)videoFolder
{
	NSString *fullFolderPath = [[VDVideoDL videosFolder] stringByAppendingPathComponent:videoFolder];
	VDVideo *video = [videos objectForKey:videoFolder];
	if (video == nil) {
		video = [[VDVideo alloc] initWithFolder:fullFolderPath];
	}
	return video;
}

-(void)removeVideoAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *folder = [self videoFolderForIndexPath:indexPath];
	VDVideo *video = [self videoInfoForIndexPath:indexPath];
	[[NSFileManager defaultManager] removeItemAtPath:video.folder error:nil];
	[videos removeObjectForKey:folder];
	[videos_folders removeObject:folder];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)addVideo:(VDVideo *)video
{
	NSString *folder = [video.folder lastPathComponent];
	if ([videos_folders indexOfObject:folder] != NSNotFound) {
		return;
	}
	[videos_folders addObject:folder];
	[videos setObject:video forKey:folder];
	NSIndexPath *path = [NSIndexPath indexPathForRow:([videos_folders count] - 1) inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
