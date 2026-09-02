-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: db_mkhmicro
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `in_time` time DEFAULT NULL,
  `out_time` time DEFAULT NULL,
  `work_hours` decimal(5,2) DEFAULT NULL,
  `status` enum('present','absent','late','half_day') COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attendance_employee_id_date_unique` (`employee_id`,`date`),
  KEY `attendance_tenant_id_foreign` (`tenant_id`),
  KEY `attendance_branch_id_foreign` (`branch_id`),
  CONSTRAINT `attendance_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `attendance_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  CONSTRAINT `attendance_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,1,1,1,'2026-07-15','07:55:00',NULL,NULL,'present',NULL,'2026-07-15 05:50:04','2026-07-15 05:50:04');
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_documents`
--

DROP TABLE IF EXISTS `candidate_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `candidate_id` bigint unsigned NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `candidate_documents_candidate_id_foreign` (`candidate_id`),
  KEY `candidate_documents_type_index` (`type`),
  CONSTRAINT `candidate_documents_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_documents`
--

LOCK TABLES `candidate_documents` WRITE;
/*!40000 ALTER TABLE `candidate_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_educations`
--

DROP TABLE IF EXISTS `candidate_educations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_educations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `candidate_id` bigint unsigned NOT NULL,
  `institution` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `degree` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `field_of_study` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `candidate_educations_candidate_id_foreign` (`candidate_id`),
  CONSTRAINT `candidate_educations_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_educations`
--

LOCK TABLES `candidate_educations` WRITE;
/*!40000 ALTER TABLE `candidate_educations` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_educations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_experiences`
--

DROP TABLE IF EXISTS `candidate_experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_experiences` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `candidate_id` bigint unsigned NOT NULL,
  `company` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT '0',
  `responsibilities` text COLLATE utf8mb4_unicode_ci,
  `achievements` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `candidate_experiences_candidate_id_foreign` (`candidate_id`),
  CONSTRAINT `candidate_experiences_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_experiences`
--

LOCK TABLES `candidate_experiences` WRITE;
/*!40000 ALTER TABLE `candidate_experiences` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_experiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_interview_participants`
--

DROP TABLE IF EXISTS `candidate_interview_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_interview_participants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `candidate_interview_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cip_interview_employee_unique` (`candidate_interview_id`,`employee_id`),
  KEY `cip_employee_fk` (`employee_id`),
  CONSTRAINT `cip_employee_fk` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cip_interview_fk` FOREIGN KEY (`candidate_interview_id`) REFERENCES `candidate_interviews` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_interview_participants`
--

LOCK TABLES `candidate_interview_participants` WRITE;
/*!40000 ALTER TABLE `candidate_interview_participants` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_interview_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_interviewers`
--

DROP TABLE IF EXISTS `candidate_interviewers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_interviewers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `candidate_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `candidate_interviewers_candidate_id_employee_id_unique` (`candidate_id`,`employee_id`),
  KEY `candidate_interviewers_employee_id_foreign` (`employee_id`),
  CONSTRAINT `candidate_interviewers_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE,
  CONSTRAINT `candidate_interviewers_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_interviewers`
--

LOCK TABLES `candidate_interviewers` WRITE;
/*!40000 ALTER TABLE `candidate_interviewers` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_interviewers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_interviews`
--

DROP TABLE IF EXISTS `candidate_interviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_interviews` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `candidate_id` bigint unsigned NOT NULL,
  `interview_date` date NOT NULL,
  `interview_time` time NOT NULL,
  `interview_notes` text COLLATE utf8mb4_unicode_ci,
  `score` decimal(5,2) DEFAULT NULL,
  `result` enum('pending','pass','fail') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `candidate_interviews_candidate_id_foreign` (`candidate_id`),
  CONSTRAINT `candidate_interviews_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_interviews`
--

LOCK TABLES `candidate_interviews` WRITE;
/*!40000 ALTER TABLE `candidate_interviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_interviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `candidate_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `date_of_birth` date DEFAULT NULL,
  `position_applied` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cv_path` text COLLATE utf8mb4_unicode_ci,
  `photo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('applied','shortlisted','interviewed','selected','rejected','hired') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'applied',
  `interview_date` date DEFAULT NULL,
  `interview_time` time DEFAULT NULL,
  `interview_notes` text COLLATE utf8mb4_unicode_ci,
  `appointment_letter_path` text COLLATE utf8mb4_unicode_ci,
  `joining_date` date DEFAULT NULL,
  `expected_salary` decimal(10,2) DEFAULT NULL,
  `offered_salary` decimal(10,2) DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `candidates_candidate_code_unique` (`candidate_code`),
  UNIQUE KEY `candidates_email_unique` (`email`),
  KEY `candidates_tenant_id_foreign` (`tenant_id`),
  KEY `candidates_branch_id_foreign` (`branch_id`),
  CONSTRAINT `candidates_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `candidates_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Sri Lanka',
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LKR',
  `manager_user_id` bigint unsigned DEFAULT NULL,
  `opening_asset` decimal(18,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `companies_email_unique` (`email`),
  KEY `companies_manager_user_id_foreign` (`manager_user_id`),
  CONSTRAINT `companies_manager_user_id_foreign` FOREIGN KEY (`manager_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,'M K Holdings','mkholdings2012@gmail.com','Panadura','0774492632','https://company.com','Sri Lanka','LKR',NULL,0.00,'2026-05-19 07:37:45','2026-05-20 03:37:36');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_document_templates`
--

DROP TABLE IF EXISTS `company_document_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_document_templates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned NOT NULL,
  `template_type` enum('loan_agreement','reminder_letter','arrears_letter','mortgage_agreement','mortgage_reminder','mortgage_legal_letter') COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_by` bigint unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `company_document_templates_uploaded_by_foreign` (`uploaded_by`),
  KEY `idx_company_template_active` (`company_id`,`template_type`,`is_active`),
  CONSTRAINT `company_document_templates_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `company_document_templates_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_document_templates`
--

LOCK TABLES `company_document_templates` WRITE;
/*!40000 ALTER TABLE `company_document_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `company_document_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_documents`
--

DROP TABLE IF EXISTS `customer_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned NOT NULL,
  `document_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_documents_customer_id_foreign` (`customer_id`),
  KEY `customer_documents_uploaded_by_foreign` (`uploaded_by`),
  CONSTRAINT `customer_documents_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `customer_documents_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_documents`
--

LOCK TABLES `customer_documents` WRITE;
/*!40000 ALTER TABLE `customer_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `customer_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nic_passport` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permanent_address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `current_address` text COLLATE utf8mb4_unicode_ci,
  `employment_type` enum('salaried','self_employed','business') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employer_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date NOT NULL,
  `gender` enum('male','female','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `marital_status` enum('single','married','divorced','widowed') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `occupation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `monthly_income` decimal(12,2) DEFAULT NULL,
  `other_income_sources` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `existing_loans` tinyint(1) NOT NULL DEFAULT '0',
  `monthly_loan_obligations` decimal(12,2) DEFAULT NULL,
  `credit_score` int DEFAULT NULL,
  `customer_type` enum('individual','business') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'individual',
  `status` enum('active','inactive','blacklisted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customers_customer_code_unique` (`customer_code`),
  UNIQUE KEY `customers_nic_passport_unique` (`nic_passport`),
  UNIQUE KEY `customers_email_unique` (`email`),
  KEY `customers_branch_id_foreign` (`branch_id`),
  KEY `customers_created_by_foreign` (`created_by`),
  KEY `customers_tenant_id_branch_id_index` (`tenant_id`,`branch_id`),
  KEY `customers_customer_code_index` (`customer_code`),
  KEY `customers_status_index` (`status`),
  CONSTRAINT `customers_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `customers_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `customers_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,1,1,'92','Customer','1','111111111v-1@deskoffinance.local','0771111111','111111111V','Moratuwa','Moratuwa',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',2,'2026-06-23 02:13:39','2026-06-23 02:13:39'),(2,1,1,'93','Customer','2','222222222v-2@deskoffinance.local','0772222222','222222222V','Panadura','Panadura',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',2,'2026-06-23 02:15:38','2026-07-15 02:00:11'),(3,1,1,'94','Kamal','Customer','33333333333v-5@deskoffinance.local','0773333333','33333333333V','Piliyandala','Piliyandala',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',1,'2026-06-26 07:13:32','2026-06-26 07:13:32'),(4,1,1,'95','Suraj','Customer','44444444444v-6@deskoffinance.local','0775555555','44444444444V','jnjjmjbgb','jnjjmjbgb',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',1,'2026-06-26 07:15:54','2026-06-26 07:15:54'),(5,1,1,'96','Sumudu Saman','Saman','5555555555v-7@deskoffinance.local','0775555555','5555555555V','Pailiyandala','Pailiyandala',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',7,'2026-07-04 01:41:08','2026-07-04 02:01:16'),(6,1,1,'97','Suresh','Kumara','666666666v-8@deskoffinance.local','07766666677','666666666V','Madapatha','Madapatha',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',7,'2026-07-04 01:59:21','2026-07-04 02:01:37'),(7,1,1,'98','Dasun','Kumara','777777777v-9@deskoffinance.local','07788888881','777777777V','Moratumulla','Moratumulla',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',1,'2026-07-15 01:24:57','2026-07-15 02:00:38'),(8,1,1,'99','Gihan','Fernando','999999999v-11@deskoffinance.local','07556315635','999999999V','Madapatha','Madapatha',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',1,'2026-07-15 02:34:16','2026-07-15 02:34:16'),(9,1,1,'381','G','K Nalin Chaminda','770672333v-12@deskoffinance.local','0758425691','770672333V','Walana','Walana',NULL,NULL,NULL,'1990-01-01','other',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'individual','active',1,'2026-07-15 02:38:39','2026-07-15 03:27:05');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `departments_tenant_id_name_unique` (`tenant_id`,`name`),
  KEY `departments_branch_id_foreign` (`branch_id`),
  CONSTRAINT `departments_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `departments_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,1,1,'Loan Management Department','Loan Management Department',1,'2026-04-26 01:04:37','2026-04-26 01:04:37'),(2,1,1,'Customer Management (CRM)','Customer Management (CRM)',1,'2026-04-26 01:04:46','2026-04-26 01:04:46'),(3,1,1,'Collections Department','Collections Department',1,'2026-04-26 01:04:54','2026-04-26 01:04:54'),(4,1,1,'Finance & Accounting','Finance & Accounting',1,'2026-04-26 01:05:01','2026-04-26 01:05:01'),(5,1,1,'Risk & Compliance','Risk & Compliance',1,'2026-04-26 01:05:09','2026-04-26 01:05:09'),(6,1,1,'Field Operations','Field Operations',1,'2026-04-26 01:05:19','2026-04-26 01:05:19'),(7,1,1,'Human Resources (HR)','Human Resources (HR)',1,'2026-04-26 01:05:27','2026-04-26 01:05:27'),(8,1,1,'Administration','Administration',1,'2026-04-26 01:05:34','2026-04-26 01:05:34'),(9,1,1,'IT / System Management','IT / System Management',1,'2026-04-26 01:05:51','2026-04-26 01:05:51'),(10,1,1,'Reporting & Analytics','Reporting & Analytics',1,'2026-04-26 01:06:04','2026-04-26 01:06:04'),(11,1,1,'Marketing & Sales','Marketing & Sales',1,'2026-04-26 01:06:18','2026-04-26 01:06:18'),(12,1,1,'Audit Department','Audit Department',1,'2026-04-26 01:06:39','2026-04-26 01:06:39');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `designations`
--

DROP TABLE IF EXISTS `designations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `designations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `salary_range_min` decimal(10,2) DEFAULT NULL,
  `salary_range_max` decimal(10,2) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `designations_tenant_id_name_unique` (`tenant_id`,`name`),
  KEY `designations_branch_id_foreign` (`branch_id`),
  CONSTRAINT `designations_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `designations_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `designations`
--

LOCK TABLES `designations` WRITE;
/*!40000 ALTER TABLE `designations` DISABLE KEYS */;
INSERT INTO `designations` VALUES (2,1,1,'Admin / System Admin','Admin / System Admin',NULL,NULL,1,'2026-04-26 01:07:17','2026-04-26 01:07:17'),(3,1,1,'Branch Manager','Branch Manager',NULL,NULL,1,'2026-04-26 01:08:14','2026-04-26 01:08:14'),(4,1,1,'Loan Officer','Loan Officer',NULL,NULL,1,'2026-04-26 01:08:36','2026-04-26 01:08:36'),(5,1,1,'Credit Officer / Risk Officer','Credit Officer / Risk Officer',NULL,NULL,1,'2026-04-26 01:09:29','2026-04-26 01:09:29'),(6,1,1,'Loan Approver (Senior Level)','Loan Approver (Senior Level)',NULL,NULL,1,'2026-04-26 01:09:57','2026-04-26 01:09:57'),(7,1,1,'Collection Officer (Field Officer)','Collection Officer (Field Officer)',NULL,NULL,1,'2026-04-26 01:10:25','2026-04-26 01:10:25'),(8,1,1,'Collection Supervisor','Collection Supervisor',NULL,NULL,1,'2026-04-26 01:10:42','2026-04-26 01:10:42'),(9,1,1,'Recovery Officer','Recovery Officer',NULL,NULL,1,'2026-04-26 01:11:11','2026-04-26 01:11:11'),(10,1,1,'Accountant','Accountant',NULL,NULL,1,'2026-04-26 01:11:23','2026-04-26 01:11:23'),(11,1,1,'Finance Manager','Finance Manager',NULL,NULL,1,'2026-04-26 01:11:35','2026-04-26 01:11:35'),(12,1,1,'Cashier','Cashier',NULL,NULL,1,'2026-04-26 01:11:52','2026-04-26 01:11:52'),(13,1,1,'Customer Service Officer','Customer Service Officer',NULL,NULL,1,'2026-04-26 01:12:16','2026-04-26 01:12:16'),(14,1,1,'Data Entry Operator','Data Entry Operator',NULL,NULL,1,'2026-04-26 01:12:27','2026-04-26 01:12:27'),(15,1,1,'HR Manager','HR Manager',NULL,NULL,1,'2026-04-26 01:12:43','2026-04-26 01:12:43'),(16,1,1,'Admin Officer','Admin Officer',NULL,NULL,1,'2026-04-26 01:12:55','2026-04-26 01:12:55'),(17,1,1,'IT Administrator','IT Administrator',NULL,NULL,1,'2026-04-26 01:13:12','2026-04-26 01:13:12'),(18,1,1,'Auditor','Auditor',NULL,NULL,1,'2026-04-26 01:13:27','2026-04-26 01:13:27'),(19,1,1,'Marketing Executive','Marketing Executive',NULL,NULL,1,'2026-04-26 01:13:45','2026-04-26 01:13:45'),(20,1,1,'Business Analyst','Business Analyst',NULL,NULL,1,'2026-04-26 01:13:59','2026-04-26 01:13:59');
/*!40000 ALTER TABLE `designations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `draft_loans`
--

DROP TABLE IF EXISTS `draft_loans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `draft_loans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `finance_id` bigint unsigned DEFAULT NULL,
  `tenant_id` bigint unsigned NOT NULL DEFAULT '1',
  `branch_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `customer_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `finance_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'vehicle',
  `product_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft loan',
  `asset_reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_details` json DEFAULT NULL,
  `valuation_details` json DEFAULT NULL,
  `guarantor_details` json DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `tenure_months` int NOT NULL,
  `installment_frequency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `interest_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `start_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `due_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total_paid_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `balance_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `next_collection_date` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending_approval',
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `draft_loans_finance_id_foreign` (`finance_id`),
  KEY `draft_loans_product_type_status_index` (`product_type`,`status`),
  KEY `draft_loans_customer_id_status_index` (`customer_id`,`status`),
  CONSTRAINT `draft_loans_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `draft_loans_finance_id_foreign` FOREIGN KEY (`finance_id`) REFERENCES `finances` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `draft_loans`
--

LOCK TABLES `draft_loans` WRITE;
/*!40000 ALTER TABLE `draft_loans` DISABLE KEYS */;
/*!40000 ALTER TABLE `draft_loans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_allowances_deductions`
--

DROP TABLE IF EXISTS `employee_allowances_deductions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_allowances_deductions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` enum('allowance','deduction') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount_type` enum('fixed','percentage') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fixed',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_allowances_deductions_employee_id_foreign` (`employee_id`),
  CONSTRAINT `employee_allowances_deductions_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_allowances_deductions`
--

LOCK TABLES `employee_allowances_deductions` WRITE;
/*!40000 ALTER TABLE `employee_allowances_deductions` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_allowances_deductions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_documents`
--

DROP TABLE IF EXISTS `employee_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `branch_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_documents_employee_id_foreign` (`employee_id`),
  KEY `employee_documents_type_index` (`type`),
  KEY `employee_documents_branch_id_foreign` (`branch_id`),
  CONSTRAINT `employee_documents_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `employee_documents_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_documents`
--

LOCK TABLES `employee_documents` WRITE;
/*!40000 ALTER TABLE `employee_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_educations`
--

DROP TABLE IF EXISTS `employee_educations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_educations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `institution` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `degree` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `field_of_study` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `branch_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_educations_employee_id_foreign` (`employee_id`),
  KEY `employee_educations_branch_id_foreign` (`branch_id`),
  CONSTRAINT `employee_educations_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `employee_educations_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_educations`
--

LOCK TABLES `employee_educations` WRITE;
/*!40000 ALTER TABLE `employee_educations` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_educations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_experiences`
--

DROP TABLE IF EXISTS `employee_experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_experiences` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `company` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT '0',
  `responsibilities` text COLLATE utf8mb4_unicode_ci,
  `achievements` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `branch_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_experiences_employee_id_foreign` (`employee_id`),
  KEY `employee_experiences_branch_id_foreign` (`branch_id`),
  CONSTRAINT `employee_experiences_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `employee_experiences_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_experiences`
--

LOCK TABLES `employee_experiences` WRITE;
/*!40000 ALTER TABLE `employee_experiences` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_experiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `employee_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mobile` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nic_passport` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `photo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` bigint unsigned NOT NULL,
  `designation_id` bigint unsigned NOT NULL,
  `join_date` date NOT NULL,
  `basic_salary` decimal(10,2) NOT NULL,
  `commission` decimal(5,2) DEFAULT NULL,
  `commission_base` enum('company_profit','own_business') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `overtime_payment_per_hour` decimal(8,2) DEFAULT NULL,
  `deduction_late_hour` decimal(8,2) DEFAULT NULL,
  `employee_type` enum('full_time','part_time','contract') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `reporting_person` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tin` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_applicable` tinyint(1) NOT NULL DEFAULT '0',
  `tax_relief_eligible` tinyint(1) NOT NULL DEFAULT '0',
  `apit_tax_amount` decimal(10,2) DEFAULT NULL,
  `apit_tax_rate` decimal(5,2) DEFAULT NULL,
  `epf_employee_contribution` decimal(5,2) DEFAULT NULL,
  `epf_employer_contribution` decimal(5,2) DEFAULT NULL,
  `etf_employee_contribution` decimal(5,2) DEFAULT NULL,
  `etf_employer_contribution` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_employee_code_unique` (`employee_code`),
  UNIQUE KEY `employees_email_unique` (`email`),
  UNIQUE KEY `employees_nic_passport_unique` (`nic_passport`),
  KEY `employees_tenant_id_foreign` (`tenant_id`),
  KEY `employees_branch_id_foreign` (`branch_id`),
  KEY `employees_department_id_foreign` (`department_id`),
  KEY `employees_designation_id_foreign` (`designation_id`),
  CONSTRAINT `employees_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `employees_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `employees_designation_id_foreign` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`id`),
  CONSTRAINT `employees_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,1,1,'EMP0001','Achintha','Suresh','achintha1@gmail.com','0741492632','TEMP1782186970','Panadura',NULL,'2005-02-10','other',6,7,'2024-02-01',30000.00,NULL,NULL,NULL,NULL,'full_time','active',NULL,'2026-06-23 01:56:10','2026-06-23 01:56:10',NULL,NULL,0,0,NULL,NULL,8.00,12.00,0.00,3.00),(2,1,1,'EMP0002','Chamuditha','Nilusha','Chamuditha1@gmail.com','0720981729','TEMP1782187205','Panadura',NULL,'2006-03-01','other',6,7,'2026-05-01',30000.00,NULL,NULL,NULL,NULL,'full_time','active',NULL,'2026-06-23 02:00:05','2026-06-23 02:00:05',NULL,NULL,0,0,NULL,NULL,8.00,12.00,0.00,3.00),(3,1,1,'EMP0003','Buddhika','Darshana','buddhika92fer@gmail.com','0774492632','TEMP1782187826','Panadura',NULL,NULL,'other',8,3,'2012-05-01',50000.00,NULL,NULL,NULL,NULL,'full_time','active',NULL,'2026-06-23 02:10:26','2026-06-23 02:10:26',NULL,NULL,0,0,NULL,NULL,8.00,12.00,0.00,3.00),(4,1,1,'EMP0004','Buddhika','Darshana','buddhika92fer2@gmail.com','','TEMP1784089415','Panadura',NULL,'1992-03-26','other',8,2,'2012-05-01',500000.00,NULL,NULL,NULL,NULL,'full_time','active',NULL,'2026-07-15 02:23:35','2026-07-15 02:23:35',NULL,NULL,0,0,NULL,NULL,8.00,12.00,0.00,3.00);
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finance_collections`
--

DROP TABLE IF EXISTS `finance_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finance_collections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `finance_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned DEFAULT NULL,
  `collector_id` bigint unsigned DEFAULT NULL,
  `payment_date` date NOT NULL,
  `payment_amount` decimal(15,2) NOT NULL,
  `refund_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `pay_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `reference_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cheque_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cheque_date` date DEFAULT NULL,
  `cheque_bank` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `interest_charged` decimal(15,2) NOT NULL DEFAULT '0.00',
  `interest_paid` decimal(15,2) NOT NULL DEFAULT '0.00',
  `principal_paid` decimal(15,2) NOT NULL DEFAULT '0.00',
  `arrears` decimal(15,2) NOT NULL DEFAULT '0.00',
  `remaining_capital` decimal(15,2) NOT NULL DEFAULT '0.00',
  `meta` json DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `finance_collections_finance_id_payment_date_index` (`finance_id`,`payment_date`),
  KEY `fin_coll_branch_idx` (`branch_id`),
  KEY `fin_coll_collector_idx` (`collector_id`),
  CONSTRAINT `finance_collections_finance_id_foreign` FOREIGN KEY (`finance_id`) REFERENCES `finances` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finance_collections`
--

LOCK TABLES `finance_collections` WRITE;
/*!40000 ALTER TABLE `finance_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `finance_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finance_documents`
--

DROP TABLE IF EXISTS `finance_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finance_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `finance_id` bigint unsigned NOT NULL,
  `document_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `finance_documents_finance_id_index` (`finance_id`),
  CONSTRAINT `finance_documents_finance_id_foreign` FOREIGN KEY (`finance_id`) REFERENCES `finances` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finance_documents`
--

LOCK TABLES `finance_documents` WRITE;
/*!40000 ALTER TABLE `finance_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `finance_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finance_product_types`
--

DROP TABLE IF EXISTS `finance_product_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finance_product_types` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `interest_rate` decimal(8,2) DEFAULT NULL,
  `interest_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tenure_months` int unsigned DEFAULT NULL,
  `installment_frequency` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `finance_product_types_name_unique` (`name`),
  UNIQUE KEY `finance_product_types_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finance_product_types`
--

LOCK TABLES `finance_product_types` WRITE;
/*!40000 ALTER TABLE `finance_product_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `finance_product_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finances`
--

DROP TABLE IF EXISTS `finances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finances` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL DEFAULT '1',
  `branch_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `finance_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'vehicle',
  `product_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `asset_reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_details` json DEFAULT NULL,
  `valuation_details` json DEFAULT NULL,
  `guarantor_details` json DEFAULT NULL,
  `repayment_plan` json DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `down_payment` decimal(15,2) NOT NULL DEFAULT '0.00',
  `financed_amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `interest_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fixed',
  `tenure_months` int NOT NULL,
  `installment_frequency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `installment_amount` decimal(15,2) NOT NULL,
  `refund_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total_paid_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `balance_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `due_date` date DEFAULT NULL,
  `due_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `due_capital_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `due_interest_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `arrears` decimal(15,2) NOT NULL DEFAULT '0.00',
  `penalty` decimal(15,2) NOT NULL DEFAULT '0.00',
  `next_collection_date` date DEFAULT NULL,
  `finance_end_date` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `start_date` date DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `finances_customer_id_foreign` (`customer_id`),
  CONSTRAINT `finances_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finances`
--

LOCK TABLES `finances` WRITE;
/*!40000 ALTER TABLE `finances` DISABLE KEYS */;
/*!40000 ALTER TABLE `finances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_types`
--

DROP TABLE IF EXISTS `leave_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_types` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `max_days_per_year` int NOT NULL DEFAULT '0',
  `requires_documentation` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `leave_types_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_types`
--

LOCK TABLES `leave_types` WRITE;
/*!40000 ALTER TABLE `leave_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leaves`
--

DROP TABLE IF EXISTS `leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leaves` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `leave_type` enum('annual','casual','medical','maternity','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `days_requested` int NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','section_head_approved','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint unsigned DEFAULT NULL,
  `approver_notes` text COLLATE utf8mb4_unicode_ci,
  `approved_at` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `section_head_approved` tinyint(1) NOT NULL DEFAULT '0',
  `section_head_approved_by` bigint unsigned DEFAULT NULL,
  `section_head_approved_at` timestamp NULL DEFAULT NULL,
  `section_head_notes` text COLLATE utf8mb4_unicode_ci,
  `hr_approved` tinyint(1) NOT NULL DEFAULT '0',
  `hr_approved_by` bigint unsigned DEFAULT NULL,
  `hr_approved_at` timestamp NULL DEFAULT NULL,
  `hr_notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `leaves_tenant_id_foreign` (`tenant_id`),
  KEY `leaves_branch_id_foreign` (`branch_id`),
  KEY `leaves_employee_id_foreign` (`employee_id`),
  KEY `leaves_approved_by_foreign` (`approved_by`),
  KEY `leaves_section_head_approved_by_foreign` (`section_head_approved_by`),
  KEY `leaves_hr_approved_by_foreign` (`hr_approved_by`),
  CONSTRAINT `leaves_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `employees` (`id`),
  CONSTRAINT `leaves_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `leaves_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  CONSTRAINT `leaves_hr_approved_by_foreign` FOREIGN KEY (`hr_approved_by`) REFERENCES `employees` (`id`),
  CONSTRAINT `leaves_section_head_approved_by_foreign` FOREIGN KEY (`section_head_approved_by`) REFERENCES `employees` (`id`),
  CONSTRAINT `leaves_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaves`
--

LOCK TABLES `leaves` WRITE;
/*!40000 ALTER TABLE `leaves` DISABLE KEYS */;
/*!40000 ALTER TABLE `leaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loan_request_documents`
--

DROP TABLE IF EXISTS `loan_request_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_request_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `loan_request_id` bigint unsigned NOT NULL,
  `document_type` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'supporting',
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `loan_request_documents_uploaded_by_foreign` (`uploaded_by`),
  KEY `loan_request_documents_loan_request_id_index` (`loan_request_id`),
  CONSTRAINT `loan_request_documents_loan_request_id_foreign` FOREIGN KEY (`loan_request_id`) REFERENCES `loan_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `loan_request_documents_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan_request_documents`
--

LOCK TABLES `loan_request_documents` WRITE;
/*!40000 ALTER TABLE `loan_request_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `loan_request_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loan_requests`
--

DROP TABLE IF EXISTS `loan_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL DEFAULT '1',
  `branch_id` bigint unsigned DEFAULT NULL,
  `request_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loan_product` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_no` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_full_name` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_nic` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_mobile` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `principal` decimal(16,2) NOT NULL,
  `annual_rate` decimal(8,4) NOT NULL,
  `tenure_months` int unsigned NOT NULL,
  `installment_frequency` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `installments` int unsigned NOT NULL DEFAULT '0',
  `installment_amount` decimal(16,2) NOT NULL DEFAULT '0.00',
  `total_payable` decimal(16,2) NOT NULL DEFAULT '0.00',
  `customer_details` json NOT NULL,
  `guarantor_details` json DEFAULT NULL,
  `status` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending_approval',
  `approval_level` tinyint unsigned NOT NULL DEFAULT '1',
  `required_approval_level` tinyint unsigned NOT NULL DEFAULT '2',
  `created_by` bigint unsigned DEFAULT NULL,
  `last_action_by` bigint unsigned DEFAULT NULL,
  `last_action_at` timestamp NULL DEFAULT NULL,
  `approval_note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `loan_requests_request_no_unique` (`request_no`),
  KEY `loan_requests_status_approval_level_index` (`status`,`approval_level`),
  KEY `loan_requests_customer_no_index` (`customer_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan_requests`
--

LOCK TABLES `loan_requests` WRITE;
/*!40000 ALTER TABLE `loan_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `loan_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_centers`
--

DROP TABLE IF EXISTS `mf_centers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_centers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mf_route_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `meeting_day` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mf_centers_code_unique` (`code`),
  KEY `mf_centers_mf_route_id_foreign` (`mf_route_id`),
  CONSTRAINT `mf_centers_mf_route_id_foreign` FOREIGN KEY (`mf_route_id`) REFERENCES `mf_routes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_centers`
--

LOCK TABLES `mf_centers` WRITE;
/*!40000 ALTER TABLE `mf_centers` DISABLE KEYS */;
/*!40000 ALTER TABLE `mf_centers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_groups`
--

DROP TABLE IF EXISTS `mf_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_groups` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mf_route_id` bigint unsigned NOT NULL,
  `mf_center_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mf_groups_code_unique` (`code`),
  KEY `mf_groups_mf_route_id_foreign` (`mf_route_id`),
  KEY `mf_groups_mf_center_id_foreign` (`mf_center_id`),
  CONSTRAINT `mf_groups_mf_center_id_foreign` FOREIGN KEY (`mf_center_id`) REFERENCES `mf_centers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mf_groups_mf_route_id_foreign` FOREIGN KEY (`mf_route_id`) REFERENCES `mf_routes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_groups`
--

LOCK TABLES `mf_groups` WRITE;
/*!40000 ALTER TABLE `mf_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `mf_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_holiday_loan_date_shifts`
--

DROP TABLE IF EXISTS `mf_holiday_loan_date_shifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_holiday_loan_date_shifts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mf_holiday_id` bigint unsigned NOT NULL,
  `loan_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `loan_id` bigint unsigned NOT NULL,
  `field_name` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_date` date NOT NULL,
  `shifted_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mf_holiday_shift_unique` (`mf_holiday_id`,`loan_type`,`loan_id`,`field_name`),
  KEY `mf_holiday_loan_date_shifts_loan_type_loan_id_index` (`loan_type`,`loan_id`),
  CONSTRAINT `mf_holiday_loan_date_shifts_mf_holiday_id_foreign` FOREIGN KEY (`mf_holiday_id`) REFERENCES `mf_holidays` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_holiday_loan_date_shifts`
--

LOCK TABLES `mf_holiday_loan_date_shifts` WRITE;
/*!40000 ALTER TABLE `mf_holiday_loan_date_shifts` DISABLE KEYS */;
INSERT INTO `mf_holiday_loan_date_shifts` VALUES (1,1,'microfinance',1,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(2,1,'microfinance',1,'next_payment_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(3,1,'microfinance',2,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(4,1,'microfinance',3,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(5,1,'microfinance',4,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(6,1,'microfinance',4,'next_payment_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(7,1,'microfinance',6,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(8,1,'microfinance',7,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(9,1,'microfinance',7,'next_payment_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(10,1,'microfinance',8,'due_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(11,1,'microfinance',8,'next_payment_date','2026-07-05','2026-07-06','2026-07-04 13:46:09','2026-07-04 13:46:09'),(12,3,'microfinance',1,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(13,3,'microfinance',1,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(14,3,'microfinance',3,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(15,3,'microfinance',3,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(16,3,'microfinance',4,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(17,3,'microfinance',4,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(18,3,'microfinance',5,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(19,3,'microfinance',5,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(20,3,'microfinance',6,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(21,3,'microfinance',6,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(22,3,'microfinance',7,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(23,3,'microfinance',7,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(24,3,'microfinance',8,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(25,3,'microfinance',8,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(26,3,'microfinance',11,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(27,3,'microfinance',11,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(28,3,'microfinance',12,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(29,3,'microfinance',12,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(30,3,'microfinance',13,'due_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21'),(31,3,'microfinance',13,'next_payment_date','2026-07-20','2026-07-21','2026-07-19 00:03:21','2026-07-19 00:03:21');
/*!40000 ALTER TABLE `mf_holiday_loan_date_shifts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_holidays`
--

DROP TABLE IF EXISTS `mf_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_holidays` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `holiday_date` date NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mf_holidays_holiday_date_unique` (`holiday_date`),
  KEY `mf_holidays_holiday_date_is_active_index` (`holiday_date`,`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_holidays`
--

LOCK TABLES `mf_holidays` WRITE;
/*!40000 ALTER TABLE `mf_holidays` DISABLE KEYS */;
INSERT INTO `mf_holidays` VALUES (1,'2026-07-05','sunday',NULL,1,1,'2026-07-04 13:46:09','2026-07-04 13:46:09'),(2,'2026-07-19','Sunday',NULL,1,1,'2026-07-15 05:52:51','2026-07-15 05:52:51'),(3,'2026-07-20','Monday',NULL,1,1,'2026-07-19 00:03:21','2026-07-19 00:03:21');
/*!40000 ALTER TABLE `mf_holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_loan_collections`
--

DROP TABLE IF EXISTS `mf_loan_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_loan_collections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mf_loan_request_id` bigint unsigned NOT NULL,
  `collection_date` date NOT NULL,
  `collected_amount` decimal(14,2) NOT NULL,
  `correction_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `capital_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `interest_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `penalty_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `payment_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `payment_reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `deleted_by` bigint unsigned DEFAULT NULL,
  `deletion_reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mf_loan_collections_created_by_foreign` (`created_by`),
  KEY `mf_loan_collections_mf_loan_request_id_collection_date_index` (`mf_loan_request_id`,`collection_date`),
  KEY `mf_loan_collections_payment_type_index` (`payment_type`),
  KEY `mf_loan_collections_deleted_by_foreign` (`deleted_by`),
  CONSTRAINT `mf_loan_collections_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mf_loan_collections_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mf_loan_collections_mf_loan_request_id_foreign` FOREIGN KEY (`mf_loan_request_id`) REFERENCES `mf_loan_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_loan_collections`
--

LOCK TABLES `mf_loan_collections` WRITE;
/*!40000 ALTER TABLE `mf_loan_collections` DISABLE KEYS */;
INSERT INTO `mf_loan_collections` VALUES (1,1,'2026-06-24',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-06-24 07:01:25','2026-06-24 07:01:25',NULL),(2,3,'2026-06-24',2300.00,0.00,2062.78,237.22,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-06-24 07:02:48','2026-06-24 07:02:48',NULL),(3,4,'2026-06-24',1000.00,0.00,862.07,137.93,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-06-24 07:07:37','2026-06-24 07:07:37',NULL),(4,2,'2026-06-25',2000.00,0.00,1793.72,206.28,0.00,'cash',NULL,NULL,7,NULL,NULL,'2026-06-25 06:55:33','2026-06-25 06:55:33',NULL),(5,4,'2026-06-25',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,7,NULL,NULL,'2026-06-25 06:56:50','2026-06-25 06:56:50',NULL),(6,3,'2026-06-26',1200.00,0.00,1076.23,123.77,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-06-26 07:06:26','2026-06-26 07:06:26',NULL),(7,1,'2026-06-26',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-06-26 07:07:09','2026-06-26 07:07:09',NULL),(8,4,'2026-06-26',3000.00,0.00,2586.20,413.80,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-06-26 07:17:54','2026-06-26 07:17:54',NULL),(9,2,'2026-06-27',7000.00,0.00,6278.03,721.97,0.00,'cash',NULL,NULL,1,1,NULL,'2026-06-27 07:04:00','2026-06-27 07:04:32','2026-06-27 07:04:32'),(10,5,'2026-07-04',1237.33,0.00,1056.00,168.96,12.37,'cash',NULL,NULL,5,5,NULL,'2026-07-04 00:17:31','2026-07-04 00:18:56','2026-07-04 00:18:56'),(11,5,'2026-07-04',9000.00,0.00,7758.64,1241.36,0.00,'cash',NULL,NULL,5,5,NULL,'2026-07-04 00:18:06','2026-07-04 00:19:04','2026-07-04 00:19:04'),(12,5,'2026-07-04',1000.00,0.00,862.07,137.93,0.00,'cash',NULL,NULL,5,5,NULL,'2026-07-04 00:18:27','2026-07-04 00:19:08','2026-07-04 00:19:08'),(13,3,'2026-07-04',1000.00,0.00,886.86,101.99,11.15,'cash',NULL,NULL,5,5,NULL,'2026-07-04 00:23:16','2026-07-04 00:23:30','2026-07-04 00:23:30'),(14,1,'2026-07-04',14000.00,0.00,12055.60,1928.93,15.47,'cash',NULL,NULL,5,NULL,NULL,'2026-07-04 00:24:39','2026-07-04 00:24:39',NULL),(15,6,'2026-07-04',500.00,0.00,440.43,50.65,8.92,'cash',NULL,NULL,6,NULL,NULL,'2026-07-04 00:36:22','2026-07-04 00:36:22',NULL),(16,6,'2026-07-04',500.00,0.00,448.43,51.57,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-04 00:36:38','2026-07-04 00:36:38',NULL),(17,4,'2026-07-04',1500.00,0.00,1279.76,204.77,15.47,'cash',NULL,NULL,6,NULL,NULL,'2026-07-04 00:49:09','2026-07-04 00:49:09',NULL),(18,2,'2026-07-04',109500.00,0.00,98206.28,11293.72,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-04 02:04:08','2026-07-04 02:04:08',NULL),(19,10,'2026-07-15',1000.00,0.00,862.07,137.93,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-15 01:30:21','2026-07-15 01:30:21',NULL),(20,5,'2026-07-15',1200.00,0.00,1034.49,165.51,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-15 01:32:40','2026-07-15 01:32:40',NULL),(21,3,'2026-07-15',1200.00,0.00,1062.23,122.16,15.61,'cash',NULL,NULL,5,NULL,NULL,'2026-07-15 01:32:50','2026-07-15 01:32:50',NULL),(22,1,'2026-07-15',1500.00,0.00,1274.44,203.91,21.65,'cash',NULL,NULL,5,NULL,NULL,'2026-07-15 01:33:00','2026-07-15 01:33:00',NULL),(23,8,'2026-07-15',4200.00,0.00,3906.26,234.38,59.36,'cash',NULL,NULL,6,NULL,NULL,'2026-07-15 01:44:41','2026-07-15 01:44:41',NULL),(24,7,'2026-07-15',900.00,0.00,765.09,122.42,12.49,'cash',NULL,NULL,6,NULL,NULL,'2026-07-15 01:44:49','2026-07-15 01:44:49',NULL),(25,6,'2026-07-15',900.00,0.00,795.97,91.54,12.49,'cash',NULL,NULL,6,6,NULL,'2026-07-15 01:46:18','2026-07-15 03:20:11','2026-07-15 03:20:11'),(26,4,'2026-07-15',1600.00,0.00,1360.64,217.71,21.65,'cash',NULL,NULL,6,NULL,NULL,'2026-07-15 01:46:29','2026-07-15 01:46:29',NULL),(27,8,'2026-07-15',4000.00,0.00,3773.58,226.42,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-15 01:49:19','2026-07-15 01:49:19',NULL),(28,12,'2026-07-15',32300.00,0.00,28893.95,3332.44,73.61,'cash',NULL,NULL,6,NULL,NULL,'2026-07-15 02:41:56','2026-07-15 02:41:56',NULL),(29,5,'2026-07-15',1200.00,0.00,1034.49,165.51,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-15 03:00:09','2026-07-15 03:00:09',NULL),(30,12,'2026-07-17',1700.00,0.00,1524.21,175.79,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-17 00:57:47','2026-07-17 00:57:47',NULL),(31,8,'2026-07-17',4300.00,0.00,4056.60,243.40,0.00,'cash',NULL,NULL,8,8,NULL,'2026-07-17 00:57:58','2026-07-17 01:10:29','2026-07-17 01:10:29'),(32,7,'2026-07-17',900.00,0.00,775.86,124.14,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-17 00:58:08','2026-07-17 00:58:08',NULL),(33,6,'2026-07-17',900.00,0.00,795.97,91.54,12.49,'cash',NULL,NULL,8,NULL,NULL,'2026-07-17 00:58:17','2026-07-17 00:58:17',NULL),(34,4,'2026-07-17',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,8,8,NULL,'2026-07-17 00:58:52','2026-07-17 01:04:58','2026-07-17 01:04:58'),(35,11,'2026-07-17',1500.00,0.00,1134.13,181.46,184.41,'cash',NULL,NULL,8,8,NULL,'2026-07-17 00:59:17','2026-07-17 01:08:32','2026-07-17 01:08:32'),(36,9,'2026-07-17',700.00,0.00,603.45,96.55,0.00,'cash',NULL,NULL,8,8,NULL,'2026-07-17 00:59:44','2026-07-17 01:07:15','2026-07-17 01:07:15'),(37,5,'2026-07-17',1300.00,0.00,1120.69,179.31,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-17 00:59:57','2026-07-17 00:59:57',NULL),(38,3,'2026-07-17',1200.00,0.00,1076.23,123.77,0.00,'cash',NULL,NULL,8,8,NULL,'2026-07-17 01:00:08','2026-07-17 01:02:22','2026-07-17 01:02:22'),(39,1,'2026-07-17',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,8,8,'ASSS','2026-07-17 01:00:19','2026-07-17 01:00:50','2026-07-17 01:00:50'),(40,1,'2026-07-17',1600.00,0.00,1379.31,220.69,0.00,'cash',NULL,NULL,8,8,NULL,'2026-07-17 01:01:56','2026-07-17 01:02:15','2026-07-17 01:02:15'),(41,3,'2026-07-17',10000.00,0.00,8968.61,1031.39,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-17 01:03:50','2026-07-17 01:03:50',NULL),(42,8,'2026-07-17',4300.00,0.00,4056.60,243.40,0.00,'cash',NULL,NULL,1,8,NULL,'2026-07-17 01:11:05','2026-07-17 01:11:39','2026-07-17 01:11:39'),(43,8,'2026-07-17',4300.00,0.00,4056.60,243.40,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 01:13:16','2026-07-17 01:13:16',NULL),(44,4,'2026-07-17',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 01:13:36','2026-07-17 01:13:36',NULL),(45,1,'2026-07-17',1600.00,0.00,1379.31,220.69,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 01:15:09','2026-07-17 01:15:09',NULL),(46,11,'2026-07-17',1500.00,0.00,1170.03,187.20,142.77,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 01:19:21','2026-07-17 01:19:21',NULL),(47,9,'2026-07-17',600.00,0.00,517.24,82.76,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 01:19:32','2026-07-17 01:19:32',NULL),(48,9,'2026-07-17',600.00,0.00,517.24,82.76,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 01:19:49','2026-07-17 01:19:49',NULL),(49,13,'2026-07-18',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 23:35:31','2026-07-17 23:35:31',NULL),(50,11,'2026-07-18',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 23:37:26','2026-07-17 23:37:26',NULL),(51,5,'2026-07-18',1200.00,0.00,1034.49,165.51,0.00,'cash',NULL,NULL,1,5,NULL,'2026-07-17 23:40:22','2026-07-17 23:59:32','2026-07-17 23:59:32'),(52,3,'2026-07-18',1000.00,0.00,896.86,103.14,0.00,'cash',NULL,NULL,1,NULL,NULL,'2026-07-17 23:41:09','2026-07-17 23:41:09',NULL),(53,6,'2026-07-18',900.00,0.00,807.17,92.83,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-17 23:45:48','2026-07-17 23:45:48',NULL),(54,12,'2026-07-18',1700.00,0.00,1524.21,175.79,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-18 01:31:13','2026-07-18 01:31:13',NULL),(55,8,'2026-07-18',5000.00,0.00,4716.98,283.02,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-18 01:31:29','2026-07-18 01:31:29',NULL),(56,7,'2026-07-18',10000.00,0.00,8620.67,1379.33,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-18 01:31:39','2026-07-18 01:31:39',NULL),(57,6,'2026-07-18',7200.00,0.00,6457.40,742.60,0.00,'cash',NULL,NULL,6,6,NULL,'2026-07-18 01:31:50','2026-07-18 01:35:35','2026-07-18 01:35:35'),(58,4,'2026-07-18',3000.00,0.00,2586.20,413.80,0.00,'cash',NULL,NULL,6,6,NULL,'2026-07-18 01:32:05','2026-07-18 01:37:49','2026-07-18 01:37:49'),(59,13,'2026-07-19',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-18 23:57:45','2026-07-18 23:57:45',NULL),(60,11,'2026-07-19',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-18 23:58:02','2026-07-18 23:58:02',NULL),(61,9,'2026-07-19',600.00,0.00,517.24,82.76,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-18 23:58:15','2026-07-18 23:58:15',NULL),(62,5,'2026-07-19',1200.00,0.00,1034.49,165.51,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-18 23:58:26','2026-07-18 23:58:26',NULL),(63,3,'2026-07-19',1200.00,0.00,1076.23,123.77,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-18 23:58:40','2026-07-18 23:58:40',NULL),(64,1,'2026-07-19',1600.00,0.00,1379.31,220.69,0.00,'cash',NULL,NULL,5,NULL,NULL,'2026-07-18 23:58:52','2026-07-18 23:58:52',NULL),(65,12,'2026-07-19',1700.00,0.00,1524.21,175.79,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-19 00:00:03','2026-07-19 00:00:03',NULL),(66,8,'2026-07-19',4300.00,0.00,4056.60,243.40,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-19 00:00:13','2026-07-19 00:00:13',NULL),(67,7,'2026-07-19',900.00,0.00,775.86,124.14,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-19 00:00:26','2026-07-19 00:00:26',NULL),(68,6,'2026-07-19',892.00,0.00,800.00,92.00,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-19 00:00:34','2026-07-19 00:00:34',NULL),(69,4,'2026-07-19',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,6,NULL,NULL,'2026-07-19 00:01:05','2026-07-19 00:01:05',NULL),(70,13,'2026-07-21',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:23:00','2026-07-21 02:23:00',NULL),(71,9,'2026-07-21',700.00,0.00,603.45,96.55,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:23:12','2026-07-21 02:23:12',NULL),(72,9,'2026-07-21',700.00,0.00,603.45,96.55,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:24:10','2026-07-21 02:24:10',NULL),(73,5,'2026-07-21',1200.00,0.00,1034.49,165.51,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:24:21','2026-07-21 02:24:21',NULL),(74,3,'2026-07-21',1200.00,0.00,1076.23,123.77,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:24:30','2026-07-21 02:24:30',NULL),(75,1,'2026-07-21',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:24:38','2026-07-21 02:24:38',NULL),(76,12,'2026-07-21',1700.00,0.00,1524.21,175.79,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:24:51','2026-07-21 02:24:51',NULL),(77,8,'2026-07-21',4200.00,0.00,3962.26,237.74,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:25:01','2026-07-21 02:25:01',NULL),(78,7,'2026-07-21',900.00,0.00,775.86,124.14,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:25:08','2026-07-21 02:25:08',NULL),(79,6,'2026-07-21',900.00,0.00,807.17,92.83,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:25:14','2026-07-21 02:25:14',NULL),(80,4,'2026-07-21',1500.00,0.00,1293.10,206.90,0.00,'cash',NULL,NULL,8,NULL,NULL,'2026-07-21 02:25:21','2026-07-21 02:25:21',NULL);
/*!40000 ALTER TABLE `mf_loan_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_loan_guarantors`
--

DROP TABLE IF EXISTS `mf_loan_guarantors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_loan_guarantors` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mf_loan_request_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nic` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `contact_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `relationship` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mf_loan_guarantors_mf_loan_request_id_foreign` (`mf_loan_request_id`),
  CONSTRAINT `mf_loan_guarantors_mf_loan_request_id_foreign` FOREIGN KEY (`mf_loan_request_id`) REFERENCES `mf_loan_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_loan_guarantors`
--

LOCK TABLES `mf_loan_guarantors` WRITE;
/*!40000 ALTER TABLE `mf_loan_guarantors` DISABLE KEYS */;
/*!40000 ALTER TABLE `mf_loan_guarantors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_loan_request_documents`
--

DROP TABLE IF EXISTS `mf_loan_request_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_loan_request_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mf_loan_request_id` bigint unsigned NOT NULL,
  `document_type` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mf_loan_request_documents_mf_loan_request_id_foreign` (`mf_loan_request_id`),
  KEY `mf_loan_request_documents_uploaded_by_foreign` (`uploaded_by`),
  CONSTRAINT `mf_loan_request_documents_mf_loan_request_id_foreign` FOREIGN KEY (`mf_loan_request_id`) REFERENCES `mf_loan_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mf_loan_request_documents_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_loan_request_documents`
--

LOCK TABLES `mf_loan_request_documents` WRITE;
/*!40000 ALTER TABLE `mf_loan_request_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `mf_loan_request_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_loan_requests`
--

DROP TABLE IF EXISTS `mf_loan_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_loan_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint unsigned DEFAULT NULL,
  `loan_scope` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'center_loan',
  `mf_route_id` bigint unsigned DEFAULT NULL,
  `mf_center_id` bigint unsigned DEFAULT NULL,
  `mf_group_id` bigint unsigned DEFAULT NULL,
  `manager_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_officer` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_leader` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `loan_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_no` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nick_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nic` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_no` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `loan_amount` decimal(15,2) NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `refund_option` enum('day','week','month') COLLATE utf8mb4_unicode_ci NOT NULL,
  `interest_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'flat',
  `interest_rate` decimal(10,7) NOT NULL,
  `terms_count` int NOT NULL,
  `refundable_amount` decimal(15,2) NOT NULL,
  `installment_amount` decimal(15,2) NOT NULL,
  `loan_balance` decimal(15,2) DEFAULT NULL,
  `document_charges` decimal(15,2) NOT NULL DEFAULT '0.00',
  `stamp_charges` decimal(15,2) NOT NULL DEFAULT '0.00',
  `insurance_charges` decimal(15,2) NOT NULL DEFAULT '0.00',
  `charge_payment_mode` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'hand_cash',
  `net_disbursed_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `loan_request_date` date NOT NULL,
  `next_payment_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `loan_end_date` date DEFAULT NULL,
  `arrears_balance` decimal(14,2) NOT NULL DEFAULT '0.00',
  `penalty_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
  `penalty_grace_days` int unsigned NOT NULL DEFAULT '2',
  `penalty_starts_on` date DEFAULT NULL,
  `documents_requested` tinyint(1) NOT NULL DEFAULT '0',
  `document_request_note` text COLLATE utf8mb4_unicode_ci,
  `document_requested_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `rejected_at` timestamp NULL DEFAULT NULL,
  `hold_at` timestamp NULL DEFAULT NULL,
  `hold_reason` text COLLATE utf8mb4_unicode_ci,
  `closed_at` timestamp NULL DEFAULT NULL,
  `closed_reason` text COLLATE utf8mb4_unicode_ci,
  `status` enum('requested','approved','released','rejected','hold','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'requested',
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mf_loan_requests_created_by_foreign` (`created_by`),
  KEY `mf_loan_requests_branch_id_foreign` (`branch_id`),
  KEY `mf_loan_requests_mf_route_id_foreign` (`mf_route_id`),
  KEY `mf_loan_requests_mf_center_id_foreign` (`mf_center_id`),
  KEY `mf_loan_requests_mf_group_id_foreign` (`mf_group_id`),
  KEY `mf_loan_requests_customer_no_index` (`customer_no`),
  CONSTRAINT `mf_loan_requests_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mf_loan_requests_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mf_loan_requests_mf_center_id_foreign` FOREIGN KEY (`mf_center_id`) REFERENCES `mf_centers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mf_loan_requests_mf_group_id_foreign` FOREIGN KEY (`mf_group_id`) REFERENCES `mf_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mf_loan_requests_mf_route_id_foreign` FOREIGN KEY (`mf_route_id`) REFERENCES `mf_routes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_loan_requests`
--

LOCK TABLES `mf_loan_requests` WRITE;
/*!40000 ALTER TABLE `mf_loan_requests` DISABLE KEYS */;
INSERT INTO `mf_loan_requests` VALUES (1,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0001','92','Customer 1','Customer 1','111111111V','Moratuwa','0771111111',100000.00,NULL,'day','flat',5.3333330,75,116000.00,1546.67,84083.76,0.00,0.00,0.00,'hand_cash',100000.00,'2026-06-23','2026-07-22','2026-07-22','2026-09-23',-7733.30,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',2,'2026-06-23 02:13:39','2026-07-21 02:24:38'),(2,1,'route_loan',3,NULL,NULL,'Buddhika Darshana','Chamuditha Nilusha','','RL-L 02-L0001','93','Customer 2','Customer 2','222222222V','Panadura','0772222222',100000.00,NULL,'day','flat',5.7500000,50,111500.00,2230.00,98206.28,0.00,0.00,0.00,'hand_cash',100000.00,'2026-06-23','2026-07-07','2026-07-06','2026-08-23',-111500.00,0.20,2,'2026-07-09',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'released',2,'2026-06-23 02:15:38','2026-07-04 13:46:09'),(3,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0002','92','Customer 1','Customer 1','111111111V','Moratuwa','0771111111',50000.00,NULL,'day','flat',5.7500000,50,55750.00,1115.00,45798.76,0.00,0.00,0.00,'hand_cash',50000.00,'2026-06-23','2026-07-22','2026-07-22','2026-08-23',-260.00,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',2,'2026-06-23 02:37:22','2026-07-21 02:24:30'),(4,1,'route_loan',3,NULL,NULL,'Buddhika Darshana','Chamuditha Nilusha','','RL-L 02-L0002','93','Customer 2','Customer 2','222222222V','Panadura','0772222222',100000.00,NULL,'day','flat',5.3333330,75,116000.00,1546.67,91325.13,0.00,0.00,0.00,'hand_cash',100000.00,'2026-06-23','2026-07-22','2026-07-22','2026-09-23',2366.70,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',2,'2026-06-23 02:38:23','2026-07-21 02:25:21'),(5,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0003','94','Kamal','Kamal','33333333333V','Piliyandala','0773333333',80000.00,NULL,'day','flat',5.3333333,75,92800.00,1237.33,76810.33,0.00,0.00,0.00,'hand_cash',80000.00,'2026-06-26','2026-07-22','2026-07-22','2026-09-26',2561.31,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',1,'2026-06-26 07:13:32','2026-07-21 02:24:21'),(6,1,'route_loan',3,NULL,NULL,'Buddhika Darshana','Chamuditha Nilusha','','RL-L 02-L0003','95','Suraj','suraj','44444444444V','jnjjmjbgb','0775555555',40000.00,NULL,'day','flat',5.7500000,50,44600.00,892.00,37508.00,0.00,0.00,0.00,'hand_cash',40000.00,'2026-06-24','2026-07-22','2026-07-22','2026-08-26',7004.00,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',1,'2026-06-26 07:15:54','2026-07-21 02:25:14'),(7,1,'route_loan',3,NULL,NULL,'Buddhika Darshana','Chamuditha Nilusha','','RL-L 01-L0004','96','Sumudu','Sumudu','5555555555V','Pailiyandala','0775555555',60000.00,NULL,'day','flat',5.3333333,78,69600.00,892.31,NULL,0.00,0.00,0.00,'hand_cash',60000.00,'2026-07-04','2026-07-22','2026-07-22','2026-10-04',-215.35,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',7,'2026-07-04 01:41:08','2026-07-21 02:25:08'),(8,1,'route_loan',3,NULL,NULL,'Buddhika Darshana','Chamuditha Nilusha','','RL-L 02-L0005','97','Suresh Kumara','Suresh Vegi','666666666V','Madapatha','07766666666',100000.00,NULL,'day','flat',6.0000000,25,106000.00,4240.00,92320.16,0.00,0.00,0.00,'hand_cash',100000.00,'2026-07-04','2026-07-22','2026-07-22','2026-08-04',16400.00,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',7,'2026-07-04 01:59:21','2026-07-21 02:25:01'),(9,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0004','98','Dasun','Dasun Perera','777777777V','Moratumulla','07788888888',40000.00,NULL,'day','flat',5.3333333,75,46400.00,618.67,40000.00,0.00,0.00,0.00,'hand_cash',40000.00,'2026-07-15','2026-08-20','2026-08-15','2026-10-28',-3200.00,0.20,2,'2026-08-18',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',1,'2026-07-15 01:24:57','2026-07-21 02:24:10'),(10,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0005','98','Dasun Customer','Dasun Perera','777777777V','Moratumulla','07788888888',60000.00,NULL,'day','flat',5.3333333,75,69600.00,928.00,NULL,0.00,0.00,0.00,'hand_cash',60000.00,'2026-07-12',NULL,NULL,'2026-09-25',0.00,0.20,2,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-15 01:41:54',NULL,'closed',1,'2026-07-15 01:25:45','2026-07-15 01:41:54'),(11,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0006','99','Gihan Fernando','Gihan','999999999V','Madapatha','07556315635',100000.00,NULL,'day','flat',5.3333333,78,116000.00,1487.18,100000.00,0.00,0.00,0.00,'hand_cash',100000.00,'2026-05-13','2026-07-21','2026-07-21','2026-08-13',74320.54,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',1,'2026-07-15 02:34:16','2026-07-19 00:03:21'),(12,1,'route_loan',3,NULL,NULL,'Buddhika Darshana','Chamuditha Nilusha','','RL-L 02-L0006','381','G K Nalin Chaminda','Nalin','770672333V','Walana','0758425691',75000.00,NULL,'day','flat',5.7666660,50,83650.00,1673.00,NULL,0.00,0.00,0.00,'hand_cash',75000.00,'2026-06-20','2026-07-22','2026-07-22','2026-09-20',11090.00,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',1,'2026-07-15 02:38:39','2026-07-21 02:24:51'),(13,1,'route_loan',1,NULL,NULL,'Buddhika Darshana','Achintha Suresh','','RL-L 01-L0007','92','Customer 1','Customer 1','111111111V','Moratuwa','0771111111',100000.00,NULL,'day','flat',5.3333333,78,116000.00,1487.18,NULL,0.00,0.00,0.00,'hand_cash',100000.00,'2026-07-17','2026-07-22','2026-07-22','2026-10-18',-38.46,0.20,2,'2026-07-24',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',8,'2026-07-17 01:17:35','2026-07-21 02:23:00');
/*!40000 ALTER TABLE `mf_loan_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_penalty_settings`
--

DROP TABLE IF EXISTS `mf_penalty_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_penalty_settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `penalty_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_penalty_settings`
--

LOCK TABLES `mf_penalty_settings` WRITE;
/*!40000 ALTER TABLE `mf_penalty_settings` DISABLE KEYS */;
INSERT INTO `mf_penalty_settings` VALUES (1,0.20,1,'2026-06-23 02:05:00','2026-07-15 01:56:20');
/*!40000 ALTER TABLE `mf_penalty_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mf_routes`
--

DROP TABLE IF EXISTS `mf_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mf_routes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mf_routes_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mf_routes`
--

LOCK TABLES `mf_routes` WRITE;
/*!40000 ALTER TABLE `mf_routes` DISABLE KEYS */;
INSERT INTO `mf_routes` VALUES (1,'Line 1','L 01',1,'2026-06-23 02:02:44','2026-06-23 02:02:44'),(3,'Line 2','L 02',1,'2026-06-23 02:03:47','2026-06-23 02:03:47');
/*!40000 ALTER TABLE `mf_routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgage_assets`
--

DROP TABLE IF EXISTS `mortgage_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgage_assets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mortgage_id` bigint unsigned NOT NULL,
  `asset_type` enum('land','house','vehicle','gold','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ownership_type` enum('single','joint') COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `deed_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deed_date` date DEFAULT NULL,
  `survey_plan_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registration_office` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `land_size_or_area` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_reg_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `engine_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `chassis_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgage_assets_created_by_foreign` (`created_by`),
  KEY `mortgage_assets_mortgage_id_index` (`mortgage_id`),
  CONSTRAINT `mortgage_assets_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `mortgage_assets_mortgage_id_foreign` FOREIGN KEY (`mortgage_id`) REFERENCES `mortgages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgage_assets`
--

LOCK TABLES `mortgage_assets` WRITE;
/*!40000 ALTER TABLE `mortgage_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgage_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgage_documents`
--

DROP TABLE IF EXISTS `mortgage_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgage_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mortgage_id` bigint unsigned NOT NULL,
  `document_type` enum('deed','valuation','agreement','insurance','nic','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgage_documents_uploaded_by_foreign` (`uploaded_by`),
  KEY `mortgage_documents_mortgage_id_index` (`mortgage_id`),
  CONSTRAINT `mortgage_documents_mortgage_id_foreign` FOREIGN KEY (`mortgage_id`) REFERENCES `mortgages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mortgage_documents_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgage_documents`
--

LOCK TABLES `mortgage_documents` WRITE;
/*!40000 ALTER TABLE `mortgage_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgage_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgage_guarantors`
--

DROP TABLE IF EXISTS `mortgage_guarantors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgage_guarantors` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mortgage_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nic` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `relationship` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `income` decimal(12,2) DEFAULT NULL,
  `contact_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgage_guarantors_mortgage_id_index` (`mortgage_id`),
  CONSTRAINT `mortgage_guarantors_mortgage_id_foreign` FOREIGN KEY (`mortgage_id`) REFERENCES `mortgages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgage_guarantors`
--

LOCK TABLES `mortgage_guarantors` WRITE;
/*!40000 ALTER TABLE `mortgage_guarantors` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgage_guarantors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgage_payments`
--

DROP TABLE IF EXISTS `mortgage_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgage_payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mortgage_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned DEFAULT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `schedule_id` bigint unsigned DEFAULT NULL,
  `paid_date` date NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `interest_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `principal_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `profit_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `outstanding_principal_after` decimal(15,2) NOT NULL DEFAULT '0.00',
  `payment_method` enum('cash','bank','transfer','cheque') COLLATE utf8mb4_unicode_ci NOT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `collected_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgage_payments_schedule_id_foreign` (`schedule_id`),
  KEY `mortgage_payments_collected_by_foreign` (`collected_by`),
  KEY `mortgage_payments_mortgage_id_index` (`mortgage_id`),
  KEY `mortgage_payments_paid_date_index` (`paid_date`),
  CONSTRAINT `mortgage_payments_collected_by_foreign` FOREIGN KEY (`collected_by`) REFERENCES `users` (`id`),
  CONSTRAINT `mortgage_payments_mortgage_id_foreign` FOREIGN KEY (`mortgage_id`) REFERENCES `mortgages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mortgage_payments_schedule_id_foreign` FOREIGN KEY (`schedule_id`) REFERENCES `mortgage_schedules` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgage_payments`
--

LOCK TABLES `mortgage_payments` WRITE;
/*!40000 ALTER TABLE `mortgage_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgage_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgage_schedules`
--

DROP TABLE IF EXISTS `mortgage_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgage_schedules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mortgage_id` bigint unsigned NOT NULL,
  `installment_no` int NOT NULL,
  `due_date` date NOT NULL,
  `principal` decimal(15,2) NOT NULL,
  `interest` decimal(15,2) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('pending','paid','overdue','partially_paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgage_schedules_mortgage_id_index` (`mortgage_id`),
  KEY `mortgage_schedules_due_date_index` (`due_date`),
  KEY `mortgage_schedules_status_index` (`status`),
  CONSTRAINT `mortgage_schedules_mortgage_id_foreign` FOREIGN KEY (`mortgage_id`) REFERENCES `mortgages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgage_schedules`
--

LOCK TABLES `mortgage_schedules` WRITE;
/*!40000 ALTER TABLE `mortgage_schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgage_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgage_valuations`
--

DROP TABLE IF EXISTS `mortgage_valuations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgage_valuations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mortgage_id` bigint unsigned NOT NULL,
  `market_value` decimal(15,2) DEFAULT NULL,
  `forced_sale_value` decimal(15,2) DEFAULT NULL,
  `valuation_date` date DEFAULT NULL,
  `valuer_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgage_valuations_mortgage_id_index` (`mortgage_id`),
  CONSTRAINT `mortgage_valuations_mortgage_id_foreign` FOREIGN KEY (`mortgage_id`) REFERENCES `mortgages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgage_valuations`
--

LOCK TABLES `mortgage_valuations` WRITE;
/*!40000 ALTER TABLE `mortgage_valuations` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgage_valuations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mortgages`
--

DROP TABLE IF EXISTS `mortgages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mortgages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `mortgage_type` enum('land','house','vehicle','gold','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_amount` decimal(15,2) NOT NULL,
  `approved_amount` decimal(15,2) DEFAULT NULL,
  `interest_rate` decimal(5,2) NOT NULL,
  `interest_type` enum('fixed','reducing') COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenure_months` int NOT NULL,
  `installment_frequency` enum('daily','weekly','monthly','quarterly','yearly') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `interest_calculation_frequency` enum('daily','weekly','monthly','yearly') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `installment_amount` decimal(15,2) DEFAULT NULL,
  `penalty_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
  `processing_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `insurance_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('draft','submitted','approved','active','arrears','settled','released') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `approved_by` bigint unsigned DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `arrears_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `due_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `due_interest_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mortgages_branch_id_foreign` (`branch_id`),
  KEY `mortgages_approved_by_foreign` (`approved_by`),
  KEY `mortgages_created_by_foreign` (`created_by`),
  KEY `mortgages_tenant_id_branch_id_index` (`tenant_id`,`branch_id`),
  KEY `mortgages_customer_id_index` (`customer_id`),
  KEY `mortgages_status_index` (`status`),
  CONSTRAINT `mortgages_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `mortgages_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `mortgages_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `mortgages_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mortgages`
--

LOCK TABLES `mortgages` WRITE;
/*!40000 ALTER TABLE `mortgages` DISABLE KEYS */;
/*!40000 ALTER TABLE `mortgages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payrolls`
--

DROP TABLE IF EXISTS `payrolls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payrolls` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `month_year` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `basic_salary` decimal(10,2) NOT NULL,
  `allowances` decimal(10,2) NOT NULL DEFAULT '0.00',
  `deductions` decimal(10,2) NOT NULL DEFAULT '0.00',
  `net_salary` decimal(10,2) NOT NULL,
  `working_days` int NOT NULL,
  `present_days` int NOT NULL,
  `absent_days` int NOT NULL,
  `overtime_hours` decimal(5,2) NOT NULL DEFAULT '0.00',
  `overtime_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('pending','processed','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `processed_at` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payrolls_employee_id_month_year_unique` (`employee_id`,`month_year`),
  KEY `payrolls_tenant_id_foreign` (`tenant_id`),
  KEY `payrolls_branch_id_foreign` (`branch_id`),
  CONSTRAINT `payrolls_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `payrolls_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  CONSTRAINT `payrolls_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payrolls`
--

LOCK TABLES `payrolls` WRITE;
/*!40000 ALTER TABLE `payrolls` DISABLE KEYS */;
/*!40000 ALTER TABLE `payrolls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'credit_general_route_collection','Credit','Route Collection | Route: /dashboard/microfinance/collections',1,'2026-06-23 01:47:08','2026-06-23 01:47:08'),(2,'credit_general_loan_management','Credit','Loan Management | Route: /dashboard/loan',1,'2026-06-23 01:47:18','2026-06-23 01:47:18'),(3,'credit_general_new_loan_request','Credit','New Loan Request | Route: /dashboard/loan/request',1,'2026-06-23 01:47:18','2026-06-23 01:47:18'),(4,'credit_general_loan_request_view','Credit','Loan Request View | Route: /dashboard/loan/requests',1,'2026-06-23 01:47:19','2026-06-23 01:47:19'),(5,'credit_general_request_queue','Credit','Request Queue | Route: /dashboard/loan/requests',1,'2026-06-23 01:47:19','2026-06-23 01:47:19'),(6,'credit_general_credit_module','Credit','Credit Module | Route: /dashboard/credit',1,'2026-06-23 01:47:19','2026-06-23 01:47:19'),(7,'credit_general_finance_management','Credit','Finance Management | Route: /dashboard/finance',1,'2026-06-23 01:47:19','2026-06-23 01:47:19'),(8,'credit_general_issue_finance','Credit','Issue Finance | Route: /dashboard/finance/issue',1,'2026-06-23 01:47:20','2026-06-23 01:47:20'),(9,'credit_general_approvals','Credit','Approvals | Route: /dashboard/finance/approvals',1,'2026-06-23 01:47:20','2026-06-23 01:47:20'),(10,'credit_general_finance_customer_handling','Credit','Finance Customer Handling | Route: /dashboard/finance/customers',1,'2026-06-23 01:47:20','2026-06-23 01:47:20'),(11,'credit_general_finance_reports','Credit','Finance Reports | Route: /dashboard/finance/reports',1,'2026-06-23 01:47:20','2026-06-23 01:47:20'),(12,'credit_general_finance_collection','Credit','Finance Collection | Route: /dashboard/finance/collections',1,'2026-06-23 01:47:21','2026-06-23 01:47:21'),(13,'credit_general_microfinance','Credit','Microfinance | Route: /dashboard/microfinance',1,'2026-06-23 01:47:21','2026-06-23 01:47:21'),(14,'credit_general_request_loan','Credit','Request Loan | Route: /dashboard/microfinance/loans/request',1,'2026-06-23 01:47:21','2026-06-23 01:47:21'),(15,'credit_general_loan_approvals','Credit','Loan Approvals | Route: /dashboard/microfinance/loans/approvals',1,'2026-06-23 01:47:21','2026-06-23 01:47:21'),(16,'credit_general_view_related_loans','Credit','View Related Loans | Route: /dashboard/microfinance/loans/released',1,'2026-06-23 01:47:21','2026-06-23 01:47:21'),(17,'credit_general_collection_management','Credit','Collection Management | Route: /dashboard/microfinance/collections',1,'2026-06-23 01:47:22','2026-06-23 01:47:22'),(18,'credit_general_center_collection','Credit','Center Collection | Route: /dashboard/microfinance/collections',1,'2026-06-23 01:47:22','2026-06-23 01:47:22'),(19,'credit_general_office_collection','Credit','Office Collection | Route: /dashboard/microfinance/collections',1,'2026-06-23 01:47:22','2026-06-23 01:47:22'),(20,'credit_general_payments_view','Credit','Payments View | Route: /dashboard/microfinance/payments',1,'2026-06-23 01:47:23','2026-06-23 01:47:23'),(21,'credit_general_microfinance_customers','Credit','Microfinance Customers | Route: /dashboard/microfinance/customers',1,'2026-06-23 01:47:23','2026-06-23 01:47:23'),(22,'credit_general_summary_report_workspace','Credit','Summary Report Workspace | Route: /dashboard/microfinance',1,'2026-06-23 01:47:23','2026-06-23 01:47:23'),(23,'credit_general_summary_report_total_outstanding_amount','Credit','Summary Report Total Outstanding Amount | Route: /dashboard/microfinance',1,'2026-06-23 01:47:23','2026-06-23 01:47:23'),(24,'credit_general_summary_report_today_collection','Credit','Summary Report Today Collection | Route: /dashboard/microfinance',1,'2026-06-23 01:47:23','2026-06-23 01:47:23'),(25,'credit_general_summary_report_asset_value_total','Credit','Summary Report Asset Value Total | Route: /dashboard/microfinance',1,'2026-06-23 01:47:24','2026-06-23 01:47:24'),(26,'credit_general_summary_report_month_collection','Credit','Summary Report Month Collection | Route: /dashboard/microfinance',1,'2026-06-23 01:47:24','2026-06-23 01:47:24'),(27,'credit_general_summary_report_imagine_profit','Credit','Summary Report Imagine Profit | Route: /dashboard/microfinance',1,'2026-06-23 01:47:24','2026-06-23 01:47:24'),(28,'credit_general_summary_report_today_profit','Credit','Summary Report Today Profit | Route: /dashboard/microfinance',1,'2026-06-23 01:47:24','2026-06-23 01:47:24'),(29,'credit_general_summary_report_month_profit','Credit','Summary Report Month Profit | Route: /dashboard/microfinance',1,'2026-06-23 01:47:25','2026-06-23 01:47:25'),(30,'credit_general_settings_workspace','Credit','Settings Workspace | Route: /dashboard/microfinance/settings',1,'2026-06-23 01:47:25','2026-06-23 01:47:25'),(31,'credit_general_create_route','Credit','Create Route | Create Route function',1,'2026-06-23 01:47:25','2026-06-23 01:47:25'),(32,'credit_general_create_center','Credit','Create Center | Create Center function',1,'2026-06-23 01:47:25','2026-06-23 01:47:25'),(33,'credit_general_create_group','Credit','Create Group | Create Group function',1,'2026-06-23 01:47:25','2026-06-23 01:47:25'),(34,'credit_general_mark_holiday','Credit','Mark Holiday | Mark Holiday function',1,'2026-06-23 01:47:26','2026-06-23 01:47:26'),(35,'credit_general_add_initial_penalty_rate','Credit','Add Initial Penalty Rate | Add Initial Penalty Rate function',1,'2026-06-23 01:47:26','2026-06-23 01:47:26'),(36,'credit_general_loan_hold_close_control','Credit','Loan Hold / Close Control',1,'2026-06-23 01:47:26','2026-06-23 01:47:26'),(37,'credit_general_mortgage_management','Credit','Mortgage Management | Route: /dashboard/mortgages',1,'2026-06-23 01:47:26','2026-06-23 01:47:26'),(38,'credit_general_create_mortgage','Credit','Create Mortgage | Route: /dashboard/mortgages/create',1,'2026-06-23 01:47:26','2026-06-23 01:47:26'),(39,'credit_general_mortgage_approvals','Credit','Mortgage Approvals | Route: /dashboard/mortgages/approvals',1,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(40,'credit_general_mortgage_portfolio','Credit','Mortgage Portfolio | Route: /dashboard/mortgages/portfolio',1,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(41,'credit_general_mortgage_reports','Credit','Mortgage Reports | Route: /dashboard/mortgages/reports',1,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(42,'hrm_employee_add_new_employee','HRM','Add New Employee | Route: /dashboard/hrm/employees | Add New Employee Modal',1,'2026-06-23 01:47:42','2026-06-23 01:47:42'),(43,'hrm_employee_edit_employee_details','HRM','Edit Employee Details | Route: /dashboard/hrm/employees | Edit Employee Modal',1,'2026-06-23 01:47:43','2026-06-23 01:47:43'),(44,'hrm_employee_add_education','HRM','Add Education | Route: /dashboard/hrm/employees | Education Modal',1,'2026-06-23 01:47:43','2026-06-23 01:47:43'),(45,'hrm_employee_add_experience','HRM','Add Experience | Route: /dashboard/hrm/employees | Experience Modal',1,'2026-06-23 01:47:43','2026-06-23 01:47:43'),(46,'hrm_employee_add_documents','HRM','Add Documents | Route: /dashboard/hrm/employees | Documents Modal',1,'2026-06-23 01:47:43','2026-06-23 01:47:43'),(47,'hrm_employee_add_allowances','HRM','Add Allowances | Route: /dashboard/hrm/employees | Allowances & Deductions Modal',1,'2026-06-23 01:47:43','2026-06-23 01:47:43'),(48,'hrm_employee_leave_management','HRM','Leave Management | Route: /dashboard/hrm/employees | Leave Management Modal',1,'2026-06-23 01:47:44','2026-06-23 01:47:44'),(49,'hrm_employee_delete_employee','HRM','Delete Employee | Route: /dashboard/hrm/employees | Delete Function',1,'2026-06-23 01:47:44','2026-06-23 01:47:44'),(50,'hrm_department_add_department','HRM','Add Department | Route: /dashboard/hrm/departments',1,'2026-06-23 01:47:44','2026-06-23 01:47:44'),(51,'hrm_department_edit_department','HRM','Edit Department | Route: /dashboard/hrm/departments | Edit Department Modal',1,'2026-06-23 01:47:44','2026-06-23 01:47:44'),(52,'hrm_department_delete_department','HRM','Delete Department | Route: /dashboard/hrm/departments -',1,'2026-06-23 01:47:45','2026-06-23 01:47:45'),(53,'hrm_designation_designation_management_view_delete','HRM','Designation Management (View/Delete) | Route: /dashboard/hrm/designations',1,'2026-06-23 01:47:45','2026-06-23 01:47:45'),(54,'hrm_attendance_attendance_management','HRM','Attendance Management | Route: /dashboard/hrm/attendance',1,'2026-06-23 01:47:45','2026-06-23 01:47:45'),(55,'hrm_leave_new_leave_request','HRM','New Leave Request | Route: /dashboard/hrm/leaves',1,'2026-06-23 01:47:45','2026-06-23 01:47:45'),(56,'hrm_leave_approve_leave','HRM','Approve Leave | Route: /dashboard/hrm/leaves | New Leave Request',1,'2026-06-23 01:47:46','2026-06-23 01:47:46'),(57,'hrm_leave_reject_leave','HRM','Reject Leave | Route: /dashboard/hrm/leaves',1,'2026-06-23 01:47:46','2026-06-23 01:47:46'),(58,'hrm_leave_manage_leave_types','HRM','Manage Leave Types | Route: /dashboard/hrm/leaves',1,'2026-06-23 01:47:46','2026-06-23 01:47:46'),(59,'hrm_leave_delete_leave','HRM','Delete Leave | Route: /dashboard/hrm/leaves',1,'2026-06-23 01:47:46','2026-06-23 01:47:46'),(60,'hrm_leave_edit_leave','HRM','Edit Leave | Route: /dashboard/hrm/leaves',1,'2026-06-23 01:47:46','2026-06-23 01:47:46'),(61,'hrm_roles_designation_privileges_add_new_role','HRM','Add New Role | Route: /dashboard/hrm/roles',1,'2026-06-23 01:47:47','2026-06-23 01:47:47'),(62,'hrm_roles_designation_privileges_delete_role','HRM','Delete Role | Route: /dashboard/hrm/roles',1,'2026-06-23 01:47:47','2026-06-23 01:47:47'),(63,'hrm_roles_designation_privileges_edit_role','HRM','Edit Role | Route: /dashboard/hrm/roles',1,'2026-06-23 01:47:47','2026-06-23 01:47:47'),(64,'hrm_payroll_management_generate_payroll','HRM','Generate Payroll | Route: /dashboard/hrm/payroll',1,'2026-06-23 01:47:47','2026-06-23 01:47:47'),(65,'hrm_candidates_add_candidate','HRM','Add Candidate | Route: /dashboard/hrm/candidates',1,'2026-06-23 01:47:48','2026-06-23 01:47:48'),(66,'hrm_candidates_view_candidate','HRM','View Candidate | Route: /dashboard/hrm/candidates',1,'2026-06-23 01:47:48','2026-06-23 01:47:48'),(67,'hrm_candidates_edit_candidate','HRM','Edit Candidate | Route: /dashboard/hrm/candidates',1,'2026-06-23 01:47:48','2026-06-23 01:47:48'),(68,'hrm_candidates_delete_candidate','HRM','Delete Candidate | Route: /dashboard/hrm/candidates',1,'2026-06-23 01:47:48','2026-06-23 01:47:48'),(69,'savings_deposits_dashboard_savings_deposits_general_manage_accounts','Savings & Deposits - /dashboard/savings-deposits','Manage Accounts | Route: /dashboard/savings-deposits/accounts',1,'2026-06-23 01:47:59','2026-06-23 01:47:59'),(70,'reports_general_micro_finance_related_reports','Reports','Micro Finance Related Reports',1,'2026-06-23 01:47:59','2026-06-23 01:47:59'),(71,'reports_general_collection_report','Reports','Collection Report | Route: /dashboard/microfinance/reports/collection',1,'2026-06-23 01:47:59','2026-06-23 01:47:59'),(72,'reports_general_field_officer_collection_report','Reports','Field Officer Collection Report | Route: /dashboard/microfinance/reports/field-officer-collection',1,'2026-06-23 01:48:00','2026-06-23 01:48:00'),(73,'reports_general_arrears_report','Reports','Arrears Report | Route: /dashboard/microfinance/reports/arrears',1,'2026-06-23 01:48:00','2026-06-23 01:48:00'),(74,'reports_general_active_member_report','Reports','Active Member Report | Route: /dashboard/microfinance/reports/active-members',1,'2026-06-23 01:48:00','2026-06-23 01:48:00'),(75,'reports_general_blacklisted_customer_report','Reports','Blacklisted Customer Report | Route: /dashboard/microfinance/reports/blacklisted-customers',1,'2026-06-23 01:48:00','2026-06-23 01:48:00'),(76,'reports_general_re_payment_report','Reports','Re-Payment Report | Route: /dashboard/microfinance/reports/repayment',1,'2026-06-23 01:48:01','2026-06-23 01:48:01'),(77,'reports_general_recovery_report','Reports','Recovery Report | Route: /dashboard/microfinance/reports/recovery',1,'2026-06-23 01:48:01','2026-06-23 01:48:01'),(78,'reports_general_mortgage_management_related_reports','Reports','Mortgage Management Related Reports',1,'2026-06-23 01:48:01','2026-06-23 01:48:01'),(79,'reports_general_mortgage_collection_report','Reports','Mortgage Collection Report | Route: /dashboard/mortgages/reports/collection',1,'2026-06-23 01:48:02','2026-06-23 01:48:02'),(80,'reports_general_mortgage_arrears_report','Reports','Mortgage Arrears Report | Route: /dashboard/mortgages/reports/arrears',1,'2026-06-23 01:48:02','2026-06-23 01:48:02'),(81,'reports_general_mortgage_portfolio_report','Reports','Mortgage Portfolio Report | Route: /dashboard/mortgages/reports/portfolio',1,'2026-06-23 01:48:02','2026-06-23 01:48:02'),(82,'reports_general_savings_and_deposit_related_reports','Reports','Savings and Deposit Related Reports',1,'2026-06-23 01:48:02','2026-06-23 01:48:02'),(83,'reports_general_savings_ledger_report','Reports','Savings Ledger Report | Route: /dashboard/savings-deposits/reports/ledger',1,'2026-06-23 01:48:02','2026-06-23 01:48:02'),(84,'reports_general_deposit_growth_report','Reports','Deposit Growth Report | Route: /dashboard/savings-deposits/reports/deposit-growth',1,'2026-06-23 01:48:03','2026-06-23 01:48:03'),(85,'reports_general_maturity_report','Reports','Maturity Report | Route: /dashboard/savings-deposits/reports/maturity',1,'2026-06-23 01:48:03','2026-06-23 01:48:03'),(86,'reports_general_finance_management_related_reports','Reports','Finance Management Related Reports',1,'2026-06-23 01:48:03','2026-06-23 01:48:03'),(87,'reports_general_income_and_expense_report','Reports','Income and Expense Report | Route: /dashboard/finance/reports/income-expense',1,'2026-06-23 01:48:03','2026-06-23 01:48:03'),(88,'reports_general_cash_flow_report','Reports','Cash Flow Report | Route: /dashboard/mortgages/reports/arrears',1,'2026-06-23 01:48:04','2026-06-23 01:48:04'),(89,'reports_general_general_ledger_snapshot','Reports','General Ledger Snapshot | Route: /dashboard/finance/reports/general-ledger',1,'2026-06-23 01:48:04','2026-06-23 01:48:04'),(90,'reports_general_branch_management_related_reports','Reports','Branch Management Related Reports',1,'2026-06-23 01:48:04','2026-06-23 01:48:04'),(91,'reports_general_branch_performance_report','Reports','Branch Performance Report',1,'2026-06-23 01:48:04','2026-06-23 01:48:04'),(92,'reports_general_branch_collection_report','Reports','Branch Collection Report',1,'2026-06-23 01:48:05','2026-06-23 01:48:05'),(93,'reports_general_branch_staff_productivity_report','Reports','Branch Staff Productivity Report',1,'2026-06-23 01:48:05','2026-06-23 01:48:05'),(94,'credit_summary_report_workspace_summary_report_total_outstanding_amount','Credit','Summary Report Total Outstanding Amount | Route: /dashboard/microfinance',1,'2026-06-23 01:48:06','2026-06-23 01:48:06'),(95,'credit_summary_report_workspace_summary_report_today_collection','Credit','Summary Report Today Collection | Route: /dashboard/microfinance',1,'2026-06-23 01:48:06','2026-06-23 01:48:06'),(96,'credit_summary_report_workspace_summary_report_asset_value_total','Credit','Summary Report Asset Value Total | Route: /dashboard/microfinance',1,'2026-06-23 01:48:06','2026-06-23 01:48:06'),(97,'credit_summary_report_workspace_summary_report_month_collection','Credit','Summary Report Month Collection | Route: /dashboard/microfinance',1,'2026-06-23 01:48:07','2026-06-23 01:48:07'),(98,'credit_summary_report_workspace_summary_report_imagine_profit','Credit','Summary Report Imagine Profit | Route: /dashboard/microfinance',1,'2026-06-23 01:48:07','2026-06-23 01:48:07'),(99,'credit_summary_report_workspace_summary_report_today_profit','Credit','Summary Report Today Profit | Route: /dashboard/microfinance',1,'2026-06-23 01:48:07','2026-06-23 01:48:07'),(100,'credit_summary_report_workspace_summary_report_month_profit','Credit','Summary Report Month Profit | Route: /dashboard/microfinance',1,'2026-06-23 01:48:08','2026-06-23 01:48:08');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'API Token','fcaeb86c157d4699a56372ea3f5145a014e83cd17de1e66fb911a82717f3d204','[\"*\"]','2026-06-17 03:31:34',NULL,'2026-06-17 03:30:57','2026-06-17 03:31:34'),(2,'App\\Models\\User',2,'API Token','89f3c0599c8f4bd9d6d24fb0b8a90244008c626c156905fcd372f1611b7b5521','[\"*\"]','2026-06-19 00:15:06',NULL,'2026-06-19 00:12:42','2026-06-19 00:15:06'),(3,'App\\Models\\User',3,'API Token','e461f1a285fa3a12a3ebf536b87cb4e474dd80c17c9112d6a0f9927a2c301d9f','[\"*\"]','2026-06-19 00:15:12',NULL,'2026-06-19 00:15:12','2026-06-19 00:15:12'),(4,'App\\Models\\User',2,'API Token','a5b05b76b16581c4ca5ac548626715ff8da8162f4db71a0979e494f334f67f33','[\"*\"]','2026-06-19 00:15:51',NULL,'2026-06-19 00:15:38','2026-06-19 00:15:51'),(5,'App\\Models\\User',1,'API Token','9bca8854173fef1b2b9c3ae26a6b01230b27f82e9df639391088ddc8f9e27db3','[\"*\"]','2026-06-19 01:35:05',NULL,'2026-06-19 01:35:04','2026-06-19 01:35:05'),(6,'App\\Models\\User',2,'API Token','1c3128eb3740bb0485df65a3936a943ce2b3b0501d1cfb655fb5b5ef5d7385e0','[\"*\"]','2026-06-19 01:41:01',NULL,'2026-06-19 01:35:17','2026-06-19 01:41:01'),(7,'App\\Models\\User',2,'API Token','97a42fddf5d79ec19b10447da04ae2db377134af03f9d606d00ee059b55da835','[\"*\"]','2026-06-22 03:36:58',NULL,'2026-06-22 03:35:39','2026-06-22 03:36:58'),(8,'App\\Models\\User',2,'API Token','81457d11675c6dadd0e8c34fc2341fa2cd005bd2ab555f8277982bc653135334','[\"*\"]','2026-06-23 03:05:21',NULL,'2026-06-23 01:42:52','2026-06-23 03:05:21'),(9,'App\\Models\\User',5,'API Token','03d153b7ef0cb7ec652fdad27b5641d04d50294f4166676fab045d48d5fae672','[\"*\"]','2026-06-23 02:33:28',NULL,'2026-06-23 02:18:08','2026-06-23 02:33:28'),(10,'App\\Models\\User',3,'API Token','7d8e7dd4e8ec6aca69f539a0bd33c737b3d24d8c46be7f4636b200588dcd0745','[\"*\"]','2026-06-23 02:31:14',NULL,'2026-06-23 02:26:57','2026-06-23 02:31:14'),(11,'App\\Models\\User',6,'API Token','d50550b1a99838ce6f15b3a021f5a9c27f955ed78c486137cb2914bbb9636fff','[\"*\"]','2026-06-23 02:40:51',NULL,'2026-06-23 02:33:40','2026-06-23 02:40:51'),(12,'App\\Models\\User',5,'API Token','ae16430a8c9c38462856a005f43d70b443de57c45049ae1a98b74acb1e161ca4','[\"*\"]','2026-06-23 03:09:36',NULL,'2026-06-23 03:08:38','2026-06-23 03:09:36'),(13,'App\\Models\\User',7,'API Token','6a036f9f2441db0daa61ebb8c9b97626af14b6ddfb368e4458cf22acd6b0426b','[\"*\"]','2026-06-23 03:11:31',NULL,'2026-06-23 03:11:29','2026-06-23 03:11:31'),(14,'App\\Models\\User',1,'API Token','e6d4bb0b2aaa18e57d363410991270de105063216f39db99fbab2efedd54a528','[\"*\"]','2026-06-23 03:16:42',NULL,'2026-06-23 03:11:41','2026-06-23 03:16:42'),(15,'App\\Models\\User',7,'API Token','5fa97fca597129e052261d3c882113e8cde450d9b9e5b767eac31efaf0ec5c8a','[\"*\"]','2026-06-23 03:17:00',NULL,'2026-06-23 03:16:48','2026-06-23 03:17:00'),(16,'App\\Models\\User',5,'API Token','63db37b10f64d6a5deedaeb45458434af845c808b8e7fce3433ac53af21105b5','[\"*\"]','2026-06-24 07:06:35',NULL,'2026-06-24 06:59:13','2026-06-24 07:06:35'),(17,'App\\Models\\User',5,'API Token','ac2f7c77428298d6f53d8d3ee17719400b735fcb3929f8546a0c709b9094248a','[\"*\"]','2026-06-24 07:04:12',NULL,'2026-06-24 07:00:39','2026-06-24 07:04:12'),(18,'App\\Models\\User',6,'API Token','a16bcc7d316cd45013971978a96c61eb8bbbfd902463c5d10c9aa45327950113','[\"*\"]','2026-06-24 07:13:48',NULL,'2026-06-24 07:06:45','2026-06-24 07:13:48'),(19,'App\\Models\\User',7,'API Token','57766bb27a465c8871072c3809b106e2ec0388c91d47c9ce5a58038eb428a2ec','[\"*\"]','2026-06-24 10:23:09',NULL,'2026-06-24 10:22:40','2026-06-24 10:23:09'),(20,'App\\Models\\User',1,'API Token','a8d1488a095eb42ae3394678f70bb237a636db5406caa0b26a9a4dfdec093cc1','[\"*\"]','2026-06-24 10:24:28',NULL,'2026-06-24 10:23:29','2026-06-24 10:24:28'),(21,'App\\Models\\User',7,'API Token','d3e0970a291aac97ca9dd54b4c1e6229a6e899522c0f3bf35725ad755a9ed7dc','[\"*\"]','2026-06-25 06:58:30',NULL,'2026-06-25 06:47:45','2026-06-25 06:58:30'),(22,'App\\Models\\User',1,'API Token','1aed01c51250e47d839a4b95131015981c89d8b5a794eb846b22d050672661b4','[\"*\"]','2026-06-25 07:08:27',NULL,'2026-06-25 06:58:35','2026-06-25 07:08:27'),(23,'App\\Models\\User',1,'API Token','690a2795a77f3bd9fb95994b27cea6789e28bf5f55fb7773c95882ed97a2957f','[\"*\"]','2026-06-25 07:41:54',NULL,'2026-06-25 07:31:42','2026-06-25 07:41:54'),(24,'App\\Models\\User',6,'API Token','2b3be1cfe4362c0ed77626663d3f39cd8cf9d940caf7d3f63ee20850d3ef24a6','[\"*\"]','2026-06-25 07:47:13',NULL,'2026-06-25 07:41:59','2026-06-25 07:47:13'),(25,'App\\Models\\User',7,'API Token','9528f795def4ea0bca20de3f649089a0edd3df94c21604951fcd275f04e7f7a0','[\"*\"]','2026-06-25 07:48:53',NULL,'2026-06-25 07:47:19','2026-06-25 07:48:53'),(26,'App\\Models\\User',5,'API Token','16cc1ecd8fed0215f12ed4b60c2ab451a1c8d9f152ea8d58c9bdafcfa9a9e9b4','[\"*\"]','2026-06-26 07:07:40',NULL,'2026-06-26 06:59:17','2026-06-26 07:07:40'),(27,'App\\Models\\User',1,'API Token','e65c0f24d1c999e409ad6f17c6df9d0fa5793a2595bc8cf8102f24f4fbd36b98','[\"*\"]','2026-06-26 07:08:02',NULL,'2026-06-26 07:07:48','2026-06-26 07:08:02'),(28,'App\\Models\\User',1,'API Token','3f4793046adec1f11284ad49a17dace26cffe6c694a23254bd8c82b03d519a0a','[\"*\"]','2026-06-26 07:17:54',NULL,'2026-06-26 07:10:30','2026-06-26 07:17:54'),(29,'App\\Models\\User',1,'API Token','6bc44808351e04046eda60584f0dce54a6ca2ce6fa214e7b674506c282829acc','[\"*\"]','2026-06-27 10:38:08',NULL,'2026-06-27 06:55:06','2026-06-27 10:38:08'),(30,'App\\Models\\User',5,'API Token','882839dd1bf92a29fabe0794b67d82f10a0afb84fa610e594adffe21de3cd196','[\"*\"]','2026-07-01 23:20:52',NULL,'2026-07-01 23:19:48','2026-07-01 23:20:52'),(31,'App\\Models\\User',5,'API Token','8d910cdd9140a985b0796dec5646056c64b834d580d8a6cf38e7e52fb29ae106','[\"*\"]','2026-07-04 00:34:32',NULL,'2026-07-04 00:03:00','2026-07-04 00:34:32'),(32,'App\\Models\\User',1,'API Token','709f416bd1845b18697a5c06f07eb05534a47433a7181aef35a73e8f8685529d','[\"*\"]','2026-07-04 01:34:22',NULL,'2026-07-04 00:13:26','2026-07-04 01:34:22'),(33,'App\\Models\\User',6,'API Token','2715000075d991f5fff80e9a91f3c385086f85d78eec8bbbdcddb17c87b92c3f','[\"*\"]','2026-07-04 00:51:35',NULL,'2026-07-04 00:34:37','2026-07-04 00:51:35'),(34,'App\\Models\\User',5,'API Token','975fde1ed4b30f33e2c25b2bf49ee7b5f0ad628e6e223a29e3fbf420a132779e','[\"*\"]','2026-07-04 00:52:46',NULL,'2026-07-04 00:51:40','2026-07-04 00:52:46'),(35,'App\\Models\\User',6,'API Token','3fd0431e4f4926f70912d15be020a61ac3b3f19fe5f70c36263ec0e65b0569fd','[\"*\"]','2026-07-04 00:56:36',NULL,'2026-07-04 00:52:52','2026-07-04 00:56:36'),(36,'App\\Models\\User',5,'API Token','7f2bbc5f2c964b51519f1d526c23f02f6c1b46bb9d74e68f810e26799730018c','[\"*\"]','2026-07-04 01:14:43',NULL,'2026-07-04 01:08:29','2026-07-04 01:14:43'),(37,'App\\Models\\User',5,'API Token','c9d32e4095f7fae25cabb24bf0efbd52511bd395e8384f7104964fedaead2a91','[\"*\"]','2026-07-04 01:16:51',NULL,'2026-07-04 01:16:21','2026-07-04 01:16:51'),(38,'App\\Models\\User',5,'API Token','c9aba0f7bd9eb5c90a2ab059c42ae89ba84cc37c6326a0ebe251ea6b30a8d717','[\"*\"]','2026-07-04 01:34:29',NULL,'2026-07-04 01:28:04','2026-07-04 01:34:29'),(39,'App\\Models\\User',5,'API Token','caa3e35d4559852d00f16a67e6a2b33cfef946d15f025f3ea97c6388ce5e0a3f','[\"*\"]','2026-07-04 01:53:38',NULL,'2026-07-04 01:34:37','2026-07-04 01:53:38'),(40,'App\\Models\\User',7,'API Token','5c7ac645b052bccf73b1793f5c465c8d552add96add0fbec531838a7ae1c5bc4','[\"*\"]','2026-07-04 02:13:20',NULL,'2026-07-04 01:35:04','2026-07-04 02:13:20'),(41,'App\\Models\\User',6,'API Token','efb945b0c453b1ffbb9f9a3019b699a0a1119b6ce061bc4011d7fa1b67f73d38','[\"*\"]','2026-07-04 02:00:25',NULL,'2026-07-04 01:53:41','2026-07-04 02:00:25'),(42,'App\\Models\\User',6,'API Token','98a2dd090566d6265bba8c318284fe11c7f652aa67dd35cc6257ddda839b8b83','[\"*\"]','2026-07-04 02:16:22',NULL,'2026-07-04 02:00:28','2026-07-04 02:16:22'),(43,'App\\Models\\User',1,'API Token','c629045da81b0cb3663f46d92cecd799c6ec52026bde40c8d42b5e0410830a00','[\"*\"]','2026-07-04 02:15:52',NULL,'2026-07-04 02:13:34','2026-07-04 02:15:52'),(44,'App\\Models\\User',1,'API Token','83a8b95df92482c16f76046b57a69865b9bf32569fb1c9272dfeb11a0ea82c52','[\"*\"]','2026-07-04 13:46:30',NULL,'2026-07-04 13:43:21','2026-07-04 13:46:30'),(45,'App\\Models\\User',1,'API Token','7202a0ea7e95f2536a4e2adf92803055f6f0dae499207b005b7ca06e27a5758a','[\"*\"]','2026-07-09 03:36:33',NULL,'2026-07-09 03:36:13','2026-07-09 03:36:33'),(46,'App\\Models\\User',1,'API Token','7683e04f18a4d284d2dcc9024fb57cb668e6aa85688580d49f86fee13cb569cb','[\"*\"]','2026-07-12 06:58:02',NULL,'2026-07-12 06:55:51','2026-07-12 06:58:02'),(47,'App\\Models\\User',1,'API Token','cdf702a1f36b8cdd401e494d596a154c8c2036499ef23e4409564692d2fcf7bf','[\"*\"]','2026-07-14 03:49:30',NULL,'2026-07-14 03:49:17','2026-07-14 03:49:30'),(48,'App\\Models\\User',7,'API Token','9090f08eb720b175674c4de3794375ab28d899a7ab13e7ad886d4df66ff2b464','[\"*\"]','2026-07-15 01:14:36',NULL,'2026-07-15 01:14:26','2026-07-15 01:14:36'),(49,'App\\Models\\User',1,'API Token','3c4168dca0a966f6ee78df6d905c667176f50d764256d2712d38e917305929de','[\"*\"]','2026-07-15 02:06:49',NULL,'2026-07-15 01:14:54','2026-07-15 02:06:49'),(50,'App\\Models\\User',5,'API Token','170acea1accca5054f50e58a2446d233a300617944beffdd66a69663c8d1287e','[\"*\"]','2026-07-15 01:37:41',NULL,'2026-07-15 01:27:28','2026-07-15 01:37:41'),(51,'App\\Models\\User',5,'API Token','979633a792d65cc6bc0074bff3c9724aa8843222865dbc12aee5942c837c63e6','[\"*\"]','2026-07-15 01:44:23',NULL,'2026-07-15 01:37:46','2026-07-15 01:44:23'),(52,'App\\Models\\User',6,'API Token','adca294e45019f9a61ea5f6dcbcaa3c77eaa762272d4d8b5391e4588ae679218','[\"*\"]','2026-07-15 02:01:26',NULL,'2026-07-15 01:44:27','2026-07-15 02:01:26'),(53,'App\\Models\\User',5,'API Token','d882394ff8fe42672944ff5f8b15808ea1f7b9f02277795f775b64110bd98eb7','[\"*\"]','2026-07-15 02:21:27',NULL,'2026-07-15 02:01:30','2026-07-15 02:21:27'),(54,'App\\Models\\User',1,'API Token','1f4db8ca44461d11f1c2cc0e92288649023a7d293bf158d9af4e162f82597965','[\"*\"]','2026-07-15 02:14:41',NULL,'2026-07-15 02:06:55','2026-07-15 02:14:41'),(55,'App\\Models\\User',7,'API Token','92c09ca5ff2c8c65a81009d3858451279dad742b928118dc6db44f513dd07e82','[\"*\"]','2026-07-15 02:15:16',NULL,'2026-07-15 02:14:45','2026-07-15 02:15:16'),(56,'App\\Models\\User',1,'API Token','923e50f92dc38657be6f33c9fde35cce2272add97dbf5642d5098fb82ec177bb','[\"*\"]','2026-07-15 02:23:43',NULL,'2026-07-15 02:15:28','2026-07-15 02:23:43'),(57,'App\\Models\\User',1,'API Token','68e6758564f2de3985063045af1be26dc91e0ac9e7578a328e5dedc3c2f9f4d4','[\"*\"]','2026-07-15 02:35:12',NULL,'2026-07-15 02:21:31','2026-07-15 02:35:12'),(58,'App\\Models\\User',8,'API Token','d01cfd8af9bbaf1ea3f99aea92388c041ee3ae3f7298140010a27b3bf2312619','[\"*\"]','2026-07-15 02:24:09',NULL,'2026-07-15 02:23:56','2026-07-15 02:24:09'),(59,'App\\Models\\User',1,'API Token','ae1b3add2798c9a960e85a08acd5d877d577cc41bae582436d320705366d3431','[\"*\"]','2026-07-15 05:55:41',NULL,'2026-07-15 02:29:04','2026-07-15 05:55:41'),(60,'App\\Models\\User',5,'API Token','2826e4a6252db928af7fc0cb25437653ff5d8c6038cbb286eef2381dba40ea78','[\"*\"]','2026-07-15 02:35:46',NULL,'2026-07-15 02:35:19','2026-07-15 02:35:46'),(61,'App\\Models\\User',6,'API Token','804c60fde703bbdd317a0173dfe63df211f69937a6a2e28b3891a6814b5e7d34','[\"*\"]','2026-07-15 05:42:25',NULL,'2026-07-15 02:39:36','2026-07-15 05:42:25'),(62,'App\\Models\\User',5,'API Token','4f30e770037a2448b3c9e37609b6a01195ce9c18996d61fdd938b20937f56922','[\"*\"]','2026-07-15 04:11:12',NULL,'2026-07-15 04:10:30','2026-07-15 04:11:12'),(63,'App\\Models\\User',5,'API Token','ebb661994eaa93a0133660f2fee8bc94eb48e540841e797a1ad8b0f793e10959','[\"*\"]','2026-07-15 05:42:57',NULL,'2026-07-15 05:42:29','2026-07-15 05:42:57'),(64,'App\\Models\\User',8,'API Token','6f4fa3ed3049cf106152ef99236e1302c5336e386104e7c925151b240978ac9e','[\"*\"]','2026-07-17 01:52:27',NULL,'2026-07-17 00:47:50','2026-07-17 01:52:27'),(65,'App\\Models\\User',5,'API Token','54f233f47a1ed235da2721992d9cb3423c4797640f915ce9ba1ca49e1f896a86','[\"*\"]','2026-07-17 01:09:02',NULL,'2026-07-17 01:02:37','2026-07-17 01:09:02'),(66,'App\\Models\\User',1,'API Token','97e4ba737e4128ebaacb12df1987bdf4922b7f61f6be2b229f7d7f3df2cb954c','[\"*\"]','2026-07-17 01:47:46',NULL,'2026-07-17 01:09:10','2026-07-17 01:47:46'),(67,'App\\Models\\User',5,'API Token','55a301f09adfae0aa9565753d15c4d7f6293733fc1be09944747b9af599ed536','[\"*\"]','2026-07-17 01:47:56',NULL,'2026-07-17 01:47:50','2026-07-17 01:47:56'),(68,'App\\Models\\User',1,'API Token','ce1e6190df7b00456818814d95fb06415acea364ea309d0c27801f3eff3ae229','[\"*\"]','2026-07-17 23:44:46',NULL,'2026-07-17 23:33:36','2026-07-17 23:44:46'),(69,'App\\Models\\User',6,'API Token','b7d40856e226392d2fa314222565d18f06fe840edd553c3c61229d34669e741a','[\"*\"]','2026-07-17 23:47:59',NULL,'2026-07-17 23:44:53','2026-07-17 23:47:59'),(70,'App\\Models\\User',5,'API Token','8b17c558dab160840fe346476b03b462b3720e873c9223cdd8f43b1f779775c0','[\"*\"]','2026-07-17 23:51:03',NULL,'2026-07-17 23:48:07','2026-07-17 23:51:03'),(71,'App\\Models\\User',5,'API Token','c4450f4eae21d91f93045740879481cc8b6f51b16d6f3fc0b7c16bdb12778535','[\"*\"]','2026-07-17 23:59:39',NULL,'2026-07-17 23:55:50','2026-07-17 23:59:39'),(72,'App\\Models\\User',6,'API Token','017c6a97bb1102ca54560292dfa3813b8a981464a5e1277da8f9a89eaffc3268','[\"*\"]','2026-07-18 01:39:42',NULL,'2026-07-18 01:30:55','2026-07-18 01:39:42'),(73,'App\\Models\\User',8,'API Token','549e8930c58fb6495740707aa43d96c0e42664d6ce1299ed5dc83a5093645684','[\"*\"]','2026-07-18 01:55:55',NULL,'2026-07-18 01:34:21','2026-07-18 01:55:55'),(74,'App\\Models\\User',5,'API Token','32a48b7b7beae18f3724749f097e6da4a679c7a85a82b4d65a6f9cb12f057aca','[\"*\"]','2026-07-18 01:40:13',NULL,'2026-07-18 01:39:47','2026-07-18 01:40:13'),(75,'App\\Models\\User',6,'API Token','36821c02812cf08fde7135602f0f99f00d221271a71f0a30858369cd76468fb7','[\"*\"]','2026-07-18 01:40:53',NULL,'2026-07-18 01:40:19','2026-07-18 01:40:53'),(76,'App\\Models\\User',1,'API Token','404b0677ad152153ccda3421e193138ca37acb41f63de80acc0d33f367f03e51','[\"*\"]','2026-07-18 05:59:02',NULL,'2026-07-18 01:41:01','2026-07-18 05:59:02'),(77,'App\\Models\\User',1,'API Token','31e3abab25ccc5143c12c2c0c70065a58803e3f53e30a65be429fe69e0d47080','[\"*\"]','2026-07-18 23:52:30',NULL,'2026-07-18 23:49:09','2026-07-18 23:52:30'),(78,'App\\Models\\User',5,'API Token','2be1a7f3f80185cd162831e6610b857a0d5eba62f5136538b910996b534cd8bd','[\"*\"]','2026-07-18 23:59:32',NULL,'2026-07-18 23:52:35','2026-07-18 23:59:32'),(79,'App\\Models\\User',6,'API Token','c2427489b8d4d85ecfa5a5677ec5153201501bac96e1053c7bf0e065debf395a','[\"*\"]','2026-07-19 00:02:13',NULL,'2026-07-18 23:59:48','2026-07-19 00:02:13'),(80,'App\\Models\\User',1,'API Token','c0e58eff9972d5ce04f304933216427ba9461cedce0ffd62b68a94420eef684c','[\"*\"]','2026-07-19 00:04:17',NULL,'2026-07-19 00:02:20','2026-07-19 00:04:17'),(81,'App\\Models\\User',5,'API Token','dddb0f772fd9cf0d493d0ce74e506630263893cb7dd36348bf5cc4efbbfd8b4e','[\"*\"]','2026-07-20 02:14:01',NULL,'2026-07-20 02:13:20','2026-07-20 02:14:01'),(82,'App\\Models\\User',6,'API Token','511e63bc1ac440181a240870752e6e055ed189a789c1bc741a837699917ed79b','[\"*\"]','2026-07-20 02:14:27',NULL,'2026-07-20 02:14:05','2026-07-20 02:14:27'),(83,'App\\Models\\User',1,'API Token','a2d1cd9f97ebbf7bd383f8a5a052b136698f9d4b2873d8bef68d67e5ba76415d','[\"*\"]','2026-07-20 02:14:42',NULL,'2026-07-20 02:14:42','2026-07-20 02:14:42'),(84,'App\\Models\\User',8,'API Token','980185ff4bb773c34615766b849697e5419686abe2391d5a2f2a481714ed6378','[\"*\"]','2026-07-20 02:17:08',NULL,'2026-07-20 02:16:51','2026-07-20 02:17:08'),(85,'App\\Models\\User',8,'API Token','5d69d4c926e7982dda9b31e970daa2b52f141ee3eb8e37afc3776787c028175c','[\"*\"]','2026-07-21 02:05:57',NULL,'2026-07-21 02:00:43','2026-07-21 02:05:57'),(86,'App\\Models\\User',5,'API Token','76d6ae5a3035b25260092883cf0d234a3733b25728900b4c242f1bcd7cdd16dd','[\"*\"]','2026-07-21 02:06:34',NULL,'2026-07-21 02:06:07','2026-07-21 02:06:34'),(87,'App\\Models\\User',8,'API Token','e32e26d92d360bfeb2176ae54efc191f1277fef623bef62c82ba43756178a786','[\"*\"]','2026-07-21 02:25:54',NULL,'2026-07-21 02:06:43','2026-07-21 02:25:54'),(88,'App\\Models\\User',1,'API Token','ad6b734202c9926936de05b471cd56e22e0357ca4f1beb340752e8d380747fee','[\"*\"]','2026-08-06 00:57:37',NULL,'2026-08-06 00:32:54','2026-08-06 00:57:37'),(89,'App\\Models\\User',8,'API Token','a612cd7db508e3debca5cccddea1d80b572a4adec1d36c9e0d57fa63477de6c2','[\"*\"]','2026-08-11 02:30:28',NULL,'2026-08-11 02:29:50','2026-08-11 02:30:28'),(90,'App\\Models\\User',8,'API Token','24e39a63749ccad7f82f6676d12ccaec8bb7e48877721e285832bbe2df01ab19','[\"*\"]','2026-08-11 02:30:37',NULL,'2026-08-11 02:30:36','2026-08-11 02:30:37'),(91,'App\\Models\\User',6,'API Token','0787350dce465e1c92ce213a42f14dbce6b89e1ba7f91622bbf0a8bc6820c16f','[\"*\"]','2026-08-11 02:30:56',NULL,'2026-08-11 02:30:42','2026-08-11 02:30:56'),(92,'App\\Models\\User',7,'API Token','1830c9f36ca544922a33d354a92d6d7587a0b8445bdeb297cea8313c404a5d94','[\"*\"]','2026-08-23 23:24:25',NULL,'2026-08-23 23:23:40','2026-08-23 23:24:25'),(93,'App\\Models\\User',1,'API Token','2984d71b2d4d5470ddfc4e06b2810313eb4acd314e02cdd421ee5b333e2ea916','[\"*\"]','2026-08-24 23:46:47',NULL,'2026-08-24 23:45:24','2026-08-24 23:46:47'),(94,'App\\Models\\User',8,'API Token','3a7fdcd16a7caf8e681a6a918dd0f0107fe55a8fd0fc4da5d0430ca8dac0869f','[\"*\"]','2026-08-25 01:04:50',NULL,'2026-08-25 01:04:42','2026-08-25 01:04:50'),(95,'App\\Models\\User',1,'API Token','76467c3925cf3399ddf659d95b5a5c4d5a4de87b546d09220fcdbbbcd41d9f69','[\"*\"]','2026-08-31 13:54:16',NULL,'2026-08-31 13:54:00','2026-08-31 13:54:16');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint unsigned NOT NULL,
  `permission_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_permissions_role_id_permission_id_unique` (`role_id`,`permission_id`),
  KEY `role_permissions_permission_id_foreign` (`permission_id`),
  CONSTRAINT `role_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=479 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (38,2,19,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(39,2,33,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(40,2,14,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(41,2,26,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(42,2,10,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(43,2,6,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(44,2,18,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(45,2,22,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(46,2,2,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(47,2,28,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(48,2,12,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(49,2,8,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(50,2,15,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(51,2,27,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(52,2,11,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(53,2,7,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(54,2,23,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(55,2,3,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(56,2,20,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(57,2,13,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(58,2,25,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(59,2,9,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(60,2,5,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(61,2,17,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(62,2,21,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(63,2,29,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(64,2,1,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(80,4,19,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(81,4,13,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(82,4,5,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(83,4,17,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(84,4,21,'2026-05-19 07:37:46','2026-05-19 07:37:46'),(87,1,38,'2026-05-21 03:08:31','2026-05-21 03:08:31'),(88,1,39,'2026-05-21 03:08:31','2026-05-21 03:08:31'),(89,1,40,'2026-05-21 03:08:31','2026-05-21 03:08:31'),(90,1,41,'2026-05-21 03:08:31','2026-05-21 03:08:31'),(189,8,76,'2026-05-21 03:20:11','2026-05-21 03:20:11'),(190,8,77,'2026-05-21 03:20:11','2026-05-21 03:20:11'),(201,3,38,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(202,3,39,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(203,3,40,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(204,3,41,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(205,3,42,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(206,3,43,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(207,3,44,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(208,3,45,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(209,3,46,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(210,3,47,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(211,3,48,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(212,3,49,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(213,3,50,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(214,3,51,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(215,3,52,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(216,3,53,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(217,3,54,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(218,3,55,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(219,3,56,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(220,3,57,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(221,3,58,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(222,3,59,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(223,3,60,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(224,3,61,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(225,3,62,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(226,3,63,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(227,3,64,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(228,3,65,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(229,3,66,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(230,3,67,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(231,3,68,'2026-05-21 03:22:51','2026-05-21 03:22:51'),(232,3,69,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(233,3,70,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(234,3,71,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(235,3,72,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(236,3,73,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(237,3,74,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(238,3,75,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(239,3,76,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(240,3,77,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(241,3,78,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(242,3,79,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(243,3,80,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(244,3,81,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(245,3,82,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(246,3,83,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(247,3,84,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(248,3,85,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(249,3,86,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(250,3,87,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(251,3,88,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(252,3,89,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(253,3,90,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(254,3,91,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(255,3,92,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(256,3,93,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(257,3,94,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(258,3,95,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(259,3,96,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(260,3,97,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(261,3,98,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(262,3,99,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(263,3,100,'2026-05-21 03:22:52','2026-05-21 03:22:52'),(302,1,2,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(303,1,3,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(304,1,4,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(305,1,5,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(306,1,6,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(307,1,7,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(308,1,8,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(309,1,9,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(310,1,10,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(311,1,11,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(312,1,12,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(313,1,13,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(314,1,14,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(315,1,15,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(316,1,16,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(317,1,17,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(318,1,18,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(319,1,1,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(320,1,19,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(321,1,20,'2026-06-23 01:47:27','2026-06-23 01:47:27'),(322,1,21,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(323,1,22,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(324,1,23,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(325,1,24,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(326,1,25,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(327,1,26,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(328,1,27,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(329,1,28,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(330,1,29,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(331,1,30,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(332,1,31,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(333,1,32,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(334,1,33,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(335,1,34,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(336,1,35,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(337,1,36,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(338,1,37,'2026-06-23 01:47:28','2026-06-23 01:47:28'),(339,3,2,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(340,3,3,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(341,3,4,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(342,3,5,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(343,3,6,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(344,3,7,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(345,3,8,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(346,3,9,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(347,3,10,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(348,3,11,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(349,3,12,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(350,3,13,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(351,3,14,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(352,3,15,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(353,3,16,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(354,3,17,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(355,3,18,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(356,3,1,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(357,3,19,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(358,3,20,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(359,3,21,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(360,3,22,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(361,3,23,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(362,3,24,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(363,3,25,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(364,3,26,'2026-06-23 01:48:08','2026-06-23 01:48:08'),(365,3,27,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(366,3,28,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(367,3,29,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(368,3,30,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(369,3,31,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(370,3,32,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(371,3,33,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(372,3,34,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(373,3,35,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(374,3,36,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(375,3,37,'2026-06-23 01:48:09','2026-06-23 01:48:09'),(376,8,1,'2026-06-23 01:49:56','2026-06-23 01:49:56'),(378,8,72,'2026-06-23 01:49:56','2026-06-23 01:49:56'),(379,8,13,'2026-06-23 02:22:14','2026-06-23 02:22:14'),(380,4,2,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(381,4,3,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(382,4,4,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(383,4,6,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(384,4,7,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(385,4,8,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(386,4,9,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(387,4,10,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(388,4,11,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(389,4,12,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(390,4,14,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(391,4,15,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(392,4,16,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(393,4,18,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(394,4,1,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(395,4,20,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(396,4,22,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(397,4,23,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(398,4,24,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(399,4,25,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(400,4,26,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(401,4,27,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(402,4,28,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(403,4,29,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(404,4,30,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(405,4,31,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(406,4,32,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(407,4,33,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(408,4,34,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(409,4,35,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(410,4,36,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(411,4,37,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(412,4,38,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(413,4,39,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(414,4,40,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(415,4,41,'2026-06-23 03:15:20','2026-06-23 03:15:20'),(416,4,42,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(417,4,43,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(418,4,44,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(419,4,45,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(420,4,46,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(421,4,47,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(422,4,48,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(423,4,49,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(424,4,50,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(425,4,51,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(426,4,52,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(427,4,53,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(428,4,54,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(429,4,55,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(430,4,56,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(431,4,57,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(432,4,58,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(433,4,59,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(434,4,60,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(435,4,61,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(436,4,62,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(437,4,63,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(438,4,64,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(439,4,65,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(440,4,66,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(441,4,67,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(442,4,68,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(443,4,69,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(444,4,70,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(445,4,71,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(446,4,72,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(447,4,73,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(448,4,74,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(449,4,75,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(450,4,76,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(451,4,77,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(452,4,78,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(453,4,79,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(454,4,80,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(455,4,81,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(456,4,82,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(457,4,83,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(458,4,84,'2026-06-23 03:16:19','2026-06-23 03:16:19'),(459,4,85,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(460,4,86,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(461,4,87,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(462,4,88,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(463,4,89,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(464,4,90,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(465,4,91,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(466,4,92,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(467,4,93,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(468,4,94,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(469,4,95,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(470,4,96,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(471,4,97,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(472,4,98,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(473,4,99,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(474,4,100,'2026-06-23 03:16:20','2026-06-23 03:16:20'),(475,8,73,'2026-07-04 01:08:16','2026-07-04 01:08:16'),(477,8,75,'2026-07-15 02:11:22','2026-07-15 02:11:22'),(478,8,95,'2026-07-15 02:11:22','2026-07-15 02:11:22');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Super Admin','Full system access with all permissions',1,'2026-04-26 00:58:43','2026-04-26 00:58:43'),(3,'Admin / System Admin','Admin / System Admin',1,'2026-04-26 01:07:17','2026-04-26 01:07:17'),(4,'Branch Manager','Branch Manager',1,'2026-04-26 01:08:14','2026-04-26 01:08:14'),(5,'Loan Officer','Loan Officer',1,'2026-04-26 01:08:36','2026-04-26 01:08:36'),(6,'Credit Officer / Risk Officer','Credit Officer / Risk Officer',1,'2026-04-26 01:09:29','2026-04-26 01:09:29'),(7,'Loan Approver (Senior Level)','Loan Approver (Senior Level)',1,'2026-04-26 01:09:57','2026-04-26 01:09:57'),(8,'Collection Officer (Field Officer)','Collection Officer (Field Officer)',1,'2026-04-26 01:10:25','2026-04-26 01:10:25'),(9,'Collection Supervisor','Collection Supervisor',1,'2026-04-26 01:10:42','2026-04-26 01:10:42'),(10,'Recovery Officer','Recovery Officer',1,'2026-04-26 01:11:11','2026-04-26 01:11:11'),(11,'Accountant','Accountant',1,'2026-04-26 01:11:23','2026-04-26 01:11:23'),(12,'Finance Manager','Finance Manager',1,'2026-04-26 01:11:34','2026-04-26 01:11:34'),(13,'Cashier','Cashier',1,'2026-04-26 01:11:52','2026-04-26 01:11:52'),(14,'Customer Service Officer','Customer Service Officer',1,'2026-04-26 01:12:16','2026-04-26 01:12:16'),(15,'Data Entry Operator','Data Entry Operator',1,'2026-04-26 01:12:27','2026-04-26 01:12:27'),(16,'HR Manager','HR Manager',1,'2026-04-26 01:12:43','2026-04-26 01:12:43'),(17,'Admin Officer','Admin Officer',1,'2026-04-26 01:12:55','2026-04-26 01:12:55'),(18,'IT Administrator','IT Administrator',1,'2026-04-26 01:13:12','2026-04-26 01:13:12'),(19,'Auditor','Auditor',1,'2026-04-26 01:13:27','2026-04-26 01:13:27'),(20,'Marketing Executive','Marketing Executive',1,'2026-04-26 01:13:45','2026-04-26 01:13:45'),(21,'Business Analyst','Business Analyst',1,'2026-04-26 01:13:59','2026-04-26 01:13:59'),(22,'Admin','Administrative access',1,'2026-05-05 19:39:37','2026-05-05 19:39:37');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `savings_account_transactions`
--

DROP TABLE IF EXISTS `savings_account_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `savings_account_transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint unsigned NOT NULL,
  `transaction_type` enum('deposit','withdrawal','interest_credit') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `balance_before` decimal(15,2) NOT NULL DEFAULT '0.00',
  `balance_after` decimal(15,2) NOT NULL DEFAULT '0.00',
  `transaction_date` date DEFAULT NULL,
  `reference_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sat_account_date_idx` (`savings_account_id`,`transaction_date`),
  KEY `sat_type_date_idx` (`transaction_type`,`transaction_date`),
  CONSTRAINT `savings_account_transactions_savings_account_id_foreign` FOREIGN KEY (`savings_account_id`) REFERENCES `savings_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `savings_account_transactions`
--

LOCK TABLES `savings_account_transactions` WRITE;
/*!40000 ALTER TABLE `savings_account_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `savings_account_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `savings_accounts`
--

DROP TABLE IF EXISTS `savings_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `savings_accounts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint unsigned NOT NULL DEFAULT '1',
  `branch_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `account_number` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_type` enum('savings','current','fixed_deposit') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'savings',
  `opening_deposit` decimal(15,2) NOT NULL DEFAULT '0.00',
  `balance` decimal(15,2) NOT NULL DEFAULT '0.00',
  `interest_rate` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `opened_at` date DEFAULT NULL,
  `status` enum('active','dormant','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `savings_accounts_account_number_unique` (`account_number`),
  KEY `savings_accounts_customer_id_status_index` (`customer_id`,`status`),
  KEY `savings_accounts_account_type_status_index` (`account_type`,`status`),
  CONSTRAINT `savings_accounts_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `savings_accounts`
--

LOCK TABLES `savings_accounts` WRITE;
/*!40000 ALTER TABLE `savings_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `savings_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'system_online','1','2026-06-23 02:00:55','2026-06-23 02:00:55');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test`
--

LOCK TABLES `test` WRITE;
/*!40000 ALTER TABLE `test` DISABLE KEYS */;
/*!40000 ALTER TABLE `test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  `assigned_at` timestamp NOT NULL,
  `assigned_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_roles_user_id_role_id_unique` (`user_id`,`role_id`),
  KEY `user_roles_role_id_foreign` (`role_id`),
  KEY `user_roles_assigned_by_foreign` (`assigned_by`),
  CONSTRAINT `user_roles_assigned_by_foreign` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,1,1,'2026-05-19 07:37:47',1,NULL,NULL),(2,3,8,'2026-05-23 01:32:39',3,NULL,NULL),(3,4,8,'2026-05-23 01:49:02',4,NULL,NULL),(4,2,3,'2026-05-23 02:45:54',2,NULL,NULL),(5,5,8,'2026-06-23 02:18:08',5,NULL,NULL),(6,6,8,'2026-06-23 02:33:41',6,NULL,NULL),(7,7,4,'2026-06-23 03:11:31',7,NULL,NULL),(8,8,3,'2026-07-15 02:23:57',8,NULL,NULL);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` bigint unsigned DEFAULT NULL,
  `branch_id` bigint unsigned DEFAULT NULL,
  `designation_id` bigint unsigned DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_employee_id_foreign` (`employee_id`),
  KEY `users_branch_id_foreign` (`branch_id`),
  KEY `users_designation_id_foreign` (`designation_id`),
  CONSTRAINT `users_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `users_designation_id_foreign` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`id`),
  CONSTRAINT `users_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Super Admin','superadmin@softcodelk.com',NULL,'$2y$12$b8spxAWMUqrJ67yShbIzl.g6qusgmoA0TrHpSaGwUCbrjHv/Fzbye',NULL,NULL,NULL,NULL,'2026-05-19 07:37:45','2026-05-19 07:37:45'),(2,'Buddhika Darshana','buddhika1992fer@gmail.com',NULL,'$2y$12$XVN3Lr1LrtdB9c9u0bJAYe1La1CNBp6XzvjlipB.v4bCLGT9Zqev2',1,1,2,NULL,'2026-05-23 01:12:18','2026-05-23 01:12:18'),(3,'Achintha Suresh','achintha@gmail.com',NULL,'$2y$12$3cnYhYjZwyV6BGD98RZLdew.gaLvlHNp5seQNbRXppIyb2zCeOZKK',2,1,7,NULL,'2026-05-23 01:14:35','2026-05-23 01:14:35'),(4,'Chamuditha Nilusha','Chamuditha@gmail.com',NULL,'$2y$12$SmgujcGF2vzx9MDxj86.yOf6BHzjzkK16Xh9TkzkMKiq3v7QI.dsm',3,1,7,NULL,'2026-05-23 01:17:30','2026-05-23 01:17:30'),(5,'Achintha Suresh','achintha1@gmail.com',NULL,'$2y$12$Ph5nT7LuSG3nrGY.sEOOH.VgKztvy8iC1gEsQBb3nbJ1lRf4VpUOO',1,1,7,NULL,'2026-06-23 01:56:11','2026-06-23 01:56:11'),(6,'Chamuditha Nilusha','Chamuditha1@gmail.com',NULL,'$2y$12$wh42eW9EYWddWqNbE1U3pOxG3CMBNE7Pn9dmOosF.nZuyvOCmgUuG',2,1,7,NULL,'2026-06-23 02:00:05','2026-06-23 02:00:05'),(7,'Buddhika Darshana','buddhika92fer@gmail.com',NULL,'$2y$12$CsH9rQsgLxRtASiZ9Q1IzeKl.3XpOholQFgr.SBdMPTx75Q0BFRWa',3,1,3,NULL,'2026-06-23 02:10:26','2026-06-23 02:10:26'),(8,'Buddhika Darshana','buddhika92fer2@gmail.com',NULL,'$2y$12$S1aSJzu4hoOEaKQt/ODFg.XC00zocsxHj.dOICmwvRAOMy.aq00T6',4,1,2,NULL,'2026-07-15 02:23:35','2026-07-15 02:23:35');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'db_mkhmicro'
--

--
-- Dumping routines for database 'db_mkhmicro'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 17:54:19
