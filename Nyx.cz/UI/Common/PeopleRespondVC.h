//
//  PeopleRespondVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheManager.h"
#import "ServerConnector.h"
#import "JSONParser.h"
#import "ApiBuilder.h"

#import "ContentTableWithPeople.h"


@interface PeopleRespondVC : UIViewController <CacheManagerDelegate, ServerConnectorDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _widthForTableCellBodyTextView;
    CGSize _keyboardSize;
    BOOL _firstInit, _closingKeyboard, _moveTableFirst, _refreshFeedDetailPostDataForComments;
    
    CGRect _bottomFrame;
    CGRect _tableFrame;
    
    NSString *_postIdentificationTable, *_postIdentificationPostFeedMessage, *_postIdentificationPostMailboxMessage, *_postIdentificationPostDiscussionMessage;
    NSString *_currentAttachmentName;
    NSString *_respondTo;
}


@property (nonatomic , strong) UINavigationController *nController;
@property (nonatomic, strong) ServerConnector *sc;

@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSAttributedString *bodyText;
@property (nonatomic, assign) CGFloat bodyHeight;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *discussionId;
@property (nonatomic, strong) ContentTableWithPeople *table;

@property (nonatomic, strong) NSDictionary *postData;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITextView *responseView;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) NSString *peopleRespondMode;

@property (nonatomic, strong) NSMutableArray *attachmentNames;

@end
