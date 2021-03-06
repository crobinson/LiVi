//
//  AWSContentDeliveryViewController.m
//  MySampleApp
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.6
//
#import "ContentDeliveryViewController.h"

#import "AWSContentManager.h"

#import <MediaPlayer/MediaPlayer.h>

#import "AWSIdentityManager.h"

@interface ContentDeliveryViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AWSContentManager *manager;

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSString *marker;
@property (nonatomic, assign) BOOL didLoadAllContents;

@end

@interface NSString (ContentDeliveryViewController)

+ (NSString *)aws_stringFromByteCount:(NSUInteger)byteCount;

@end

@implementation ContentDeliveryViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.manager = [AWSContentManager sharedManager];

    // Sets up the UIs.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showContentManagerActionOptions:)];
    // Sets up the date formatter.
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    self.dateFormatter.timeStyle = kCFDateFormatterShortStyle;
    self.dateFormatter.locale = [NSLocale currentLocale];

    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self updateUserInterface];
    [self loadMoreContents];
}

- (void)updateUserInterface {
    self.cacheLimitLabel.text = [NSString aws_stringFromByteCount:self.manager.maxCacheSize];
    self.currentCacheSizeLabel.text = [NSString aws_stringFromByteCount:self.manager.cachedUsedSize];
    self.availableCacheSizeLabel.text = [NSString aws_stringFromByteCount:self.manager.maxCacheSize - self.manager.cachedUsedSize];
    self.pinnedCacheSizeLabel.text = [NSString aws_stringFromByteCount:self.manager.pinnedSize];

    if (!self.prefix) {
        self.pathLabel.text = @"/";
    }

    [self.tableView reloadData];
}

#pragma mark - Content Manager user action methods

- (void)showContentManagerActionOptions:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    __weak ContentDeliveryViewController *weakSelf = self;

    UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:@"Refresh"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [weakSelf refreshContents];
                                                          }];
    [alertController addAction:refreshAction];

    UIAlertAction *downloadObjectsAction = [UIAlertAction actionWithTitle:@"Download Recent"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [weakSelf downloadObjectsToFillCache];
                                                                  }];
    [alertController addAction:downloadObjectsAction];

    UIAlertAction *changeLimitAction = [UIAlertAction actionWithTitle:@"Set Cache Size"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [weakSelf showDiskLimitOptions];
                                                              }];
    [alertController addAction:changeLimitAction];



    UIAlertAction *removeAllObjectsAction = [UIAlertAction actionWithTitle:@"Clear Cache"
                                                                     style:UIAlertActionStyleDestructive
                                                                   handler:^(UIAlertAction *action) {
                                                                       [weakSelf.manager clearCache];
                                                                       [weakSelf updateUserInterface];
                                                                   }];
    [alertController addAction:removeAllObjectsAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)refreshContents {
    self.marker = nil;
    [self loadMoreContents];
}

- (void)loadMoreContents {
    __weak ContentDeliveryViewController *weakSelf = self;
    [self.manager listAvailableContentsWithPrefix:self.prefix
                                           marker:self.marker
                                completionHandler:^(NSArray *contents, NSString *nextMarker, NSError *error) {
                                    if (error) {
                                      [weakSelf showSimpleAlertWithTitle:@"Error"
                                                                 message:@"Failed to load the list of contents."
                                                       cancelButtonTitle:@"Okay"];
                                      NSLog(@"Failed to load the list of contents. %@", error);
                                  }
                                  if (contents.count > 0) {
                                      weakSelf.contents = contents;

                                      weakSelf.didLoadAllContents = !nextMarker;
                                      weakSelf.marker = nextMarker;
                                  }
                                  [weakSelf updateUserInterface];
                              }];
}

