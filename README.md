# Detour

Rollouts for `ActiveRecord` models. It is a spiritual fork of
[ArRollout](https://github.com/markpundsack/ar_rollout).

| development status | master status | Code Climate |
| ------------------ | ------------- | ------------ |
| [![development status][dev_image]][branch_status] | [![master status][master_image]][branch_status] | [![Code Climate][code_climate_image]][code_climate]

[dev_image]: https://api.travis-ci.org/jclem/detour.png?branch=development
[master_image]: https://api.travis-ci.org/jclem/detour.png?branch=master
[branch_status]: https://travis-ci.org/jclem/detour/branches
[code_climate_image]: https://codeclimate.com/github/jclem/detour.png
[code_climate]: https://codeclimate.com/github/jclem/detour

## Contents

  * [About](#about)
  * [Requirements](#requirements)
  * [Installation](#installation)
  * [Configuration](#configuration)
  * [Usage](#usage)

* * *

## About

Detour helps you manage feature flags in your Rails app, allowing you to test
out new features via incremental rollouts to subsets of records, rather than
exposing your entire userbase to beta features.

## Requirements

Detour currently requires:

  * Ruby >= 1.9.3
  * Rails 3.2 (support for Rails 4 coming)

## Installation

Add it to your Gemfile:

```ruby
gem 'detour'
```

Bundle:

```shell    
$ bundle install
```

Run the initializer:

```shell
$ rails generate detour
```

Run the Detour migrations:

```shell
$ rake db:migrate
```

## Configuration

The Detour initializer creates an initializer at
`config/initializers/detour.rb`.

### Mount Detour in your app

Detour is a `Rails::Engine`, and needs to be mounted at a point of your
choosing in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Detour::Engine => "/admin/detour"
end
```

### Make your models flaggable

Each model that you'd like to be able to be flagged into and out of features
needs to call `acts_as_flaggable`:

```ruby    
class User < ActiveRecord::Base
  acts_as_flaggable
end

class Widget < ActiveRecord::Base
  acts_as_flaggable
end
```

When flagging in users, for example, in the Detour admin interface, you
probably won't know their ID values. You can tell Detour that you'd like to
find users by email, instead (or any other attribute):

```ruby 
class User < ActiveRecord::Base
  acts_as_flaggable find_by: :email
end

class User < ActiveRecord::Base
  acts_as_flaggable find_by: :name
end
```

### Define flaggable types

Detour needs a list of all classes that will potentially be flagged into
features. This list can be set with the `flaggable_types` setting, and needs
to match the list of classes that call `acts_as_flaggable`.

```ruby
Detour.configure do |config|
  # The `User` and `Widget` models will be able to be flagged into features.
  config.flaggable_types = %w[User Widget]
end
```

### Define search directories

Detour's admin interface can tell you exactly where you're checking for each
feature in your code, but it needs to be told what directories to search
through:

```ruby
Detour.configure do |config|
  # Detour will search for `.rb` and `.erb` files anywhere in your `app`
  # directory for feature checks.
  config.feature_search_dirs = %w[app/**/*.{rb,erb}]
end
```

### Define a feature check regex

In order for the Detour admin interface to tell you where you're checking for
specific features, Detour by default looks for things that look like
`.has_feature?(:feature_name)` and `.has_feature?("feature_name")`. However,
you may have aliased this method, or wrapped it in something else. You can
change Detour's search regular expression:

```ruby 
Detour.configure do |config|
  # Detour will look for feature checks that look more like `rollout?(:feature)`
  config.feature_search_regex = /rollout\?\s*\(?[:"]([\w-]+)/
end
```

### Define groups

Detour can roll out features to records in groups. These groups can either be
defined in the database, which you manage in the Detour admin interface, or
they can be defined in code, in Detour's initializer. The blocks that you use
to define your groups will get a record passed in to them, that you can check
for specific traits. If the block returns a truthy value, the record will be
considered part of the group.

```ruby    
Detour.configure do |config|
  # Define a group for your admins
  config.define_users_group :admins do |user|
    user.admin?
  end

  # Define a group for your super users
  config.define_users_group :super_users do |user|
    user.super_user?
  end

  # Define a group for your premium widgets
  config.define_widgets_group :premiums do |widget|
    widget.is_premium?
  end
end
```

### Restrict the admin interface

You probably don't want any user to have access to your Detour admin
interface, which is open to all by defaut. The easier way to restrict access
is to `class_eval` Detour's main controller in the Detour initializer.
`Detour::ApplicationController` probably won't have methods like
`current_user` available to it, so it's easiest to include them via a module,
as below:

```ruby
Detour::ApplicationController.class_eval do
  include CurrentUser

  before_filter :admin_required!

  private

  def admin_required!
    if current_user && current_user.admin?
      true
    else
      # Redirect a non-admin user somewhere else
    end
  end
end
```

## Usage

The usage examples all assume that Detour is mounted on the `/detour` path,
and they assume a `User` class that more or less looks like the following:

```ruby    
class User < ActiveRecord::Base
  acts_as_flaggable find_by: :email
end
```

In these examples, we'll be logged in as the user with email
"user@example.com", and we'll be viewing the following page:

```erb 
<% if current_user.has_feature?(:foo_feature) %>
 <h1>User has "foo_feature"!</h1>
<% end %>
```

### Flagging in a single user

![](http://f.cl.ly/items/3i431s0v2A3k0c2t2k43/flag-in.mov.gif)

### Flagging in a defined group

![](http://cl.ly/image/2C3G2t212G0r/defined-group.mov.gif)

### Flagging in a managed group

![](http://cl.ly/image/1q3U2J2F2439/managed-groups.mov.gif)

### Flagging in a percentage of users

![](http://cl.ly/image/2n2b412Y3x3q/percentage.mov.gif)

### Opting out a user

![](http://cl.ly/image/003E2B1D320v/opt-out.mov.gif)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/detour/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks, Heroku

While I created and maintain this project, it was done while I was an employee
of [Heroku][heroku] on the Human Interfaces Team, and they were kind enough to
allow me to open source the work. Heroku is awesome.

[heroku]: https://www.heroku.com/home
