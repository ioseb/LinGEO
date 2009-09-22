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
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate.result count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	cell.textLabel.text = [(EngGeo *)[appDelegate.result objectAtIndex:indexPath.row] eng];

	return cell;
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

