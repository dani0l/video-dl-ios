import youtube_dl
import youtube_dl.version

ydl_version = youtube_dl.version.__version__

class VideoDL(youtube_dl.YoutubeDL):
    def __init__(self, params, hook):
        default_params = {
            'continuedl': True,
            'writeinfojson': True,
            'writethumbnail': True,
            # TODO: check certificates, it may require bundling *.pem files
            'nocheckcertificate': True,
        }
        default_params.update(params)
        super(VideoDL, self).__init__(default_params)
        self.add_default_info_extractors()
        self.add_progress_hook(hook)
