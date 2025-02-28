//
//  PeopleRespondVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConnector.h"
#import "JSONParser.h"
#import "ApiBuilder.h"

#import "ContentTableWithPeople.h"


@interface PeopleRespondVC : UIViewController <ServerConnectorDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>
{
    CGFloat _widthForTableCellBodyTextView;
    CGSize _keyboardSize;
    BOOL _firstInit, _closingKeyboard, _moveTableFirst, _refreshFeedDetailPostDataForComments;
    
    CGRect _bottomFrame;
    CGRect _tableFrame;
    
    NSString *_postIdentificationTable, *_postIdentificationPostFeedMessage, *_postIdentificationPostMailboxMessage, *_postIdentificationPostDiscussionMessage, *_postIdentificationPostReaction;
    NSString *_currentAttachmentName;
    NSString *_respondTo;
    NSString *_discussionId;
    
    NSMutableArray *_reactionsToDownload, *_nyxRowsForSection, *_nyxRowHeights, *_nyxTexts;
}


@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITextView *responseView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *manageButton;

@property (nonatomic , strong) UINavigationController *nController;
@property (nonatomic, strong) ServerConnector *sc;

@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSAttributedString *bodyText;
@property (nonatomic, strong) NSString *bodyTextSource;
@property (nonatomic, assign) CGFloat bodyHeight;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *firstDiscussionPostId;
@property (nonatomic, strong) NSArray *previousReactions;

@property (nonatomic, strong) ContentTableWithPeople *table;

@property (nonatomic, strong) NSDictionary *postData;

@property (nonatomic, strong) NSString *peopleRespondMode;

@property (nonatomic, strong) NSMutableArray *attachmentNames;

@property (nonatomic, strong) NSDictionary *disscussionClubData;


@end
