//
//  PeopleRespondVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "PeopleRespondVC.h"
#import "ComputeRowHeight.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"
#import <Photos/Photos.h>
#import "StorageManager.h"


@interface PeopleRespondVC ()

@end

@implementation PeopleRespondVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Detail";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        _firstInit = YES;
        _closingKeyboard = NO;
        _moveTableFirst = NO;
        _refreshFeedDetailPostDataForComments = NO;
        _postIdentificationTable = @"table";
        _postIdentificationPostFeedMessage = @"message";
        _postIdentificationPostMailboxMessage = @"mailMessage";
        _postIdentificationPostDiscussionMessage = @"discussionMessage";
        self.attachmentNames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.table = [[ContentTableWithPeople alloc] initWithRowHeight:70];
    self.table.allowsSelection = YES;
    self.table.canEditFirstRow = NO;
    self.table.nController = self.nController;
    
    // Set content to "DETAIL" - ignore cell tap in nested table (otherwise it would be infinite loop)
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeFeed]) {
        self.table.peopleTableMode = kPeopleTableModeFeedDetail;
    }
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeMailbox]) {
        self.table.peopleTableMode = kPeopleTableModeMailboxDetail;
    }
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeFriends]) {
        self.table.peopleTableMode = kPeopleTableModeFriendsDetail;
        self.title = @"Napsat zprávu";
    }
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion]) {
        self.table.peopleTableMode = kPeopleTableModeDiscussionDetail;
    }
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    
    self.responseView = [[UITextView alloc] init];
//    [self.responseView setTextContainerInset:(UIEdgeInsetsZero)];
    self.responseView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    self.responseView.clipsToBounds = YES;
    self.responseView.font = [UIFont systemFontOfSize:13];
    self.responseView.layer.cornerRadius = 6.0f;
    
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.backgroundColor = [UIColor clearColor];
    [self.sendButton setImage:[UIImage imageNamed:@"send"] forState:(UIControlStateNormal)];
    [self.sendButton addTarget:self action:@selector(sendResponse) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion])
    {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnSendButtonDetected:)];
        longPress.minimumPressDuration = kLongPressMinimumDuration;
        [self.sendButton addGestureRecognizer:longPress];
    }
    
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion]) {
        [self rightButtonIsAttachment:NO];
    }
    
    // RESTORE PREVIOUS text to respond view.
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion])
    {
        // Add respond variables to respond text input view AND previous messages if exist.
        if (self.nick && [self.nick length] > 0 && self.postId && [self.postId length] > 0)
        {
            _respondTo = [NSString stringWithFormat:@"{reply %@|%@}: ", [self.nick uppercaseString], self.postId];
        }
        
        NSMutableString *tmp = [[NSMutableString alloc] init];
        if ([self currentlyStoredMessages] && [[self currentlyStoredMessages] count] > 0)
        {
            for (NSDictionary *d in [self currentlyStoredMessages]) {
                [tmp appendString:[d objectForKey:@"text"]];
                if ([d objectForKey:@"attachment"])
                    [self.attachmentNames addObject:[d objectForKey:@"attachment"]];
            }
            if (_respondTo && [_respondTo length] > 0) {
                self.responseView.text = [NSString stringWithFormat:@"%@\n\n%@", tmp, _respondTo];
            } else {
                self.responseView.text = [NSString stringWithFormat:@"%@\n\n", tmp];
            }
        }
        else
        {
            if (_respondTo && [_respondTo length] > 0) {
                self.responseView.text = _respondTo;
            }
        }
    }
}

- (void)rightButtonIsAttachment:(BOOL)attachmentButton
{
    if (!attachmentButton) {
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                                                             target:self
                                                                                                                             action:@selector(chooseAttachment)];
    } else {
        UIImage *image = [UIImage imageNamed:@"attachment"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(removeAttachmentButton) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.nController.topViewController.navigationItem.rightBarButtonItem = barButtonItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_firstInit) {
        _firstInit = NO;
        CGRect f = self.view.frame;
        // - 65 is there because there is big avatar left of table cell body text view.
        _widthForTableCellBodyTextView = f.size.width - kWidthForTableCellBodyTextViewSubstract;
        
        CGFloat bottomBarHeight = f.size.height / 4;
        CGFloat edgeInsect = 10;
        CGFloat maxButtonSize = 70;
        
        self.bottomView.frame = CGRectMake(0, f.size.height - bottomBarHeight, f.size.width, bottomBarHeight);
        _bottomFrame = self.bottomView.frame;
        
        self.responseView.frame = CGRectMake(edgeInsect, edgeInsect, _bottomFrame.size.width - maxButtonSize - (3 * edgeInsect), bottomBarHeight - (2 * edgeInsect));
        
        self.sendButton.frame = CGRectMake(_bottomFrame.size.width - maxButtonSize - edgeInsect, bottomBarHeight / 2 - (maxButtonSize / 2), maxButtonSize, maxButtonSize);
        
        // 64 = navigation bar + status bar
        self.table.view.frame = CGRectMake(0, 64, f.size.width, f.size.height - 64 - bottomBarHeight);
        _tableFrame = self.table.view.frame;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeFeed]) {
        [self placeLoadingView];
        [self getAvatar];
        [self getFeedDetailPostData];
    }
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion]) {
        // All data required is already in properties. No loading needed to respond someone to mail.
        [self configureTableWithJson:nil];
    }
}

