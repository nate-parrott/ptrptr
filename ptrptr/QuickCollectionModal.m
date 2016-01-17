//
//  QuickCollectionModal.m
//  computer
//
//  Created by Nate Parrott on 10/19/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "QuickCollectionModal.h"
#import "ALGReversedFlowLayout.h"
#import "Chameleon.h"

#define RAND_FLOAT ((rand() % 10000) / 10000.0)

@implementation QuickCollectionItem

@end


@interface QuickCollectionModal () <UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation QuickCollectionModal

- (instancetype)init {
    self = [super init];
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flow = [ALGReversedFlowLayout new];
    flow.itemSize = CGSizeMake(70, 70);
    CGFloat margin = 20;
    flow.minimumInteritemSpacing = margin;
    flow.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flow];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = bgView;
    [bgView addGestureRecognizer:tapRec];
}

- (void)setItems:(NSArray<__kindof QuickCollectionItem *> *)items {
    _items = items;
    CGFloat hue = 0;
    for (QuickCollectionItem *model in self.items) {
        UIColor *color = [UIColor colorWithHue:fmod(hue, 1) saturation:0.8 brightness:0.8 alpha:1];
        hue += 0.12;
        model.color = [color flatten];
    }
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QuickCollectionItem *model = self.items[indexPath.item];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if (model.icon) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:model.icon];
        imageView.contentMode = UIViewContentModeCenter;
        cell.backgroundView = imageView;
    } else if (model.label) {
        UILabel *label = [UILabel new];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = model.label;
        cell.backgroundView = label;
    }
    cell.backgroundView.backgroundColor = model.color;
    cell.backgroundView.layer.cornerRadius = 5;
    cell.backgroundView.clipsToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QuickCollectionItem *model = self.items[indexPath.item];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (model.action) model.action();
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat topInset = self.topBar.frame.size.height;
    self.collectionView.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(topInset, 0, 0, 0));
    self.topBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.topBar.frame.size.height);
    
    UICollectionViewFlowLayout *flow = (id)self.collectionView.collectionViewLayout;
    CGFloat margin = 20;
    CGFloat itemSize = flow.itemSize.width;
    // width = itemSize * cellsWide + (cellsWide + 1) * margin
    CGFloat width = self.collectionView.bounds.size.width;
    CGFloat cellsWide = floor((-width + margin)/(-itemSize - margin));
    margin = (-width + itemSize*cellsWide)/(-cellsWide - 1);
    margin = floor(margin-0.5);
    flow.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    flow.minimumInteritemSpacing = margin;
    flow.minimumLineSpacing = margin;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setTopBar:(UIView *)topBar {
    [_topBar removeFromSuperview];
    _topBar = topBar;
    [self.view addSubview:_topBar];
}

#pragma mark Transitioning

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    BOOL isPresenting = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] == self;
    UIView *container = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    if (isPresenting) {
        [container addSubview:self.view];
        self.view.frame = [transitionContext finalFrameForViewController:self];
        self.view.backgroundColor = [UIColor clearColor];
        self.topBar.alpha = 0;
        [self makeIconsFlyIn:YES withDuration:duration];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            self.topBar.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration/2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [transitionContext completeTransition:YES];
        });
    } else {
        [self makeIconsFlyIn:NO withDuration:duration];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.view.backgroundColor = [UIColor clearColor];
            self.topBar.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

- (void)makeIconsFlyIn:(BOOL)flyIn withDuration:(NSTimeInterval)duration {
    [self.view layoutIfNeeded];
    NSArray *cells = self.collectionView.visibleCells;
    CGFloat flight = 0.3;
    for (UICollectionViewCell *cell in cells.reverseObjectEnumerator) {
        if (flyIn) {
            cell.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height * flight);
            cell.alpha = 0;
        }
        CGFloat maxDelay = duration * 0.3;
        NSTimeInterval delay = maxDelay * RAND_FLOAT;
        CGFloat initialVelocity = flyIn ? 0.1 : 0;
        [UIView animateWithDuration:duration - maxDelay delay:delay usingSpringWithDamping:0.8 initialSpringVelocity:initialVelocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
            if (flyIn) {
                cell.transform = CGAffineTransformIdentity;
            } else {
                cell.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height * flight);
            }
            cell.alpha = flyIn ? 1 : 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (CGSize)itemSize {
    [self view];
    return [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
}

- (void)setItemSize:(CGSize)itemSize {
    [self view];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:itemSize];
}

@end
