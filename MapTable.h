//
//  MapTable.h
//  LinGO
//
//  Created by Mr.Woods on 8/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapTable : NSObject {
	NSMutableArray *keys;
	NSMutableArray *values;
}

@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableArray *values;

- (void) setObject:(id)v forKey:(id)v;
- (id) objectForKey:(id)k;

@end
