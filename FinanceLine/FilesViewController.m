//
//  FilesViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-10.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "FilesViewController.h"
#import "Constants.h"

@interface FilesViewController ()

@end

@implementation FilesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:NULL]
           mutableCopyWithZone:nil];
  
  UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newFile)];
  self.navigationItem.leftBarButtonItem = newButton;
  
  UIBarButtonItem *dupButton = [[UIBarButtonItem alloc] initWithTitle:@"Duplicate" style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(duplicateCurrent)];
  self.navigationItem.rightBarButtonItem = dupButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark File Actions

- (void)newFile {
  [self.fileDelegate newFile];
}

- (void)duplicateCurrent {
  [self.fileDelegate duplicateFile];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"fileCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  // Configure the cell...
  UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
  NSString *fileName = [files objectAtIndex:[indexPath row]];
  nameLabel.text = [fileName stringByDeletingPathExtension];

  return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
  NSString *fileName = [files objectAtIndex:indexPath.row];
  return ![fileName isEqualToString: kMainFileName];
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.fileDelegate deleteFile:[files objectAtIndex:indexPath.row]];
    [files removeObjectAtIndex:[indexPath row]];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *fileName = [files objectAtIndex:[indexPath row]];
  [self.fileDelegate openFile:fileName];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
