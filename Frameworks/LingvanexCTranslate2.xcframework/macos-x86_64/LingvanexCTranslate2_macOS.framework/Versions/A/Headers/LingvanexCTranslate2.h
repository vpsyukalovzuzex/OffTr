//
// LingvanexCTranslate2.h
//

#import <Foundation/Foundation.h>

@interface LingvanexCTranslate2 : NSObject

- (instancetype)init;

- (void)setupWithPath:(NSString *)path
             fromCode:(NSString *)fromCode
               toCode:(NSString *)toCode;

- (NSString *)translatedWithString:(NSString *)string;

@end
