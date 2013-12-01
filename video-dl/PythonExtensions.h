#import <Foundation/Foundation.h>

#import "Python.h"

id convertPyObject(PyObject *object);

@interface NSString (Python)

+(NSString *)stringWithPyUnicode:(PyObject *)object;
+(NSString *)stringWithPyString:(PyObject *)object;
-(PyObject *)pyObject;

@end

@interface NSNumber (Python)

+(NSNumber *)numberWithPyInt:(PyObject *)object;
+(NSNumber *)numberWithPyLong:(PyObject *)object;
+(NSNumber *)numberWithPyFloat:(PyObject *)object;
-(PyObject *)pyObject;

@end

@interface NSDictionary (Python)

+(NSDictionary *)dictionaryWithPyObject:(PyObject *)object;
-(PyObject *)pyObject;

@end

@interface NSArray (Python)

+(NSArray *)arrayWithPyObject:(PyObject *)object;
-(PyObject *)pyObject;

@end
