//
// AppliaticsExpressionParser.m
// Appliatics
//
//  Created by Anping Wang on 6/17/13.
//

#import "SSExpressionParser.h"

@implementation SSExpressionParser
//this does only do one attribute, will have to make sure we can handle more than one attr

+ (NSString *) toString:(id) value
{
    if (value == [NSNull null] || !value){
        value = @"";
    }
    if ([value isKindOfClass:[NSArray class]])
    {
        value = [value count] > 0 ? [value objectAtIndex:0] :@"";
    }
    return value;
}

+ (NSString *) parse:(NSString *) expression forObject:(id) entity
{
    if ([expression isEqual:[NSNull null]] || !expression)
    {
        return nil;
    }
    if ([entity isEqual:[NSNull null]] || !entity)
    {
        return nil;
    }
    NSString *format = expression;
    NSRange stringRange = NSMakeRange(0, [expression length]);
    
    NSRegularExpression* regexp = [[NSRegularExpression alloc] initWithPattern:@"#\\{.*?\\}"
                                                                       options:NSRegularExpressionCaseInsensitive error:nil];
    
    format = [regexp stringByReplacingMatchesInString:expression options:0 range:NSMakeRange(0, [expression length]) withTemplate:@"%@"];
    
    NSMutableArray *attributes = [NSMutableArray array];
    [regexp enumerateMatchesInString:expression
                             options:0
                               range:stringRange
                          usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange matchRange = [result rangeAtIndex:0];
         NSString* matchString = [expression substringWithRange:matchRange];
         NSRange attRange = {2, [matchString length] - 3};
         matchString = [matchString substringWithRange:attRange];
         
         [attributes addObject:matchString];
     }
     ];
    
    if ([attributes count] == 0)
    {
        //no expression found
        return expression;
    }
    
    
    //the following should be generalized
    if ([attributes count]==1)
    {
        id value = [entity objectForKey:[attributes objectAtIndex:0]];
        
        
        return [NSString stringWithFormat:format, [self toString:value ]];
    }
    
    if ([attributes count]==2)
    {
        
        id value = [entity objectForKey:[attributes objectAtIndex:0]];
        id value2 = [entity objectForKey:[attributes objectAtIndex:1]];
        
        
        return [NSString stringWithFormat:format, [self toString:value ], [self toString:value2 ]];
    }
    if ([attributes count]==3)
    {
        id value = [entity objectForKey:[attributes objectAtIndex:0]];
        id value2 = [entity objectForKey:[attributes objectAtIndex:1]];
        id value3 = [entity objectForKey:[attributes objectAtIndex:2]];
        
        return [NSString stringWithFormat:format, [self toString:value ], [self toString:value2 ], [self toString:value3 ]];
    }
    
    return nil;
}
@end
