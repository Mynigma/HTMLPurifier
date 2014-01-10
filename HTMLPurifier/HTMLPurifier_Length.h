//
//  HTMLPurifier_Length.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPurifier_Length : NSObject
{

    /**
     * String numeric magnitude.
     * @type string
     */
    NSString* n;

    /**
     * String unit. False is permitted if $n = 0.
     * @type string|bool
     */
    NSString* unit;

    /**
     * Whether or not this length is valid. Null if not calculated yet.
     * @type bool
     */
    NSNumber* isValid;

    /**
     * Array Lookup array of units recognized by CSS 2.1
     * @type array
     */
    NSDictionary* allowedUnits;
}

    /**
     * @param string $n Magnitude
     * @param bool|string $u Unit
     */
    public function __construct($n = '0', $u = false)
    {
        $this->n = (string) $n;
        $this->unit = $u !== false ? (string) $u : false;
    }

    /**
     * @param string $s Unit string, like '2em' or '3.4in'
     * @return HTMLPurifier_Length
     * @warning Does not perform validation.
     */
    public static function make($s)
    {
        if ($s instanceof HTMLPurifier_Length) {
            return $s;
        }
        $n_length = strspn($s, '1234567890.+-');
        $n = substr($s, 0, $n_length);
        $unit = substr($s, $n_length);
        if ($unit === '') {
            $unit = false;
        }
        return new HTMLPurifier_Length($n, $unit);
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
