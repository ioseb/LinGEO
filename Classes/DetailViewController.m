//
//  DetailViewController.m
//  LinGEO
//

#import "LinGEOAppDelegate.h"
#import "DetailViewController.h"

@interface DetailViewController()
- (void)addToBookmarks;
@end

@implementation DetailViewController

@synthesize aTableView, trn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: return 1;
		case 1: return 1;
		case 2: return [trn.geo count];
	}
	NSLog(@"Section %@", section);
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return @"English";
		case 1: return @"Transcription";
		case 2: return @"Georgian";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
        
        // disable selection
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}	
	
	NSMutableString *_geo;
	
	switch (indexPath.section) {
		case 0: 
			cell.text = trn.eng;
			break;
		case 1:
			cell.text = trn.transcription;
			break;
		case 2:
			_geo = [NSMutableString stringWithString:[trn.types objectAtIndex:indexPath.row]];
			[_geo appendString:@" - "];
			[_geo appendString:[trn.geo objectAtIndex:indexPath.row]];
			cell.text = [_geo description];
			break;
	}
	
	return cell;
	
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

//If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
											  initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
											  target:self action:@selector(addToBookmarks)];
	LinGEOAppDelegate *delegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([delegate bookmarkExists:(int)trn.pk]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)addToBookmarks {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	LinGEOAppDelegate *appDelegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate addToBookmarks:trn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in DetailViewController");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = @"Details";
}

- (void)dealloc {
	[aTableView release];
	[trn release];
	[super dealloc];
}


@end
