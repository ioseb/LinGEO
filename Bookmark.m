//
//  Bookmark.m
//  LinGO
//
//  Created by Mr.Woods on 8/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"


@implementation Bookmark

@synthesize pk, rid, eng, transcription, geo, type, types, date, geoArray;

- (id)init {
	[super init];
	return self;
}

- (void) dealloc {
	[eng release];
	[transcription release];
	[geo release];
	[type release];
	[date release];
	[geoArray release];
	[super dealloc];
}

@end
