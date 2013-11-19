//
//  SpecializedOutputStreamFactory.m
//  OutputSpecialization
//
//  Created by John Bito on 11/15/13.
/*
 Copyright (c) 2013 Zillow, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <objc/runtime.h>
#import "SpecializedOutputStreamFactory.h"

@interface SpecializedOutputStreamFactory() <SpecializedOutputStreamTraits>

@property (nonatomic, strong) NSOutputStream *delegate;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger increment;
@end

@implementation SpecializedOutputStreamFactory

#pragma mark Instance creation
/*
 * Your class method has to set up the instance of the delegate,
 * so your creation methods will have to decide on the right way
 * to initialize the 'base' class.
 */
+ (SpecializedOutputStream *)createSpecializedOutputStream
{
    return (SpecializedOutputStream *) [[self alloc] initToMemory];
}

#pragma mark Internal initializer
- (instancetype)initToMemory
{
    self = [super init];
    if (self)
    {
        self.delegate = [NSOutputStream outputStreamToMemory];
    }
    return self;
}

#pragma mark Overridden method
- (void)write:(const uint8_t *)buffer maxLength:(NSUInteger)limit
{
    if (self.increment > 1)
    {
        NSUInteger current;
        for (current = self.offset; current < limit; current += self.increment)
        {
            [self.delegate write:buffer + current maxLength:1];
        }
        self.offset = (current - limit);
    }
    else
    {
        [self.delegate write:buffer maxLength:limit];
        NSData *data = [self.delegate propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [data length];
    }
}

#pragma mark Instance method
- (void)setSpecialBehavior:(NSString *)specialBehavior
{
    self.increment = 2;
    // The first character is odd.
    if ([@"Even" isEqualToString:specialBehavior])
    {
        self.offset = 1;
    }
    else if (![@"Odd" isEqualToString:specialBehavior])
    {
        self.increment = 1;
    }
}

#pragma mark Forwarding to delegate
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (class_respondsToSelector([self class], aSelector)) { return self; }
    if ([self.delegate respondsToSelector:aSelector]) { return self.delegate; }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (class_respondsToSelector([self class], aSelector)) { return YES; }
    if ([self.delegate respondsToSelector:aSelector]) { return YES; }
    return [super respondsToSelector:aSelector];
}

@end
