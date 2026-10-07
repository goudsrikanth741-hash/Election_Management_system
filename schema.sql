CREATE DATABASE IF NOT EXISTS univelect_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE univelect_db;

DROP TABLE IF EXISTS votes;
DROP TABLE IF EXISTS candidates;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS elections;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  student_id VARCHAR(30) UNIQUE NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) UNIQUE NOT NULL,
  department VARCHAR(120) DEFAULT 'General Studies',
  year INT DEFAULT 1,
  password_hash CHAR(64) NOT NULL,
  role ENUM('STUDENT','CANDIDATE','ADMIN') NOT NULL DEFAULT 'STUDENT',
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  avatar VARCHAR(500),
  title VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE elections (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  start_date VARCHAR(100),
  end_date VARCHAR(100),
  status ENUM('DRAFT','ACTIVE','CLOSED') NOT NULL DEFAULT 'DRAFT',
  total_registered_voters INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE positions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  election_id INT NOT NULL,
  title VARCHAR(120) NOT NULL,
  description VARCHAR(500),
  max_votes INT NOT NULL DEFAULT 1,
  FOREIGN KEY (election_id) REFERENCES elections(id) ON DELETE CASCADE,
  UNIQUE KEY uq_position (election_id,title)
);

CREATE TABLE candidates (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  election_id INT NOT NULL,
  position_id INT NOT NULL,
  tagline VARCHAR(255),
  manifesto TEXT,
  status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (election_id) REFERENCES elections(id) ON DELETE CASCADE,
  FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
  UNIQUE KEY uq_candidate (user_id,election_id,position_id)
);

CREATE TABLE votes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  election_id INT NOT NULL,
  position_id INT NOT NULL,
  candidate_id INT NOT NULL,
  receipt_hash VARCHAR(40) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (election_id) REFERENCES elections(id) ON DELETE CASCADE,
  FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
  FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
  UNIQUE KEY uq_vote_per_position (user_id,election_id,position_id)
);

-- Demo passwords: Student@123 and Admin@2025. Hashes are SHA-256 for this classroom project.
INSERT INTO users(student_id,name,email,department,year,password_hash,role,avatar) VALUES
('STU9021','Alex Vance','alex.vance@apex.edu','Computer Science',3,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80'),
('STU9022','Elena Gilbert','elena.g@apex.edu','Electrical Engineering',2,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80'),
('STU9023','Marcus Brody','marcus.b@apex.edu','Business Administration',4,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&auto=format&fit=crop&q=80'),
('STU9024','Sarah Jenkins','sarah.j@apex.edu','Biotechnology',3,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','CANDIDATE','https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'),
('STU9025','Devon Patel','devon.p@apex.edu','Mechanical Engineering',4,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','CANDIDATE','https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80'),
('STU9026','Kavita Rao','kavita.r@apex.edu','Physical Education',3,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80'),
(NULL,'Dr. Robert Chen','admin@apex.edu','Student Affairs',0,'fcf7bb6d546cfb82d2e55486984ae7a1862a666acb441e0cf8b4ed34a4fcf9d7','ADMIN','https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop&q=80');

INSERT INTO elections(title,code,description,start_date,end_date,status,total_registered_voters) VALUES
('Spring 2025 Student Government Association General Election','SGA-2025-SP','Annual election for the executive committee of the University Student Government Association.','Apr 10, 2025 • 8:00 AM','Apr 20, 2025 • 8:00 PM','ACTIVE',2450),
('Faculty Representative Council By-Election','FRC-2025-BY','By-election for departmental faculty representatives across Engineering and Sciences.','May 05, 2025 • 9:00 AM','May 12, 2025 • 6:00 PM','DRAFT',1180);

INSERT INTO positions(election_id,title,description,max_votes) VALUES
(1,'President','Chief executive officer representing the entire student body.',1),
(1,'Vice President','Leads the student senate and supports university policy work.',1),
(1,'General Secretary','Oversees records, communications and student societies.',1),
(1,'Sports & Cultural Secretary','Manages sports meets, tournaments and cultural festivals.',1),
(2,'Faculty Representative','Represents student academic interests at faculty board meetings.',1);

INSERT INTO candidates(user_id,election_id,position_id,tagline,manifesto,status) VALUES
(4,1,1,'Empowering Student Voices & Sustainable Campus Innovation','Modernize lab equipment, create 24/7 library quiet zones and guarantee budget transparency.','APPROVED'),
(5,1,1,'Action, Accountability & Career Pathways','Expand internship partnerships, improve cafeteria quality and campus Wi-Fi.','APPROVED'),
(2,1,2,'Bridging the Gap Between Administration and Students','Transparent club funding, campus safety lighting and faster academic petitions.','APPROVED'),
(3,1,2,'Practical Leadership & Entrepreneurship Support','Launch a student startup grant fund, hackathons and alumni mentorship.','APPROVED'),
(1,1,3,'Digital Campus Transformation & Open Communication','Build a unified student app, digital ID cards and grievance support.','APPROVED'),
(6,1,4,'Revitalizing Varsity Sports & Annual Cultural Gala','Rebuild courts, secure tournament sponsorships and improve Spring Fest.','APPROVED'),
(5,2,5,'Curriculum Reform Through Student Feedback','Anonymous course feedback dashboards and a joint student-faculty review board.','PENDING');
