# Detour Rake Tasks

## Contents

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

## Creating features

```sh
$ bundle exec rake detour:create[new_ui]
```

## Destroying features

```sh
$ bundle exec rake detour:destroy[new_ui]
```

## Flagging a record into a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:activate[new_ui,User,2]
```

## Removing a flag-in for a record for a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:deactivate[new_ui,User,2]
```

## Opt a record out of a feature

This will ensure that `record.has_feature?(:feature)` will always be false for
the given feature, regardless of other individual flag, percentage, or group
rollouts that would otherwise target this record.

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:opt_out[new_ui,User,2]
```

## Un-opt out a record from a feature

This task requires passing the feature name, the record's class, and the
record's ID.

```sh
$ bundle exec rake detour:un_opt_out[new_ui,User,2]
```

## Flag a programmatic group into a feature

This task requires passing the feature name, the record class for the group,
and the name of the group.

```sh
$ bundle exec rake detour:activate_group[new_ui,User,admins]
```

## Remove a flag-in for a programmatic group for a feature

This task requires passing the feature name, the record class for the group,
and the name of the group.

```sh
$ bundle exec rake detour:deactivate_group[new_ui,User,admins]
```

## Flag a percentage of records into a feature

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

## Remove a flag-in for a percentage of records for a feature

This task requires passing the feature name, and the record class for the group.

```sh
$ bundle exec rake detour:deactivate_percentage[new_ui,User]
```
