//
//  FBPlayerPicker.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/21/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "FBPlayerPicker.h"

@implementation FBPlayerPicker
@synthesize table;
@synthesize filteredData;
@synthesize allData;
#define degreesToRadians(x) (M_PI * x / 180.0)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        }
    
    return self;
}
- (id)initWithData:(NSArray *)data{
    self = [super init];
    if (self) {
        // Initialization code
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
        gameFont =  appDelegate.gameFont;//[[NSString alloc] initWithFormat:@"friendly robot"];
        NSMutableArray *unsortedData = [[[NSMutableArray alloc] initWithArray:data] autorelease];
        NSLog(@"unsorted data.\ncount: %d",[unsortedData count]);
        
        //sort the fb peeps by name
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        allData = [[NSMutableArray alloc] initWithArray:[unsortedData sortedArrayUsingDescriptors:sortDescriptors]];
        
        
        NSLog(@"allData sorted.\ncount: %d",[allData count]);
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect tableRect = CGRectMake(0, 0, winSize.width/2, winSize.height);
        
        table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        [table setTransform:transform];
        
        [table setDelegate:self];
        [table setDataSource:self];
        
        
        //Make the table transparent
        table.backgroundColor = [UIColor clearColor];
        table.opaque = NO;
        table.backgroundView = nil;
        table.center = CGPointMake(winSize.height/2, winSize.width/4); //UIkit coordinates

        table.allowsMultipleSelection = NO;
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        //SEARCH BAR STUFF
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, winSize.width/2, 40)];
        [searchBar setDelegate:self];
        [searchBar setBackgroundColor:[UIColor clearColor]];
        [searchBar setBarStyle:UIBarStyleBlack];
        searchBar.showsCancelButton = YES;
        searchBar.showsScopeBar = YES;
        
        [table setTableHeaderView:searchBar];
        
        fb = [[Facebook alloc] init];
        fb = appDelegate.facebook;
        
        //status stuff
        //activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        inPlayerArrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        inPlayerArrayView.backgroundColor = [UIColor redColor];

        //processing arrays to prevent multiple processing at once
        peopleToBeProcessed = [[NSMutableArray alloc]init];
        
        //scroll to hide search bar
        table.contentOffset = CGPointMake(0, searchBar.frame.size.height);
    }
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length == 0)
    {
        isFiltered = NO;
    }
    else
    {
        isFiltered = YES;
        filteredData = [[NSMutableArray alloc] init];
        
        
        for (int i = 0; i < [allData count]; i++)
        {
            NSString *name = [[allData objectAtIndex:i] objectForKey:@"name"];
            NSRange nameRange = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            //NSRange descriptionRange = [faceData.description rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound /*|| descriptionRange.location != NSNotFound*/)
            {
                [filteredData addObject:[allData objectAtIndex:i]];
            }
        }
    }
    
    [self.table reloadData];
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
    NSLog(@"searchBar Searched=%@",theSearchBar.text);
    [theSearchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.font = [UIFont fontWithName:gameFont size:23];
        cell.imageView.layer.cornerRadius = 8;
    }
    
    
    // Configure the cell...
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    cell.textLabel.textColor = [UIColor yellowColor];
    //NSString *cellFbID;
    NSString *name;
    if (isFiltered) {
        NSString *pictureUrl = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"url"];
        //Excellent lazy loading code (SDWebImage) by "rs" on GitHub
        [cell.imageView setImageWithURL:[NSURL URLWithString:pictureUrl]
                       placeholderImage:[UIImage imageNamed:@"erinPlayer.png"]];
        
        name = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = name;
        //cellFbID = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"id"];
    }else{
        NSString *thumbNailUrl = [[allData objectAtIndex:indexPath.row] objectForKey:@"thumbUrl"];
        
        //Excellent lazy loading code (SDWebImage) by "rs" on GitHub
        [cell.imageView setImageWithURL:[NSURL URLWithString:thumbNailUrl]
                       placeholderImage:[UIImage imageNamed:@"erinPlayer.png"]];
        
        name = [[allData objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = name;
        //cellFbID = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"id"];
    }
    
    //FaceData *fd = [[FaceData alloc]init];
    BOOL playerCellInGame = NO;
    for (FaceData *fd in appDelegate.faceDataArray) {
        if ([fd.name isEqualToString:name]) {
            playerCellInGame = YES;
            NSLog(@"HasFaceData:%@",name);
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    //[fd release];
    if (!playerCellInGame) {// without this, accessory views get resued or something in many cells, incorrectly.
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //cell tags: 0 = not searching, 1 = is searching, 2 = face found, 3 = face not found
    if (cell.tag == 0) {
        cell.accessoryView = nil;
    }else if (cell.tag == 1){
        //cell.accessoryView = activitySpinner;
    }else if (cell.tag == 2){
        cell.accessoryView = nil;
    }else if (cell.tag == 3){
        cell.accessoryView = nil;
    }
    
    //NSLog(@"cell returned");
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{

}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //attempt at creating a processing pool, so that one is done at a time, to avoid heavy memory situationz
    [peopleToBeProcessed addObject:indexPath];
    [self processSelected:tableView];
    [self clickSound];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (void)returnToIntroScene{
    NSLog(@"return to game over called");
    //[scoresTable removeFromSuperview];
    //[[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)processSelected:(UITableView *)tableView{
    NSMutableArray *processedPeople = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in peopleToBeProcessed) {
        NSString *fbID;
        if (isFiltered) {
            selectedName = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"name"];
            fbID = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"id"];
            //NSLog(@"Selected FB: %@",selectedName);
            smallProfPicUrl = [NSString stringWithFormat:@"%@",[[filteredData objectAtIndex:indexPath.row] objectForKey:@"url"]];
        }else{
            selectedName = [[allData objectAtIndex:indexPath.row] objectForKey:@"name"];
            selectedFacebookID = [[allData objectAtIndex:indexPath.row] objectForKey:@"id"];
            fbID = [[allData objectAtIndex:indexPath.row] objectForKey:@"id"];
            //NSLog(@"Selected FB: %@",selectedName);
            smallProfPicUrl = [[allData objectAtIndex:indexPath.row] objectForKey:@"url"];
        }
        
        smallProfPicUrl = [smallProfPicUrl stringByReplacingOccurrencesOfString:@"_q.jpg" withString:@"_n.jpg"];
        smallImg = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:smallProfPicUrl]]];
        
        //NSLog(@"smallPicUrl: %@", smallProfPicUrl);
        selectedFacebookID = fbID;
        
        
        //FaceData *fd = [[FaceData alloc]init];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        BOOL playerCellInGame = NO;
        for (FaceData *fd in appDelegate.faceDataArray) {
            if ([fd.facebookID isEqualToString:fbID]) {
                playerCellInGame = YES;
                //NSLog(@"HasFaceDataAlready:%@",fbID);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (!playerCellInGame) {
            UIActivityIndicatorView *activitySpinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                        UIActivityIndicatorViewStyleWhite] autorelease];
            cell.accessoryView = activitySpinner;
            cell.detailTextLabel.text = @"Finding Face...";
            [activitySpinner startAnimating];
            
            [fb requestWithGraphPath:fbID
                           andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"name,picture,albums.limit(10).fields(type,photos.limit(1).fields(source))", @"fields", nil]
                         andDelegate:self];
        }
        //add to processed list
        [processedPeople addObject:indexPath];
        
    }
    
    
    NSLog(@"processedPeople:%d", [processedPeople count]);
    NSLog(@"peopleToBeProcess:%d", [peopleToBeProcessed count]);
    
    for (NSIndexPath *indexPath in processedPeople) {
        [peopleToBeProcessed removeObject:indexPath];
    }
    [processedPeople release]; processedPeople = nil;
    
}
- (void)faceDetectionProcessWithFBResult:(id)result{
    NSLog(@"FB didLoad");
    /*
     NSArray *friendsData = [[result objectForKey:@"friends"] objectForKey:@"data"];
     
     for (NSDictionary *friend in friendsData) {
     */
    //[appDelegate.debuggerImages removeAllObjects];
    NSString *currentName = [result objectForKey:@"name"];
    NSArray *friendAlbData = [[result objectForKey:@"albums"] objectForKey:@"data"];
    BOOL profileAlbumFound = NO;
    faceFound = NO;
    for (NSDictionary *album in friendAlbData) {
        
        NSString *albumType = [album objectForKey:@"type"];
        //find the profile pictures album
        if ([albumType isEqualToString:@"profile"]) {
            
            NSLog(@"found friend %@ profile album", currentName);
            profileAlbumFound = YES;
            
            //grab the full-size profile pic
            NSString *bigPicUrl = [[[[album objectForKey:@"photos"] objectForKey:@"data"] objectAtIndex:0] objectForKey:@"source"];
            NSLog(@"URL = %@",bigPicUrl);
            
            UIImage *largeProfilePic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bigPicUrl]]];
            
            //[appDelegate.debuggerImages addObject:largeProfilePic]; //CRASHES HERE sometimes: URL is null, cant add nil object
            NSLog(@"album pic Size: %d, %d",(int)largeProfilePic.size.width, (int)largeProfilePic.size.height);
            largeProfilePic = [ImageProcessor scaleImageToWinsizeMaintainAspectRatio:largeProfilePic];;
            CGSize largeSize = CGSizeMake(largeProfilePic.size.width, largeProfilePic.size.height);
            //[appDelegate.debuggerImages addObject:largeProfilePic];
            //rotate image
            largeProfilePic = [UIImage imageWithCGImage: largeProfilePic.CGImage scale: 1.0 orientation: UIImageOrientationLeft];
            largeProfilePic = [ImageProcessor imageWithImage:largeProfilePic scaledToSize:CGSizeMake(largeSize.height, largeSize.width)];
            
            largeProfilePic = [ImageProcessor mergeImage:largeProfilePic withImage:[UIImage imageNamed:@"faceDetectionContext.png"]];
            //[appDelegate.debuggerImages addObject:largeProfilePic];
            NSLog(@"Image Size scaled to winsize: %d, %d",(int)largeProfilePic.size.width, (int)largeProfilePic.size.height);
            
            faceFound = [FaceData createFaceDataObjectsWithImage:largeProfilePic fromSource:@"facebook" andName:currentName];
        }
    }
    if (!profileAlbumFound) {
        NSLog(@"did not find %@ profile album", currentName);
    }
    //If this method fails,
    if (!faceFound) {
        //NSLog(@"big image face not found, try old method with url: %@", smallProfPicUrl);
        UIImage *img = smallImg;
        //[appDelegate.debuggerImages addObject:img];
        NSLog(@"Image Size: %d, %d",(int)img.size.width, (int)img.size.height);
        img = [ImageProcessor scaleImageToWinsizeMaintainAspectRatio:img];
        NSLog(@"Image Size scaled to winsize: %d, %d",(int)img.size.width, (int)img.size.height);
        CGSize picSize = CGSizeMake(img.size.width, img.size.height);
        //[appDelegate.debuggerImages addObject:img];
        
        UIImage *leftImage  = [UIImage imageWithCGImage: img.CGImage scale: 1.0 orientation: UIImageOrientationLeft];
        leftImage = [ImageProcessor imageWithImage:leftImage scaledToSize:CGSizeMake(picSize.height, picSize.width)];
        leftImage = [ImageProcessor mergeImage:leftImage withImage:[UIImage imageNamed:@"faceDetectionContext.png"]];
        
        //[appDelegate.debuggerImages addObject:leftImage];
        if ([FaceData createFaceDataObjectsWithImage:leftImage fromSource:@"facebook" andName:currentName]) {
            faceFound = YES;
        }else{
            NSLog(@"no face detected");
        }
    }
}

// ==================================== Facebook Delegate Methods ====================================//
// ==================================== Facebook Delegate Methods ====================================//
- (void)requestLoading:(FBRequest *)request{
    //NSLog(@"FB requestLoading");
    NSLog(@"FB table request: %@",request);
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    //NSLog(@"FB didReceiveResponse");
}
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    //NSLog(@"FB didLoadRawResponse");
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    //NSLog(@"FB didLoad");
    [self performSelectorInBackground:@selector(faceDetectionProcessWithFBResult:) withObject:result];
    //[self faceDetectionProcessWithFBResult:result];
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request failed with error");
    NSLog(@"%@",[error localizedDescription]);
    //[activitySpinner stopAnimating];
}

- (void)clickSound{
    [[SimpleAudioEngine sharedEngine] playEffect:@"generalClick.mp3"];
}

- (void)dealloc {
    
    //[scoresTable release];
    [allData release];
    [filteredData release];
    [smallProfPicUrl release];
    [fb release];
    [super dealloc];
    
}
@end
