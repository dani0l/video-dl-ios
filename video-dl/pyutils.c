#include "pyutils.h"

void py_print(PyObject *object)
{
	PyObject_Print(object, stdout, 0);
}

void py_print_error()
{
	if (PyErr_Occurred()) PyErr_Print();
}
