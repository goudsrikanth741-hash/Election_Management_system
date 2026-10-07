# UnivElect - Java Full Stack Web Application

UnivElect is a university election web application converted from the supplied frontend into a Maven + Jakarta Servlet + MySQL + Tomcat application.

## Stack
- Frontend: HTML, Tailwind CSS, JavaScript, Chart.js
- Backend: Java 17, Jakarta Servlets 6
- Database: MySQL 8+
- Build: Maven
- Server: Apache Tomcat 10.1+

## Project structure
`src/main/webapp/index.html` is the frontend. Java code is under `src/main/java/com/univelect` with DAO, model, utility and servlet layers.

## Database setup
1. Install MySQL.
2. Open `schema.sql` in MySQL Workbench.
3. Execute the complete script.
4. By default the application expects `localhost:3306`, database `univelect_db`, user `root`, and an empty password.
5. If your MySQL password is not empty, set environment variable `UNIVELECT_DB_PASSWORD` before starting Tomcat, or set JVM property `-Dunivelect.db.password=YOUR_PASSWORD`.

## Demo accounts
- Student: `STU9021` / `Student@123`
- Candidate: `STU9024` / `Student@123`
- Admin: `admin@apex.edu` / `Admin@2025`

These are classroom/demo credentials. Change them before any real deployment.

## Build
```bash
mvn clean package
```
The WAR is created at `target/univ-electionsystem.war`.

## Tomcat deployment
Copy the WAR into Tomcat's `webapps` folder and start Tomcat. Then open:

`http://localhost:8080/univ-electionsystem/`

The frontend calls the Java `/api/*` servlet endpoints. Voting is persisted in MySQL and protected by server-side duplicate-vote constraints.

## Important
This is an academic/demo election system, not a production voting platform. Password hashing is SHA-256 for simplicity; a production system should use a slow password-hashing scheme such as Argon2id/bcrypt/PBKDF2, HTTPS, CSRF protection, stronger session controls, audit logging and security review.
