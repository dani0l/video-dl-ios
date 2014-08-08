video-dl-ios
============

# Building

Before you can build the app you have to follow some steps:

1. Fetch some resources: `./devscripts/update-submodules.sh`

2. Build the python library and create the python modules file hierarchy:

	```bash
	make all
	```

Then you can open the Xcode project and test it in the simulator.

# Updating youtube-dl

If you want to use the latest youtube-dl version, you can run `git submodule update --remote youtube-dl`. Be careful, because the api could have changed and it may not work.

# Copyright

The code is releades under the MIT License, the full license is available in the [LICENSE](LICENSE) file.
