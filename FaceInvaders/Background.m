//
//  Background.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/21/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "Background.h"

@implementation Background


+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	Background *layer = [Background node];
	[scene addChild: layer];
	return scene;
}

+ (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    /*
    //Code for creating a gradient. Note that it uses UIKit-type coordinates (upper left is origin)
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    float gradientAlpha = 0.7;    
    CGPoint vertices[4];
    ccColor4F colors[4];
    int nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureSize, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};      //WHAAAAAATTTTT THHHHHEEEEEE FFUUUUUUUUCCCKKKKKKK
    vertices[nVertices] = CGPointMake(textureSize, textureSize);    //DOOOESSSSNOOOOTTTT WORK WITTTTH FUCKING RETNA
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};      // SSSMMMMMM FUCKING DDDDDDDDD BUKLL KLDJHDWH KUSDJHCJKDSCGDHJWCG
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    // 3: Draw/blend into the texture that was created in GIMP
    //CGBlendFunc does some sort of multiplying of color w/
    //the texture alpha layer.
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(textureSize/2, textureSize/2);
    [noise visit];
    */
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

+ (ccColor4F)randomBrightColor {
    
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor = 
        ccc4(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255, 
             255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
    
}
+ (ccColor3B)randomBrightColor3B{
    
    while (true) {
        float requiredBrightness = 192;
        ccColor3B randomColor = 
        ccc3(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return randomColor;
        }        
    }
}
+ (ccColor3B)randomMatchingColor3BToColor:(ccColor3B)col{
    
    return ccc3(col.r+arc4random() % 127, col.g, col.b+arc4random() % 30);
}
+ (ccColor3B)randomDullColor3B{
    
    while (true) {
        float maxBrightness = 192/2;
        float minBrightness = 192/3;
        ccColor3B randomColor = 
        ccc3(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255);
        if (randomColor.r < maxBrightness && randomColor.r > minBrightness &&  
            randomColor.g < maxBrightness && randomColor.g > minBrightness &&
            randomColor.b < maxBrightness && randomColor.b > minBrightness) {
            return randomColor;
        }        
    }
}
- (void)genBackground {
    
    /*
    [_background removeFromParentAndCleanup:YES];
    
    ccColor4F bgColor = [self randomBrightColor];
    ccColor4F color2 = [self randomBrightColor];
    //_background = [self spriteWithColor:bgColor textureSize:512];
    int nStripes = ((arc4random() % 4) + 1) * 2;
    _background = [self stripedSpriteWithColor1:bgColor color2:color2 textureSize:512 stripes:nStripes];
    
    self.scale = 0.5;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _background.position = ccp(winSize.width/2, winSize.height/2);        
    
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    
    [self addChild:_background];
    */
    
    [_background removeFromParentAndCleanup:YES];
    
    ccColor4F bgColor = [Background randomBrightColor];
    _background = [Background spriteWithColor:bgColor textureSize:512];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _background.position = ccp(winSize.width/2, winSize.height/2);        
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    
    [self addChild:_background];
    
    ccColor4F color3 = [Background randomBrightColor];
    ccColor4F color4 = [Background randomBrightColor];
    CCSprite *stripes = [self stripedSpriteWithColor1:color3 color2:color4 textureSize:512 stripes:4];
    ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
    [stripes.texture setTexParameters:&tp2];
    _terrain.stripes = stripes;
    _terrain2.stripes = stripes;
    _terrain2.stripes.opacity = 0.75;
    
    
}


-(CCSprite *)stripedSpriteWithColor1:(ccColor4F)c1 color2:(ccColor4F)c2 textureSize:(float)textureSize  stripes:(int)nStripes {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:c1.r g:c1.g b:c1.b a:c1.a];
    
    // 3: Draw into the texture    
    
    // Layer 1: Stripes
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    CGPoint vertices[nStripes*6];
    int nVertices = 0;
    float x1 = -textureSize;
    float x2;
    float y1 = textureSize;
    float y2 = 0;
    float dx = textureSize / nStripes * 2;
    float stripeWidth = dx/2;
    for (int i=0; i<nStripes; i++) {
        x2 = x1 + textureSize;
        vertices[nVertices++] = CGPointMake(x1, y1);
        vertices[nVertices++] = CGPointMake(x1+stripeWidth, y1);
        vertices[nVertices++] = CGPointMake(x2, y2);
        vertices[nVertices++] = vertices[nVertices-2];
        vertices[nVertices++] = vertices[nVertices-2];
        vertices[nVertices++] = CGPointMake(x2+stripeWidth, y2);
        x1 += dx;
    }
    
    glColor4f(c2.r, c2.g, c2.b, c2.a);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)nVertices);
    
    // layer 2: gradient
    glEnableClientState(GL_COLOR_ARRAY);
    
    float gradientAlpha = 0.7;    
    ccColor4F colors[4];
    nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureSize, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(textureSize, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    // layer 3: top highlight    
    float borderWidth = textureSize/16;
    float borderAlpha = 0.3f;
    nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){1, 1, 1, borderAlpha};
    vertices[nVertices] = CGPointMake(textureSize, 0);
    colors[nVertices++] = (ccColor4F){1, 1, 1, borderAlpha};
    
    vertices[nVertices] = CGPointMake(0, borderWidth);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(textureSize, borderWidth);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    // Layer 4: Noise  
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(textureSize/2, textureSize/2);
    [noise visit];
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

-(id) init {
    if((self=[super init])) {		
        
        _terrain = [Terrain node];
        _terrain2 = [Terrain node];
        _terrain2.scale = 2;
        [self addChild:_terrain2 z:1];
        [self addChild:_terrain z:2];
        
        [self genBackground];
        self.isTouchEnabled = YES;   
        
        [self scheduleUpdate];
        
        self.scale = 0.33;
    }
    return self;
}
- (void)update:(ccTime)dt {
    
    float PIXELS_PER_SECOND = 100;
    static float offset = 0;
    offset += PIXELS_PER_SECOND * dt;
    
    CGSize textureSize = _background.textureRect.size;
    [_background setTextureRect:CGRectMake(offset * 0.7, 0, textureSize.width, textureSize.height)];
    
    [_terrain setOffsetX:offset*2.5];
    [_terrain2 setOffsetX:offset*0.85];
    
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self genBackground];
    
}

@end