#pragma mark - DATA

- (void)getAvatar
{
    CacheManager *cm = [[CacheManager alloc] init];
    cm.delegate = self;
    [cm getAvatarForNick:self.nick];
}

- (void)getFeedDetailPostData
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *apiRequest = [ApiBuilder apiFeedOfFriendsPostsFor:self.nick withId:self.postId];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    sc.identifitaion = _postIdentificationTable;
    [sc downloadDataForApiRequest:apiRequest];
}

#pragma mark - LOADING VIEW

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.view viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}

#pragma mark - CACHE DELEGATE

- (void)cacheComplete:(NSData *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO ?
//        _avatarView.image = [UIImage imageWithData:cache];
    });
}

#pragma mark - BUTTON

- (void)sendResponse
{
    if ([self.responseView.text length] > 0)
    {
        if ([self currentlyStoredMessages] && [[self currentlyStoredMessages] count] > 0)
        {
            NSString *message = [NSString stringWithFormat:@"Bude odeslána tato zpráva včetně dalších odpovědí. Příloha bude odeslána pouze poslední přidaná."];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Odeslat tuto a všechny uložené zprávy?"
                                                                           message:message
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *sendAll = [UIAlertAction actionWithTitle:@"Odeslat vše" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [self send];
            }];
            [alert addAction:cancel];
            [alert addAction:sendAll];
            [self presentViewController:alert animated:YES completion:^{}];
        }
        else
        {
            [self send];
        }
    }
    else
    {
        PRESENT_ERROR(@"Chyba", @"Nemohu odeslat prázdnou zprávu.")
    }
}

- (void)send
{
    [self placeLoadingView];
    
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeFeed])
    {
        sc.identifitaion = _postIdentificationPostFeedMessage;
        NSString *apiRequest = [ApiBuilder apiFeedOfFriendsPostCommentAs:self.nick withId:self.postId sendMessage:self.responseView.text];
        [sc downloadDataForApiRequest:apiRequest];
    }
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeFriends])
    {
        sc.identifitaion = _postIdentificationPostMailboxMessage;
        if (!self.attachmentNames || [self.attachmentNames count] < 1) {
            NSString *apiRequest = [ApiBuilder apiMailboxSendTo:self.nick message:self.responseView.text];
            [sc downloadDataForApiRequest:apiRequest];
        } else {
            NSDictionary *apiRequest = [ApiBuilder apiMailboxSendWithAttachmentTo:self.nick message:self.responseView.text];
            [sc downloadDataForApiRequestWithParameters:apiRequest andAttachmentName:self.attachmentNames];
        }
    }
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion])
    {
        sc.identifitaion = _postIdentificationPostDiscussionMessage;
        NSDictionary *apiRequest = [ApiBuilder apiDiscussionSendWithAttachment:self.discussionId message:self.responseView.text];
        // self.attachmentNames can be nil.
        [sc downloadDataForApiRequestWithParameters:apiRequest andAttachmentName:self.attachmentNames];
    }
}

#pragma mark - SERVER API DELEGATE

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self removeLoadingView];
    });
    if (!data)
    {
        [self presentErrorWithTitle:@"Žádná data" andMessage:@"Nelze se připojit na server."];
    }
    else
    {
        JSONParser *jp = [[JSONParser alloc] initWithData:data];
        if (!jp.jsonDictionary)
        {
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorString);
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorDataString);
            [self presentErrorWithTitle:@"Chyba při parsování" andMessage:jp.jsonErrorString];
        }
        else
        {
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
//                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                if ([identification isEqualToString:_postIdentificationTable]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self configureTableWithJson:jp.jsonDictionary];
                    });
                }
                if ([identification isEqualToString:_postIdentificationPostFeedMessage]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _refreshFeedDetailPostDataForComments = YES;
                        [self closeKeyboard];
                        POST_NOTIFICATION_FRIENDS_FEED_CHANGED
                    });
                }
                if ([identification isEqualToString:_postIdentificationPostMailboxMessage]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self closeKeyboard];
                        [self.nController popViewControllerAnimated:YES];
                        POST_NOTIFICATION_MAILBOX_CHANGED
                    });
                }
                if ([identification isEqualToString:_postIdentificationPostDiscussionMessage]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self closeKeyboard];
                        [self.nController popViewControllerAnimated:YES];
                        POST_NOTIFICATION_DISCUSSION_LOAD_NEWER_FROM(self.postId)
                        // Delete stored messages.
                        [self deleteStoredMessages];
                    });
                }
            }
        }
    }
}

