#import "PythonExtensions.h"

id convertPyObject(PyObject *object)
{
	if (PyUnicode_Check(object)) return [NSString stringWithPyUnicode:object];
	else if (PyInt_Check(object)) return [NSNumber numberWithPyInt:object];
	else if (PyLong_Check(object)) return [NSNumber numberWithPyLong:object];
	else if (PyFloat_Check(object)) return [NSNumber numberWithPyFloat:object];
	else if (PyString_Check(object)) return [NSString stringWithPyString:object];
	else if (PyDict_Check(object)) return [NSDictionary dictionaryWithPyObject:object];
	else if (PyList_Check(object)) return [NSArray arrayWithPyObject:object];
	else if (object == Py_None) return  [NSNull null];
	return nil;
}

@implementation NSString (Python)

+(NSString *)stringWithPyUnicode:(PyObject *)object
{
	return [NSString stringWithPyString:PyUnicode_AsUTF8String(object)];
}

+(NSString *)stringWithPyString:(PyObject *)object
{
	return [NSString stringWithUTF8String:PyBytes_AsString(object)];
}

-(PyObject *)pyObject
{
	return PyUnicode_FromString([self UTF8String]);
}

@end

@implementation NSNumber (Python)

+(NSNumber *)numberWithPyInt:(PyObject *)object
{
	return [NSNumber numberWithLong:PyLong_AsLong(object)];
}

+(NSNumber *)numberWithPyLong:(PyObject *)object
{
	return [NSNumber numberWithLongLong:PyLong_AsLongLong(object)];
}

+(NSNumber *)numberWithPyFloat:(PyObject *)object
{
	return [NSNumber numberWithDouble:PyFloat_AsDouble(object)];
}


-(PyObject *)pyObject
{
	return PyFloat_FromDouble([self doubleValue]);
}

@end

@implementation NSDictionary (Python)

+(NSDictionary *)dictionaryWithPyObject:(PyObject *)object
{
	PyObject *_items = PyDict_Items(object);
	int len = PyList_Size(_items);
	NSMutableDictionary *res = [NSMutableDictionary dictionaryWithCapacity:len];
	for (int i=0; i<len; i++) {
		PyObject *item = PyList_GetItem(_items, i);
		PyObject *_key = PyTuple_GetItem(item, 0);
		PyObject *_value = PyTuple_GetItem(item, 1);
		id key = convertPyObject(_key);
		id value = convertPyObject(_value);
		[res setObject:value forKey:key];
	}
	return res;
}

-(PyObject *)pyObject
{
	PyObject *dict = PyDict_New();
	for (id key in self) {
		id value = self[key];
		PyDict_SetItem(dict, [key pyObject], [value pyObject]);
	}
	return dict;
}

@end

@implementation NSArray (Python)

+(NSArray *)arrayWithPyObject:(PyObject *)object
{
	int len = PyList_Size(object);
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:len];
	for (int i=0; i<len; i++) {
		PyObject *item = PyList_GetItem(object, i);
		[res setObject:convertPyObject(item) atIndexedSubscript:i];
	}
	return res;
}

-(PyObject *)pyObject
{
	PyObject *list = PyList_New(0);
	for (id element in self) PyList_Append(list, [element pyObject]);
	return list;
}

@end
