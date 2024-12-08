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
        creating_marker = "Creating new marker...",
        job_required = "This blip requires %s job",
        jobtype_required = "This blip requires %s job type",
        blip_updated = "Blip updated successfully!",
        marker_updated = "Marker updated successfully!",
        too_close = "Position is too close to another marker",
        framework_error = "Framework initialization error"
    },
    error = {
        no_permission = "You don't have permission to do this!",
        failed_to_create = "Failed to create %s",
        failed_to_remove = "Failed to remove %s",
        invalid_type = "Invalid %s type",
        invalid_scale = "Invalid scale (must be between 0.0 and 10.0)",
        invalid_color = "Invalid color value",
        invalid_description = "You must provide a description",
        invalid_job = "Invalid job specified",
        invalid_jobtype = "Invalid job type specified",
        invalid_position = "Invalid position for marker",
        database_error = "Database error occurred",
        gs_blips_error = "Error with gs_blips integration"
    },
    input = {
        blip = {
            header = "Create Blip",
            sprite = "Sprite (0-826)",
            scale = "Scale (0.0-10.0)",
            color = "Color (0-85)",
            description = "Title/Name",
            details = "Detailed Description (Optional)",
            job = "Job (leave empty for all)",
            jobtype = "Job Type (automatically set)",
            dynamic = "Enable Dynamic Updates",
            category = "Category (Optional)"
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
    },
    jobs = {
        police = "Police",
        sheriff = "Sheriff",
        statepolice = "State Police",
        ambulance = "Ambulance",
        doctor = "Doctor",
        mechanic = "Mechanic",
        taxi = "Taxi",
        realtor = "Realtor",
        all = "All Jobs"
    },
    jobtypes = {
        leo = "Law Enforcement",
        medical = "Medical Services",
        mechanic = "Mechanical Services",
        business = "Business Services",
        all = "All Types"
    },
    categories = {
        general = "General",
        emergency = "Emergency Services",
        services = "Public Services",
        entertainment = "Entertainment",
        business = "Businesses",
        government = "Government"
    },
    ui = {
        confirm = "Confirm",
        cancel = "Cancel",
        close = "Close",
        save = "Save Changes",
        edit = "Edit",
        delete = "Delete",
        refresh = "Refresh",
        distance = "Distance: %s meters",
        created_by = "Created by: %s",
        last_updated = "Last updated: %s",
        view_details = "View Details",
        hide_details = "Hide Details"
    },
    tooltips = {
        sprite = "Choose from common blip sprites in the Config",
        color = "Choose from available colors in the Config",
        scale = "Adjust the size of the blip/marker",
        job = "Restrict to specific job or leave for all",
        jobtype = "Automatically set based on job selection",
        dynamic = "Enable live distance updates",
        marker_type = "Different marker styles available",
        alpha = "Transparency (0 = invisible, 255 = solid)"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
