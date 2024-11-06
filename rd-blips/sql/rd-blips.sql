-- Create blips table
CREATE TABLE IF NOT EXISTS `rd_blips` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `sprite` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` int(11) NOT NULL,
    `description` varchar(255) NOT NULL,
    `job` varchar(50) NOT NULL DEFAULT 'all',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create markers table
CREATE TABLE IF NOT EXISTS `rd_markers` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `type` int(11) NOT NULL,
    `scale` float NOT NULL,
    `color` longtext NOT NULL,
    `description` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_blips_job ON rd_blips(job);
CREATE INDEX IF NOT EXISTS idx_blips_description ON rd_blips(description);
CREATE INDEX IF NOT EXISTS idx_markers_description ON rd_markers(description);