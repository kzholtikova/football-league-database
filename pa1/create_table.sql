CREATE SCHEMA football_system;
USE football_system;

CREATE TABLE seasons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    start_date DATE NOT NULL
);

CREATE TABLE leagues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country TEXT NOT NULL,
    teams_number INT NOT NULL
);

CREATE TABLE match_days (
    id INT AUTO_INCREMENT PRIMARY KEY,
    season_id INTEGER NOT NULL,
    day_number INTEGER NOT NULL CHECK (day_number > 0),
    CONSTRAINT season2day_unique UNIQUE (season_id, day_number),
    FOREIGN KEY (season_id) REFERENCES seasons(id)
);

CREATE TABLE players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    birthdate DATE NOT NULL,
    nationality TEXT,
    number INT NOT NULL
);

CREATE TABLE teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city TEXT NOT NULL,
    stadium TEXT NOT NULL,
    manager TEXT NOT NULL,
    league_id INT,
    FOREIGN KEY (league_id) REFERENCES leagues (id)
);

CREATE TABLE team_squads (
    team_id INTEGER,
    player_id INTEGER,
    position TEXT NOT NULL,
    PRIMARY KEY (team_id, player_id),
    FOREIGN KEY (team_id) REFERENCES teams(id),
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    datetime DATETIME NOT NULL,
    venue VARCHAR(255) NOT NULL,
    match_day_id INTEGER,
    FOREIGN KEY (match_day_id) REFERENCES match_days(id)
);

CREATE TABLE attendees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    team_id INT,
    is_home BOOLEAN NOT NULL,
    is_winner BOOLEAN,
    FOREIGN KEY (match_id) REFERENCES matches(id),
    FOREIGN KEY (team_id) REFERENCES teams(id)
);

CREATE TABLE goals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT,
    attendee_id INT,
    time TIME NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (attendee_id) REFERENCES attendees(id)
);

CREATE TABLE standings (
    match_day_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    points INTEGER NOT NULL,
    played INTEGER NOT NULL,
    won INTEGER NOT NULL,
    drawn INTEGER NOT NULL,
    lost INTEGER NOT NULL,
    goals_for INTEGER NOT NULL,
    goals_against INTEGER NOT NULL,
    PRIMARY KEY (match_day_id, team_id),
    FOREIGN KEY (team_id) REFERENCES teams(id)
);
