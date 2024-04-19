# CS:GO Custom Votes (1.0.0)
You are free to modify code. This plugin is currently in use on my server; you can join and see how it performs.

> [!TIP]
> Some things can be improved, such as setting DEFAULT_MAP automatically and managing cooldowns differently. But I'll let you handle those tasks! ❤️

## Features
* `!awp` / `sm_awp` - call an awp vote (restrict / unrestrict)
* `!changemap` / `sm_changemap` - call a changemap vote (last map and the current map are removed from the cycle)
* `!resetcooldowns` / `sm_resetcooldowns` - reset all cooldowns (generic_admin flag required)

## Customization
* You can change basic options at the beginning of the code.
* Cooldowns are in minutes.
* Sourcemod colors are used: [View colors](https://i.imgur.com/q2wb8Cu.png)
```
#define AWP_COOLDOWN 3
#define CHANGEMAP_COOLDOWN 6
#define DEFAULT_MAP "de_mirage" 
#define PREFIX "\x0BALYXHVH \x08▪"
```
