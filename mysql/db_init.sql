DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) UNIQUE NOT NULL,
    `is_locked` BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS `muscle_groups`;
CREATE TABLE `muscle_groups`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) UNIQUE NOT NULL,
    `is_locked` BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS `exercises`;
CREATE TABLE `exercises`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    `description` VARCHAR(500),
    `notes` VARCHAR(500),
    `icon` VARCHAR(100) DEFAULT NULL,
    `muscle_group_id` INTEGER DEFAULT 1,
    `category_id` INTEGER DEFAULT 1
);

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`(
	`id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(100) UNIQUE NOT NULL,
    `name` VARCHAR(100) DEFAULT NULL,
    `password` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `role_id` INTEGER DEFAULT 2,
---    `personal_token` VARCHAR(100) DEFAULT NULL,
    `avatar` VARCHAR(100) DEFAULT NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    `active_workout_plan_id` INTEGER DEFAULT NULL
);

DROP TABLE IF EXISTS `workouts`;
CREATE TABLE `workouts`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    `workout_plan_id` INTEGER NOT NULL
);

DROP TABLE IF EXISTS `workout_plans`;
CREATE TABLE `workout_plans`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `image` VARCHAR(100) DEFAULT NULL,
    `creator_id` INTEGER NOT NULL,
    `is_public` BOOLEAN DEFAULT FALSE
);

DROP TABLE IF EXISTS `workout_logs`;
CREATE TABLE `workout_logs`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `user_id` INTEGER,
    `name` VARCHAR(100) NOT NULL,
    `date` DATE NOT NULL,
    `duration` INTEGER NOT NULL,
    `notes` VARCHAR(100) DEFAULT NULL
);

DROP TABLE IF EXISTS `log_entries`;
CREATE TABLE `log_entries`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `workout_log_id` INTEGER NOT NULL,
    `exercise_name` VARCHAR(50) NOT NULL,
    `set_number` INTEGER NOT NULL,
    `data_1` INTEGER NOT NULL,
    `data_2` INTEGER
);

DROP TABLE IF EXISTS `user_workout_plan_map`;
CREATE TABLE `user_workout_plan_map`(
    PRIMARY KEY(`user_id`, `workout_plan_id`),
    `user_id` INTEGER NOT NULL,
    `workout_plan_id` INTEGER NOT NULL
);

DROP TABLE IF EXISTS `exercise_workout_map`;
CREATE TABLE `exercise_workout_map`(
    PRIMARY KEY(`exercise_id`, `workout_id`),
    `exercise_id` INTEGER NOT NULL,
    `workout_id` INTEGER NOT NULL,
    `sets` INTEGER NOT NULL,
    `data_1_target` INTEGER
);

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings`(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `option` VARCHAR(50) NOT NULL UNIQUE,
    `value` VARCHAR(50) NOT NULL,
    `changed_by` VARCHAR(50) NOT NULL,
    `changed_on` DATE DEFAULT NULL
);


ALTER TABLE `exercises`
    ADD CONSTRAINT `FK1_exercise_has_category` FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE SET NULL,
    ADD CONSTRAINT `FK2_exercise_has_muscle_group` FOREIGN KEY (`muscle_group_id`) REFERENCES `muscle_groups`(`id`) ON DELETE SET NULL;
    
ALTER TABLE `users`
    ADD CONSTRAINT `FK3_user_has_role` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE SET NULL,
    ADD CONSTRAINT `FK4_user_has_active_workout_plan` FOREIGN KEY (`active_workout_plan_id`) REFERENCES `workout_plans`(`id`) ON DELETE SET NULL;

ALTER TABLE `workouts`
    ADD CONSTRAINT `FK5_workout_has_workout_plan` FOREIGN KEY (`workout_plan_id`) REFERENCES `workout_plans`(`id`) ON DELETE CASCADE;

ALTER TABLE `workout_plans`
    ADD CONSTRAINT `FK6_workout_plan_has_creator` FOREIGN KEY (`creator_id`) REFERENCES `users`(`id`) ON DELETE CASCADE;

ALTER TABLE `workout_logs`
    ADD CONSTRAINT `FK7_workout_log_has_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE;

ALTER TABLE `user_workout_plan_map`
    ADD CONSTRAINT `FK8_user_plan_map_has_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `FK9_user_plan_map_has_workout` FOREIGN KEY (`workout_plan_id`) REFERENCES `workout_plans`(`id`) ON DELETE CASCADE;

ALTER TABLE `exercise_workout_map`
    ADD CONSTRAINT `FK10_exercise_workout_map_has_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `FK11_exercise_workout_map_has_workout` FOREIGN KEY (`workout_id`) REFERENCES `workouts`(`id`) ON DELETE CASCADE;

ALTER TABLE `log_entries`
    ADD CONSTRAINT `FK12_log_entry_has_log_parent` FOREIGN KEY (`workout_log_id`) REFERENCES `workout_logs`(`id`) ON DELETE CASCADE;

INSERT INTO `roles`(`name`, `is_locked`) VALUES ('Admin', true), ('User', true), ('Guest', true);
INSERT INTO `categories`(`name`) VALUES ('Weight and Repetitions'), ('Distance and Time'), ('Repetitions'), ('Time');
INSERT INTO `muscle_groups`(`name`, `is_locked`) VALUES ('None', true), ('Quadriceps', true), ('Hamstrings', true), ('Calves', true), ('Chest', true), ('Back', true), ('Shoulders', true), ('Biceps', true), ('Triceps', true), ('Forearms', true), ('Trapezius', true), ('Abs', true), ('Cardio', true);
INSERT INTO `users`(`username`, `name`, `password`, `email`, `role_id`) VALUES ('admin', 'Administrator', 'admin', 'admin@example.com', 1);
INSERT INTO `settings`(`option`, `value`, `changed_by`, `changed_on`) VALUES ('api_token', '', 'god', NOW());