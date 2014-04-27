# Possibly - Maybe monad for Ruby

Maybe monad implementation for Ruby

```ruby
puts Maybe(User.find_by_id("123")).username.downcase.getOrElse("N/A")

=> # puts downcased username if user "123" can be found, otherwise puts "N/A"
```

## Installation

```ruby
gem install possibly
```

## Getting started

```
require 'possibly'

first_name = Maybe(deep_hash)[:account][:profile][:first_name].getOrElse("No first name available")
```

## Documentation

Maybe monad is a programming pattern that allows to treat nil values that same way as non-nil values. This is done by wrapping the value, which may or may not be `nil` to, a wrapper class.

The implementation includes three different classes: `Maybe`, `Some` and `None`. `Some` represents a value, `None` represents a non-value and `Maybe` is a constructor, which results either `Some`, or `None`.

```ruby
Maybe("I'm a value")    => #<Maybe::Some:0x007ff7a85621e0 @value="I'm a value">
Maybe(nil)              => #<Maybe::None:0x007ff7a852bd20>
```

Both `Some` and `None` implement four trivial methods: `isSome?`, `isNone?`, `get` and `getOrElse`

```ruby
Maybe("I'm a value").isSome?                => true
Maybe("I'm a value").isNone?                => false
Maybe(nil).isSome?                          => false
Maybe(nil).isNone?                          => true
Maybe("I'm a value").get                    => "I'm a value"
Maybe("I'm a value").getOrElse("No value")  => "I'm a value"
Maybe(nil).get                              => RuntimeError: No such element
Maybe(nil).getOrElse("No value")            => "No value"
```

In addition, `Some` and `None` implement `Enumerable`, so all methods available for `Enumerable` are available for `Some` and `None`:

```ruby
Maybe("Print me!").each { |v| puts v }      => it puts "Print me!"
Maybe(nil).each { |v| puts v }              => puts nothing
Maybe(4).map { |v| Math.sqrt(v) }           => #<Maybe::Some:0x007ff7ac8697b8 @value=2.0>
Maybe(nil).map { |v| Math.sqrt(v) }         => #<Maybe::None:0x007ff7ac809b10>
Maybe(2).inject(3) { |a, b| a + b }         => 5
None().inject(3) { |a, b| a + b }           => 3
```

All the other methods you call on `Some` are forwarded to the `value`.

```ruby
Maybe("I'm a value").upcase                 => #<Maybe::Some:0x007ffe198e6128 @value="I'M A VALUE">
Maybe(nil).upcase                           => None
```

## Examples

Instead of using if-clauses to define whether a value is a `nil`, you can wrap the value with `Maybe()` and threat it the same way whether or not it is a `nil`

Without Maybe():

```ruby
user = User.find_by_id(user_id)
number_of_friends = if user && user.friends
  user.friends.count
else
  0
end
```

With Maybe():

```ruby
number_of_friends = Maybe(User.find_by_id(user_id)).friends.count.getOrElse(0)
```

Same in HAML view, without Maybe():

```haml
- if @user && @user.friends
  = @user.friends.count
- else
  0
```

```haml
= Maybe(@user).friends.count.getOrElse(0)
```

## License

[MIT](LICENSE)

## Author

[Mikko Koski](https://github.com/rap1ds) / [@rap1ds](http://twitter.com/rap1ds)

## Sponsored by

[Sharetribe](https://github.com/sharetribe) / [@sharetribe](http://twitter.com/sharetribe) / [www.sharetribe.com](https://www.sharetribe.com)