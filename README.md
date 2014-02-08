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
  - [Configuration](#configuration)
  - [Marking a model as flaggable](#marking-a-model-as-flaggable)
  - [Determining if a record is flagged into a feature](#determining-if-a-record-is-flagged-into-a-feature)
  - [Defining programmatic groups](#defining-programmatic-groups)
- [Contributing](#contributing)

## Installation

Add this line to your application's Gemfile:

    gem 'detour'

And then execute:

    $ bundle

In your rails app:

    $ bundle exec rails generate detour

Run the Detour migrations:

    $ bundle exec rake db:migrate

## Usage

`Detour` works by determining whether or not a specific record
should have features accessible to it based on individual flags, flags for a
percentage of records, or flags for a programmable group of records.

### Configuration

Edit `config/initializers/detour.rb`:

```ruby
Detour.configure do |config|
  # Detour needs to know at boot which models will
  # have flags defined for them:
  config.flaggable_types = %w[User Widget]

  # Detour needs to know what directories to search
  # through in order to find places where you're
  # checking for flags in your code. Provide it an
  # array of glob strings:
  config.feature_search_dirs = %w[app/**/*.{rb,erb}]
end
```

Mount the app in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Detour::Engine => "/detour"
end
```

### Restricting the admin interface

If you'd like your Detour admin interface only accessible to admins, for example,
you can add a `before_filter` to `Detour::ApplicationController` in the Detour
initializer:

```ruby
# config/initializers/detour.rb

Detour::ApplicationController.class_eval do
  include CurrentUser

  before_filter :admin_required!

  private

  def admin_required!
    if current_user && current_user.admin?
      true
    else
      # redirect somewhere for non-admins
    end
  end
end
```

Since `Detour::ApplicationController` isn't a subclass of my `ApplicationController`,
I've included a `CurrentUser` module that I built in this app that adds a
`current_user` method to any controller that it's included in. Now, only admins
will have access to the Detour admin interface.

### Marking a model as flaggable

In addition to listing classes that are flaggable in your initializer, add
`acts_as_flaggable` to the class definitions themselves:

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

Call the `#has_feature?` method on an instance of your class that implements
`acts_as_flaggable`.

```ruby
if current_user.has_feature? :new_user_interface
  render_new_user_interface
end
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
