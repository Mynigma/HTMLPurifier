//
//  HTMLPurifier_Length.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Length.h"

@implementation HTMLPurifier_Length

- (id)initWithN:(NSString*)newN u:(NSString*)newU
{
    self = [super init];
    if (self) {
        allowedUnits = @{@"em":@YES, @"ex":@YES, @"px":@YES, @"in":@YES, @"cm":@YES, @"mm":@YES, @"pt":@YES, @"pc":@YES};
        n = newN;
        unit = newU;
    }
    return self;
}

- (id)initWithN:(NSString*)newN
{
    return [self initWithN:newN u:nil];
}

- (id)init
{
    return [self initWithN:nil u:nil];
}

    /**
     * @param string $s Unit string, like '2em' or '3.4in'
     * @return HTMLPurifier_Length
     * @warning Does not perform validation.
     */
- (HTMLPurifier_Length*)makeWithS:(NSObject*)s
    {
        if ([s isKindOfClass:[HTMLPurifier_Length class]])
            return  (HTMLPurifier_Length*)s;


        if([s isKindOfClass:[NSString class]])
{

        NSInteger n_length = strspn([(NSString*)s cStringUsingEncoding:NSUTF8StringEncoding], '1234567890.+-');
        $n = substr($s, 0, $n_length);
        $unit = substr($s, $n_length);
        if ($unit === '') {
            $unit = false;
        }
        return new HTMLPurifier_Length($n, $unit);
}
    }

    /**
     * Validates the number and unit.
     * @return bool
     */
    protected function validate()
    {
        // Special case:
        if ($this->n === '+0' || $this->n === '-0') {
            $this->n = '0';
        }
        if ($this->n === '0' && $this->unit === false) {
            return true;
        }
        if (!ctype_lower($this->unit)) {
            $this->unit = strtolower($this->unit);
        }
        if (!isset(HTMLPurifier_Length::$allowedUnits[$this->unit])) {
            return false;
        }
        // Hack:
        $def = new HTMLPurifier_AttrDef_CSS_Number();
        $result = $def->validate($this->n, false, false);
        if ($result === false) {
            return false;
        }
        $this->n = $result;
        return true;
    }

    /**
     * Returns string representation of number.
     * @return string
     */
    public function toString()
    {
        if (!$this->isValid()) {
            return false;
        }
        return $this->n . $this->unit;
    }

    /**
     * Retrieves string numeric magnitude.
     * @return string
     */
    public function getN()
    {
        return $this->n;
    }

    /**
     * Retrieves string unit.
     * @return string
     */
    public function getUnit()
    {
        return $this->unit;
    }

    /**
     * Returns true if this length unit is valid.
     * @return bool
     */
    public function isValid()
    {
        if ($this->isValid === null) {
            $this->isValid = $this->validate();
        }
        return $this->isValid;
    }

    /**
     * Compares two lengths, and returns 1 if greater, -1 if less and 0 if equal.
     * @param HTMLPurifier_Length $l
     * @return int
     * @warning If both values are too large or small, this calculation will
     *          not work properly
     */
    public function compareTo($l)
    {
        if ($l === false) {
            return false;
        }
        if ($l->unit !== $this->unit) {
            $converter = new HTMLPurifier_UnitConverter();
            $l = $converter->convert($l, $this->unit);
            if ($l === false) {
                return false;
            }
        }
        return $this->n - $l->n;
    }
}

@end
