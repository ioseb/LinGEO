//
//  RootViewController.m
//  LinGO
//

#import "RootViewController.h"
#import "LinGOAppDelegate.h"
#import "EngGeo.h"
#import "DetailViewController.h"
#import "BookmarkViewController.h"

@implementation RootViewController

@synthesize aTableView, aSearchBar;

- (void)viewDidLoad {
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	LinGOAppDelegate *appDelegate = (LinGOAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([appDelegate.bookmarks count] == 0) {
		aSearchBar.showsBookmarkButton = NO;
	} else {
		aSearchBar.showsBookmarkButton = YES;
	}
    
    // set focus in search bar
    [aSearchBar becomeFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	LinGOAppDelegate *appDelegate = (LinGOAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate.result count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	LinGOAppDelegate *appDelegate = (LinGOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	cell.text = [(EngGeo *)[appDelegate.result objectAtIndex:indexPath.row] eng];
	
	// Set up the cell
	return cell;
}

// decide what kind of accesory view (to the far right) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	 detailView.trn = (EngGeo *)[((LinGOAppDelegate *)[[UIApplication sharedApplication] delegate]).result objectAtIndex:indexPath.row];
	 [self.navigationController pushViewController:detailView animated:YES];
	 [detailView release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[aTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return YES;
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
	LinGOAppDelegate *appDelegate = (LinGOAppDelegate *)[[UIApplication sharedApplication] delegate];
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