- (void)showDiskLimitOptions {
    __weak ContentDeliveryViewController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Disk Cache Size"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSNumber *number in @[@1, @5, @20, @50, @100]) {
        UIAlertAction *byteLimitOptionAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ MB", number]
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          weakSelf.manager.maxCacheSize = [number unsignedIntegerValue] * 1024 * 1024;
                                                                          [weakSelf updateUserInterface];
                                                                      }];
        [alertController addAction:byteLimitOptionAction];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)downloadObjectsToFillCache {
    __weak ContentDeliveryViewController *weakSelf = self;
    [self.manager listRecentContentsWithPrefix:self.prefix
                                       completionHandler:^(id result, NSError *error) {
                                           for (AWSContent *content in result) {
                                               if (!content.isCached
                                                   && !content.isDirectory) {
                                                   [weakSelf downloadContent:content
                                                             pinOnCompletion:NO];
                                            }
                                        }
                                    }];
}

#pragma mark - Content user action methods

- (void)showActionOptionsForContent:(AWSContent *)content {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    __weak ContentDeliveryViewController *weakSelf = self;

    if (content.isCached) {
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [weakSelf openContent:content];
                                                               });
                                                           }];
        [alertController addAction:openAction];
    }

    // If the content hasn't been downloaded, and it's larger than the limit of the cache,
    // we don't allow downloading the contentn.
    if (content.knownRemoteByteCount + 4 * 1024 < self.manager.maxCacheSize) { // 4 KB is for local metadata.
        NSString *title = @"Download";
        if ([content.knownRemoteLastModifiedDate compare:content.downloadedDate] == NSOrderedDescending) {
            title = @"Download Latest Version";
        }
        UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:title
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [weakSelf downloadContent:content
                                                                             pinOnCompletion:NO];
                                                               }];
        [alertController addAction:downloadAction];
    }

    UIAlertAction *downloadAndPinAction = [UIAlertAction actionWithTitle:@"Download & Pin"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     [weakSelf downloadContent:content
                                                                               pinOnCompletion:YES];
                                                                 }];
    [alertController addAction:downloadAndPinAction];

    if (content.isCached) {
        if (content.isPinned) {
            UIAlertAction *unpinAction = [UIAlertAction actionWithTitle:@"Unpin"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    [content unPin];
                                                                    [weakSelf updateUserInterface];
                                                                }];
            [alertController addAction:unpinAction];
        } else {
            UIAlertAction *pinAction = [UIAlertAction actionWithTitle:@"Pin"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [content pin];
                                                                  [weakSelf updateUserInterface];
                                                              }];
            [alertController addAction:pinAction];
        }

        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Delete Local Copy"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {
                                                                 [content removeLocal];
                                                                 [weakSelf updateUserInterface];
                                                             }];
        [alertController addAction:removeAction];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)downloadContent:(AWSContent *)content
        pinOnCompletion:(BOOL)pinOnCompletion {
    __weak ContentDeliveryViewController *weakSelf = self;
    [content downloadWithDownloadType:AWSContentDownloadTypeIfNewerExists
                      pinOnCompletion:pinOnCompletion
                        progressBlock:^(AWSContent *content, NSProgress *progress) {
                            if ([weakSelf.contents containsObject:content]) {
                                NSInteger row = [weakSelf.contents indexOfObject:content];
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                                            inSection:0];
                                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath]
                                                          withRowAnimation:UITableViewRowAnimationNone];
                            }
                        } completionHandler:^(AWSContent *content, NSData *data, NSError *error) {
                            if (error) {
                                NSLog(@"Failed to download a content from a server. %@", error);
                                [weakSelf showSimpleAlertWithTitle:@"Error"
                                                           message:@"Failed to download a content from a server."
                                                 cancelButtonTitle:@"Okay"];
                            }

                            [weakSelf updateUserInterface];
                        }];
}

