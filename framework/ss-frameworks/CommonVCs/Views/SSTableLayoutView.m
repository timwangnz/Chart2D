//
//  SSTableLayoutView.m
//  SixStreams
//
//  Created by Anping Wang on 12/22/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableLayoutView.h"
#import "SSRoundButton.h"
#import "SSRoundView.h"
#import "SSPagesVC.h"

@interface SSTableLayoutView()<SSPagesVCDelegate>
{
    float imageHeight, imageWidth;
    UIView *imageView;
    NSUInteger flowIndex;
    SSPagesVC *pagesVC;
    BOOL swipeDisabled;
    
}

@end

@implementation SSTableLayoutView

- (void) reloadData
{
    for (UIView *childView in self.childViews) {
        if ([childView isKindOfClass:[SSRoundView class]])
        {
            SSRoundView *roundChild = (SSRoundView *) childView;
            [roundChild autofit];
        }
    }
    [super reloadData];
}
- (void) disablesSwipe
{
    swipeDisabled = YES;
}

- (void) lastStep
{
    NSInteger toPage = flowIndex- 1;

    if (toPage < 0)
    {
        toPage  = [self.childViews count] - 1;
    }
    
    [pagesVC setPageTo:toPage];
}

- (void) nextStep
{
    NSUInteger toPage = flowIndex + 1;
    if (toPage > [self.childViews count] - 1)
    {
        toPage  = 0;
    }
    [pagesVC setPageTo:toPage];
}

- (void) replaceChildView : (UIView *) childView with:(UIView *) newView
{
    [self.childViews replaceObjectAtIndex:[self.childViews indexOfObject:childView] withObject:newView];
}

- (void) removeChildView: (UIView *) childView
{
    [self.childViews removeObject:childView];
    [self reloadData];
}

- (void) removeChildViews
{
    [self.childViews removeAllObjects];
    [self reloadData];
}

- (void) addChildView : (UIView *) childView at:(int) idx
{
    if(!childView)
    {
        return;
    }
    if ([self.childViews containsObject:childView])
    {
        return;
    }
    
    if(idx < [self.childViews count] + 1)
    {
        [self.childViews insertObject:childView atIndex:idx - 1];
    }
    else
    {
        [self.childViews addObject:childView];
    }
    
    [self reloadData];
}

- (void) addChildView:(UIView *)childView
{
    if(!childView)
    {
        return;
    }
    if ([self.childViews containsObject:childView])
    {
        return;
    }
    [self.childViews addObject:childView];
    [self reloadData];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.childViews = [NSMutableArray array];
    self.dataSource = self;
    self.delegate = self;
}

- (void) hideKeyboard:(UIView *) uiView
{
    [uiView resignFirstResponder];
    for (UIView *childView in uiView.subviews) {
        [self hideKeyboard:childView];
    }
}

- (void) setTableHeaderView:(UIView *)tableHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:tableHeaderView.frame];
    [view addSubview:tableHeaderView];
    imageHeight = tableHeaderView.frame.size.height;
    imageWidth = self.frame.size.width;
    imageView = tableHeaderView;
    view.clipsToBounds = YES;
    [super setTableHeaderView:view];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIView *headview = self.tableHeaderView;
    if(headview)
    {
        float y = scrollView.contentOffset.y;
        if (y < 0)
        {
            y = 0;
        }
        else if (y > imageHeight){
            y = imageHeight;
        }
        imageView.frame = CGRectMake(0, y/2, imageWidth, imageHeight);
        scrollView.contentInset = UIEdgeInsetsMake(-y/2, 0.0, 0.0, 0.0);
        scrollView.scrollIndicatorInsets=UIEdgeInsetsMake(-y/2,0.0,0.0,0.0);
    }
    [self hideKeyboard:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.flow ? 2 : [self.childViews count];
}

#define LAYOUT_CELL @"layoutCell"
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.flow) {
        return indexPath.row == 0 ? 10 : self.frame.size.height - 60;
    }
    else
    {
        UIView *childView = [self.childViews objectAtIndex:indexPath.row];
        if (childView.frame.size.height == NAN)
        {
            return 10;
        }
        else
        {
            return childView.frame.size.height;
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:LAYOUT_CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LAYOUT_CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = self.backgroundColor;
        cell.indentationLevel = 0;
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }

    if(self.flow)
    {
        if(indexPath.row == 0)
        {
            UILabel *title = [[UILabel alloc]initWithFrame:cell.frame];
            title.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:title];
        }
        else if(indexPath.row == 1)
        {
            cell.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 60);
            cell.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 60);
            [self setupPages:cell.contentView];
        }
    }
    else
    {
        [cell.contentView addSubview:[self.childViews objectAtIndex:indexPath.row]];
        [cell.contentView setNeedsLayout];
    }
    return cell;
}

- (void) setupPages : (UIView *) parent
{
    if (pagesVC == nil) {
        pagesVC = [[SSPagesVC alloc] init];
        pagesVC.showPageControl = NO;
        if (swipeDisabled)
        {
            [pagesVC disablesSwipe];
        }
        [pagesVC initialize:parent pageDelegate:self];
        [pagesVC reloadPages];
    }
    else
    {
        [pagesVC initialize:parent pageDelegate:self];
    }
}

- (NSUInteger) numberOfPagesFor: (SSPagesVC *) pageControl
{
    return [self.childViews count];
}

- (UIView *) pagesVC:(SSPagesVC *) pageControl viewAtPage:(NSUInteger ) page
{
    return self.childViews[page];
}

- (void) pagesVC:(SSPagesVC *) pageControl didChangeTo :(NSUInteger) page
{
    [self hideKeyboard:self];
    flowIndex = page;
}

@end
