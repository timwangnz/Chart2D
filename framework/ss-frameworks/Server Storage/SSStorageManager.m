//
//  StorageManager.m
//  Anping Wang
//
//  Created by Anping Wang on 9/19/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSStorageManager.h"
#import "SSSecurityVC.h"
#import "DebugLogger.h"

@interface SSStorageManager ()
{
   
}
@end

@implementation SSStorageManager

static SSStorageManager *storageManager;

static NSString *_ROOT_PATH = @"Documents";
static NSString *_NS_PREFIX = @"SIX";

static NSString *_DEFAULT_DELIMITER_REPLACEMENT = @"_";

+ (SSStorageManager *) storageManager
{
    if (!storageManager)
    {
        storageManager = [[SSStorageManager alloc]init];
    }
    return storageManager;
}

- (void) cleanup
{
    [self clearAll];
}

- (NSURL*)applicationDirectory
{
    
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSFileManager*fm = [NSFileManager defaultManager];
    
    NSURL*   dirPath = nil;
    
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if ([appSupportDir count] > 0)
    {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];
        
        // If the directory does not exist, this method creates it.
        // This method call works in OS X 10.7 and later only.
        
        NSError* theError = nil;
        if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&theError])
        {
            // Handle the error.
            return nil;
        }
        //DebugLog(@"%@", dirPath);
    }
    return dirPath;
}

- (void) clearAll
{
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:_ROOT_PATH];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
    NSString *file;
    NSError *error = nil;
    while (file = [dirEnum nextObject])
    {
        NSString *filePath = [docsDir stringByAppendingPathComponent:file];
        [localFileManager removeItemAtPath:filePath error:&error];
        if (error)
        {
            DebugLog(@"%@", error);
        }
    }
}

//create a directory if does not exist yet
- (BOOL) createDirectoryForFile:(NSString *) fileName
{
    NSError *theError = nil;
    NSString *dirPath = fileName;
    NSArray *elements = [fileName componentsSeparatedByString:@"/"];
    NSString *file = [elements lastObject];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSRange range = {0, [dirPath length] - [file length] - 1};
    dirPath = [dirPath substringWithRange: range];
    BOOL worked = YES;
    if (![localFileManager fileExistsAtPath: dirPath ])
    {
        [localFileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&theError];
        if (theError)
        {
            DebugLog(@"%@", theError);
            worked = NO;
        }
    }
    return worked;
}

- (BOOL) createDirectory:(NSString *) fileName
{
    NSError *theError = nil;
   
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
  
    BOOL worked = YES;
    if (![localFileManager fileExistsAtPath: fileName ])
    {
        [localFileManager createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:&theError];
        if (theError)
        {
            DebugLog(@"%@", theError);
            worked = NO;
        }
    }
    return worked;
}

- (void) clearJson : (NSString *) uri
{
    NSString * fileName = [self getCacheFileName:uri];
    [self deleteLocalFile:[NSString stringWithFormat:@"%@.dic", fileName]];
}

- (void) save : (NSDictionary *) dictionary uri :(NSString *) uri
{
    NSString * fileName = [self getCacheFileName:uri];
    if([self createDirectoryForFile:fileName])
    {
        if(![dictionary writeToFile: [NSString stringWithFormat:@"%@.dic", fileName] atomically:TRUE])
        {
            DebugLog(@"%@%@\n%@", @"Failed to write to ", [NSString stringWithFormat:@"%@.dic", fileName], dictionary);
        }
    }
}

- (NSString *) getCacheFileName:(NSString *) uri
{
    NSString *filePath = [self getCachePath:_NS_PREFIX path:uri];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cachedFileName = [documentsDirectory stringByAppendingPathComponent:filePath];
    return cachedFileName;
}

- (void) clearContent : (NSString *) uri
{
    [self deleteLocalFile:[self getCacheFileName:uri]];
}

- (void) saveContent : (NSData *) data uri :(NSString *) uri
{
    NSError* error;
    NSString *filename = [self getCacheFileName:uri];
    if ([self createDirectoryForFile:filename])
    {
        [data writeToFile:filename options:NSDataWritingAtomic error:&error];
        if (error)
        {
            DebugLog(@"%@\%@", filename, error);
        }
    }
}

- (NSData *) readContent :(NSString *) uri
{
    return [NSData dataWithContentsOfFile:[self getCacheFileName:uri]];
}

- (void) delete:(NSString *) objectType
{
    [self deleteLocalFile:[NSString stringWithFormat:@"%@.dic", [self getCacheFileName:objectType]]];
}

- (NSDictionary *) read :(NSString *) uri
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@.dic", [self getCacheFileName:uri]]];
}

- (NSDictionary *) readFromResource :(NSString *) uri
{
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:uri ofType:@"dic"];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}


- (NSString *) getCachePath : (NSString *) prefix path : (NSString *) path
{
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@/%@%@", prefix,[SSSecurityVC username], _DEFAULT_DELIMITER_REPLACEMENT, path];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@"\"" withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@"*" withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@"." withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@" " withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@"&" withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@"?" withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@"=" withString:_DEFAULT_DELIMITER_REPLACEMENT];
    cachePath = [cachePath stringByReplacingOccurrencesOfString:@":" withString:_DEFAULT_DELIMITER_REPLACEMENT];
    return cachePath;
}

- (BOOL) deleteLocalFile:(NSString *) filename
{
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    
    NSError *error = nil;
    
    BOOL worked = [localFileManager removeItemAtPath:filename error:&error ];
    
    if (error)
    {
        DebugLog(@"%@", error);
        return NO;
    }
    return worked;
}


@end
