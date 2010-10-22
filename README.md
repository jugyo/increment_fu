IncrementFu
===============

It provides the usefull methods for increment or decrement.

Example
=======

schema:

    create_table :foos do |t|
      t.integer  :bar
      t.integer  :baz
    end

model:

    class Foo < ActiveRecord::Base
      increment_fu :bar, :min => 0, :max => 10
      increment_fu :baz, :min => lambda { |f| f.bar - 10 }, :max => lambda { |f| f.bar + 10 }
    end

usage:

    foo = Foo.create(:bar => 0, :baz => 0)
    p foo.bar # => 0
    foo.increment_bar
    p foo.bar # => 1
    foo.increment_bar(10)
    p foo.bar # => 10

Copyright (c) 2010 jugyo, released under the MIT license
