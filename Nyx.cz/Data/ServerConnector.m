//
//  ServerConnector.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ServerConnector.h"
#import "Constants.h"
#import "StorageManager.h"

// mime
#import <MobileCoreServices/MobileCoreServices.h>

@implementation ServerConnector

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - UTILITY for BINARY API CALLS

// POST DATA & BINARY https://stackoverflow.com/questions/24250475/post-multipart-form-data-with-objective-c

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName {
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    for (NSString *path in paths)
    {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        NSLog(@"%@ - %@ ADDING : [%@]", self, NSStringFromSelector(_cmd), filename);
        
//        NSLog(@"PATH %@", path);
//        NSLog(@"FILENAME %@", filename);
//        NSLog(@"MIMETYPE %@", mimetype);
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

#pragma mark - API CALLS - BINARY

- (void)downloadDataForApiRequestWithParameters:(NSDictionary *)params andAttachmentName:(NSArray *)attachmentNames
{
//    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), params);
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerAPIURL]
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                              timeoutInterval:10];
    [mutableRequest setHTTPMethod:@"POST"];
 
    NSString *boundary = [self generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [mutableRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSData *httpBody;
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    if (attachmentNames && [attachmentNames count] > 0)
    {
        for (NSInteger i = 0 ; i < [attachmentNames count]; i++) {
            StorageManager *sm = [[StorageManager alloc] init];
            NSString *path = [NSString stringWithFormat:@"%@/%@", sm.imageCacheRoot, [attachmentNames objectAtIndex:i]];
            [paths addObject:path];
        }
        httpBody = [self createBodyWithBoundary:boundary parameters:params paths:paths fieldName:@"attachment"];
    } else {
        httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[] fieldName:@"attachment"];
    }
    [mutableRequest setHTTPBody:httpBody];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:mutableRequest
                                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                             {
                                                 if (error)
                                                 {
                                                     NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
                                                     [self downloadDidEndWithData:nil forIdentification:self.identifitaion];
                                                 }
                                                 else
                                                 {
                                                     // **** DEBUG ****
                                                     //            NSLog(@"= DEBUG: %@: Response length %lu", [self class], (unsigned long)[data length]);
                                                     //            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                     //            NSLog(@"= DEBUG: DATA [%@]", dataString);
                                                     // **** DEBUG ****
                                                     [self downloadDidEndWithData:data forIdentification:self.identifitaion];
                                                 }
                                             }];
    [sessionDataTask resume];
}

#pragma mark - API CALLS - ENCODED URL

- (void)downloadDataForApiRequest:(NSString *)apiRequest
{
    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), apiRequest);
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerAPIURL]
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                              timeoutInterval:10];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:[apiRequest dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:mutableRequest
                                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                             {
                                                 if (error)
                                                 {
                                                     NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
                                                     [self downloadDidEndWithData:nil forIdentification:self.identifitaion];
                                                 }
                                                 else
                                                 {
                                                     // **** DEBUG ****
                                                     //            NSLog(@"= DEBUG: %@: Response length %lu", [self class], (unsigned long)[data length]);
                                                     //            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                     //            NSLog(@"= DEBUG: DATA [%@]", dataString);
                                                     // **** DEBUG ****
                                                     [self downloadDidEndWithData:data forIdentification:self.identifitaion];
                                                 }
                                             }];
    [sessionDataTask resume];
}

#pragma mark - URL DOWNLOAD

- (void)downloadDataFromURL:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                              timeoutInterval:10];
    [mutableRequest setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:mutableRequest
                                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                             {
                                                 if (error)
                                                 {
                                                     NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
                                                     [self downloadDidEndWithData:nil forIdentification:self.identifitaion];
                                                 }
                                                 else
                                                 {
                                                     // **** DEBUG ****
                                                     //            NSLog(@"= DEBUG: %@: Response length %lu", [self class], (unsigned long)[data length]);
                                                     //            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                     //            NSLog(@"= DEBUG: DATA [%@]", dataString);
                                                     // **** DEBUG ****
                                                     [self downloadDidEndWithData:data forIdentification:self.identifitaion];
                                                 }
                                             }];
    [sessionDataTask resume];
}

#pragma mark - DELEGATE

- (void)downloadDidEndWithData:(NSData *)data forIdentification:(NSString *)identification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFinishedWithData:withIdentification:)])
    {
        [self.delegate performSelector:@selector(downloadFinishedWithData:withIdentification:) withObject:data withObject:self.identifitaion];
    }
}

@end
