//
//  HTMLPurifier_Zipper.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.


#import "HTMLPurifier_Zipper.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_Zipper


- (id)initWithFront:(NSArray*)newFront back:(NSArray*)newBack
{
    self = [super init];
    if (self) {
        _front = [newFront mutableCopy];
        _back = [newBack mutableCopy];
    }
    return self;
}
     /**
     * Creates a zipper from an array, with a hole in the
     * 0-index position.
     * @param Array to zipper-ify.
     * @return Tuple of zipper and element of first position.
     */
    + (NSArray*)fromArray:(NSArray*)array
{
        HTMLPurifier_Zipper* z = [[HTMLPurifier_Zipper alloc] initWithFront:@[] back:array_reverse([array mutableCopy])];
        NSObject* t = [z delete]; // delete the "dummy hole"
        if (!t)
            return @[z];
        return @[z, t];
    }

    /**
     * Convert zipper back into a normal array, optionally filling in
     * the hole with a value. (Usually you should supply a $t, unless you
     * are at the end of the array.)
     */
- (NSArray*)toArray:(NSObject*)t
{
        NSMutableArray* a = [[self front] mutableCopy];
        if (t)
            [a addObject:t];
        for (NSInteger i = [[self back] count]-1; i >= 0; i--)
        {
            [a addObject:self.back[i]];
        }
        return a;
}

    /**
     * Move hole to the next element.
     * @param $t Element to fill hole with
     * @return Original contents of new hole.
     */
- (NSObject*)next:(NSObject*)t
{
        if(t)
            array_push(self.front, t);
        return self.back.count==0 ? nil : array_pop(self.back);
}

    /**
     * Iterated hole advancement.
     * @param $t Element to fill hole with
     * @param $i How many forward to advance hole
     * @return Original contents of new hole, i away
     */
- (NSObject*) advance:(NSObject*)t by:(NSInteger)n
{
    for (NSInteger i = 0; i < n; i++)
    {
        t = [self next:t];
    }
        return t;
}

    /**
     * Move hole to the previous element
     * @param $t Element to fill hole with
     * @return Original contents of new hole.
     */
- (NSObject*)prev:(NSObject*)t
{
    if (t)
        array_push(self.back, t);
    return self.front.count==0 ? nil : array_pop(self.front);
}

    /**
     * Delete contents of current hole, shifting hole to
     * next element.
     * @return Original contents of new hole.
     */
- (NSObject*)delete
{
    return self.back.count==0 ? nil : array_pop(self.back);
}

    /**
     * Returns true if we are at the end of the list.
     * @return bool
     */
- (BOOL)done
{
    return self.back.count==0;
}

    /**
     * Insert element before hole.
     * @param Element to insert
     */
- (void)insertBefore:(NSObject*)t
{
    if(t)
        array_push(self.front, t);
}

    /**
     * Insert element after hole.
     * @param Element to insert
     */
- (void)insertAfter:(NSObject*)t
{
        if (t)
            array_push(self.back, t);
}

    /**
     * Splice in multiple elements at hole.  Functional specification
     * in terms of array_splice:
     *
     *      $arr1 = $arr;
     *      $old1 = array_splice($arr1, $i, $delete, $replacement);
     *
     *      list($z, $t) = HTMLPurifier_Zipper::fromArray($arr);
     *      $t = $z->advance($t, $i);
     *      list($old2, $t) = $z->splice($t, $delete, $replacement);
     *      $arr2 = $z->toArray($t);
     *
     *      assert($old1 === $old2);
     *      assert($arr1 === $arr2);
     *
     * NB: the absolute index location after this operation is
     * *unchanged!*
     *
     * @param Current contents of hole.
     */
- (NSObject*)splice:(NSObject*)t delete:(NSInteger)delete replacement:(NSArray*)replacement
{
        // delete
        NSMutableArray* old = [NSMutableArray new];
        NSObject* r = t;
        for (NSInteger i = delete; i > 0; i--)
        {
            if (r) {
                [old addObject:r];
                r = [self delete];
            }
        }
        // insert
        for (NSInteger i = replacement.count-1; i >= 0; i--)
        {
            [self insertAfter:r];
            r = replacement[i];
        }
        return @[old, r];
}


@end
