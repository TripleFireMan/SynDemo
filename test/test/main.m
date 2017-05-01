//
//  main.m
//  test
//
//  Created by 成焱 on 2017/4/23.
//  Copyright © 2017年 cheng.yan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYLockTestObject.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CYLockTestObject *testLock = [CYLockTestObject new];
//        [testLock testLock];
//        [testLock testSynchronized];
//        [testLock testBeforelock];
//        [testLock testSemaphore];
//        [testLock testAtomic];
//        [testLock testConditionLock];
//        [testLock testBarrierAsyncAndSync];
//        [testLock testPthreadMutex];
//        [testLock testUnfairlock];
//        [testLock testRecursiveLock];
        
        [testLock testCondition];
        

        while (1) {
                [[NSRunLoop currentRunLoop]run];
        }
        
        

        
        
    }
    return 0;
}



