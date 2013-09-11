//
//  FilesViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-10.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilesControllerDelegate <NSObject>
- (void)openFile:(NSString*)fileName;
- (void)newFile;
- (void)duplicateFile;
- (void)deleteFile:(NSString*)fileName;
@end

@interface FilesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
  NSMutableArray *files;
}

@property (nonatomic, strong) id<FilesControllerDelegate> fileDelegate;

@end
