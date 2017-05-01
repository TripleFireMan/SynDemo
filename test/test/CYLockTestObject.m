//
//  CYLockTestObject.m
//  test
//
//  Created by 成焱 on 2017/4/23.
//  Copyright © 2017年 cheng.yan. All rights reserved.
//

#import "CYLockTestObject.h"
#import <pthread.h>
#import <libkern/OSAtomic.h>
#import <os/lock.h>
@interface CYSource : NSObject

@property (nonatomic, copy) NSString *name;

@end


@implementation CYSource


@end

@implementation CYLockTestObject

- (void)testLock
{
    // 先简单描述下使用场景，现在有一个线程A，有一个线程B，都要访问资源C，且线程A访问资源C要耗时2秒，线程B此时需要等待。
    __block NSString *name = @"成焱";
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 3;
    
    
    NSLock *lock = [NSLock new];
    
    [queue addOperationWithBlock:^{
        
        NSLog(@"1 将要上锁");
        [lock lock];
        NSLog(@"1 已上锁，访问资源");
        name = @"哇哈哈";
        sleep(3);
        NSLog(@"1 将要解锁");
        [lock unlock];
        NSLog(@"1 已解锁");
        
    }];
    
    [queue addOperationWithBlock:^{

        sleep(1);//保证此线程后面的方法后调用
        NSLog(@"2 将要上锁");
        [lock lock];
        NSLog(@"2 已上锁，访问资源");
        name = @"康师傅";
        sleep(2);
        NSLog(@"2 将要解锁");
        [lock unlock];
        NSLog(@"2 已解锁");
        
    }];
    
}

- (void)testBeforelock
{
    // 该测试方法主要用来测试锁的直道某时间结束函数怎么使用,lockbeforedate:的作用是在某个时间之前，一直尝试获取锁，如果获取到了，就进行锁操作，如果没获取到，则就不加锁。
    
    __block NSString *name = @"your name";
    
    NSLock *lock = [NSLock new];
    
    
    dispatch_queue_t globle = dispatch_get_global_queue(0, 0);
    
    
    dispatch_async(globle, ^{
       
        NSLog(@"线程1 将要加锁");
        [lock lock];
        
        name = @"hehe";
        
        sleep(10);
        NSLog(@"线程1 将要解锁");
        [lock unlock];
        
    });
    
    dispatch_async(globle, ^{
        
        // 保证此线程后调用
//        sleep(12);
        
        // 未来2秒的时间
        NSDate *date = [[NSDate date]dateByAddingTimeInterval:11];
        // 在未来2秒前尝试获取锁
        NSLog(@"在未来2秒前尝试获取锁");
        
        BOOL islocked = [lock lockBeforeDate:date];
        
        NSLog(@"在第4秒 请求获取锁，获取锁状态为 %d",islocked);
        
        name = @"wawa";
        
        
        
        if (islocked) {
            NSLog(@"线程2 将要解锁");
            [lock unlock];
        }else{
            NSLog(@"线程2 未获取到锁");
        }

        NSLog(@"线程2 已解锁");
    });
    
}

- (void)testSynchronized
{
    
    __block NSString *source = @"资源";
    
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    
    dispatch_async(global, ^{
       
        @synchronized (source) {
            NSLog(@"1 将要执行");
            sleep(3);
            NSLog(@"1 执行完毕");
        }
        
    });
    
    dispatch_async(global, ^{
        
        sleep(1);//只是为了让这个线程后调用
        
        @synchronized (source) {
            NSLog(@"2 将要执行");
            sleep(1);
            NSLog(@"2 执行完毕");
        }
        
    });
    
}

- (void)testSemaphore
{
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(global, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1 将要执行");
        sleep(3);
        NSLog(@"1 执行完毕");
        dispatch_semaphore_signal(semaphore);
    });

    dispatch_async(global, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"2 将要执行");
        sleep(3);
        NSLog(@"2 执行完毕");
        dispatch_semaphore_signal(semaphore);
        
    });
}

- (void)testAtomic
{
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(global, ^{
        NSLog(@"1 将要执行");
        self.name = @"成焱";
        sleep(3);
        NSLog(@"1 执行完毕");
    });
    
    dispatch_async(global, ^{
        NSLog(@"2 将要执行");
        self.name = @"开心";
        sleep(3);
        NSLog(@"2 执行完毕");
        
    });
}

