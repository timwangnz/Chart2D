
#import <Availability.h>

#import <UIKit/UIKit.h>

enum {
    SSStarRatingDisplayFull=0,
    SSStarRatingDisplayHalf,
    SSStarRatingDisplayAccurate
};
typedef NSUInteger SSStarRatingDisplayMode;

typedef void(^SSStarRatingReturnBlock)(float rating);

@protocol SSStarRatingProtocol;

@interface SSStarRating : UIControl
@property (nonatomic,strong) UIImage *backgroundImage;
@property (nonatomic,strong) UIImage *starHighlightedImage;
@property (nonatomic,strong) UIImage *starImage;
@property (nonatomic) NSInteger maxRating;
@property (nonatomic) float rating;
@property (nonatomic) CGFloat horizontalMargin;
@property (nonatomic) BOOL editable;
@property (nonatomic) SSStarRatingDisplayMode displayMode;
@property (nonatomic) float halfStarThreshold;

@property (nonatomic,weak) id<SSStarRatingProtocol> delegate;
@property (nonatomic,copy) SSStarRatingReturnBlock returnBlock;
@end


@protocol SSStarRatingProtocol <NSObject>

@optional
-(void)starsSelectionChanged:(SSStarRating*)control rating:(float)rating;

@end

