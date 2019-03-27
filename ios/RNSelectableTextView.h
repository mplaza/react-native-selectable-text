#import <RCTText/RCTBaseTextInputView.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNSelectableTextView : RCTBaseTextInputView

@property (nonnull, nonatomic, copy) NSString *value;
@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nullable, nonatomic, copy) NSArray<NSDictionary *> *highlights;
@property (nullable, nonatomic, copy) NSArray<NSNumber *> *highlightColor;

@end

NS_ASSUME_NONNULL_END
