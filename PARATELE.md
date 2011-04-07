# Currently implemented

## `run` instead of `install`/`status`

The coupling between `install` and `system` only works for a very specific way of using Tele, which didn't make sense to me. I prefer to have a single `install.sh` that performs the checks that would normally be put in `status.sh`. That way I can just `run install`, and if everything is fine nothing is done, but if something is wrong, it will be fixed.

`install`/`status` has been replaced by `run` which runs an arbitrary command.

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

## Environments

Servers belongs in an environment. E.g.:

    {
      "production": {
        "servers": {
          "db1": ["redis", "cdb"],
          "web2": ["nginx", "varnish"],
          "web1": ["nginx", "varnish"]
        },
        "attributes": {
          "branch": "master"
        }
      },
      "staging": {
        "servers": {
          "sta1": ["nginx", "redis"]
        },
        "attributes": {
          "branch": "staging"
        }
      }
    }

You have to specify an environment when using `run`:

    paratele run install production

It is also possible to run a command on a subset of servers:

    paratele run install production:web1,web2

## ERB Templates

Instead of `recipes/redis/install.sh`, commands are now stored as ERB templates: `recipes/redis/install.erb`. The template is rendered locally, with the local variable `attributes` available, populated by the `attributes` key in the given environment. The template should render a shell script.

## Recipe run order dependency (sorta, kinda)

If a recipe fails, execution for that server will stop, and the remaining recipes will not be executed. This means a recipe can depend on those listed before it being succesfully executed. E.g. it wouldn't make sense to try and install Ruby applications if the `ruby` recipe installing Ruby itself failed. (This is kinda like `cutest` actually. Fail fast!)

## Useful exit status

If any recipe on any server fails, Tele will have an exit status of 1. Otherwise it will be 0.

## Verbose output

* Default: Stdout/stderr from the servers will be printed to the local stderr if a recipe fail.
* Quiet (`-q`): Stdout/stderr from the servers will never be printed locally.
* Verbose (`-v`): Stdout/stderr from the server will always be printed to the local stderr.
