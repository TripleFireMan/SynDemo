//
//  CYLockTestObject.h
	//  test
//
//  Created by 成焱 on 2017/4/23.
//  Copyright © 2017年 cheng.yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYLockTestObject : NSObject

@property (nonatomic, copy)  NSString *name;

// 测试Lock的demo
- (void)testLock;
- (void)testBeforelock;
- (void)testSynchronized;
- (void)testSemaphore;
- (void)testAtomic;
- (void)testConditionLock;
- (void)testBarrierAsyncAndSync;
- (void)testPthreadMutex;
- (void)testUnfairlock;
- (void)testRecursiveLock;
- (void)testCondition;
@end
