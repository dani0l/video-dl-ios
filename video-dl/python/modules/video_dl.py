import youtube_dl

ydl_version = youtube_dl.__version__

class VideoDL(youtube_dl.YoutubeDL):
    def __init__(self, params, hook):
        default_params = {
            'continuedl': True,
            'writeinfojson': True,
            'writethumbnail': True,
        }
        default_params.update(params)
        super(VideoDL, self).__init__(default_params)
        self.add_default_info_extractors()
        self.fd.add_progress_hook(hook)
