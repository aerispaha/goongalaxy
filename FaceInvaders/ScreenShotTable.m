//
//  ScreenShotTable.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 10/23/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "ScreenShotTable.h"

@implementation ScreenShotTable
@synthesize table;

- (id)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        tableScale = 0.667; //0.5 would fill half of screen
        _message = [[NSString alloc] initWithString:message];
        NSLog(@"_message: %@", _message);
        //grab Facebook session and screen shot images
        fb = [[Facebook alloc] init];
        fb = appDelegate.facebook;
        screenShotArray = [[NSMutableArray alloc] init];
        screenshotPaths = [[NSMutableArray alloc] initWithArray:[ScreenshotHandler loadPathsFromDisk]];
        /*
        for (NSString *path in screenshotPaths) {
            UIImage *screenImg = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            
            if (CC_CONTENT_SCALE_FACTOR() == 2) {
                screenImg = [ImageProcessor  scaleImageRegardlessOfDisplayType:screenImg by:tableScale*0.5];
            }else{
                screenImg = [ImageProcessor scaleImage:screenImg by:tableScale];
            }
            [screenShotArray addObject:screenImg];
        }
        */
        
        //create table
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        CGRect tableRect = CGRectMake(0, 0, winSize.width*tableScale, winSize.height);
        table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        [table setTransform:transform];
        [table setDelegate:self];
        [table setDataSource:self];
        
        //Configure the table
        table.backgroundColor = [UIColor clearColor];
        table.opaque = NO;
        table.backgroundView = nil;
        table.center = CGPointMake(winSize.height/2, winSize.width*(tableScale/2)); //UIkit coordinates
        table.allowsMultipleSelection = NO;
        [table setSeparatorStyle:UITableViewCellSelectionStyleGray];
        
    }
    return self;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

        return [screenshotPaths count];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    /*
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        // Configure the cell...
        UIView  *backView           = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        backView.backgroundColor    = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundView = backView;
        cell.textLabel.textColor = [UIColor yellowColor];
        cell.textLabel.text = _message;
        cell.textLabel.font = [UIFont fontWithName:appDelegate.gameFont size:30];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        NSLog(@"cell returned");
        return cell;
    }else{
        */
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        // Configure the cell...
        
        NSString *path = [screenshotPaths objectAtIndex:indexPath.row];
    
    //[cell.imageView setImageWithURL:[NSURL URLWithString:path]
    //               placeholderImage:[UIImage imageNamed:@"erinPlayer.png"]];
    
        UIImage *screenImg = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    cell.imageView.frame = cell.frame;
    //UIImage *screenImg = cell.imageView.image;
    
        if (CC_CONTENT_SCALE_FACTOR() == 2) {
            screenImg = [ImageProcessor  scaleImageRegardlessOfDisplayType:screenImg by:tableScale*0.5];
        }else{
            screenImg = [ImageProcessor scaleImage:screenImg by:tableScale*0.5];
        }
    
        //UIView  *backView           = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        //UIImage *screenImg          = [screenShotArray objectAtIndex:indexPath.row];
        //UIColor *screenImgUIColor   = [[[UIColor alloc] initWithPatternImage:screenImg] autorelease];
        //backView.backgroundColor    = screenImgUIColor;
    
    cell.imageView.image = screenImg;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundView = backView;
        cell.textLabel.text = nil;
        NSLog(@"cell returned");
        return cell;
    //}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    CGSize  winSize = [[CCDirector sharedDirector] winSize];
    //if (indexPath.section != 0) {
        picIndexPath = indexPath.row;
        float currentVersion = 6.0;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
        {
            NSLog(@"Running in IOS-6");
            //ACTIVITY SHEET iOS6
            UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
            vc.view.frame = CGRectMake(0, 0, winSize.width, winSize.height);
            [vc.view setTransform:CGAffineTransformMakeRotation(0.5*M_PI)];
            vc.view.center = ccp(winSize.height/2, winSize.width/2);
            [[[CCDirector sharedDirector] openGLView] addSubview:vc.view];
            
            //NSString *message = [NSString stringWithFormat:@"GoonGalaxy"];
            UIImage *img = [NSKeyedUnarchiver unarchiveObjectWithFile:[screenshotPaths objectAtIndex:picIndexPath]];
            img = [UIImage imageWithData:UIImageJPEGRepresentation(img, 1)];
            NSArray *activityItems = @[img];
            
            UIActivityViewController *activitySheet = [[UIActivityViewController alloc] initWithActivityItems:activityItems  applicationActivities:nil];
            
            //exclude these activity typs
            activitySheet.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypePostToWeibo,UIActivityTypePrint, UIActivityTypeMail, UIActivityTypeMessage];
            
            [vc presentViewController:activitySheet animated:YES completion:nil];
            
            [activitySheet setCompletionHandler:^(NSString *activityType, BOOL completed) {
                //Dismiss here
                NSLog(@"CompletionHandler dialog - activity: %@ - finished flag: %d", activityType, completed);
                if (activityType == UIActivityTypeMail || activityType == UIActivityTypeMessage) {
                    [vc resignFirstResponder];
                    
                    NSLog(@"resign first responder called");
                }
                [vc.view removeFromSuperview];
                [vc release];
                
                
            }];
            
            
            //[activityItems release];
            [activitySheet release];
            
        }else{
            
            //for devices without iOS 6
            UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)] autorelease];
            [view setTransform:CGAffineTransformMakeRotation(0.5*M_PI)];
            view.center = ccp(winSize.height/2, winSize.width/2);
            
            
            UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share This Screenshot!"
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Cancel"
                                                            destructiveButtonTitle:nil
                                                                 otherButtonTitles:@"Facebook", @"Copy to Clipboard", nil];
            
            //[shareActionSheet setTransform:CGAffineTransformMakeRotation(0.5*M_PI)];
            
            [shareActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            [view addSubview:shareActionSheet];
            [shareActionSheet showInView:view];
            [shareActionSheet release];
            
        }
    //}else{
        //NSLog(@"selected cell with no functions");
    //}
    
}
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType{
    NSLog(@"activityViewController itemForActivityType: %@", activityType);
    return nil;
}
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController{
    //i dont know what to do with this
    return activityViewController;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

        return [[CCDirector sharedDirector]winSize].height*tableScale;
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        NSLog(@"said no with index");
    }
    else if (buttonIndex == 1){
        NSLog(@"said yes to fb");
        [self facebookPostImageAtIndex:picIndexPath];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        NSLog(@"Facebook Button 1 Clicked");
        [self confirmUserWantsToPostToFacebook];
    } else if (buttonIndex == 1) {
        NSLog(@"Copy Button 2 Clicked");
        UIImage *img = [NSKeyedUnarchiver unarchiveObjectWithFile:[screenshotPaths objectAtIndex:picIndexPath]];

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSData *jpegData = UIImageJPEGRepresentation(img, 1.0);
        [pasteboard setData:jpegData forPasteboardType:[UIPasteboardTypeListImage objectAtIndex:0]];
        
        //NSData *imgData = UIImagePNGRepresentation(landscapeImg);
        //[pasteboard setData:imgData forPasteboardType:[UIPasteboardTypeListImage objectAtIndex:0]];
        
    } else if (buttonIndex == 2) {
        NSLog(@"Email Button 3 Clicked");
    } else if (buttonIndex == 3) {
        NSLog(@"Cancel Button Clicked");
    } else if (buttonIndex == 4) {
        
    }
}

