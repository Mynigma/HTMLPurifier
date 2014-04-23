//
//   HTMLPurifier_Queue.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Queue.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_Queue


- (id)init
{
    return [self initWithInput:[NSMutableArray new]];
}

- (id)initWithInput:(NSArray*)newInput
{
    self = [super init];
    if (self) {
        input = [newInput mutableCopy];
        output = [NSMutableArray new];
    }
    return self;
}

/**
 * Shifts an element off the front of the queue.
 */
- (NSObject*)shift
{
    if(output.count==0)
    {
        output = array_reverse(input);
        input = [NSMutableArray new];
    }
    if(output.count==0)
        return nil;

    return array_pop(output);
}



/**
 * Pushes an element onto the front of the queue.
 */
- (void)push:(NSObject*)x
{
    if(!x)
        return;

    array_push(input, x);
}

/**
 * Checks if it's empty.
 */
- (BOOL)isEmpty
{
    return input.count==0 && output.count==0;
}

@end
