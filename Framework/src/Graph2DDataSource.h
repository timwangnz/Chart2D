//
//  Graph2DDataSource.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/16/12.
//

#import <Foundation/Foundation.h>
@class Graph2DView;

@protocol Graph2DDataSource <NSObject>

@required
    //graphs
    //return 1 for one chart
    - (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview;
    //number of items in a group
    //return number of items 
    - (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph;
    //return value
    - (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) item forSeries :(NSInteger) series;
@optional//only needed if it is range, default is 0
    - (NSNumber *) graph2DView:(Graph2DView *)graph2DView lowValueAtIndex:(NSInteger)item forSeries:(NSInteger)series;
@end