- (void)openContent:(AWSContent *)content {
    if ([content.key hasSuffix:@".mov"]
        || [content.key hasSuffix:@".m4p"]
        || [content.key hasSuffix:@".m4v"]
        || [content.key hasSuffix:@".mp4"]
        || [content.key hasSuffix:@".mpv"]
        || [content.key hasSuffix:@".3gp"]
        || [content.key hasSuffix:@".mp3"]) { // Video and sound files
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectoryPath = [directories firstObject];
        NSURL *movieURL = [NSURL fileURLWithPath:[cacheDirectoryPath stringByAppendingPathComponent:content.key]];
        [content.cachedData writeToURL:movieURL atomically:YES];

        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc]initWithContentURL:movieURL];
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];

        [self presentMoviePlayerViewControllerAnimated:controller];
    } else if ([content.key hasSuffix:@".jpg"]
               || [content.key hasSuffix:@".png"]) { // Image files
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ContentDelivery" bundle:nil];
        ContentDeliveryImageViewController *imageViewController = [storyboard instantiateViewControllerWithIdentifier:@"ContentDeliveryImageViewController"];
        imageViewController.image = [UIImage imageWithData:content.cachedData];
        imageViewController.title = content.key;

        [self.navigationController pushViewController:imageViewController
                                             animated:YES];
    } else {
        [self showSimpleAlertWithTitle:@"Sorry!"
                               message:@"We can only open image, video, and sound files."
                     cancelButtonTitle:@"Okay"];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContentDeliveryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentDeliveryCell"
                                                                   forIndexPath:indexPath];
    AWSContent *content = self.contents[indexPath.row];

    cell.prefix = self.prefix;
    cell.content = content;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.contents.count - 1) {
        if (!self.didLoadAllContents) {
            [self loadMoreContents];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    AWSContent *content = self.contents[indexPath.row];
    if (content.isDirectory) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ContentDelivery"
                                                             bundle:nil];
        ContentDeliveryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ContentDeliveryViewController"];
        viewController.prefix = content.key;

        [self.navigationController pushViewController:viewController
                                             animated:YES];
    } else {
        [self showActionOptionsForContent:content];
    }
}

#pragma mark - Utility

- (void)showSimpleAlertWithTitle:(NSString *)title
                         message:(NSString *)message
               cancelButtonTitle:(NSString *)cancelTitle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end

@implementation ContentDeliveryCell

- (void)setContent:(AWSContent *)content {
    NSString *displayFilename = content.key;
    if (self.prefix) {
        displayFilename = [displayFilename substringFromIndex:self.prefix.length];
    }
    self.fileNameLabel.text = displayFilename;

    self.downloadedImageView.hidden = !content.isCached;
    self.keepImageView.hidden = !content.isPinned;

    NSUInteger contentByteCount = content.fileSize;
    if (contentByteCount == 0) {
        contentByteCount = content.knownRemoteByteCount;
    }
    if (content.isDirectory) {
        self.detailLabel.text = @"This is a folder";
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.detailLabel.text = [NSString aws_stringFromByteCount:contentByteCount];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([content.knownRemoteLastModifiedDate compare:content.downloadedDate] == NSOrderedDescending) {
        self.detailLabel.text = [NSString stringWithFormat:@"%@ - New Version Available", self.detailLabel.text];
        self.detailLabel.textColor = [UIColor blueColor];
    } else {
        self.detailLabel.textColor = [UIColor blackColor];
    }

    if (content.status == AWSContentStatusTypeRunning) {
        self.progressView.progress = content.progress.fractionCompleted;
        self.progressView.hidden = NO;
    } else {
        self.progressView.hidden = YES;
    }
}

@end

@implementation ContentDeliveryImageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.imageView.image = self.image;
}

@end

@implementation NSString (AWSContentDeliveryViewController)

+ (NSString *)aws_stringFromByteCount:(NSUInteger)byteCount {
    if (byteCount < 1024) {
        return [NSString stringWithFormat:@"%lu B", (unsigned long)byteCount];
    }
    if (byteCount < 1024 * 1024) {
        return [NSString stringWithFormat:@"%lu KB", (unsigned long)byteCount / 1024];
    }
    if (byteCount < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%lu MB", (unsigned long)byteCount / 1024 / 1024];
    }
    return [NSString stringWithFormat:@"%lu GB", (unsigned long)byteCount / 1024 / 1024 / 1024];
}

@end
