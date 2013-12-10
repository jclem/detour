# ActiveRecord::Rollout

Rollouts for `ActiveRecord` models. It is a spiritual fork of [ArRollout](https://github.com/markpundsack/ar_rollout).

## Installation

Add this line to your application's Gemfile:

    gem 'active_record_rollout', require: 'active_record/rollout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_rollout

## Usage

`ActiveRecord::Rollout` works by determining whether or not a specific record
should have features accessible to it based on individual flags, flags for a
percentage of records, or flags for a programmable group of records.

### Marking a model as flaggable

```ruby
class User < ActiveRecord::Base
  include ActiveRecord::Rollout::Flaggable
end
```

This module adds `has_many` associations to `User` for `flaggable_flags` (where
the user has been individually flagged into a feature), `opt_out_flags` (where
the user has been opted out of a feature), and `features` (the features that
the user has been individually flagged into, regardless of opt outs).

However, these methods aren't enough to determine whether or not the user is
flagged into a specific feature. The `#has_feature?` method provided by
`ActiveRecord::Rollout::Flaggable` should be used for this.

### Determining if a record is flagged into a feature

`#has_feature?` has two methods of use. The first one, where it is passed a
block, will increment a `failure_count` on the given feature if the block
raises an exception (the exception is again raised after incrementing). This
currently does not alter the behavior of the feature, but it services a metrics
purpose:

```ruby
current_user.has_feature? :new_user_interface do
  render_new_user_interface
end
```

When not given a block, it simply returns a boolean, and does not watch for
exceptions:

```ruby
if current_user.has_feature? :new_user_interface
end
```

### Feature operations

Features and flags are intended to be controlled by a rake tasks. To create
them programmatically, consult the documentation.

#### Creating features

```sh
$ bundle exec rake rollout:create[new_ui]
```

#### Destroying features

```sh
$ bundle exec rake rollout:destroy[new_ui]
```

#### Flagging a record into a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake rollout:activate[new_ui,User,2]
```

#### Removing a flag-in for a record for a feature:

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake rollout:deactivate[new_ui,User,2]
```

#### Opt a record out of a feature

This will ensure that `record.has_feature?(:feature)` will always be false for
the given feature, regardless of other individual flag, percentage, or group
rollouts that would otherwise target this record.

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake rollout:opt_out[new_ui,User,2]
```

#### Un-opt out a record from a feature.

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake rollout:un_opt_out[new_ui,User,2]
```

#### Flag a programmatic group into a feature.

This task requires passing the feature name, the record class for the group,
and the name of the group.

```sh
$ bundle exec rake rollout:activate_group[new_ui,User,admins]
```

#### Remove a flag-in for a programmatic group for a feature.

This task requires passing the feature name, the record class for the group,
and the name of the group.

```sh
$ bundle exec rake rollout:deactivate_group[new_ui,User,admins]
```

#### Flag a percentage of records into a feature.

This relies on the following formula to determine if a record is flagged in to
a feature based on percentage:

```ruby
record.id % 10 < percentage / 10
```

This task requires passing the feature name, the record class for the group,
and the percentage of records to be flagged in.

```sh
$ bundle exec rake rollout:activate_percentage[new_ui,User,20]
```

#### Remove a flag-in for a percentage of records for a feature.

This task requires passing the feature name, and the record class for the group.

```sh
$ bundle exec rake rollout:deactivate_percentage[new_ui,User]
```

### Defining programmatic groups

A specific group of records matching a given block can be flagged into a
feature. In order to define these groups, use
`ActiveRecord::Rollout.configure`:

```ruby
ActiveRecord::Rollout.configure do |config|
  # Any User that returns truthy for `user.admin?` will be included in this
  # group.
  config.define_user_group :admins do |user|
    user.admin?
  end

  # Any FizzBuzz that returns truthy for `fizz_buzz.bar?` will be included in
  # this group.
  config.define_fizz_buzz_group :foo do |fizz_buzz|
    fizz_buzz.bar?
  end
end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/active_record_rollout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
