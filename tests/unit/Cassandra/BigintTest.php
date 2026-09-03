<?php

/**
 * Copyright 2015-2017 DataStax, Inc.
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

use PHPUnit\Framework\TestCase;

/**
 * NumberTest already exercises the arithmetic, conversions and range checks
 * that Bigint shares with the other numeric types. What is left to Bigint
 * itself is covered here: the string a 64 bit value is rendered as, the
 * bounds, and the type.
 *
 * These are worth their own assertions because rendering a 64 bit integer
 * needs a platform specific format, and getting it wrong printed the format
 * specifier rather than the number on Windows while every Linux build stayed
 * green.
 *
 * @requires extension cassandra
 */
class BigintTest extends TestCase {
    public function testValueFromString()
    {
        $bigint = new Bigint("42");
        $this->assertEquals("42", $bigint->value());
        $this->assertEquals("42", (string) $bigint);
    }

    public function testValueFromInteger()
    {
        $bigint = new Bigint(42);
        $this->assertEquals("42", $bigint->value());
        $this->assertEquals("42", (string) $bigint);
    }

    public function testValueNegative()
    {
        $bigint = new Bigint("-42");
        $this->assertEquals("-42", $bigint->value());
        $this->assertEquals("-42", (string) $bigint);
    }

    /**
     * A value that needs all 64 bits, which is where a format meant for a
     * narrower type would show up.
     */
    public function testValueAtBounds()
    {
        $this->assertEquals("9223372036854775807", (new Bigint("9223372036854775807"))->value());
        $this->assertEquals("-9223372036854775808", (new Bigint("-9223372036854775808"))->value());
    }

    public function testMinimum()
    {
        $minimum = Bigint::min();
        $this->assertInstanceOf(Bigint::class, $minimum);
        $this->assertEquals("-9223372036854775808", $minimum->value());
    }

    public function testMaximum()
    {
        $maximum = Bigint::max();
        $this->assertInstanceOf(Bigint::class, $maximum);
        $this->assertEquals("9223372036854775807", $maximum->value());
    }

    public function testType()
    {
        $this->assertEquals("bigint", (new Bigint("1"))->type()->name());
        $this->assertEquals(Type::bigint(), (new Bigint("1"))->type());
    }

    public function testConversions()
    {
        $bigint = new Bigint("42");
        $this->assertSame(42, $bigint->toInt());
        $this->assertSame(42.0, $bigint->toDouble());
    }

    /**
     * The message names both bounds and the offending value, so all three are
     * rendered through the same 64 bit format. Building it wrong took the
     * process down rather than raising anything.
     */
    public function testStringArgOverflowError()
    {
        $this->expectException(Exception\RangeException::class);
        $this->expectExceptionMessage("value must be between -9223372036854775808 and 9223372036854775807, 9223372036854775808 given");
        new Bigint("9223372036854775808");
    }

    public function testStringArgUnderflowError()
    {
        $this->expectException(Exception\RangeException::class);
        $this->expectExceptionMessage("value must be between -9223372036854775808 and 9223372036854775807, -9223372036854775809 given");
        new Bigint("-9223372036854775809");
    }
}