#pragma mark - RESULT

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PRESENT_ERROR(title, message)
    });
}

- (void)configureTableWithJson:(NSDictionary *)nyxDictionary
{
    // Response VC for Feed comments.
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeFeed])
    {
        NSMutableArray * postDictionaries = [[NSMutableArray alloc] init];
        [postDictionaries addObject:self.postData];
        [postDictionaries addObjectsFromArray:[[nyxDictionary objectForKey:@"data"] objectForKey:@"comments"]];
        
        if ([postDictionaries count] > 0)
        {
            // Add FEED post as first cell here also.
            [self.table.nyxSections removeAllObjects];
            [self.table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
            [self.table.nyxRowsForSections removeAllObjects];
            [self.table.nyxRowsForSections addObjectsFromArray:@[postDictionaries]];
            
            NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
            NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
            
            for (NSDictionary *d in postDictionaries)
            {
                // Calculate heights and create array with same structure just only for row height.
                // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
                ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"text"] forWidth:_widthForTableCellBodyTextView minHeight:40 inlineImages:nil];
                [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
                [tempArrayForRowBodyText addObject:rowHeight.attributedText];
            }
            [self.table.nyxPostsRowHeights removeAllObjects];
            [self.table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            [self.table.nyxPostsRowBodyTexts removeAllObjects];
            [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
    }
    // Response VC for Mailbox response.
    if ([self.peopleRespondMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleRespondMode isEqualToString:kPeopleTableModeDiscussion])
    {
        [self.table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        [self.table.nyxRowsForSections addObjectsFromArray:@[@[self.postData]]];
        [self.table.nyxPostsRowHeights addObjectsFromArray:@[@[[NSNumber numberWithFloat:self.bodyHeight]]]];
        [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[@[self.bodyText]]];
    }
    
    if (!self.table.view.window) {
        [self.view addSubview:self.table.view];
    } else {
        [self.table reloadTableData];
    }
    if (!self.bottomView.window) {
        [self.view addSubview:self.bottomView];
        [self.bottomView addSubview:self.responseView];
        [self.bottomView addSubview:self.sendButton];
    }
}

#pragma mark - KEYBOARD

- (void)closeKeyboard
{
    _closingKeyboard = YES;
    _moveTableFirst = YES;
    [self.responseView resignFirstResponder];
    [self.responseView setText:@""];
}

- (void)keyboardWillChangeFrame:(NSNotification *) notification
{
    // Last keyboard position was higher than current ? Move table first so user can't see empty space.
    if ([[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height < _keyboardSize.height) {
        _moveTableFirst = YES;
    }
    _keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self performSelectorOnMainThread:@selector(keyboardChanged) withObject:nil waitUntilDone:YES];
}

- (void)keyboardChanged
{
    if (_closingKeyboard) {
        // Set height of keyboard to 0.
        _keyboardSize = CGSizeMake(0, 0);
    }
    CGRect newFrameBottom = CGRectMake(_bottomFrame.origin.x, _bottomFrame.origin.y - _keyboardSize.height, _bottomFrame.size.width, _bottomFrame.size.height);
    CGRect newFrameTable = CGRectMake(_tableFrame.origin.x, _tableFrame.origin.y, _tableFrame.size.width, _tableFrame.size.height - _keyboardSize.height);
    if (_moveTableFirst) {
        self.table.view.frame = newFrameTable;
    }
    [UIView animateWithDuration:.4 animations:^{
        self.bottomView.frame = newFrameBottom;
    } completion:^(BOOL finished) {
        self.table.view.frame = newFrameTable;
    }];
    _closingKeyboard = NO;
    _moveTableFirst = NO;
    
    if (_refreshFeedDetailPostDataForComments) {
        _refreshFeedDetailPostDataForComments = NO;
        [self getFeedDetailPostData];
    }
}

#pragma mark - ATTACHMENT

- (void)chooseAttachment
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle =
    (UIImagePickerControllerSourceTypePhotoLibrary == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = imagePickerController.popoverPresentationController;
    presentationController.barButtonItem = self.nController.topViewController.navigationItem.rightBarButtonItem;  // display popover from the UIBarButtonItem as an anchor
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
    else if (status == PHAuthorizationStatusDenied) {
        PRESENT_ERROR(@"ACCESS ERROR", @"Access to Photo Library is denied.")
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self presentViewController:imagePickerController animated:YES completion:^{}];
            }
            else {
                PRESENT_ERROR(@"ACCESS ERROR", @"Access to Photo Library is denied.")
            }
        }];
    }
    else if (status == PHAuthorizationStatusRestricted) {
        PRESENT_ERROR(@"ACCESS ERROR", @"Access to Photo Library is restricted.")
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSURL *originalImage = [info valueForKey:UIImagePickerControllerImageURL];
    // Copy original image to cache directory
    StorageManager *sc = [[StorageManager alloc] init];
    [sc copyFileFromUrl:originalImage toCacheName:@"attachmentOriginal.jpg"];
    NSData *d = [sc readImage:@"attachmentOriginal.jpg"];
    UIImage *image = [UIImage imageWithData:d];
    
    // Sizes are * 2 in real. RESIZE HERE
    CGSize s = image.size;
    CGFloat w = s.width;
    CGFloat h = s.height;
    CGFloat i = 0.0f;
    if (w > h)
        i = 400 / w;
    if (h > w)
        i = 400 / h;
    CGSize newSize = CGSizeMake(w * i, h * i);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *newImageData = UIImageJPEGRepresentation(newImage, 0.8f);
    NSLog(@"%@ - %@ : Image size [%li] bytes.", self, NSStringFromSelector(_cmd), (long)[newImageData length]);
    
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *attachmentName = [NSString stringWithFormat:@"attachment_%@.jpg", timestamp];
    [sc storeImage:newImageData withName:attachmentName];
    _currentAttachmentName = attachmentName;
    [self.attachmentNames addObject:attachmentName];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self rightButtonIsAttachment:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)removeAttachmentButton
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Smazat přílohu?"
                                                                   message:@"Ke zprávě je přiložena příloha. Opravdu odstranit?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Smazat" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
//        [self.attachmentNames removeObject:_currentAttachmentName];
        [self.attachmentNames removeAllObjects];
        [self rightButtonIsAttachment:NO];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - LONG TAP ON SEND BUTTON - STORE TO SEND IT LATER

- (void)longPressOnSendButtonDetected:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        NSString *message = @"Tuto zprávu (včetně minulých, pokud existují) je možno uložit a přidávat k ní další odpovědi dalším lidem. Při odeslání jsou pak všechny odpovědi odeslány naráz. Již uložené zprávy nelze editovat.\nPřílohu je možno přidat k příspěvkům pouze jednu. Odešle se poslední přidaná.";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uložit, odeslat, nebo začít novou zprávu?"
                                                                       message:message
                                                                preferredStyle:(UIAlertControllerStyleActionSheet)];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
        UIAlertAction *store = [UIAlertAction actionWithTitle:@"Uložit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self storeCurrentMessageToPreferences];
        }];
        UIAlertAction *deleteAll = [UIAlertAction actionWithTitle:@"Smazat uložené a začít znova" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self deleteStoredMessages];
        }];
        UIAlertAction *sendNow = [UIAlertAction actionWithTitle:@"Odeslat" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self sendResponse];
        }];
        [alert addAction:cancel];
        [alert addAction:store];
        [alert addAction:deleteAll];
        [alert addAction:sendNow];
        [self presentViewController:alert animated:YES completion:^{}];
    }
}

- (NSArray *)currentlyStoredMessages
{
    NSArray *currentlyStoredMessages = [Preferences messagesForDiscussion:nil];
    return currentlyStoredMessages;
}

- (void)storeCurrentMessageToPreferences
{
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    NSDictionary *storedMessage;
    if ([self.attachmentNames lastObject]) {
        storedMessage = @{@"text": self.responseView.text, @"attachment": [self.attachmentNames lastObject]};
    } else {
        storedMessage = @{@"text": self.responseView.text};
    }
    [finalArray addObject:storedMessage];
    [Preferences messagesForDiscussion:finalArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeKeyboard];
        [self.nController popViewControllerAnimated:YES];
    });
}

- (void)deleteStoredMessages
{
    [Preferences messagesForDiscussion:(NSMutableArray *)@[]];
    self.responseView.text = _respondTo;
    [self.attachmentNames removeAllObjects];
}

@end




