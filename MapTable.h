//
//  MapTable.h
//  LinGO
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
