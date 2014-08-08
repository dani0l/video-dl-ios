#include "pyutils.h"

#include <stdio.h>

#include <wchar.h>

void py_path_append(wchar_t *new_dir)
{
	wchar_t *current_path = Py_GetPath();
	wchar_t *final_path = wcscat(wcscat(current_path, L":"), new_dir);
	wprintf(L"%s\n", final_path);
	PySys_SetPath(final_path);
}

void py_print(PyObject *object)
{
	PyObject_Print(object, stdout, 0);
}

void py_print_error()
{
	if (PyErr_Occurred()) PyErr_Print();
}
