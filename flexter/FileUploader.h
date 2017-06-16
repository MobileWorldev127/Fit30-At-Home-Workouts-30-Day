//
//  FileUploader.h
//  flexter
//
//  Created by Anurag Tolety on 5/31/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUploader : NSObject

@property (atomic) BOOL uploading;

+ (void)addToUploadQueueWithData:(NSData*)data ofType:(NSString*)extension forObjectOfType:(NSString*)type WithObjectId:(NSString*)objectId forKey:(NSString*)keyString inBackground:(BOOL)backgroundUpload;
+ (void)startUploading;
+ (void)stopUploading;

@end
