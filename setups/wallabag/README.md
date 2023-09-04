# Wallabag

## Setup

- Start container `just start`
- Run migrations `just migrate`
- Create user from shell: `just console fos:user:create`
- Promote user: `just console fos:user:promote` (set role to `ROLE_SUPER_ADMIN`)
- Increase php memory limit in `/etc/php81/php.ini` to `512M`
- Change `php-fpm`'s pool user and group to `root` instead of `nobody`. Without
  this, the docker container won't be able to download and save images.
- Allow `php-fpm` to run as root. Add `-R` argument in `/etc/s6/php-fpm/run`.
  ([ref](https://stackoverflow.com/a/26045162/1754752))
- In the UI, set Internal Settings -> Import -> Enable Redis to 1
- In the UI, set Internal Settings -> Misc -> Download images locally to 1
- Restart everything: `just stop` and `just start`
- To import from Pocket, connect from the UI, and run
  `just console wallabag:import:redis-worker pocket`

References:

- [Debugging errors](https://doc.wallabag.org/en/user/errors_during_fetching.html)
- [Console commands](https://doc.wallabag.org/en/admin/console_commands.html)
- [Internal Settings](https://doc.wallabag.org/en/admin/internal_settings.html)
