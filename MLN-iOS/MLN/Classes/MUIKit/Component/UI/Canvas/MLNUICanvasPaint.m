//
//  MLNUICanvasPaint.m
//
//
//  Created by MoMo on 2019/6/5.
//

#import "MLNUICanvasPaint.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIKitHeader.h"

@interface MLNUICanvasPaint()
{
    UIFont *_font;
}
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, copy) NSString *fontName;
//dash offset
@property (nonatomic, assign) CGFloat phase;
@property (nonatomic, strong) NSArray *dashs;

@end

@implementation MLNUICanvasPaint

- (instancetype)init
{
    if (self = [super init]) {
        _paintColor = [UIColor blackColor];
        _alpha = 1.0;
        _width = 1.0;
        _fontSize = 14;
        _font = [UIFont systemFontOfSize:_fontSize];
    }
    return self;
}

- (void)setupContext:(CGContextRef)contextRef
{
    CGContextSetStrokeColorWithColor(contextRef, _paintColor.CGColor);
    CGContextSetLineWidth(contextRef, _width);
    if (_dashs && _dashs.count > 0) {
        NSInteger count = _dashs.count;
        CGFloat length[count];
        for (int i = 0; i < count; i++) {
            NSNumber *numb = [_dashs objectAtIndex:i];
            if ([numb isKindOfClass:[NSNumber class]]) {
                length[i] = [numb integerValue];
            }
            CGContextSetLineDash(contextRef, _phase, length, count);
        }
    } else {
        CGContextSetLineDash(contextRef, 0, nil, 0);
    }
}

- (void)strokeBezierPath:(UIBezierPath *)bezierPath
{
    if (!bezierPath) {
        return;
    }
    bezierPath.lineWidth = _width;
    [_paintColor set];
    [bezierPath stroke];
}

- (void)fillBezierPath:(UIBezierPath *)bezierPath
{
    if (!bezierPath) {
        return;
    }
    bezierPath.lineWidth = _width;
    [_paintColor set];
    [bezierPath fill];
}

- (UIFont *)font
{
    return _font;
}

- (void)setupShapeLayer:(CAShapeLayer *)shapeLayer
{
    if (_dashs && _dashs.count > 0) {
        shapeLayer.lineDashPattern = _dashs;
        shapeLayer.lineDashPhase = _phase;
    } else {
        shapeLayer.lineDashPattern = nil;
        shapeLayer.lineDashPhase = 0;
    }
    shapeLayer.strokeColor = shapeLayer.fillColor = [UIColor clearColor].CGColor;

    switch (_style) {
        case MLNUICanvasDrawStyleFill:
            shapeLayer.fillColor = _paintColor.CGColor;
            break;
        case MLNUICanvasDrawStyleStroke:
            shapeLayer.strokeColor = _paintColor.CGColor;
            break;
        default:
            shapeLayer.fillColor = _paintColor.CGColor;
            shapeLayer.strokeColor = _paintColor.CGColor;
            break;
    }
    shapeLayer.lineWidth = _width;
}

#pragma mark - export fo lua
- (void)lua_setPaintColor:(UIColor *)paintColor
{
    if (![paintColor isKindOfClass:[UIColor class]]) {
        MLNUIKitLuaAssert(NO, @"paintColor type must be Color!")
        return;
    }
    _paintColor = paintColor;
}

- (void)lua_setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
}

- (void)lua_setPathEffect:(NSInteger)pathEffect
{
    _pathEffect = pathEffect;
}

- (void)lua_setShader:(NSInteger)shader
{
    _shader = shader;
}

- (void)lua_setWidth:(CGFloat)width
{
    _width = width;
}

- (void)lua_setStyle:(MLNUICanvasDrawStyle)style
{
    _style = style;
}

- (void)lua_setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    _font = [UIFont systemFontOfSize:fontSize];
}

- (void)lua_setFontNameSize:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    _fontName = fontName;
    _font = [UIFont fontWithName:fontName size:fontSize]?:[UIFont systemFontOfSize:fontSize];
}

- (void)lua_setDash:(NSArray *)dashs phase:(CGFloat)phase
{
    _phase = phase;
    _dashs = dashs;
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUICanvasPaint)
LUA_EXPORT_PROPERTY(paintColor, "lua_setPaintColor:","paintColor", MLNUICanvasPaint)
LUA_EXPORT_PROPERTY(alpha, "lua_setAlpha:","alpha", MLNUICanvasPaint)
LUA_EXPORT_PROPERTY(pathEffect, "lua_setPathEffect:","pathEffect", MLNUICanvasPaint)
LUA_EXPORT_PROPERTY(shader, "lua_setShader:","shader", MLNUICanvasPaint)
LUA_EXPORT_PROPERTY(width, "lua_setWidth:","width", MLNUICanvasPaint)
LUA_EXPORT_PROPERTY(style, "lua_setStyle:","style", MLNUICanvasPaint)
LUA_EXPORT_METHOD(fontSize, "lua_setFontSize:", MLNUICanvasPaint)
LUA_EXPORT_METHOD(fontNameSize, "lua_setFontNameSize:fontSize:", MLNUICanvasPaint)
LUA_EXPORT_METHOD(setDash, "lua_setDash:phase:", MLNUICanvasPaint)
LUA_EXPORT_END(MLNUICanvasPaint, Paint, NO, NULL, NULL)
@end
