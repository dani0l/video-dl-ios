#import "PythonExtensions.h"

id convertPyObject(PyObject *object)
{
	if (PyUnicode_Check(object)) return [NSString stringWithPyUnicode:object];
	else if (PyLong_Check(object)) return [NSNumber numberWithPyLong:object];
	else if (PyFloat_Check(object)) return [NSNumber numberWithPyFloat:object];
	else if (PyDict_Check(object)) return [NSDictionary dictionaryWithPyObject:object];
	else if (PyList_Check(object)) return [NSArray arrayWithPyObject:object];
	else if (object == Py_None) return  [NSNull null];
	return nil;
}

@implementation NSString (Python)

+(NSString *)stringWithPyUnicode:(PyObject *)object
{
	return [NSString stringWithUTF8String:PyUnicode_AsUTF8(object)];
}

-(PyObject *)pyObject
{
	return PyUnicode_FromString([self UTF8String]);
}

-(wchar_t *)wideString
{
    // http://minhdanh2002.blogspot.com/2011/12/converting-between-nsstring-and-c.html
    const char *temp = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned long bufflen = strlen(temp)+1;
    wchar_t *buffer = malloc(bufflen*sizeof(wchar_t));
    mbstowcs(buffer, temp, bufflen);
    return buffer;
}

@end

@implementation NSNumber (Python)

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
	Py_ssize_t len = PyList_Size(_items);
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
	Py_ssize_t len = PyList_Size(object);
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
