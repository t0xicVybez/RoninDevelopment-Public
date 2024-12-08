# rd-blips - Advanced Blip & Marker Management System

A comprehensive FiveM resource for QBCore and QBox frameworks that enables administrators to create and manage blips and markers with advanced features including job-specific visibility, jobtype categorization, and enhanced blip information display.

## Features

### Core Functionality
- Create and remove map blips through commands
- Create and remove markers through commands
- Job and jobtype-specific blip visibility
- Persistent storage in database with enhanced metadata
- Support for multiple job systems
- Admin-only access with enhanced permissions
- Multi-framework support (QBCore/QBox)
- Configurable settings with extensive options

### Enhanced Blip Features (with gs_blips)
- Rich blip information display with titles and detailed descriptions
- Category-based blip organization
- Dynamic distance updates
- Job and jobtype-based categorization with custom icons
- Real-time blip information updates
- Custom blip metadata support
- Enhanced category management

### Job System
- Support for multiple job frameworks
- Jobtype categorization (LEO, Medical, Mechanic, etc.)
- Automatic jobtype detection
- Enhanced job-based permissions
- Flexible job category configuration

## Dependencies

### Required Dependencies
- QBCore Framework or QBox Framework
- oxmysql
- qb-input

### Optional Dependencies
- gs_blips (for enhanced blip features)
- Multi-job system support (compatible with various job systems)

## Installation

1. **Download the Resource**
   - Clone or download this repository
   - Place it in your server's `resources` folder
   - Rename the folder to `rd-blips`

2. **Import SQL**
   - Execute the `rd-blips.sql` file in your database
   - For existing installations, the resource will automatically handle database updates

3. **Server Configuration**
   - Add `ensure rd-blips` to your `server.cfg`
   - Ensure it loads after your core framework (QBCore/QBox) and dependencies
   - If using gs_blips, ensure it loads after gs_blips

4. **Framework Configuration**
   - The resource automatically detects your framework
   - Manual configuration available in config.lua if needed
   - Configure framework-specific options as needed

## Commands

### Blip Management
- `/createblip` - Opens enhanced menu to create a new blip
  - Enhanced options:
    - Job and jobtype selection
    - Detailed descriptions
    - Category assignment
    - Dynamic updates toggle
    - Custom metadata
- `/removeblip [description]` - Removes a blip
  - With description: Removes the specific blip
  - Without description: Removes the closest blip

### Marker Management
- `/createmarker` - Opens enhanced menu to create a new marker
- `/removemarker [description]` - Removes a marker
  - With description: Removes the specific marker
  - Without description: Removes the closest marker

## Configuration

The `config.lua` file includes comprehensive customization options:

```lua
Config = {
    -- Framework Configuration
    Framework = 'auto',  -- 'auto', 'qb', or 'qbx'

    -- Feature Flags
    UseGsBlips = true,         
    UseJobTypes = true,        

    -- Job Configuration
    JobTypeCategories = {
        ['leo'] = {'police', 'sheriff', 'statepolice'},
        ['medical'] = {'ambulance', 'doctor'},
        -- Add more job categories...
    },

    -- gs_blips Configuration
    GsBlips = {
        DefaultCategory = 'General',
        EnableDynamicDisplay = true,
        DisplayRefreshRate = 1000,
        UseJobCategories = true,
        EnableDescriptions = true,
        UseJobTypeCategories = true
    },

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
    `jobtype` varchar(50) DEFAULT NULL,
    `category` varchar(50) DEFAULT NULL,
    `dynamic` tinyint(1) DEFAULT 1,
    `metadata` longtext DEFAULT NULL,
    `created_by` varchar(50) DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
);
```

## Enhanced Features Guide

### Jobtype System

The new jobtype system provides:

1. **Automatic Categorization**
   - Automatic jobtype detection based on job
   - Hierarchical job organization
   - Enhanced blip filtering

2. **Enhanced Permissions**
   - Jobtype-based access control
   - Flexible permission configuration
   - Multi-level access system

### Framework Support

The resource now supports:

1. **Multiple Frameworks**
   - QBCore Framework
   - QBox Framework
   - Automatic detection and configuration

2. **Enhanced Integration**
   - Framework-specific optimizations
   - Automatic adaptation to framework features
   - Consistent functionality across frameworks

## Permissions and Job System

Enhanced permission system features:

- Multi-framework permission support
- Jobtype-based access control
- Enhanced admin permission checking
- Flexible configuration options
- Improved job categorization

## Troubleshooting

### Common Issues

1. **Framework Detection Issues**
   - Verify framework installation
   - Check load order in server.cfg
   - Confirm framework version compatibility

2. **Jobtype System Issues**
   - Verify job configuration
   - Check jobtype categories
   - Confirm database structure

3. **General Troubleshooting**
   - Verify admin permissions
   - Check database configuration
   - Confirm dependency installation
   - Review server console for errors

### Support

For support:
1. Check the issues section in the GitHub repository
2. Verify all dependencies are properly installed
3. Ensure you're using compatible versions
4. Review server console for error messages
5. Confirm proper configuration settings

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Credits

- Original development by Ronin Development
- gs_blips integration support added in v1.1.0
- QBox support and jobtype system added in v1.2.0
