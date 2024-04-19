# CS:GO Custom Votes (1.0.0)
You are free to modify code. This plugin is currently in use on my server; you can join and see how it performs.

> Logic can be enhanced; DEFAULT_MAP can be replaced with none and set automatically; 
> cooldowns can be managed differently. However, I am leaving these tasks to whoever is reading this.

## Features
* `!awp` / `sm_awp` - call an awp vote (restrict / unrestrict)
* `!changemap` / `sm_changemap` - call a changemap vote (last map and the current map are removed from the cycle)
* `!resetcooldowns` / `sm_resetcooldowns` - reset all cooldowns (generic_admin flag required)

## Customization
* You can change basic options at the beginning of the code.
* Cooldowns are in minutes.
* Sourcemod colors are used: [View colors](https://forums.alliedmods.net/image-proxy/90369c9733faff162f9797d8321253f7222d04c8/687474703a2f2f692e696d6775722e636f6d2f713277623843752e706e67)
```
#define AWP_COOLDOWN 3
#define CHANGEMAP_COOLDOWN 6
#define DEFAULT_MAP "de_mirage" 
#define PREFIX "\x0BALYXHVH \x08▪"
```
