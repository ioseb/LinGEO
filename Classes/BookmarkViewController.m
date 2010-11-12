//
//  BookmarkViewController.m
//  LinGEO
//

#import "LinGEOAppDelegate.h"
#import "BookmarkViewController.h"
#import "BookmarkDetailViewController.h"
#import "Bookmark.h"



@interface SortedBookmarks : NSObject {
	NSMutableArray *keys;
	NSMutableDictionary *mappings;
}

@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableDictionary *mappings;

- (id)initWithBookmarks:(NSMutableArray *)bookmarks;
- (int)numberOfRowsInSection:(int)section;
- (NSString *)sectionTitle:(int)section;
- (BOOL) removeBookmark:(int)section row:(int)row;
- (Bookmark *)bookmarkForSection:(int)section row:(int)row;

@end

@implementation SortedBookmarks

@synthesize keys, mappings;

- (id)initWithBookmarks:(NSMutableArray *)bookmarks {
	
	[super init];
	
	keys = [[NSMutableArray alloc] init];
	mappings = [[NSMutableDictionary alloc] init];
	
	int i;
	
	for (i = 0; i < [bookmarks count]; i++) {
		
		Bookmark *bookmark = (Bookmark *)[bookmarks objectAtIndex:i];
		NSString *chr = [[[NSString alloc] initWithFormat:@"%c", [bookmark.eng characterAtIndex:0]] lowercaseString];
		
		if ([mappings objectForKey:chr] == nil) {
			[keys addObject:chr];
			[mappings setObject:[[NSMutableArray alloc] init] forKey:chr];
		}
		
		[(NSMutableArray *)[mappings objectForKey:chr] addObject:[bookmarks objectAtIndex:i]];
		
	}
	
	return self;
	
}

- (int)numberOfRowsInSection:(int)section {
	if ([keys count] > 0) {
		return [(NSMutableArray *)[mappings objectForKey:[keys objectAtIndex:section]] count];
	}
	return 0;
}

- (NSString *)sectionTitle:(int)section {
	if ([keys count] > 0) {
		NSString *chr = (NSString *)[keys objectAtIndex:section];
		NSMutableString *title = [NSMutableString stringWithString:[chr uppercaseString]];
		[title appendString:@" - "];
		[title appendString:[chr lowercaseString]];
		return title;
	}
	return @"List is Empty";
}

// Return YES if removed entire section, otherwise NO
- (BOOL) removeBookmark:(int)section row:(int)row {
    if ([keys count] > 0) {
        
        NSString *chr = (NSString *)[keys objectAtIndex:section];
        NSMutableArray *values = [mappings objectForKey:chr];
        [values removeObjectAtIndex:row];
        
        if([values count] == 0) {
            [keys removeObjectAtIndex:section];    
            return YES;
        }
    }
    
    return NO;
}

- (Bookmark *)bookmarkForSection:(int)section row:(int)row {
    if ([keys count] > 0) {
        return (Bookmark *)[(NSMutableArray *)[mappings objectForKey:[keys objectAtIndex:section]] objectAtIndex:row];
    }
    
    return nil;
}

- (NSString *)titleForRow:(int)section row:(int)row {
	if ([keys count] > 0) {
		return [[self bookmarkForSection:section row:row] eng];
	}
	return nil;	
}

- (void) dealloc {
	[keys release];
	[mappings release];
	[super dealloc];
}

@end


@interface BookmarkViewController()
SortedBookmarks *sortedBookmarks;
@end


@implementation BookmarkViewController

@synthesize aTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
	self.title = @"Bookmarks";
    
    //  Configure the Action button
    UIBarButtonItem *action = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action)];
    

    self.navigationItem.rightBarButtonItem = action;
}

- (void)viewWillAppear:(BOOL)animated {
	LinGEOAppDelegate *delegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (sortedBookmarks != nil) {
		[sortedBookmarks release];
	}
	sortedBookmarks = [[SortedBookmarks alloc] initWithBookmarks:delegate.bookmarks];
	[sortedBookmarks retain];

    [self updateBarButtons];
    
	[aTableView reloadData];
}


#pragma mark -
#pragma mark Action

- (NSMutableString*)generateHTMLoutputForEmail
{
    NSMutableString *string = [NSMutableString new];
    
    [string appendFormat:@"<html><body bgcolor='#FFF3E0'>"];

    for(int i = 0; i < [sortedBookmarks.keys count]; i++) {
        
        for(int n = 0; n < [sortedBookmarks numberOfRowsInSection:i]; n++) {
            
            Bookmark *bookmark = [sortedBookmarks bookmarkForSection:i row:n];
            
            [string appendFormat:@"<div class='word'><b>%@</b></div>"
             "<div class='transcript'>&nbsp;%@</div>", [bookmark eng], [bookmark transcription] ];
            
            for(int i = 0; i < [bookmark.types count]; i++) {
                [string appendFormat:@"<div class='s3'>%d.&nbsp;<i>%@</i></div>", i + 1, [[bookmark.types objectAtIndex:i] lowercaseString]];
                [string appendFormat:@"<div class='s3'>&nbsp;&nbsp;&nbsp;&nbsp;%@</div>", [bookmark.geoArray objectAtIndex:i]];
            }
            
            [string appendString:@"<br>"];
        }
    }

    [string appendString:@"</body></html>"];
    
    return string;
}

-(void) emailBookmarks {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) cancel {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) action
{
    
	// open a dialog with Reload and Cabcel button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:NSLocalizedString(@"Email Bookmarks", @""), nil];
    
    
	[actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"My LinGEO Bookmarks"];
        [controller setMessageBody:[self generateHTMLoutputForEmail] isHTML:YES]; 
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email sent successfully" message:@"Bookmarks"
                                                       delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateBarButtons {
    if ([sortedBookmarks.keys count] == 0) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
    [self.aTableView setEditing:editing animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sortedBookmarks.keys count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sortedBookmarks numberOfRowsInSection:(int)section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sortedBookmarks sectionTitle:(int)section];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
   
    // Background color for header
    [headerView setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:24.0f/255.0f blue:10.0f/255.0f alpha:1.0f]];
    
    // Create label
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)] autorelease];
    label.text = [sortedBookmarks sectionTitle:(int)section];
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.font = [UIFont fontWithName:@"Georgia" size:20.0f];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:20.0f];
        
	}
	
	NSString *cellText = [sortedBookmarks titleForRow:(int)indexPath.section row:(int)indexPath.row];
	if (cellText) {
		cell.textLabel.text = cellText;
	}
	
	return cell;	
}

- (void)tableView:(UITableView *)tableView
					commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
					forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {

        [aTableView beginUpdates];
        
		LinGEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		Bookmark *bookmark = [sortedBookmarks bookmarkForSection:(int)indexPath.section row:indexPath.row];
        
        [delegate deleteBookmark:bookmark];
        
        if( [sortedBookmarks removeBookmark:indexPath.section row:indexPath.row] == YES ) {
            [aTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];        
        } else {
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [aTableView endUpdates];
        
        [self updateBarButtons];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BookmarkDetailViewController *detailView = [[BookmarkDetailViewController alloc] initWithNibName:@"BookmarkDetailView" bundle:nil];
	detailView.bookmark = [sortedBookmarks bookmarkForSection:(int)indexPath.section row:indexPath.row];
	[self.navigationController pushViewController:detailView animated:YES];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[aTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Wargning in BookmarkViewController");
}


- (void)dealloc {
	[aTableView release];
	[sortedBookmarks release];
	[super dealloc];
}


@end
