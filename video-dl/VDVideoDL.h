#import <Foundation/Foundation.h>

#import "Python.h"
#import "VDVideo.h"

@protocol VDVideDLDelegate;

@interface VDVideoDL : NSObject
{
	PyObject *vdl;
	NSString *youtube_dl_version;
}

@property id<VDVideDLDelegate> delegate;

-(void)testDownload;

-(PyObject *)progressHookWithSelf:(PyObject *)s AndArgs:(PyObject *)args;

-(void)downloadFromUrl:(NSString *)url;

+(NSString *)videosFolder;

@end


@protocol VDVideDLDelegate <NSObject>

@required
-(void)videoDL:(VDVideoDL *) videodl startedDownloadForVideo:(VDVideo *)video;
-(void)videoDL:(VDVideoDL *) videodl reportsDownloadProgress:(NSDictionary *)progress forVideo:(VDVideo *)video;
-(void)videoDL:(VDVideoDL *) videodl finishedDownloadForVideo:(VDVideo *)video;

@end
