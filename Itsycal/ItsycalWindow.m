//
//  ItsycalWindow.m
//  Itsycal
//
//  Created by Sanjay Madan on 12/14/14.
//  Copyright (c) 2014 mowglii.com. All rights reserved.
//

#import "ItsycalWindow.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kMinimumSpaceBetweenWindowAndScreenEdge = 10;
static const CGFloat kCornerRadius = 16;
static const CGFloat kVerticalPadding = 11;
// Between the bottom of the menu bar and the top of the window.
static const CGFloat kMenuBarGap = 1;

@interface ItsycalWindowFrameView : NSVisualEffectView
@end

#pragma mark -
#pragma mark ItsycalWindow

// =========================================================================
// ItsycalWindow
// =========================================================================

@implementation ItsycalWindow

- (id)init
{
    self = [super initWithContentRect:NSZeroRect styleMask:NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setLevel:NSMainMenuWindowLevel];
        [self setMovableByWindowBackground:NO];
        [self setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
        // Fade out when -[NSWindow orderOut:] is called.
        [self setAnimationBehavior:NSWindowAnimationBehaviorUtilityWindow];
        // The frame view draws the window. Its safe area excludes
        // the padding, so views placed in the window should be
        // constrained to its safeAreaLayoutGuide. The system draws
        // the window's shadow around the frame view's shape.
        [self setContentView:[ItsycalWindowFrameView new]];
    }
    return self;
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)positionRelativeToRect:(NSRect)rect screenMaxX:(CGFloat)screenMaxX
{
    // Calculate window's top left point: centered under
    // the status item, just below the menu bar.
    CGFloat w = NSWidth(self.frame);
    CGFloat x = round(NSMidX(rect) - w / 2);
    CGFloat y = NSMinY(rect) - kMenuBarGap;

    // If the calculated x position puts the window too
    // far to the right, shift the window left.
    if (x + w + kMinimumSpaceBetweenWindowAndScreenEdge > screenMaxX) {
        x = screenMaxX - w - kMinimumSpaceBetweenWindowAndScreenEdge;
    }

    // Set the window position.
    [self setFrameTopLeftPoint:NSMakePoint(x, y)];

    [self invalidateShadow];
}

@end

#pragma mark -
#pragma mark ItsycalWindowFrameView

// =========================================================================
// ItsycalWindowFrameView
// =========================================================================

@implementation ItsycalWindowFrameView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.additionalSafeAreaInsets = NSEdgeInsetsMake(kVerticalPadding, 0, kVerticalPadding, 0);

        // The window is drawn in the material of a menu, which
        // turns opaque under Reduce Transparency as menus do.
        // Kept active so it doesn't dim when the window isn't key.
        self.material = NSVisualEffectMaterialMenu;
        self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        self.state = NSVisualEffectStateActive;
        self.maskImage = [[self class] maskImage];
    }
    return self;
}

// The window's shape: a rounded rectangle with continuous corners
// that stretches between them to any size. A mask image rather
// than a layer mask, because only the mask image also shapes the
// blur the window server draws behind the window.
+ (NSImage *)maskImage
{
    // A continuous corner starts its curve further from the corner
    // than a circular one of the same radius, so leave it room.
    CGFloat inset = ceil(kCornerRadius * 1.6);
    CGFloat edge = 2 * inset + 1;
    NSImage *image = [NSImage imageWithSize:NSMakeSize(edge, edge) flipped:NO drawingHandler:^BOOL(NSRect rect) {
        CALayer *layer = [CALayer layer];
        layer.frame = rect;
        layer.backgroundColor = NSColor.blackColor.CGColor;
        layer.cornerRadius = kCornerRadius;
        layer.cornerCurve = kCACornerCurveContinuous;
        [layer renderInContext:NSGraphicsContext.currentContext.CGContext];
        return YES;
    }];
    image.capInsets = NSEdgeInsetsMake(inset, inset, inset, inset);
    image.resizingMode = NSImageResizingModeStretch;
    return image;
}

@end
