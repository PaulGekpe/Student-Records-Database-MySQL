-- =========================================
-- PLP Final Project - Question 1
-- Student Records Database (MySQL)
-- =========================================

-- Create database
CREATE DATABASE IF NOT EXISTS student_records_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE student_records_db;

-- =========================================
-- Core entities
-- =========================================

-- Students: base entity
CREATE TABLE IF NOT EXISTS Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'PreferNotToSay') NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- StudentProfiles: one-to-one with Students (each student has at most one profile)
CREATE TABLE IF NOT EXISTS StudentProfiles (
    student_id INT PRIMARY KEY,
    phone VARCHAR(25) UNIQUE,
    address_line1 VARCHAR(120),
    address_line2 VARCHAR(120),
    city VARCHAR(80),
    state_region VARCHAR(80),
    postal_code VARCHAR(20),
    country VARCHAR(80),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(25),
    CONSTRAINT fk_profile_student
        FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Departments: offers courses; one-to-many (Department -> Courses, Department -> Instructors)
CREATE TABLE IF NOT EXISTS Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(120) NOT NULL UNIQUE,
    office_phone VARCHAR(25),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Instructors: belong to one department (many-to-one)
CREATE TABLE IF NOT EXISTS Instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    hired_date DATE NOT NULL,
    CONSTRAINT fk_instructor_department
        FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Courses: belong to one department (many-to-one)
CREATE TABLE IF NOT EXISTS Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,   -- e.g., CSC101
    course_name VARCHAR(150) NOT NULL,
    credits TINYINT UNSIGNED NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT chk_course_credits CHECK (credits BETWEEN 1 AND 10),
    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Semesters: e.g., 2025-1, 2025-2
CREATE TABLE IF NOT EXISTS Semesters (
    semester_id INT PRIMARY KEY AUTO_INCREMENT,
    semester_name VARCHAR(40) NOT NULL UNIQUE,     -- e.g., '2025 Spring'
    start_date DATE NOT NULL,
    end_date   DATE NOT NULL,
    CONSTRAINT chk_semester_dates CHECK (end_date > start_date)
) ENGINE=InnoDB;

-- =========================================
-- Many-to-many relationships
-- =========================================

-- Students <-> Courses via Enrollments (many-to-many)
CREATE TABLE IF NOT EXISTS Enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    status ENUM('Enrolled', 'Dropped', 'Completed') NOT NULL DEFAULT 'Enrolled',
    grade ENUM('A','B','C','D','F','I','W') NULL,  -- nullable until completion
    PRIMARY KEY (student_id, course_id, semester_id),
    CONSTRAINT fk_enroll_student
        FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_semester
        FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Courses <-> Instructors via CourseInstructors (many-to-many)
CREATE TABLE IF NOT EXISTS CourseInstructors (
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    semester_id INT NOT NULL,
    role ENUM('Primary','Assistant') NOT NULL DEFAULT 'Primary',
    PRIMARY KEY (course_id, instructor_id, semester_id),
    CONSTRAINT fk_ci_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ci_instructor
        FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ci_semester
        FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================
-- Optional supporting tables (demonstrate constraints)
-- =========================================

-- Classrooms: for scheduling; one-to-many with CourseSections
CREATE TABLE IF NOT EXISTS Classrooms (
    classroom_id INT PRIMARY KEY AUTO_INCREMENT,
    building VARCHAR(80) NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    capacity SMALLINT UNSIGNED NOT NULL,
    UNIQUE (building, room_number),
    CONSTRAINT chk_capacity CHECK (capacity BETWEEN 5 AND 500)
) ENGINE=InnoDB;

-- CourseSections: a specific section of a course in a semester and room
CREATE TABLE IF NOT EXISTS CourseSections (
    section_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    section_code VARCHAR(20) NOT NULL,  -- e.g., 'A', 'B'
    classroom_id INT NOT NULL,
    meeting_days SET('Mon','Tue','Wed','Thu','Fri','Sat') NOT NULL,
    start_time TIME NOT NULL,
    end_time   TIME NOT NULL,
    UNIQUE (course_id, semester_id, section_code),
    CONSTRAINT chk_times CHECK (end_time > start_time),
    CONSTRAINT fk_section_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_section_semester
        FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_section_classroom
        FOREIGN KEY (classroom_id) REFERENCES Classrooms(classroom_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- SectionInstructors: assign instructors to specific sections
CREATE TABLE IF NOT EXISTS SectionInstructors (
    section_id INT NOT NULL,
    instructor_id INT NOT NULL,
    PRIMARY KEY (section_id, instructor_id),
    CONSTRAINT fk_si_section
        FOREIGN KEY (section_id) REFERENCES CourseSections(section_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_si_instructor
        FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================
-- Indexes to optimize lookups
-- =========================================
CREATE INDEX idx_students_email ON Students(email);
CREATE INDEX idx_instructors_email ON Instructors(email);
CREATE INDEX idx_courses_code ON Courses(course_code);
CREATE INDEX idx_enrollments_student ON Enrollments(student_id);
CREATE INDEX idx_enrollments_course ON Enrollments(course_id);
CREATE INDEX idx_enrollments_semester ON Enrollments(semester_id);
CREATE INDEX idx_course_instructors_course ON CourseInstructors(course_id);
CREATE INDEX idx_course_instructors_instructor ON CourseInstructors(instructor_id);
