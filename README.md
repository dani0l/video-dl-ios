video-dl-ios
============

# Building

Before you can build the app you have to follow some steps:

1. Fetch some resources:

	```bash
	git submodule init && git submodule update
	cd python-embedded && git submodule init && git submodule update
	```

2. Build the python library and create the python modules file hierarchy:

	```bash
	make all
	```

The you can open the Xcode project and test it in the simulator.
