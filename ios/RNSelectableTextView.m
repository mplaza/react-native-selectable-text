
#import <RCTText/RCTTextSelection.h>
#import <RCTText/RCTUITextView.h>
#import "RNSelectableTextView.h"
#import <RCTText/RCTTextAttributes.h>

#import <React/RCTUtils.h>

@implementation RNSelectableTextView
{
    RCTUITextView *_backedTextInputView;
}

NSString *const CUSTOM_SELECTOR = @"_CUSTOM_SELECTOR_";

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super initWithBridge:bridge]) {
        // `blurOnSubmit` defaults to `false` for <TextInput multiline={true}> by design.
        self.blurOnSubmit = NO;
        
        _backedTextInputView = [[RCTUITextView alloc] initWithFrame:self.bounds];
        _backedTextInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backedTextInputView.backgroundColor = [UIColor clearColor];
        _backedTextInputView.textColor = [UIColor blackColor];
        // This line actually removes 5pt (default value) left and right padding in UITextView.
        _backedTextInputView.textContainer.lineFragmentPadding = 0;
#if !TARGET_OS_TV
        _backedTextInputView.scrollsToTop = NO;
#endif
        _backedTextInputView.scrollEnabled = NO;
        _backedTextInputView.textInputDelegate = self;
        _backedTextInputView.editable = NO;
        _backedTextInputView.selectable = YES;
        _backedTextInputView.contextMenuHidden = YES;

        for (UIGestureRecognizer *gesture in [_backedTextInputView gestureRecognizers]) {
            if (
                [gesture isKindOfClass:[UIPanGestureRecognizer class]]
            ) {
                [_backedTextInputView setExclusiveTouch:NO];
                gesture.enabled = YES;
            } else {
                gesture.enabled = NO;
            }
        }
        
        [self addSubview:_backedTextInputView];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        
        UITapGestureRecognizer *tapGesture = [ [UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 2;
        
        [_backedTextInputView addGestureRecognizer:longPressGesture];
        [_backedTextInputView addGestureRecognizer:tapGesture];
        
        [self setUserInteractionEnabled:true];
    }
    
    return self;
}

-(void) _handleGesture
{
    if (!_backedTextInputView.isFirstResponder) {
        [_backedTextInputView becomeFirstResponder];
    }
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if (menuController.isMenuVisible) return;
    
    NSMutableArray *menuControllerItems = [NSMutableArray arrayWithCapacity:self.menuItems.count];
    
    for(NSString *menuItemName in self.menuItems) {
        NSString *sel = [NSString stringWithFormat:@"%@%@", CUSTOM_SELECTOR, menuItemName];
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle: menuItemName
                                                      action: NSSelectorFromString(sel)];
        
        [menuControllerItems addObject: item];
    }
    
    menuController.menuItems = menuControllerItems;
    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
}

-(void) handleLongPress: (UILongPressGestureRecognizer *) gesture
{
    CGPoint pos = [gesture locationInView:_backedTextInputView];
    pos.y += _backedTextInputView.contentOffset.y;

    UITextPosition *tapPos = [_backedTextInputView closestPositionToPoint:pos];
    UITextRange *word = [_backedTextInputView.tokenizer rangeEnclosingPosition:tapPos withGranularity:(UITextGranularityWord) inDirection:UITextLayoutDirectionRight];

    UITextPosition* beginning = _backedTextInputView.beginningOfDocument;

    UITextPosition *selectionStart = word.start;
    UITextPosition *selectionEnd = word.end;

    const NSInteger location = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger endLocation = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionEnd];

    [_backedTextInputView select:self];
    [_backedTextInputView setSelectedRange:NSMakeRange(location, endLocation - location)];
    [self _handleGesture];
}

-(void) handleTap: (UITapGestureRecognizer *) gesture
{
    [_backedTextInputView select:self];
    [_backedTextInputView selectAll:self];
    [self _handleGesture];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (self.value) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.value attributes:self.textAttributes.effectiveTextAttributes];
        
        double red = [self.highlightColor[0] doubleValue];
        double green = [self.highlightColor[1] doubleValue];
        double blue = [self.highlightColor[2] doubleValue];
        double alpha = [self.highlightColor[3] doubleValue];
        
        if (self.highlights != nil) {
            for (NSDictionary *item in self.highlights) {
                NSUInteger start = [[item objectForKey:@"start"] unsignedIntegerValue];
                NSUInteger end = [[item objectForKey:@"end"] unsignedIntegerValue];
                NSUInteger contentLength = [self.value length];
                
                if (start >= end) continue;
                if (start > contentLength - 1 || end > contentLength - 1) continue;
                
                [str addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:red green:green blue:blue alpha:alpha] range:NSMakeRange(start, end - start)];
            }
        }
        
        [super setAttributedText:str];
    } else {
        [super setAttributedText:attributedText];
    }
}

- (id<RCTBackedTextInputViewProtocol>)backedTextInputView
{
    return _backedTextInputView;
}

- (void)tappedMenuItem:(NSString *)eventType
{
    RCTTextSelection *selection = self.selection;
    
    NSUInteger start = selection.start;
    NSUInteger end = selection.end - selection.start;
    
    self.onSelection(@{
        @"content": [[self.attributedText string] substringWithRange:NSMakeRange(start, end)],
        @"eventType": eventType,
        @"selectionStart": @(start),
        @"selectionEnd": @(selection.end)
    });
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if ([super methodSignatureForSelector:sel]) {
        return [super methodSignatureForSelector:sel];
    }
    return [super methodSignatureForSelector:@selector(tappedMenuItem:)];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:CUSTOM_SELECTOR];
    if (match.location == 0) {
        [self tappedMenuItem:[sel substringFromIndex:17]];
    } else {
        [super forwardInvocation:invocation];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:CUSTOM_SELECTOR];

    if (match.location == 0) {
        return YES;
    }
    return NO;
}

@end
