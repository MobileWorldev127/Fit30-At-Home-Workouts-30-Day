//
//  FileUploader.m
//  flexter
//
//  Created by Anurag Tolety on 5/31/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "FileUploader.h"

// Location at which all the files to be uploaded will be stored
#define UPLOADS_FOLDER_NAME @"Uploads"

@interface FileUploader ()

@property (strong, nonatomic) NSString* localUploadFolderPath;

@end

@implementation FileUploader

+ (FileUploader*)sharedFileUploader
{
    static FileUploader *sharedFileUploader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFileUploader = [[self alloc] init];
        sharedFileUploader.uploading = NO;
    });
    return sharedFileUploader;
}

- (NSString *)localUploadFolderPath {
    if (!_localUploadFolderPath) {
        NSURL* baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] lastObject];
        _localUploadFolderPath = [baseURL.path stringByAppendingPathComponent:UPLOADS_FOLDER_NAME];
    }
    return _localUploadFolderPath;
}

+ (void)addToUploadQueueWithData:(NSData*)data ofType:(NSString*)extension forObjectOfType:(NSString*)type WithObjectId:(NSString*)objectId forKey:(NSString*)keyString inBackground:(BOOL)backgroundUpload
{
    
}

+ (void)startUploading
{
    if (![FileUploader sharedFileUploader].uploading) {
        // start uploading code
    }
}

+ (void)stopUploading
{
    
}


@end
