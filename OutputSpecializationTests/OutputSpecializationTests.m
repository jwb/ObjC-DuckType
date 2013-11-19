//
//  OutputSpecializationTests.m
//  OutputSpecializationTests
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

#import <XCTest/XCTest.h>
#import "SpecializedOutputStreamFactory.h"

@interface OutputSpecializationTests : XCTestCase

@property (nonatomic, strong) SpecializedOutputStream *testOutput;

@end

@implementation OutputSpecializationTests

- (void)setUp
{
    [super setUp];
    self.testOutput = [SpecializedOutputStreamFactory createSpecializedOutputStream];
    [self.testOutput scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.testOutput open];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOutputOdd
{
    [self.testOutput setSpecialBehavior:@"Odd"];
    NSData *data = [self writeTheSample];
    XCTAssertEqual([data length], (NSUInteger)3, @"Expect the output length to be %d; it was %d", 3, [data length]);
    char *ptr = (char *)[data bytes];
    XCTAssertTrue(*(ptr++) == '1');
    XCTAssertTrue(*(ptr++) == '3');
    XCTAssertTrue(*(ptr++) == '5');
}

- (void)testOutputEven
{
    [self.testOutput setSpecialBehavior:@"Even"];
    NSData *data = [self writeTheSample];
    XCTAssertEqual([data length], (NSUInteger)3, @"Expect the output length to be %d; it was %d", 3, [data length]);
    char *ptr = (char *)[data bytes];
    XCTAssertTrue(*(ptr++) == '2');
    XCTAssertTrue(*(ptr++) == '4');
    XCTAssertTrue(*(ptr++) == '6');
}

- (void)testOutputAll
{
    NSData *data = [self writeTheSample];
    XCTAssertEqual([data length], (NSUInteger)6, @"Expect the output length to be %d; it was %d", 6, [data length]);
    u_int8_t *ptr = (u_char *)[data bytes];
    XCTAssertTrue(*(ptr++) == '1');
    XCTAssertTrue(*(ptr++) == '2');
    XCTAssertTrue(*(ptr++) == '3');
}

- (NSData *)writeTheSample
{
    [self.testOutput write:(uint8_t *)"12" maxLength:2];
    [self.testOutput write:(uint8_t *)"345" maxLength:3];
    [self.testOutput write:(uint8_t *)"6" maxLength:1];
    return  [self.testOutput propertyForKey:NSStreamDataWrittenToMemoryStreamKey];

}
@end
