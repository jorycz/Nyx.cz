//
//  ServerConnector.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerConnectorDelegate <NSObject>
- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification;
@end


@interface ServerConnector : NSObject


@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *identifitaion;


- (void)downloadDataForApiRequest:(NSString *)apiRequest;
- (void)downloadDataForApiRequestWithParameters:(NSDictionary *)params andAttachmentName:(NSArray *)attachmentNames;

- (void)downloadDataFromURL:(NSString *)urlStr;


@end