- (void)testConditionLock
{
    int condition = 1;
    
    // 当满足条件时，如果锁空闲，可以获取到锁
    NSConditionLock *conditionLock = [[NSConditionLock alloc]initWithCondition:condition];
    
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    dispatch_async(global, ^{
        BOOL islocked = [conditionLock tryLockWhenCondition:1];
        NSLog(@"线程1 要执行");
        sleep(2);
        NSLog(@"线程1 执行完毕");
        if (islocked) {
            [conditionLock unlockWithCondition:3];
        }
    });
    dispatch_async(global, ^{
        BOOL isLocked = [conditionLock lockWhenCondition:2 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        NSLog(@"线程2 要执行");
        sleep(2);
        NSLog(@"线程2 执行完毕");
        if (isLocked) {
            [conditionLock unlockWithCondition:1];
        }
    });
    dispatch_async(global, ^{
        BOOL isLocked = [conditionLock tryLockWhenCondition:3];
        NSLog(@"线程3 要执行");
        sleep(3);
        NSLog(@"线程3 执行完毕");
        if (isLocked) {
            NSLog(@"加锁了");
            [conditionLock unlockWithCondition:10];
        }
    });
    
}

- (void)testBarrierAsyncAndSync
{
    /// 创建一个并发执行的队列
    dispatch_queue_t global = dispatch_queue_create("com.demo.chengyan", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(global, ^{
        NSLog(@"任务1");
    });
    
    dispatch_async(global, ^{
        NSLog(@"任务2");
    });
    
    
    dispatch_barrier_sync(global, ^{
        sleep(3);
        NSLog(@"任务3");
    });
    NSLog(@"---------------");
    
    dispatch_async(global, ^{
        NSLog(@"任务4");
    });
    
    dispatch_async(global, ^{
        NSLog(@"任务5");
    });
}

- (void)testDeadLock
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"deadlock");
    });
}

- (void)testPthreadMutex
{
    static pthread_mutex_t plock;
    pthread_mutex_init(&plock, NULL);

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        sleep(1);
        pthread_mutex_lock(&plock);
        NSLog(@"线程1 将要执行");
        sleep(3);
        NSLog(@"线程1 执行结束");
        pthread_mutex_unlock(&plock);
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int code = pthread_mutex_lock(&plock);
        NSLog(@"线程2 将要执行,code = %d",code);
        sleep(2);
        NSLog(@"线程2 执行结束");
        pthread_mutex_unlock(&plock);
    });
    
//    pthread_mutex_destroy(&plock);
   
}

- (void)testUnfairlock
{
    os_unfair_lock_t unfairlock = &OS_UNFAIR_LOCK_INIT;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        sleep(1);
        os_unfair_lock_lock(unfairlock);
        NSLog(@"线程1 将要执行");
        sleep(3);
        NSLog(@"线程1 执行结束");
        os_unfair_lock_unlock(unfairlock);
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        os_unfair_lock_lock(unfairlock);
        NSLog(@"线程2 将要执行");
        sleep(2);
        NSLog(@"线程2 执行结束");
        os_unfair_lock_unlock(unfairlock);
    });
    
}


- (void)testRecursiveLock
{
    NSRecursiveLock *recursive = [[NSRecursiveLock alloc]init];
//
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        
        [self getFactorial:10 cursive:recursive];
        
    });


}

- (int)getFactorial:(int)n cursive:(NSRecursiveLock *)lock
{
    int result = 0;
    NSLog(@"加锁");
    [lock lock];
    
    if (n <= 0) {
        result = 1;
    }else{
        result = [self getFactorial:n-1 cursive:lock] * n;
    }
    
    NSLog(@"result =%d",result);
    
    [lock unlock];
    NSLog(@"解锁");
    return result;
}

- (void)testCondition
{
    NSCondition *condition = [NSCondition new];
    NSMutableArray *ops = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        [condition lock];
        NSLog(@"1 将要上锁");
        while (ops.count == 0) {
            NSLog(@"1 等待");
            [condition wait];
        }
        NSLog(@"1 移除第一个元素");
        [ops removeObjectAtIndex:0];
        
        NSLog(@"1 将要解锁");
        [condition unlock];
    });
    
    dispatch_async(queue, ^{
        NSLog(@"2 将要上锁");
        [condition lock];
        NSLog(@"2 生产一个对象");
        [ops addObject:[NSObject new]];
        NSLog(@"2 发送信号");
        [condition signal];
        NSLog(@"2 将要解锁");
        [condition unlock];
    });
}
@end

















