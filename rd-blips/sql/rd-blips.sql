-- Create blips table with enhanced metadata and jobtype support
CREATE TABLE IF NOT EXISTS `rd_blips` (
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
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_by` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create markers table with enhanced metadata
CREATE TABLE IF NOT EXISTS `rd_markers` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `type` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` longtext NOT NULL,
    `description` varchar(255) NOT NULL,
    `created_by` varchar(50) DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- For existing installations we need to alter some tables
ALTER TABLE `rd_blips`
ADD COLUMN IF NOT EXISTS `details` text DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `jobtype` varchar(50) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `category` varchar(50) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `dynamic` tinyint(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS `metadata` longtext DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `created_by` varchar(50) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE `rd_markers`
ADD COLUMN IF NOT EXISTS `created_by` varchar(50) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_blips_job ON rd_blips(job);
CREATE INDEX IF NOT EXISTS idx_blips_jobtype ON rd_blips(jobtype);
CREATE INDEX IF NOT EXISTS idx_blips_category ON rd_blips(category);
CREATE INDEX IF NOT EXISTS idx_blips_description ON rd_blips(description);
CREATE INDEX IF NOT EXISTS idx_markers_description ON rd_markers(description);

-- Update existing records to set jobtype based on job
UPDATE rd_blips SET jobtype = 
CASE 
    WHEN job IN ('police', 'sheriff', 'statepolice') THEN 'leo'
    WHEN job IN ('ambulance', 'doctor') THEN 'medical'
    WHEN job IN ('mechanic', 'tuner') THEN 'mechanic'
    WHEN job IN ('taxi', 'realtor', 'restaurant') THEN 'business'
    ELSE 'all'
END
WHERE jobtype IS NULL;
