# ---- CREATE TABLES
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`(
    `role_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `role_name` VARCHAR(32) UNIQUE NOT NULL,
    `role_is_locked` BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`(
    `category_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `category_name` VARCHAR(64) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS `muscle_groups`;
CREATE TABLE `muscle_groups`(
    `muscle_group_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `muscle_group_name` VARCHAR(32) UNIQUE NOT NULL,
    `muscle_group_is_locked` BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS `exercises`;
CREATE TABLE `exercises`(
    `exercise_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `exercise_name` VARCHAR(128) UNIQUE NOT NULL,
    `exercise_description` VARCHAR(512) DEFAULT "",
    `exercise_notes` VARCHAR(1024) DEFAULT "",
    `exercise_icon` VARCHAR(256) DEFAULT "/path/to/default/exercise/icon/here",
    `muscle_group_id` INTEGER DEFAULT 1,
    `category_id` INTEGER DEFAULT 1
);

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`(
	`user_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `user_name` VARCHAR(128) DEFAULT NULL,
    `user_username` VARCHAR(64) NOT NULL,
    `user_password` VARCHAR(128) NOT NULL,
    `user_spice` VARCHAR(128) NOT NULL,
    `user_email` VARCHAR(128) UNIQUE NOT NULL,
    `role_id` INTEGER,
    `user_avatar` VARCHAR(256) DEFAULT NULL,
    `user_is_active` BOOLEAN DEFAULT TRUE,
    `workout_plan_id` INTEGER DEFAULT NULL
);

