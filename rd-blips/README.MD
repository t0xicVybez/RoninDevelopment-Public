# rd-blips - QBCore Blip & Marker Management System

A comprehensive FiveM resource for QBCore that enables administrators to create and manage blips and markers with advanced features including job-specific visibility and enhanced blip information display.

## Features

### Core Functionality
- Create and remove map blips through commands
- Create and remove markers through commands
- Job-specific blip visibility
- Persistent storage in database
- Support for IF-multijob
- Admin-only access
- Locale support
- Configurable settings

### Enhanced Blip Features (with gs_blips)
- Rich blip information display with titles and detailed descriptions
- Category-based blip organization
- Dynamic distance updates
- Job-based categorization with custom icons
- Real-time blip information updates
- Custom blip metadata support

## Dependencies

### Required Dependencies
- QBCore Framework
- oxmysql
- qb-input

### Optional Dependencies
- IF-multijob (for multiple job support)
- gs_blips (for enhanced blip features)

## Installation

1. **Download the Resource**
   - Clone or download this repository
   - Place it in your server's `resources` folder
   - Rename the folder to `rd-blips`

2. **Import SQL**
   - Execute the `rd-blips.sql` file in your database
   - For existing installations, run the upgrade SQL script to add new columns

3. **Server Configuration**
   - Add `ensure rd-blips` to your `server.cfg`
   - Ensure it loads after QBCore and its dependencies
   - If using gs_blips, ensure it loads after gs_blips

4. **Optional: gs_blips Integration**
   - Install gs_blips if you want enhanced blip features
   - Configure gs_blips options in config.lua
   - Set `Config.UseGsBlips = true` to enable integration

## Commands

### Blip Management
- `/createblip` - Opens menu to create a new blip
  - Enhanced options when using gs_blips:
    - Detailed descriptions
    - Category assignment
    - Dynamic updates toggle
    - Custom metadata
- `/removeblip [description]` - Removes a blip
  - With description: Removes the specific blip
  - Without description: Removes the closest blip

### Marker Management
- `/createmarker` - Opens menu to create a new marker
- `/removemarker [description]` - Removes a marker
  - With description: Removes the specific marker
  - Without description: Removes the closest marker

## Configuration

The `config.lua` file now includes enhanced customization options:

```lua
Config = {
    -- Feature Flags
    UseGsBlips = true,         -- Enable gs_blips integration

    -- gs_blips Configuration
    GsBlips = {
        DefaultCategory = 'General',
        EnableDynamicDisplay = true,
        DisplayRefreshRate = 1000,
        UseJobCategories = true,
        EnableDescriptions = true
    },

    -- Job Configuration
    JobEmojis = {
        ['police'] = '👮',
        ['ambulance'] = '🚑',
        -- Add more job emojis...
    },

    -- Standard Configuration
    DefaultMarkerDistance = 50.0,
    DefaultBlipScale = 0.8,
    -- Additional configuration options...
}
```

## Database Structure

### Enhanced Blips Table
```sql
CREATE TABLE `rd_blips` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `sprite` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` int(11) NOT NULL,
    `description` varchar(255) NOT NULL,
    `details` text DEFAULT NULL,
    `job` varchar(50) NOT NULL DEFAULT 'all',
    `category` varchar(50) DEFAULT NULL,
    `dynamic` tinyint(1) DEFAULT 1,
    `metadata` longtext DEFAULT NULL,
    PRIMARY KEY (`id`)
);
```

### Markers Table
```sql
CREATE TABLE `rd_markers` (
    -- Marker table structure remains unchanged...
);
```

## Enhanced Features Guide

### Using gs_blips Integration

When gs_blips integration is enabled, you gain access to:

1. **Rich Information Display**
   - Detailed blip descriptions with emoji support
   - Dynamic distance updates
   - Custom categories based on jobs

2. **Category Management**
   - Blips are automatically categorized by job
   - Custom category support for organization
   - Enhanced filtering and management

3. **Dynamic Updates**
   - Real-time distance calculations
   - Automatic display refreshing
   - Custom update intervals

4. **Extended Metadata**
   - Support for custom blip data
   - Enhanced job-specific information
   - Detailed location descriptions

## Permissions and Job System

The permission system remains robust while adding new features:

- All commands require admin permissions
- Admins are determined by QBCore permission level
- Both 'admin' and 'god' permission levels have access
- Enhanced job-specific features with gs_blips integration
- Improved categorization and filtering by job

## Troubleshooting

### Common Issues

1. **Blip Enhancement Issues**
   - Verify gs_blips is properly installed
   - Check if Config.UseGsBlips is enabled
   - Ensure proper load order in server.cfg

2. **Standard Troubleshooting**
   - Verify admin permissions
   - Check database configuration
   - Confirm dependency installation
   - Review server console for errors

### Support

For support:
1. Check the issues section in the GitHub repository
2. Verify all dependencies are properly installed
3. Ensure you're using compatible versions of all resources
4. Review server console for error messages
5. Confirm proper configuration settings

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Credits

- Original development by Ronin Development
- gs_blips integration support added in v1.1.0
