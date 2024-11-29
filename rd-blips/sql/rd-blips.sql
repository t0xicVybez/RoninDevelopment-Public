-- Create blips table with enhanced metadata support
CREATE TABLE IF NOT EXISTS `rd_blips` (
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
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create markers table (unchanged)
CREATE TABLE IF NOT EXISTS `rd_markers` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `type` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` longtext NOT NULL,
    `description` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- For existing installations we need to alter some tables
ALTER TABLE `rd_blips`
ADD COLUMN IF NOT EXISTS `details` text DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `category` varchar(50) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `dynamic` tinyint(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS `metadata` longtext DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_blips_job ON rd_blips(job);
CREATE INDEX IF NOT EXISTS idx_blips_category ON rd_blips(category);
CREATE INDEX IF NOT EXISTS idx_blips_description ON rd_blips(description);
CREATE INDEX IF NOT EXISTS idx_markers_description ON rd_markers(description);
