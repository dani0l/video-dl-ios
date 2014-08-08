#import "VDVideoDL.h"
#import "VDAppDelegate.h"

#import "PythonExtensions.h"
#import "pyutils.h"


struct VDHooks_module_state {
    PyObject *error;
};

#define GETSTATE(m) ((struct VDHooks_module_state*)PyModule_GetState(m))

static PyObject *progress_hook(PyObject *self, PyObject *args)
{
	// It's not the best way to call the method in videodl,
	// but we can't use function pointers to Obj-C methods.
	VDVideoDL *videodl = [VDAppDelegate currentVideoDL];
	return  [videodl progressHookWithSelf:self AndArgs:args];
}

static PyMethodDef VDHooks_Methods[] = {
    {"hook", progress_hook, METH_VARARGS, ""},
    {NULL, NULL, 0, NULL}
};

static int VDHooks_traverse(PyObject *m, visitproc visit, void *arg) {
    Py_VISIT(GETSTATE(m)->error);
    return 0;
}

static int VDHooks_clear(PyObject *m) {
    Py_CLEAR(GETSTATE(m)->error);
    return 0;
}

static struct PyModuleDef VDHooks_moduledef = {
    PyModuleDef_HEAD_INIT,
    "vdl_hooks",
    NULL,
    sizeof(struct VDHooks_module_state),
    VDHooks_Methods,
    NULL,
    VDHooks_traverse,
    VDHooks_clear,
    NULL
};


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

		PyObject *hooks_module = PyModule_Create(&VDHooks_moduledef);
		PyObject *hook = PyObject_GetAttrString(hooks_module, "hook");

		PyObject *videodl_mod = PyImport_ImportModule("video_dl");
		if (!videodl_mod) {
			NSLog(@"Unable to import 'video_dl' module:");
			py_print_error();
			abort(); // We should never get there with a tested build, but if there are some missing python modules we'll hit this
		}
		PyObject *VideoDL = PyObject_GetAttrString(videodl_mod, "VideoDL");
		NSDictionary *params = @{@"outtmpl": video_template};
		PyObject *init_args = Py_BuildValue("OO", [params pyObject], hook);
		vdl = PyObject_CallObject(VideoDL, init_args);


		youtube_dl_version = [NSString stringWithPyUnicode:PyObject_GetAttrString(videodl_mod, "ydl_version")];
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
	py_path_append((wchar_t *)[python_modules cStringUsingEncoding:NSUTF32LittleEndianStringEncoding]);
}

-(void)testDownload
{
	NSString *test_url;
	test_url = @"http://www.youtube.com/watch?v=BaW_jenozKc";
	[self downloadFromUrl:test_url];
	py_print_error();
}

-(PyObject *)progressHookWithSelf:(PyObject *)s AndArgs:(PyObject *)args
{
	PyObject *pyProgress;
	PyArg_ParseTuple(args, "O", &pyProgress);
	NSDictionary *progress = [NSDictionary dictionaryWithPyObject:pyProgress];
	NSString *filename = [progress objectForKey:@"filename"];
	NSString *status = [progress objectForKey:@"status"];
	if (!currentVideo) {
		currentVideo = [[VDVideo alloc] initWithFolder:[filename stringByDeletingLastPathComponent]];
		[self.delegate videoDL:self startedDownloadForVideo:currentVideo];
	}
	if ([status isEqualToString:@"finished"]) {
		[self.delegate videoDL:self finishedDownloadForVideo:currentVideo];
		currentVideo = nil;
	}
	else {
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