DROP TABLE IF EXISTS `workouts`;
CREATE TABLE `workouts`(
    `workout_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `workout_name` VARCHAR(128) NOT NULL,
    `workout_plan_id` INTEGER NOT NULL
);

DROP TABLE IF EXISTS `workout_plan_access_levels`;
CREATE TABLE `workout_plan_access_levels`(
    `access_level_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `access_level_name` VARCHAR(64) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS `workout_plans`;
CREATE TABLE `workout_plans`(
    `workout_plan_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `workout_plan_name` VARCHAR(128) NOT NULL,
    `workout_plan_description` VARCHAR(512) DEFAULT NULL,
    `workout_plan_image` VARCHAR(256) DEFAULT NULL,
    `creator_id` INTEGER NOT NULL,
    `workout_plan_is_public` BOOLEAN NOT NULL DEFAULT FALSE,
    `default_access_level_id` INTEGER NOT NULL DEFAULT 3
);

DROP TABLE IF EXISTS `workout_logs`;
CREATE TABLE `workout_logs`(
    `workout_log_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `user_id` INTEGER,
    `workout_log_name` VARCHAR(128) NOT NULL,
    `workout_log_date` DATE NOT NULL DEFAULT NOW(),
    `workout_log_duration` INTEGER NOT NULL,
    `workout_log_notes` VARCHAR(512) DEFAULT NULL
);

DROP TABLE IF EXISTS `log_entries`;
CREATE TABLE `log_entries`(
    `log_entry_id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `workout_log_id` INTEGER NOT NULL,
    `log_entry_exercise_name` VARCHAR(128) NOT NULL,
    `log_entry_exercise_category_id` INTEGER NOT NULL,
    `log_entry_set_number` INTEGER NOT NULL,
    `log_entry_data_1` INTEGER NOT NULL,
    `log_entry_data_2` INTEGER DEFAULT 0
);

DROP TABLE IF EXISTS `user_workout_plan_map`;
CREATE TABLE `user_workout_plan_map`(
    PRIMARY KEY(`user_id`, `workout_plan_id`),
    `user_id` INTEGER NOT NULL,
    `workout_plan_id` INTEGER NOT NULL,
    `access_level_id` INTEGER NOT NULL
);

DROP TABLE IF EXISTS `exercise_workout_map`;
CREATE TABLE `exercise_workout_map`(
    PRIMARY KEY(`exercise_id`, `workout_id`),
    `exercise_id` INTEGER NOT NULL,
    `workout_id` INTEGER NOT NULL,
    `sets` INTEGER NOT NULL,
    `data_1_target` INTEGER DEFAULT 0
);

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `option` VARCHAR(64) NOT NULL UNIQUE,
    `value` VARCHAR(64) NOT NULL,
    `changed_by` VARCHAR(64) NOT NULL,
    `changed_on` DATE DEFAULT NULL
);

# ---- CREATE FOREIGN KEYS
ALTER TABLE `exercises`
    ADD CONSTRAINT `FK_exercise_has_category` 
        FOREIGN KEY (`category_id`) 
        REFERENCES `categories`(`category_id`) 
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    ADD CONSTRAINT `FK_exercise_has_muscle_group` 
        FOREIGN KEY (`muscle_group_id`) 
        REFERENCES `muscle_groups`(`muscle_group_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE;
    
ALTER TABLE `users`
    ADD CONSTRAINT `FK_user_has_role` 
        FOREIGN KEY (`role_id`) 
        REFERENCES `roles`(`role_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    ADD CONSTRAINT `FK_user_has_active_workout_plan` 
        FOREIGN KEY (`workout_plan_id`) 
        REFERENCES `workout_plans`(`workout_plan_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE;

ALTER TABLE `workouts`
    ADD CONSTRAINT `FK_workout_has_workout_plan` 
        FOREIGN KEY (`workout_plan_id`) 
        REFERENCES `workout_plans`(`workout_plan_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE `workout_plans`
    ADD CONSTRAINT `FK_workout_plan_has_creator` 
        FOREIGN KEY (`creator_id`) 
        REFERENCES `users`(`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    ADD CONSTRAINT `FK_workout_plan_has_default_access` 
        FOREIGN KEY (`default_access_level_id`) 
        REFERENCES `workout_plan_access_levels`(`access_level_id`)
        ON UPDATE CASCADE;

ALTER TABLE `workout_logs`
    ADD CONSTRAINT `FK_workout_log_has_user` 
        FOREIGN KEY (`user_id`) 
        REFERENCES `users`(`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE `log_entries`
    ADD CONSTRAINT `FK_log_entry_has_log_parent` 
        FOREIGN KEY (`workout_log_id`) 
        REFERENCES `workout_logs`(`workout_log_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE `user_workout_plan_map`
    ADD CONSTRAINT `FK_user_plan_map_has_user` 
        FOREIGN KEY (`user_id`) 
        REFERENCES `users`(`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    ADD CONSTRAINT `FK_user_plan_map_has_workout` 
        FOREIGN KEY (`workout_plan_id`) 
        REFERENCES `workout_plans`(`workout_plan_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    ADD CONSTRAINT `FK_user_plan_map_has_access_level` 
        FOREIGN KEY (`access_level_id`) 
        REFERENCES `workout_plan_access_levels`(`access_level_id`)
        ON UPDATE CASCADE;

ALTER TABLE `exercise_workout_map`
    ADD CONSTRAINT `FK_exercise_workout_map_has_exercise` 
        FOREIGN KEY (`exercise_id`) 
        REFERENCES `exercises`(`exercise_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    ADD CONSTRAINT `FK_exercise_workout_map_has_workout` 
        FOREIGN KEY (`workout_id`) 
        REFERENCES `workouts`(`workout_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

# ---- INSERT DEFAULT DATA
INSERT INTO `roles`(`role_name`, `role_is_locked`)
VALUES  ('Admin',   true), 
        ('User',    true),
        ('Guest',   true);

INSERT INTO `workout_plan_access_levels`(`access_level_name`) 
VALUES  ('Plan Manager'), 
        ('Plan Member'),
        ('Plan Viewer');

INSERT INTO `categories`(`category_name`) 
VALUES  ('Weight and Repetitions'), 
        ('Distance and Time'), 
        ('Repetitions'), 
        ('Time');

INSERT INTO `muscle_groups`(`muscle_group_name`, `muscle_group_is_locked`)
VALUES  ('None',        true), 
        ('Quadriceps',  true), 
        ('Hamstrings',  true), 
        ('Calves',      true), 
        ('Chest',       true), 
        ('Back',        true), 
        ('Shoulders',   true), 
        ('Biceps',      true), 
        ('Triceps',     true), 
        ('Forearms',    true), 
        ('Trapezius',   true), 
        ('Abs',         true), 
        ('Cardio',      true);

# ---- DEFAULT LOGIN: admin | Adm!n1strat0r
INSERT INTO `users`(`user_username`, `user_name`, `user_password`, `user_spice`,`user_email`, `role_id`) 
VALUES ('admin', 'Administrator', '$2b$10$o1OFi19.5xil8.bmqBg0EuFZVl6U9Y9OX1YiN4oD6Q8N5EyT9RF02', '$2b$10$o1OFi19.5xil8.bmqBg0Eu', 'admin@example.com', 1);

