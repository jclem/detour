# Detour

Rollouts for `ActiveRecord` models. It is a spiritual fork of [ArRollout](https://github.com/markpundsack/ar_rollout).

| development status | master status | Code Climate |
| ------------------ | ------------- | ------------ |
| [![development status][dev_image]][branch_status] | [![master status][master_image]][branch_status] | [![Code Climate][code_climate_image]][code_climate]

[dev_image]: https://api.travis-ci.org/jclem/detour.png?branch=development
[master_image]: https://api.travis-ci.org/jclem/detour.png?branch=master
[branch_status]: https://travis-ci.org/jclem/detour/branches
[code_climate_image]: https://codeclimate.com/github/jclem/detour.png
[code_climate]: https://codeclimate.com/github/jclem/detour

## Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Marking a model as flaggable](#marking-a-model-as-flaggable)
  - [Determining if a record is flagged into a feature](#determining-if-a-record-is-flagged-into-a-feature)
  - [Feature operations](#feature-operations)
    - [Creating features](#creating-features)
    - [Destroying features](#destroying-features)
    - [Flagging a record into a feature](#flagging-a-record-into-a-feature)
    - [Removing a flag-in for a record for a feature](#removing-a-flag-in-for-a-record-for-a-feature)
    - [Opt a record out of a feature](#opt-a-record-out-of-a-feature)
    - [Un-opt out a record from a feature](#un-opt-out-a-record-from-a-feature)
    - [Flag a programmatic group into a feature](#flag-a-programmatic-group-into-a-feature)
    - [Remove a flag-in for a programmatic group for a feature](#remove-a-flag-in-for-a-programmatic-group-for-a-feature)
    - [Flag a percentage of records into a feature](#flag-a-percentage-of-records-into-a-feature)
    - [Remove a flag-in for a percentage of records for a feature](#remove-a-flag-in-for-a-percentage-of-records-for-a-feature)
  - [Defining a default class](#defining-a-default-class)
  - [Defining programmatic groups](#defining-programmatic-groups)
- [Contributing](#contributing)


## Installation

Add this line to your application's Gemfile:

    gem 'detour'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install detour

## Usage

`Detour` works by determining whether or not a specific record
should have features accessible to it based on individual flags, flags for a
percentage of records, or flags for a programmable group of records.

### Marking a model as flaggable

```ruby
class User < ActiveRecord::Base
  acts_as_flaggable
end
```

Or, in order to user emails rather than IDs to identify records in rake tasks:

```ruby
class User < ActiveRecord::Base
  acts_as_flaggable find_by: :email
end
```

This module adds `has_many` associations to `User` for `flaggable_flags` (where
the user has been individually flagged into a feature), `opt_out_flags` (where
the user has been opted out of a feature), and `features` (the features that
the user has been individually flagged into, regardless of opt outs).

However, these methods aren't enough to determine whether or not the user is
flagged into a specific feature. The `#has_feature?` method provided by
`Detour::Flaggable` should be used for this.

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
  render_new_user_interface
end
```

Want to make use of both? `#has_feature?` returns a boolean even when passed
a block:

```ruby
if current_user.has_feature? :new_user_interface do
  render_new_user_interface
end; else
  render_old_user_interface
end
```

### Feature operations

Features and flags are intended to be controlled by a rake tasks. To create
them programmatically, consult the documentation.

#### Creating features

```sh
$ bundle exec rake detour:create[new_ui]
```

#### Destroying features

```sh
$ bundle exec rake detour:destroy[new_ui]
```

#### Flagging a record into a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:activate[new_ui,User,2]
```

#### Removing a flag-in for a record for a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:deactivate[new_ui,User,2]
```

#### Opt a record out of a feature

This will ensure that `record.has_feature?(:feature)` will always be false for
the given feature, regardless of other individual flag, percentage, or group
rollouts that would otherwise target this record.

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:opt_out[new_ui,User,2]
```

#### Un-opt out a record from a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:un_opt_out[new_ui,User,2]
```

#### Flag a programmatic group into a feature

This task requires passing the feature name, the record class for the group,
and the name of the group.

```sh
$ bundle exec rake detour:activate_group[new_ui,User,admins]
```

#### Remove a flag-in for a programmatic group for a feature

This task requires passing the feature name, the record class for the group,
and the name of the group.

```sh
$ bundle exec rake detour:deactivate_group[new_ui,User,admins]
```

#### Flag a percentage of records into a feature

This relies on the following formula to determine if a record is flagged in to
a feature based on percentage:

```ruby
record.id % 10 < percentage / 10
```

This task requires passing the feature name, the record class for the group,
and the percentage of records to be flagged in.

```sh
$ bundle exec rake detour:activate_percentage[new_ui,User,20]
```

#### Remove a flag-in for a percentage of records for a feature

This task requires passing the feature name, and the record class for the group.

```sh
$ bundle exec rake detour:deactivate_percentage[new_ui,User]
```

### Defining a default class

In order to provide passing a class name into rake tasks, a default class can
be set:

```ruby
Detour.configure do |config|
  config.default_flaggable_class_name = "User"
end
```

Then, in your rake tasks:

```sh
# Will activate feature "foo" for all instances of User that match the admins group.
$ bundle exec rake detour:activate_group[foo,admins]
```

### Defining programmatic groups

A specific group of records matching a given block can be flagged into a
feature. In order to define these groups, use
`Detour.configure`:

```ruby
Detour.configure do |config|
  # Any User that returns truthy for `user.admin?` will be included in this
  # group: `admins`.
  config.define_user_group :admins do |user|
    user.admin?
  end

  # Any FizzBuzz that returns truthy for `fizz_buzz.bar?` will be included in
  # this group: `is_bar`.
  config.define_fizz_buzz_group :is_bar do |fizz_buzz|
    fizz_buzz.bar?
  end
end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/detour/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
