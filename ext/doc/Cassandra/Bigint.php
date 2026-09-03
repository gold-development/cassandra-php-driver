<?php

/**
 * Copyright 2017 DataStax, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace Cassandra;

/**
 * A PHP representation of the CQL `bigint` datatype
 */
final class Bigint implements \Stringable, Value, Numeric
{
    /**
     * Creates a new 64bit integer.
     *
     * @param string $value integer value as a string
     */
    public function __construct(string $value)
    {
    }

    /**
     * Returns string representation of the integer value.
     *
     * @return string integer value
     */
    public function __toString(): string
    {
    }

    /**
     * The type of this bigint.
     *
     * @return \Cassandra\Type
     */
    public function type(): \Cassandra\Type
    {
    }

    /**
     * Returns the integer value.
     *
     * @return string integer value
     */
    public function value(): string
    {
    }

    /**
     * Adds the given number to this one.
     *
     * @param \Cassandra\Numeric $num a number to add to this one
     *
     * @throws Exception\InvalidArgumentException when the given number is of another type
     * @throws Exception\RangeException when the sum falls outside the range of the type
     *
     * @return \Cassandra\Numeric sum
     */
    public function add(\Cassandra\Numeric $num): \Cassandra\Numeric
    {
    }

    /**
     * Subtracts the given number from this one.
     *
     * @param \Cassandra\Numeric $num a number to subtract from this one
     *
     * @throws Exception\InvalidArgumentException when the given number is of another type
     * @throws Exception\RangeException when the difference falls outside the range of the type
     *
     * @return \Cassandra\Numeric difference
     */
    public function sub(\Cassandra\Numeric $num): \Cassandra\Numeric
    {
    }

    /**
     * Multiplies this number by the given one.
     *
     * @param \Cassandra\Numeric $num a number to multiply this one by
     *
     * @throws Exception\InvalidArgumentException when the given number is of another type
     * @throws Exception\RangeException when the product falls outside the range of the type
     *
     * @return \Cassandra\Numeric product
     */
    public function mul(\Cassandra\Numeric $num): \Cassandra\Numeric
    {
    }

    /**
     * Divides this number by the given one.
     *
     * Integer types truncate towards zero, so 7 divided by 2 is 3 and -7
     * divided by 2 is -3.
     *
     * @param \Cassandra\Numeric $num a number to divide this one by
     *
     * @throws Exception\InvalidArgumentException when the given number is of another type
     * @throws Exception\DivideByZeroException when the given number is zero
     * @throws Exception\RuntimeException when the type has no division, as \Cassandra\Decimal does not
     *
     * @return \Cassandra\Numeric quotient
     */
    public function div(\Cassandra\Numeric $num): \Cassandra\Numeric
    {
    }

    /**
     * Returns the remainder of dividing this number by the given one.
     *
     * For \Cassandra\Float this is the floating point remainder, so 7.5
     * modulo 2.0 is 1.5.
     *
     * @param \Cassandra\Numeric $num a number to divide this one by
     *
     * @throws Exception\InvalidArgumentException when the given number is of another type
     * @throws Exception\DivideByZeroException when the given number is zero
     * @throws Exception\RuntimeException when the type has no modulo, as \Cassandra\Decimal does not
     *
     * @return \Cassandra\Numeric remainder
     */
    public function mod(\Cassandra\Numeric $num): \Cassandra\Numeric
    {
    }

    /**
     * Returns the absolute value of this number.
     *
     * @throws Exception\RangeException when the type cannot represent the result
     *
     * @return \Cassandra\Numeric absolute value
     */
    public function abs(): \Cassandra\Numeric
    {
    }

    /**
     * Returns this number with its sign inverted.
     *
     * @throws Exception\RangeException when the type cannot represent the result
     *
     * @return \Cassandra\Numeric negative value
     */
    public function neg(): \Cassandra\Numeric
    {
    }

    /**
     * Returns the square root of this number.
     *
     * Integer types truncate the result, so the square root of 10 is 3.
     *
     * @throws Exception\RangeException when this number is negative
     * @throws Exception\RuntimeException when the type has no square root, as \Cassandra\Decimal does not
     *
     * @return \Cassandra\Numeric square root
     */
    public function sqrt(): \Cassandra\Numeric
    {
    }

    /**
     * Returns this number as a PHP int, truncating any fractional part
     * towards zero.
     *
     * @throws Exception\RangeException when the value does not fit in a PHP int
     *
     * @return int this number as int
     */
    public function toInt(): int
    {
    }

    /**
     * Returns this number as a PHP float.
     *
     * Values that exceed the precision of a float are rounded, so a
     * \Cassandra\Bigint of 9007199254740993 reads back as 9007199254740992.
     *
     * @return float this number as float
     */
    public function toDouble(): float
    {
    }

    /**
     * Minimum possible Bigint value
     *
     * @return \Cassandra\Bigint minimum value
     */
    public static function min(): \Cassandra\Bigint
    {
    }

    /**
     * Maximum possible Bigint value
     *
     * @return \Cassandra\Bigint maximum value
     */
    public static function max(): \Cassandra\Bigint
    {
    }
}
