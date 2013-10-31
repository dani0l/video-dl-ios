#import "VDVideoDL.h"
#import "VDAppDelegate.h"

#import "PythonExtensions.h"
#import "pyutils.h"


static PyObject *progress_hook(PyObject *self, PyObject *args)
{
	// It's not the best way to call the method in videodl,
	// but we can't use function pointers to Obj-C methods.
	VDVideoDL *videodl = [VDAppDelegate currentVideoDL];
	return  [videodl progressHookWithSelf:self AndArgs:args];
}


@implementation VDVideoDL
{
	VDVideo *currentVideo;
}

-(id)init
{
	self = [super init];
	if (self)
	{
		[self initPythonInterpreter];
		NSString *video_template = [[VDVideoDL videosFolder] stringByAppendingPathComponent:@"%(extractor)s-%(id)s.%(ext)s/%(extractor)s-%(id)s.%(ext)s"];

		// We create a module for holding the progress hook
		static PyMethodDef HooksMethods[] = {
			{"hook", progress_hook, METH_VARARGS, ""},
			{NULL, NULL, 0, NULL}
		};
		PyObject *hooks_module = Py_InitModule("vdl_hooks", HooksMethods);
		PyObject *hook = PyObject_GetAttrString(hooks_module, "hook");

		PyObject *videodl_mod = PyImport_ImportModule("video_dl");
		PyObject *VideoDL = PyObject_GetAttrString(videodl_mod, "VideoDL");
		PyObject *init_args = Py_BuildValue("sO", [video_template UTF8String], hook);
		vdl = PyObject_CallObject(VideoDL, init_args);


		youtube_dl_version = [NSString stringWithPyString:PyObject_GetAttrString(videodl_mod, "ydl_version")];
	}
	return self;
}

-(void)initPythonInterpreter
{
	NSString *program = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"];
	NSString *python_folder = [program stringByAppendingString:@"python"];
	NSString *python_modules = [python_folder stringByAppendingString:@"/modules"];
	// TODO: undo the cd
	// The initial python path python/pylib/lib is relative to the current directory (initially "/")
	chdir([program UTF8String]);
	Py_Initialize();
	py_path_append((char *)[python_modules UTF8String]);
}

-(void)testDownload
{
	py_print(PyObject_CallMethod(vdl, "test_hook", "()", NULL));
	[self downloadFromUrl:@"http://www.youtube.com/watch?v=BaW_jenozKc"];
	PRINT_PYERROR
}

-(PyObject *)progressHookWithSelf:(PyObject *)s AndArgs:(PyObject *)args
{
	PyObject *pyProgress;
	PyArg_ParseTuple(args, "O", &pyProgress);
	NSDictionary *progress = [NSDictionary dictionaryWithPyObject:pyProgress];
	NSString *filename = [progress objectForKey:@"filename"];
	NSString *status = [progress objectForKey:@"status"];
	if ([status isEqualToString:@"finished"]) {
		[self.delegate videoDL:self finishedDownloadForVideo:currentVideo];
		currentVideo = nil;
	}
	else {
		if (!currentVideo) {
			currentVideo = [[VDVideo alloc] initWithFolder:[filename stringByDeletingLastPathComponent]];
			[self.delegate videoDL:self startedDownloadForVideo:currentVideo];
		}
		[self.delegate videoDL:self reportsDownloadProgress:progress forVideo:currentVideo];
	}
	Py_RETURN_NONE;
}

-(void)downloadFromUrl:(NSString *)url
{
	PyObject_CallMethod(vdl, "extract_info", "(s)", [url UTF8String], NULL);
}

+(NSString *)videosFolder
{
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"videos"];
}

@end
