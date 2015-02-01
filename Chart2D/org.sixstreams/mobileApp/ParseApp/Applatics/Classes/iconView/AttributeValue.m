#import "AttributeValue.h"
#import "SSTableViewVC.h"

@implementation AttributeValue

-(void) getDefinition : (NSDictionary *) def
{
    if (def)
    {
        NSArray *attrDefs = (NSArray*)[def objectForKey:@"attributes"];
        if (attrDefs != nil)
        {
            for(NSObject *attrDef in attrDefs)
            {
                NSDictionary *item = (NSDictionary*) attrDef;
                NSString  *name = [item objectForKey:NAME];
                if ([name isEqualToString:self.name]) 
                {
                    NSString  *displayName = [item objectForKey:@"displayName"];
                    
                    self.displayName = displayName ? displayName : name;
                }
            }
        }
    }
}

- (int) getLevel
{
    if (self.parent == nil) {
        return 0;
    }
    
    if (self.parent) {
        return [self.parent getLevel] + 1;
    }
    return 0;
}

- (NSArray *) getChildren
{
    return childValues;
}
- (void) addChildValue:(AttributeValue *) childValue
{
    if(childValues == nil)
    {
        childValues = [[NSMutableArray alloc] init];
    }
    [childValues addObject:childValue];
}

@end
