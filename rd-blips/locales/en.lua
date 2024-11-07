local Translations = {
    commands = {
        create_blip = 'Create a new blip on the map',
        remove_blip = 'Remove a blip from the map',
        create_marker = 'Create a new marker at your location',
        remove_marker = 'Remove a marker'
    },
    info = {
        blip_created = "Blip created successfully!",
        marker_created = "Marker created successfully!",
        blip_removed = "Blip removed successfully!",
        marker_removed = "Marker removed successfully!",
        distance_too_far = "You are too far from any %s",
        not_found = "No %s found with that description",
        creating_blip = "Creating new blip...",
        creating_marker = "Creating new marker..."
    },
    error = {
        no_permission = "You don't have permission to do this!",
        failed_to_create = "Failed to create %s",
        failed_to_remove = "Failed to remove %s",
        invalid_type = "Invalid %s type",
        invalid_scale = "Invalid scale (must be between 0.0 and 10.0)",
        invalid_color = "Invalid color value",
        invalid_description = "You must provide a description"
    },
    input = {
        blip = {
            header = "Create Blip",
            sprite = "Sprite (0-826)",
            scale = "Scale (0.0-10.0)",
            color = "Color (0-85)",
            description = "Description",
            job = "Job (leave empty for all)"
        },
        marker = {
            header = "Create Marker",
            type = "Type (0-43)",
            scale = "Scale (0.0-10.0)",
            description = "Description",
            red = "Red (0-255)",
            green = "Green (0-255)",
            blue = "Blue (0-255)",
            alpha = "Alpha (0-255)"
        }
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})