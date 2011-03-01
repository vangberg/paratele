# Currently implemented

## `run` instead of `install`/`status`

The coupling between `install` and `system` only works for a very specific way of using Tele, which didn't make sense to me. I prefer to have a single `install.sh` that performs the checks that would normally be put in `status.sh`. That way I can just `run install`, and if everything is fine nothing is done, but if something is wrong, it will be fixed.

`install`/`status` has been replaced by `run` which runs an arbitrary command. The old behaviour can somewhat be emulated with:

    tele run status || tele run install && tele run status

## Removed roles

Needless abstraction that hasn't proven useful in production use, and invites complexity (especially because a role can include other roles.) Also, they confuse matters with recipe run order. E.g.:
      
    {
      "roles": {
        "web": ["ruby", "nginx"],
        "workers": ["ruby", "resque"]
      },

      "servers": {
        "srv1": ["web", "workers"]
      }
    }
  
Will it run `ruby` twice? And if not, When will it run? Before or after `nginx`?

## Recipe run order dependency (sorta, kinda)

If a recipe fails, execution for that server will stop, and the remaining recipes will not be executed. This means a recipe can depend on those listed before it being succesfully executed. E.g. it wouldn't make sense to try and install Ruby applications if the `ruby` recipe installing Ruby itself failed. (This is kinda like `cutest` actually. Fail fast!)

## Useful exit status

If any recipe on any server fails, Tele will have an exit status of 1. Otherwise it will be 0.

## Ability to run on a subset of servers

    tele run install db1,web2

## Verbose output

Default: Stdout/stderr from the servers will be printed to the local stderr if a recipe fail.
Quiet (`-q`): Stdout/stderr from the servers will never be printed locally.
Verbose (`-v`): Stdout/stderr from the server will always be printed to the local stderr.

# Future plans

## Connection sharing

If a server has more than one recipe associated, use connection sharing for speed improvement.
