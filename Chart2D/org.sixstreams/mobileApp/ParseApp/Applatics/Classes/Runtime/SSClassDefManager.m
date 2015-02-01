#import "SSClassDefManager.h"
#import "SSClassDef.h"
#import "SSProperty.h"
#import "SSObject.h"

@interface SSClassDefManager()
{
    NSMutableDictionary *objects;
    int i;
}

@end

@implementation SSClassDefManager

static SSClassDefManager * singleInstance;

+ (SSClassDefManager *) instance
{
    if (!singleInstance)
    {
        singleInstance = [[SSClassDefManager alloc]init];
    }
    return singleInstance;
}

- (NSString *) description
{
    NSMutableString *desc = [[NSMutableString alloc]init];
    [desc appendFormat:@"Objects:%@", objects];
    return desc;
}

- (SSClassDef *) definitionOf:(NSString *)className
{
    return [objects valueForKey:className];
}

- (SSObject *) createInstanceOfType:(NSString *) name
{
    SSClassDef * classDef = [self definitionOf:name];
    if(classDef == nil)
    {
        classDef = [SSClassDef object:name];
        //
    }
    SSObject *instance = [[SSObject alloc]init];
    instance.definition = classDef;
    
    return instance;
}

#define CRM @"org.sixstreams.crm"
#define HCM @"org.sixstreams.hcm"
#define SCM @"org.sixstreams.scm"

- (void) addWidget:(NSString *) name
            view:(NSString *) viewId
          type:(NSString *)type //entity/list
              desc:(NSString *) desc
           dataUrl:(NSString *) url
{
    [[[[[self instance:@"Widget" name:name desc:desc] setObject:viewId forKey:@"parentId"] setObject:type forKey:@"type"] setObject:url forKey:@"dataUrl"] save];
}

- (void) addColumn:(NSString *) parentId name :(NSString *) name binding:(NSString *) binding dataType:(NSString *) dataType metaType:(NSString *) metaType
{
    [[[[[[self instance:@"ColumnDef" name:name desc:@""] setObject:dataType forKey:DATA_TYPE]
        setObject:metaType forKey:META_TYPE] setObject:parentId forKey:@"parentId"]
        setObject:binding forKey:@"binding"] save];
}

- (SSObject *) instance:(NSString *) className name:(NSString *) name desc:(NSString *)desc
{
    SSObject *object = [self createInstanceOfType:className];
    [object setObject:desc forKey:DESC];
    [object setObject:name forKey:NAME];    [object setObject:@"anpwang" forKey:AUTHOR];
    [object setObject:[NSNumber numberWithInt:i++] forKey:SEQUENCE];
   
    return object;
}

@end
