//
//  RootViewController.m
//  LinGEO
//

#import "RootViewController.h"
#import "LinGEOAppDelegate.h"
#import "EngGeo.h"
#import "DetailViewController.h"
#import "BookmarkViewController.h"


@implementation RootViewController

@synthesize aTableView, aSearchBar;

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // set focus in search bar
    [aSearchBar becomeFirstResponder];
    
    id keyboardImpl = [objc_getClass("UIKeyboardImpl") sharedInstance];
    [keyboardImpl setAlpha:0.9f];
    
    
    for (UIView *searchBarSubview in [aSearchBar subviews]) {
        
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            
            @try {
                
                //[(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) {
                
                // ignore exception
            }
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([appDelegate.bookmarks count] == 0) {
		aSearchBar.showsBookmarkButton = NO;
	} else {
		aSearchBar.showsBookmarkButton = YES;
	}
    
    aTableView.rowHeight = 55.0f;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate.result count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     
        cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:20.0f];
	}
	
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	

	// Add english word
    cell.textLabel.text = [(EngGeo *)[appDelegate.result objectAtIndex:indexPath.row] eng];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    // Add georgian word as detailed text
    NSMutableArray *geoArray = [(EngGeo *)[appDelegate.result objectAtIndex:indexPath.row] geo];
    NSMutableString *mutableString = [NSMutableString new];
    
    for(int i = 0; i < [geoArray count]; i++) {
        NSString *geoText = [geoArray objectAtIndex:i];
        [mutableString appendString:geoText];
        if(i < [geoArray count] - 1) {
            [mutableString appendString:@", "];
        }
    }
    cell.detailTextLabel.text = mutableString;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    [mutableString release];
    // --------------------------------------
    
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
     DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	 detailView.trn = (EngGeo *)[((LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate]).result objectAtIndex:indexPath.row];
	 [self.navigationController pushViewController:detailView animated:YES];
    
	 [detailView release];
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in RootViewController");
}

#pragma mark UISearchBarDelegate delegate methods

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate search:aSearchBar.text];
	[aTableView reloadData];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[aSearchBar resignFirstResponder];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	BookmarkViewController *bookmarkView = [[BookmarkViewController alloc] initWithNibName:@"BookmarkView" bundle:nil];
	[self.navigationController pushViewController:bookmarkView animated:YES];
}

- (void)dealloc {
	[aTableView release];
	[aSearchBar release];
	[super dealloc];
}



@end

