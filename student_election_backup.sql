-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: univelect_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `election_id` int NOT NULL,
  `position_id` int NOT NULL,
  `tagline` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manifesto` text COLLATE utf8mb4_unicode_ci,
  `status` enum('PENDING','APPROVED','REJECTED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_candidate` (`user_id`,`election_id`,`position_id`),
  KEY `election_id` (`election_id`),
  KEY `position_id` (`position_id`),
  CONSTRAINT `candidates_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `candidates_ibfk_2` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `candidates_ibfk_3` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
INSERT INTO `candidates` VALUES (1,4,1,1,'Empowering Student Voices & Sustainable Campus Innovation','Modernize lab equipment, create 24/7 library quiet zones and guarantee budget transparency.','APPROVED','2026-10-02 16:18:08'),(2,5,1,1,'Action, Accountability & Career Pathways','Expand internship partnerships, improve cafeteria quality and campus Wi-Fi.','APPROVED','2026-10-02 16:18:08'),(3,2,1,2,'Bridging the Gap Between Administration and Students','Transparent club funding, campus safety lighting and faster academic petitions.','APPROVED','2026-10-02 16:18:08'),(4,3,1,2,'Practical Leadership & Entrepreneurship Support','Launch a student startup grant fund, hackathons and alumni mentorship.','APPROVED','2026-10-02 16:18:08'),(5,1,1,3,'Digital Campus Transformation & Open Communication','Build a unified student app, digital ID cards and grievance support.','APPROVED','2026-10-02 16:18:08'),(6,6,1,4,'Revitalizing Varsity Sports & Annual Cultural Gala','Rebuild courts, secure tournament sponsorships and improve Spring Fest.','APPROVED','2026-10-02 16:18:08'),(7,5,2,5,'Curriculum Reform Through Student Feedback','Anonymous course feedback dashboards and a joint student-faculty review board.','APPROVED','2026-10-02 16:18:08');
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `elections`
--

DROP TABLE IF EXISTS `elections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `elections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_date` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_date` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('DRAFT','ACTIVE','CLOSED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `total_registered_voters` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `elections`
--

LOCK TABLES `elections` WRITE;
/*!40000 ALTER TABLE `elections` DISABLE KEYS */;
INSERT INTO `elections` VALUES (1,'Spring 2025 Student Government Association General Election','SGA-2025-SP','Annual election for the executive committee of the University Student Government Association.','Apr 10, 2025 • 8:00 AM','Apr 20, 2025 • 8:00 PM','CLOSED',2450,'2026-10-02 16:18:08'),(2,'Faculty Representative Council By-Election','FRC-2025-BY','By-election for departmental faculty representatives across Engineering and Sciences.','May 05, 2025 • 9:00 AM','May 12, 2025 • 6:00 PM','ACTIVE',1180,'2026-10-02 16:18:08');
/*!40000 ALTER TABLE `elections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `positions`
--

DROP TABLE IF EXISTS `positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `election_id` int NOT NULL,
  `title` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `max_votes` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_position` (`election_id`,`title`),
  CONSTRAINT `positions_ibfk_1` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `positions`
--

LOCK TABLES `positions` WRITE;
/*!40000 ALTER TABLE `positions` DISABLE KEYS */;
INSERT INTO `positions` VALUES (1,1,'President','Chief executive officer representing the entire student body.',1),(2,1,'Vice President','Leads the student senate and supports university policy work.',1),(3,1,'General Secretary','Oversees records, communications and student societies.',1),(4,1,'Sports & Cultural Secretary','Manages sports meets, tournaments and cultural festivals.',1),(5,2,'Faculty Representative','Represents student academic interests at faculty board meetings.',1),(6,2,'vise president','something new',1);
/*!40000 ALTER TABLE `positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT 'General Studies',
  `year` int DEFAULT '1',
  `password_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('STUDENT','CANDIDATE','ADMIN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STUDENT',
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `avatar` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `student_id` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'STU9021','Alex Vance','alex.vance@apex.edu','Computer Science',3,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','ACTIVE','https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(2,'STU9022','Elena Gilbert','elena.g@apex.edu','Electrical Engineering',2,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','ACTIVE','https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(3,'STU9023','Marcus Brody','marcus.b@apex.edu','Business Administration',4,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','ACTIVE','https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(4,'STU9024','Sarah Jenkins','sarah.j@apex.edu','Biotechnology',3,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','CANDIDATE','ACTIVE','https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(5,'STU9025','Devon Patel','devon.p@apex.edu','Mechanical Engineering',4,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','CANDIDATE','ACTIVE','https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(6,'STU9026','Kavita Rao','kavita.r@apex.edu','Physical Education',3,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','ACTIVE','https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(7,NULL,'Dr. Robert Chen','admin@apex.edu','Student Affairs',0,'fcf7bb6d546cfb82d2e55486984ae7a1862a666acb441e0cf8b4ed34a4fcf9d7','ADMIN','ACTIVE','https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop&q=80',NULL,'2026-10-02 16:18:08'),(8,'1234','bunti','bunti@apex.edu','General Studies',1,'b2a1f4fd0a460606b34c8913e2981dac8d2e283d778aba586c416ee2629bfa54','STUDENT','ACTIVE','https://ui-avatars.com/api/?name=bunti&background=6366f1&color=fff',NULL,'2026-10-02 17:09:19');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `votes`
--

DROP TABLE IF EXISTS `votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `votes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `election_id` int NOT NULL,
  `position_id` int NOT NULL,
  `candidate_id` int NOT NULL,
  `receipt_hash` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_vote_per_position` (`user_id`,`election_id`,`position_id`),
  KEY `election_id` (`election_id`),
  KEY `position_id` (`position_id`),
  KEY `candidate_id` (`candidate_id`),
  CONSTRAINT `votes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `votes_ibfk_2` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `votes_ibfk_3` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `votes_ibfk_4` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `votes`
--

LOCK TABLES `votes` WRITE;
/*!40000 ALTER TABLE `votes` DISABLE KEYS */;
INSERT INTO `votes` VALUES (1,1,1,1,2,'BLT-11B4A3C5','2026-10-02 17:04:15'),(2,1,1,2,3,'BLT-077D1A94','2026-10-02 17:04:15'),(3,1,1,3,5,'BLT-A62ABF9A','2026-10-02 17:04:15'),(4,1,1,4,6,'BLT-4A4DDA3C','2026-10-02 17:04:15'),(5,4,1,1,1,'BLT-B7D213DD','2026-10-02 17:06:22'),(6,4,1,2,4,'BLT-637547F6','2026-10-02 17:06:22'),(7,4,1,3,5,'BLT-29809FA3','2026-10-02 17:06:22'),(8,4,1,4,6,'BLT-B09A1EB0','2026-10-02 17:06:22');
/*!40000 ALTER TABLE `votes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-07 18:58:10
