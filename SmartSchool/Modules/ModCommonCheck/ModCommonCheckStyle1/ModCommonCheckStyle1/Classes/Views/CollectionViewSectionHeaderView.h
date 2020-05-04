//
//  CollectionViewSectionHeaderView.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibComponentBase/CommonDefs.h>
@class CollectionViewSectionHeaderView;

@protocol CollectionViewSectionHeaderViewDelegate <NSObject>

- (void)moreButtonTouchedOfHeaderView:(CollectionViewSectionHeaderView *)headerView;

@end

@interface CollectionViewSectionHeaderView : UICollectionReusableView
@property (nonatomic, weak) id<CollectionViewSectionHeaderViewDelegate>     delegate;

@property (nonatomic, copy)   NSString      *title;
@property (nonatomic, copy)   UIImage       *image;
@property (nonatomic, copy)   NSString      *tailContent;


+ (NSString *)reuseIdentifier;

@end