- (void)confirmUserWantsToPostToFacebook{
    UIView *view = [[CCDirector sharedDirector] openGLView];
    
    
     UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle: @"Are you sure you want to post to Facebook?"
     message: @"(You should. It's hilarious)"
     delegate: self
     cancelButtonTitle: @"Cancel"
     otherButtonTitles: @"OK", nil];
    
    [view addSubview:myAlertView];
    [myAlertView show];
    [myAlertView release];
}
- (void)facebookPostImageAtIndex:(int)indexPath{
    //UIImage *img = [/*appDelegate.picturesFromGamePlay*/screenShotArray objectAtIndex:indexPath];
    UIImage *img = [NSKeyedUnarchiver unarchiveObjectWithFile:[screenshotPaths objectAtIndex:picIndexPath]];
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
    
    //NSData *imageData = UIImagePNGRepresentation(img);//UIImageJPEGRepresentation(img, 0.75);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[fb accessToken], @"access_token",nil];
    //[params setObject:@"Caption to go with image" forKey:@"name"];
    [params setObject:[NSString stringWithFormat:@"testerino"] forKey:@"message"];
    [params setObject:imageData forKey:@"source"];
    [fb requestWithGraphPath:@"me/photos"
                         andParams: params
                     andHttpMethod: @"POST"
                       andDelegate:(id)self];
}
// ==================================== Facebook Delegate Methods ====================================//
// ==================================== Facebook Delegate Methods ====================================//
- (void)requestLoading:(FBRequest *)request{
    NSLog(@"FB requestLoading");
    //NSLog(@"request: %@",request);
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"FB didReceiveResponse");
}
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    NSLog(@"FB didLoadRawResponse");
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"FB didLoad");
    NSLog(@"result: %@",result);
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request failed with error");
    NSLog(@"%@",[error localizedDescription]);
    UIView *view = [[CCDirector sharedDirector] openGLView];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle: @"Dang!"
                                                          message: @"Failed to post to Facebook for some reason..."
                                                         delegate: self
                                                cancelButtonTitle: @"Ok"
                                                otherButtonTitles: nil, nil];
    [view addSubview:myAlertView];
    [myAlertView show];
    [myAlertView release];
}
- (void)dealloc {
    
    [screenShotArray release];

    [super dealloc];
    
}
@end
