//
//  ZCTextRunDelegate.m
//  图文混排demo
//
//  Created by pogong on 16/4/20.
//  Copyright © 2016年 pogong All rights reserved.
//

#import "ZCCTRunDelegateRefOwner.h"
#import <CoreText/CoreText.h>

static void DeallocCallback(void *ref) {
	ZCCTRunDelegateRefOwner * self = (__bridge_transfer ZCCTRunDelegateRefOwner *)(ref);
	self = nil; // release
}

static CGFloat GetAscentCallback(void *ref) {
	ZCCTRunDelegateRefOwner * self = (__bridge ZCCTRunDelegateRefOwner *)(ref);
	return self.ascent;
}

static CGFloat GetDecentCallback(void *ref) {
	ZCCTRunDelegateRefOwner * self = (__bridge ZCCTRunDelegateRefOwner *)(ref);
	return self.descent;
}

static CGFloat GetWidthCallback(void *ref) {
	ZCCTRunDelegateRefOwner * self = (__bridge ZCCTRunDelegateRefOwner *)(ref);
	return self.width;
}

@implementation ZCCTRunDelegateRefOwner

- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED {
	CTRunDelegateCallbacks callbacks;
	callbacks.version = kCTRunDelegateCurrentVersion;
	callbacks.dealloc = DeallocCallback;
	callbacks.getAscent = GetAscentCallback;
	callbacks.getDescent = GetDecentCallback;
	callbacks.getWidth = GetWidthCallback;
	return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(self.copy));
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:@(_ascent) forKey:@"ascent"];
	[aCoder encodeObject:@(_descent) forKey:@"descent"];
	[aCoder encodeObject:@(_width) forKey:@"width"];
	[aCoder encodeObject:_customRunContent forKey:@"customRunContent"];
	[aCoder encodeObject:[NSValue valueWithCGRect:_customRunFrame] forKey:@"customRunFrame"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	_ascent = ((NSNumber *)[aDecoder decodeObjectForKey:@"ascent"]).floatValue;
	_descent = ((NSNumber *)[aDecoder decodeObjectForKey:@"descent"]).floatValue;
	_width = ((NSNumber *)[aDecoder decodeObjectForKey:@"width"]).floatValue;
	_customRunContent = [aDecoder decodeObjectForKey:@"customRunContent"];
	_customRunFrame = [[aDecoder decodeObjectForKey:@"customRunFrame"] CGRectValue];
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	typeof(self) one = [self.class new];
	one.ascent = self.ascent;
	one.descent = self.descent;
	one.width = self.width;
	one.customRunContent = self.customRunContent;
	one.customRunFrame = self.customRunFrame;
	return one;
}

@end
