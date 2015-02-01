#import <Foundation/Foundation.h>

@interface AttributeValue : NSObject
{
    NSMutableArray *childValues;
}

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSObject *value;
@property (nonatomic, strong) AttributeValue *parent;
@property int sequence;
@property CGSize iconSize;
@property (nonatomic, strong) NSString *subtitle;
@property int badges;
@property (nonatomic, strong) NSString *iconImg;

//- (void) getDefinition : (NSDictionary *) def;
- (void) addChildValue :(AttributeValue *) childValue;
- (int) getLevel;
- (NSArray *) getChildren;

@end
