-- Two small lookup tables used for the joins. The main table (games) is loaded from the csv.
DROP TABLE IF EXISTS dim_platform;
CREATE TABLE dim_platform (
    platform       TEXT PRIMARY KEY,
    platform_type  TEXT NOT NULL            -- my own grouping
);
INSERT INTO dim_platform VALUES
    ('PC','PC'),('PlayStation','Console'),('Xbox','Console'),
    ('Nintendo Switch','Console'),('Mobile','Mobile'),('Cross-Platform','Cross-Platform');

DROP TABLE IF EXISTS dim_developer;
CREATE TABLE dim_developer (
    developer   TEXT PRIMARY KEY,
    hq_country  TEXT NOT NULL               -- added from public info
);
INSERT INTO dim_developer VALUES
    ('Capcom','Japan'),('Bandai Namco','Japan'),('Sony','Japan'),('Square Enix','Japan'),
    ('Nintendo','Japan'),('Microsoft','USA'),('EA','USA'),('Activision','USA'),
    ('Rockstar','USA'),('Ubisoft','France');
