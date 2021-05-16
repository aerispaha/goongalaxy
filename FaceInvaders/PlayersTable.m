//
//  GoonsTable.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 1/4/13.
//  Copyright (c) 2013 EychmoTech. All rights reserved.
//

#import "PlayersTable.h"

@implementation PlayersTable

@synthesize table;
@synthesize allData;
@synthesize filteredData;

//#define CELL_HEIGHT = 80;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
        gameFont = appDelegate.gameFont;//[[NSString alloc] initWithFormat:@"friendly robot"];
        
        NSMutableArray *unsortedData = [NSMutableArray arrayWithArray:appDelegate.faceDataArray];// [[[NSMutableArray alloc] initWithArray:appDelegate.faceDataArray] autorelease];//[[NSMutableArray alloc] initWithArray:appDelegate.faceDataArray];
        NSLog(@"unsorted data.\ncount: %d",[unsortedData count]);
        
        //sort the fb peeps by name
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        allData = [[NSMutableArray alloc] initWithArray:[unsortedData sortedArrayUsingDescriptors:sortDescriptors]];
        NSLog(@"sorted data.\ncount: %d",[allData count]);
        
        //Set up table dimensions etc
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect tableRect = CGRectMake(0, 0, winSize.width/2, winSize.height);
        table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        [table setTransform:transform];
        
        //set delegates and data source
        [table setDelegate:self];
        [table setDataSource:self];
        
        //Set up table characteristics
        table.backgroundColor = [UIColor clearColor];
        table.opaque = NO;
        table.backgroundView = nil;
        table.center = CGPointMake(winSize.height/2, winSize.width/4); //UIkit coordinates
        table.allowsMultipleSelection = NO;
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        //access FaceData
        //faceDataFiles = [[NSMutableArray alloc] initWithArray:
        //            [[NSFileManager defaultManager]contentsOfDirectoryAtPath:
        //             [FaceData faceDataDir] error:NULL]];
        
        //fd = [[FaceData alloc] init]; //needs to be released
        
        //SEARCH BAR STUFF
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, winSize.width/2, 40)];
        [searchBar  setDelegate:self];
        [searchBar  setBackgroundColor:[UIColor clearColor]];
        [searchBar  setBarStyle:UIBarStyleBlack];
        searchBar.showsCancelButton = YES;
        searchBar.showsScopeBar = YES;
        
        [table      setTableHeaderView:searchBar];
        table.contentOffset = CGPointMake(0, searchBar.frame.size.height);
        
        heroIndex = appDelegate.heroIndex;
        //[[SimpleAudioEngine sharedEngine] preloadEffect:@"generalClick.mp3"];
        
    }
    NSLog(@"Going to return PlayerTable");
    return self;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [[CCDirector sharedDirector] drawScene];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length == 0)
    {
        isFiltered = NO;
    }
    else
    {
        isFiltered = YES;
        filteredData = [[NSMutableArray alloc] init];
        
        
        for (FaceData *faceData in allData)
        {
            NSRange nameRange = [faceData.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [faceData.description rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [filteredData addObject:faceData];
            }
        }
    }
    
    [self.table reloadData];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)theSearchBar{
    
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)theSearchBar{
    NSLog(@"searchBAr Ended=%@",theSearchBar.text);
    [theSearchBar resignFirstResponder];
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    NSLog(@"searchBar Searched=%@",theSearchBar.text);
    [theSearchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar{
    [theSearchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int rowCount;
    if (isFiltered) {
        rowCount = [filteredData count];
    }else{
        rowCount = [allData count];
    }
    return rowCount;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.highlightedTextColor =  [UIColor yellowColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//UITableViewCellSelectionStyleGray;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
    }
    
    //Acces Data
    FaceData *cellFaceData;// = [[[FaceData alloc] init] autorelease];
    if (isFiltered) {
        cellFaceData = [filteredData objectAtIndex:indexPath.row];
    }else{
        cellFaceData = [allData objectAtIndex:indexPath.row];
    }
    
    UIImage *imgFromFile = [NSKeyedUnarchiver unarchiveObjectWithFile:cellFaceData.faceCroppedPath];
    cell.imageView.image = imgFromFile;//[UIImage imageWithContentsOfFile:cellFaceData.faceCroppedPath];//cellFaceData.faceCropped;
    cell.detailTextLabel.text = cellFaceData.name;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.font = [UIFont fontWithName:gameFont size:23];
    
    if ([cellFaceData.isHero intValue] == 1) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell.detailTextLabel.textColor = [UIColor yellowColor];
        NSLog(@"HERO %@ returned at index:%d", cellFaceData.name, indexPath.row);
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        NSLog(@"non hero %@ returned at index:%d", cellFaceData.name, indexPath.row);
    }
    
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// I THINK THIS WILL CRASH DURING A FILTERED TABLE, so forbidden. could fix pretty easily...
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    NSLog(@"trying to delete index row %d",indexPath.row);
    //FaceData *fd = [[FaceData alloc] init];
    FaceData *cellFaceData = [allData objectAtIndex:indexPath.row];
    NSLog(@"fd.filePath %d: %@",indexPath.row,cellFaceData.fileName);
    NSError *err;
    NSString *fdFilePath = [[FaceData faceDataDir] stringByAppendingPathComponent:cellFaceData.fileName];
    
    NSLog(@"faceDataFilePath: %@",fdFilePath);
    //NSLog(@"faceDataFiles count %d",[faceDataFiles count]);
    NSLog(@"fd.filePath %d: %@",indexPath.row,cellFaceData.fileName);
    
    if (editingStyle == UITableViewCellEditingStyleDelete && !isFiltered) {
        if ([allData count] >= 2) {//prevent whole table from being deleted
            
            // Delete the row from the data source
            [tableView beginUpdates];
            
            //delete the image associated with this faceData object
            [[NSFileManager defaultManager] removeItemAtPath:cellFaceData.faceCroppedPath error:&err];
            //delete faceData Object
            [[NSFileManager defaultManager] removeItemAtPath:fdFilePath error:&err];
            
            //NSLog(@"deleted %@ at path: %@", cellFaceData.name ,fdFilePath);
            //NSLog(@"allData object count:%d",[allData count]);
            [allData removeObjectAtIndex:indexPath.row];
            //NSLog(@"faceDataArray count:%d",[appDelegate.faceDataArray count]);
            appDelegate.faceDataArray = [allData copy]; //might be expensive
            //NSLog(@"deleted allData object. count:%d",[allData count]);
            //NSLog(@"faceDataArray count:%d",[appDelegate.faceDataArray count]);
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
            [tableView endUpdates];
            
            //faceDataFiles = [[NSMutableArray alloc] initWithArray:
            //                 [[NSFileManager defaultManager]contentsOfDirectoryAtPath:
            //                  [FaceData faceDataDir] error:NULL]];
            //NSLog(@"faceDataFiles count %d",[faceDataFiles count]);
        }
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    */
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textColor = [UIColor yellowColor];
    
    //first remove the previous hero with the existing heroIndex
    [self performSelectorInBackground:@selector(removeIndexFromActivePlayers:) withObject:[NSNumber numberWithInt:heroIndex]];
    
    //then save the new one
    [self performSelectorInBackground:@selector(addIndexToActivePlayers:) withObject:indexPath];
    
    [self clickSound];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
    [self performSelectorInBackground:@selector(removeIndexFromActivePlayers:) withObject:indexPath];
    
    [self clickSound];
    */
}
- (void)removeIndexFromActivePlayers:(NSNumber *)index{
    
    //update faceDataFile
    FaceData *cellFaceData = [allData objectAtIndex:[index integerValue]];
    NSString *fdFilePath = [[FaceData faceDataDir] stringByAppendingPathComponent:cellFaceData.fileName];
    NSNumber *num = [[[NSNumber alloc] initWithInt:0] autorelease];
    cellFaceData.isHero = num; //(NO)
    [NSKeyedArchiver archiveRootObject:cellFaceData toFile:fdFilePath];
    
    //update current array of faceObjects
    [allData replaceObjectAtIndex:[index integerValue] withObject:cellFaceData];
    appDelegate.faceDataArray = [allData copy];
    
    /*
    for (FaceData *fData in appDelegate.activeFaceDataArray) {
        //search by name for the faceData to remove from active array
        if ([fData.name isEqualToString:cellFaceData.name]) {
            [appDelegate.activeFaceDataArray removeObject:fData];
            break; //break out after removing to avoid enumerating a mutated array
        }
    }
    */
    [table cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[index integerValue] inSection:0]].detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
    NSLog(@"deselected %@:%d", cellFaceData.fileName, [cellFaceData.isActive intValue]);
}
- (void)addIndexToActivePlayers:(NSIndexPath *)index{
    
    //mark current faceData object as 'active'
    FaceData *cellFaceData = [allData objectAtIndex:index.row];
    NSNumber *num = [[NSNumber alloc] initWithInt:1];
    cellFaceData.isHero = num; /*(YES, is active)*/ [num release];
    
    //save the "active-marked" object to file
    NSString *fdFilePath = [[FaceData faceDataDir] stringByAppendingPathComponent:cellFaceData.fileName];
    [NSKeyedArchiver archiveRootObject:cellFaceData toFile:fdFilePath];
    
    //update table's array of faceObjects
    [allData replaceObjectAtIndex:index.row withObject:cellFaceData];
    appDelegate.faceDataArray = allData;//[allData copy];
    
    //appDelegate.activeFaceDataArray is updated at start of each game with [FaceData activeFaceDataArray],
    //which generates the active list based on the 'isActive' tag of each object in the "faceDataArray"
    heroIndex = index.row;
    appDelegate.heroIndex = heroIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:index.row forKey:@"heroIndex"];
    NSLog(@"\nselected: %@\n%@\nisActive:%d", cellFaceData.name, cellFaceData.fileName, [cellFaceData.isActive intValue]);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


- (void)returnToIntroScene{
    NSLog(@"return to game over called");
    //[scoresTable removeFromSuperview];
    //[[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)clickSound{
    [[SimpleAudioEngine sharedEngine] playEffect:@"generalClick.mp3"];
}
- (void)dealloc {
    //[fd release];
    //[scoresTable release];
    [gameFont release];
    [allData release];
    [filteredData release];
    [super dealloc];
    
}




@end
