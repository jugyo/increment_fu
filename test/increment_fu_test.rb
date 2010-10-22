require 'test_helper'

ActiveRecord::Schema.define do
  create_table :foos, :force => true do |table|
    table.integer  :bar
    table.integer  :baz
    table.integer  :zab
  end
end

class Foo < ActiveRecord::Base
  increment_fu :bar, :min => 0, :max => 10
  increment_fu :baz, :min => lambda { |f| f.bar - 10 }, :max => lambda { |f| f.bar + 10 }
  increment_fu :zab, :max => 10
end

class IncrementFuTest < ActiveSupport::TestCase

  #
  # increment
  #

  test 'increment' do
    # bar
    foo = create_foo
    old_value = foo.bar
    foo.increment_bar
    assert_equal(old_value + 1, foo.bar)
    foo.reload
    assert_equal(old_value, foo.bar)

    # zab
    foo = create_foo
    old_value = foo.zab
    foo.increment_zab
    assert_equal(old_value + 1, foo.zab)
    foo.reload
    assert_equal(old_value, foo.zab)
  end

  test 'increment(by)' do
    foo = create_foo
    old_value = foo.bar

    foo.increment_bar(2)
    assert_equal(old_value + 2, foo.bar)
    foo.reload
    assert_equal(old_value, foo.bar)
  end

  test 'increment!' do
    foo = create_foo
    old_value = foo.bar

    foo.increment_bar!
    assert_equal(old_value + 1, foo.bar)
    foo.reload
    assert_equal(old_value + 1, foo.bar)
  end

  test 'increment!(by)' do
    foo = create_foo
    old_value = foo.bar

    foo.increment_bar!(2)
    assert_equal(old_value + 2, foo.bar)
    foo.reload
    assert_equal(old_value + 2, foo.bar)
  end

  test 'increment for over max' do
    {9 => 9, 10 => 10, 11 => 10}.each do |by, expected|
      foo = create_foo
      foo.increment_bar(by)
      assert_equal(expected, foo.bar)

      foo = create_foo
      foo.increment_zab(by)
      assert_equal(expected, foo.zab)
    end
  end

  test 'increment! for over max' do
    {9 => 9, 10 => 10, 11 => 10}.each do |by, expected|
      foo = create_foo
      foo.increment_bar!(by)
      assert_equal(expected, foo.bar)

      foo = create_foo
      foo.increment_zab!(by)
      assert_equal(expected, foo.zab)
    end
  end

  test 'max_baz_value' do
    foo = create_foo
    assert_equal(foo.bar + 10, foo.max_baz_value)

    foo = create_foo(:bar => 10)
    assert_equal(foo.bar + 10, foo.max_baz_value)
  end

  test 'increment with a max using lambda' do
    # increment_fu :baz, :min => lambda { |f| f.bar - 10 }, :max => lambda { |f| f.bar + 10 }

    foo = create_foo
    foo.increment_baz
    assert_equal(1, foo.baz)

    foo = create_foo
    assert_equal(foo.bar + 10, foo.max_baz_value)
    foo.increment_baz(foo.max_baz_value + 1)
    assert_equal(foo.max_baz_value, foo.baz)

    foo = Foo.create(:bar => 10)
    assert_equal(foo.bar + 10, foo.max_baz_value)
    foo.increment_baz(foo.max_baz_value + 1)
    assert_equal(foo.max_baz_value, foo.baz)
  end

  #
  # decrement
  #

  test 'decrement' do
    foo = create_foo(:bar => 10)
    old_value = foo.bar

    foo.decrement_bar
    assert_equal(old_value - 1, foo.bar)
    foo.reload
    assert_equal(old_value, foo.bar)
  end

  test 'decrement(by)' do
    foo = create_foo(:bar => 10)
    old_value = foo.bar

    foo.decrement_bar(2)
    assert_equal(old_value - 2, foo.bar)
    foo.reload
    assert_equal(old_value, foo.bar)
  end

  test 'decrement!' do
    foo = create_foo(:bar => 10)
    old_value = foo.bar

    foo.decrement_bar!
    assert_equal(old_value - 1, foo.bar)
    foo.reload
    assert_equal(old_value - 1, foo.bar)
  end

  test 'decrement!(by)' do
    foo = create_foo(:bar => 10)
    old_value = foo.bar

    foo.decrement_bar!(2)
    assert_equal(old_value - 2, foo.bar)
    foo.reload
    assert_equal(old_value - 2, foo.bar)
  end

  test 'decrement for under min' do
    {9 => 1, 10 => 0, 11 => 0}.each do |by, expected|
      foo = create_foo(:bar => 10)
      foo.decrement_bar(by)
      assert_equal(expected, foo.bar)
    end
  end

  test 'decrement! for under min' do
    {9 => 1, 10 => 0, 11 => 0}.each do |by, expected|
      foo = create_foo(:bar => 10)
      foo.decrement_bar!(by)
      assert_equal(expected, foo.bar)
    end
  end

  test 'decrement attribute which is not specified an option min' do
    {9 => 1, 10 => 0, 11 => -1}.each do |by, expected|
      foo = create_foo(:zab => 10)
      foo.decrement_zab!(by)
      assert_equal(expected, foo.zab)
    end
  end

  test 'min_baz_value' do
    foo = create_foo(:bar => 10)
    assert_equal(foo.bar - 10, foo.min_baz_value)

    foo = create_foo(:bar => 10)
    assert_equal(foo.bar - 10, foo.min_baz_value)
  end

  test 'decrement with a max using lambda' do
    # increment_fu :baz, :min => lambda { |f| f.bar - 10 }, :max => lambda { |f| f.bar + 10 }

    foo = create_foo(:baz => 10)
    foo.decrement_baz
    assert_equal(9, foo.baz)

    foo = create_foo
    assert_equal(foo.bar - 10, foo.min_baz_value)
    foo.decrement_baz(foo.max_baz_value + 1)
    assert_equal(foo.min_baz_value, foo.baz)

    foo = Foo.create(:bar => 10)
    assert_equal(foo.bar - 10, foo.min_baz_value)
    foo.decrement_baz(foo.max_baz_value + 1)
    assert_equal(foo.min_baz_value, foo.baz)
  end

  #
  # validation
  #

  test 'validates of max value' do
    foo = create_foo
    foo.bar = foo.max_bar_value
    assert foo.valid?
    foo.bar += 1
    assert !foo.valid?
    assert foo.errors.invalid?(:bar)
  end

  test 'validates of min value' do
    foo = create_foo
    foo.bar = foo.min_bar_value
    assert foo.valid?
    foo.bar -= 1
    assert !foo.valid?
    assert foo.errors.invalid?(:bar)
  end

  def create_foo(params = {})
    params = {:bar => 0, :baz => 0, :zab => 0}.merge(params)
    Foo.create!(params)
  end
end
