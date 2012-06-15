//
//  RevealingCell.h
//  RevealingTableView
//
//  Created by aptiva on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RevealingCell;

@protocol RevealingCellDelegate <NSObject>
@optional
- (BOOL)cellShouldReveal:(RevealingCell *)cell;
- (void)cellDidBeginPan:(RevealingCell *)cell;
- (void)cellDidReveal:(RevealingCell *)cell;

@end

@interface RevealingCell : UITableViewCell 
@property (nonatomic, assign) id <RevealingCellDelegate> delegate;
@end
