#ifndef video_dl_pyutils_h
#define video_dl_pyutils_h

#import "Python.h"

void py_path_append(char *new_dir);
void py_print(PyObject *object);
void py_print_error();

#endif
