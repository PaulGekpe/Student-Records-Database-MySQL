# 📚 Student Records Database (MySQL)

## 📌 Overview
This project is part of the **PLP Final Project – Question 1**.  
It implements a **complete relational database management system** for managing student records in a university or college setting.

The database is designed in **MySQL** and follows best practices for:
- Well-structured tables
- Proper constraints (`PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`)
- Multiple relationship types: One-to-One, One-to-Many, Many-to-Many

---

## 🗂 Database Schema

### Entities
- **Students** – Basic student information
- **StudentProfiles** – Extended profile details (1:1 with Students)
- **Departments** – Academic departments
- **Instructors** – Teaching staff linked to departments
- **Courses** – Offered courses linked to departments
- **Semesters** – Academic terms
- **Enrollments** – Students enrolled in courses (many-to-many)
- **CourseInstructors** – Instructors assigned to courses (many-to-many)
- **Classrooms** – Physical teaching spaces
- **CourseSections** – Specific course offerings in a semester
- **SectionInstructors** – Instructors assigned to sections

---

## 🔗 Relationships
- **One-to-One:** Students ↔ StudentProfiles
- **One-to-Many:** Departments → Courses, Departments → Instructors
- **Many-to-Many:** Students ↔ Courses (via Enrollments), Courses ↔ Instructors (via CourseInstructors)

---

## 🛠 Features
- **Data integrity** enforced with constraints
- **Indexes** for faster lookups
- **CHECK constraints** for valid ranges (credits, capacity, dates)
- **ON DELETE / ON UPDATE** rules for referential integrity

---

## 📂 File Structure
student-records-db/ │ ├── student_records.sql # Main SQL script to create and populate the database └── README.md # Project documentation
