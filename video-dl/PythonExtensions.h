#import <Foundation/Foundation.h>

#import "Python.h"

id convertPyObject(PyObject *object);

@interface NSString (Python)

+(NSString *)stringWithPyUnicode:(PyObject *)object;
+(NSString *)stringWithPyString:(PyObject *)object;

@end

@interface NSNumber (Python)

+(NSNumber *)numberWithPyInt:(PyObject *)object;
+(NSNumber *)numberWithPyLong:(PyObject *)object;
+(NSNumber *)numberWithPyFloat:(PyObject *)object;

@end

@interface NSDictionary (Python)

+(NSDictionary *)dictionaryWithPyObject:(PyObject *)object;

@end

@interface NSArray (Python)

+(NSArray *)arrayWithPyObject:(PyObject *)object;

@end
