# rd-blips - QBCore Blip & Marker Management System

A FiveM resource for QBCore that allows administrators to create and manage blips and markers with job-specific visibility.

## Features
- Create and remove map blips through commands
- Create and remove markers through commands
- Job-specific blip visibility
- Persistent storage in database
- Support for IF-multijob
- Admin-only access
- Locale support
- Configurable settings

## Dependencies
- QBCore Framework
- oxmysql
- qb-input
- IF-multijob (optional)

## Installation

1. **Download the Resource**
   - Clone or download this repository
   - Place it in your server's `resources` folder
   - Rename the folder to `rd-blips`

2. **Import SQL**
   - Execute the `rd-blips.sql` file in your database

3. **Server Configuration**
   - Add `ensure rd-blips` to your `server.cfg`
   - Make sure it loads after QBCore and its dependencies

## Commands

### Blips
- `/createblip` - Opens menu to create a new blip
- `/removeblip [description]` - Removes a blip
  - If description is provided, removes the blip with that description
  - If no description is provided, removes the closest blip

### Markers
- `/createmarker` - Opens menu to create a new marker
- `/removemarker [description]` - Removes a marker
  - If description is provided, removes the marker with that description
  - If no description is provided, removes the closest marker

## Configuration
The `config.lua` file contains several customizable options:

```lua
Config = {
    -- Command Permissions
    Commands = {
        ['createblip'] = 'admin',
        ['removeblip'] = 'admin',
        ['createmarker'] = 'admin',
        ['removemarker'] = 'admin'
    },

    -- Defaults
    DefaultMarkerDistance = 50.0,
    DefaultBlipScale = 0.8,
    DefaultMarkerScale = 1.0,
    DefaultMarkerColor = {
        r = 255,
        g = 0,
        b = 0,
        a = 100
    }
}
```

## Marker Types Reference
Common marker types are included in the config:
```lua
Config.MarkerTypes = {
    ['cylinder'] = 1,
    ['arrow'] = 2,
    ['ring'] = 25,
    ['chevron'] = 27,
    ['horizontal_circle'] = 28,
    ['plane'] = 33,
    ['car'] = 36,
    ['bike'] = 37,
    ['at_symbol'] = 38
}
```

## Blip Colors Reference
Common blip colors are included in the config:
```lua
Config.BlipColors = {
    ['white'] = 0,
    ['red'] = 1,
    ['green'] = 2,
    ['blue'] = 3,
    ['yellow'] = 5,
    ['light_red'] = 6,
    ['violet'] = 7,
    ['pink'] = 8,
    ['orange'] = 17
}
```

## Common Blip Sprites Reference
Common blip sprites are included in the config:
```lua
Config.CommonBlipSprites = {
    ['store'] = 52,
    ['clothing'] = 73,
    ['barber'] = 71,
    ['garage'] = 357,
    ['gas_station'] = 361,
    ['hospital'] = 61,
    ['bank'] = 108,
    ['house'] = 40,
    ['office'] = 475,
    ['warehouse'] = 473,
    ['police'] = 60,
    ['repair'] = 446,
    ['ammunition'] = 110
}
```

## Localization
To add a new language:
1. Copy the `locales/en.lua` file
2. Rename it to your language code (e.g., `es.lua` for Spanish)
3. Translate the phrases in the new file
4. The resource will automatically use the language set in your QBCore config

## Database Structure

### Blips Table
```sql
CREATE TABLE `rd_blips` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `sprite` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` int(11) NOT NULL,
    `description` varchar(255) NOT NULL,
    `job` varchar(50) NOT NULL DEFAULT 'all',
    PRIMARY KEY (`id`)
);
```

### Markers Table
```sql
CREATE TABLE `rd_markers` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `type` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` longtext NOT NULL,
    `description` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
);
```

## Permissions
- All commands require admin permissions
- Admins are determined by QBCore permission level
- Both 'admin' and 'god' permission levels have access

## Job-Specific Blips
- Blips can be assigned to specific jobs
- When creating a blip, leave the job field empty for all jobs to see it
- Players will only see blips assigned to their current job or marked as 'all'
- Job-specific blips update automatically when players change jobs
- Supports IF-multijob job changes

## Troubleshooting

### Common Issues

1. **Blips/Markers not appearing**
   - Check if you have admin permissions
   - Verify the SQL tables were created correctly
   - Check if the coordinates are valid

2. **Commands not working**
   - Verify your admin permissions in QBCore
   - Check server console for errors
   - Ensure all dependencies are properly installed

3. **Job-specific blips not updating**
   - Verify the job name matches exactly with your jobs list
   - Check if IF-multijob events are being triggered
   - Verify the blip data in the database

### Support
For support:
1. Check the issues section in the GitHub repository
2. Verify you have met all dependencies
3. Check your server console for errors
4. Ensure you're using the latest version of QBCore

## License
This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.