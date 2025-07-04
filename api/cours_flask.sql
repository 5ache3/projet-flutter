-- MySQL dump 10.13  Distrib 9.0.1, for Win64 (x86_64)
--
-- Host: localhost    Database: cours_flask
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

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
-- Table structure for table `favorite`
--

DROP TABLE IF EXISTS `favorite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorite` (
  `id` varchar(100) NOT NULL,
  `user_id` varchar(100) DEFAULT NULL,
  `house_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorite`
--

LOCK TABLES `favorite` WRITE;
/*!40000 ALTER TABLE `favorite` DISABLE KEYS */;
INSERT INTO `favorite` VALUES ('0e1fe47cce3647908fb39f4b978e592f','a607987cb8204ba69b32a54af28842e6','38900756fb80473cb25a372ab2abce35'),('659d6698868444d681a0ce90f3228e3b','2b18039fab014e03a34c36f94d71f101','517213b61cf249a097f582f986b3fe56'),('93f55ba1623b4532a67670145aeb9b17','2b18039fab014e03a34c36f94d71f101','38900756fb80473cb25a372ab2abce35'),('b81d6f9745de4403b8eb445779c8d876','1','35298700175d4fdf8547e2f143b5f8ff'),('f1fdd5e8569348c3b11c02e7bc8f1556','e7fd085785de42148fcf8f0aced1cd68','517213b61cf249a097f582f986b3fe56');
/*!40000 ALTER TABLE `favorite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `houses`
--

DROP TABLE IF EXISTS `houses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `houses` (
  `id` varchar(100) NOT NULL,
  `admin_id` varchar(100) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `price` varchar(10) DEFAULT NULL,
  `rooms` int(11) DEFAULT NULL,
  `surface` varchar(10) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `location` varchar(30) DEFAULT NULL,
  `ville` varchar(50) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `houses`
--

LOCK TABLES `houses` WRITE;
/*!40000 ALTER TABLE `houses` DISABLE KEYS */;
INSERT INTO `houses` VALUES ('38900756fb80473cb25a372ab2abce35','1','house 2','12,000,000',4,'100','house','12222222222,213123','tvz','nkt'),('517213b61cf249a097f582f986b3fe56','1','house 3','12,000',12,'100','house','23013.132.132','nouadhibou','nkt');
/*!40000 ALTER TABLE `houses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `images` (
  `id` varchar(100) NOT NULL,
  `house_id` varchar(100) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `url` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
INSERT INTO `images` VALUES ('323b3b28b86d497090eee6072d862382','517213b61cf249a097f582f986b3fe56','','api/static/uploads/51148009b2054266aa1d26a199e63df2.jpg'),('37fea5c53a59466cb420c3dc451513f8','517213b61cf249a097f582f986b3fe56','main','api/static/uploads/789a02b3d5cc4404a165c3bca34920a0.jpg'),('49e7069d861c499b88fb45ade650dd4f','517213b61cf249a097f582f986b3fe56','','api/static/uploads/95df87f8b9c344ebaa7fbd376df00b7e.jpg'),('6f4e585390af4a3ba581524a1d31efd4','38900756fb80473cb25a372ab2abce35','','api/static/uploads/d34f9699df3644618fee5ff2ec0d9286.jpg'),('b30267cdd41a45d0a70d7c2ab2e2a844','38900756fb80473cb25a372ab2abce35','main','api/static/uploads/9a3b512201864576a3e7957390585064.jpg'),('c49cd1d373374b0fbc34b603757a4e00','38900756fb80473cb25a372ab2abce35','','/api/static/uploads/75dfc251bf7941c8a158cbf4e60e72d3.jpg');
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(100) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('2b18039fab014e03a34c36f94d71f101','user1','$2b$12$pfkZD/YbcEQY/kPIggF4leh.tqa2j571GDwmrCsZvriLK7m7lsO.i','user'),('a607987cb8204ba69b32a54af28842e6','user12','$2b$12$1Jz2f6zLkAxV5stdxBoQoePZmZLTRtT32R5GCGz7QF1ZIc4c/CNji','user'),('cc953ee3ce0c4558a5aadf19bf4f59b7','user','$2b$12$H7I3YH9Ljo1AWYpYNwdHEOcZJPK68aUUFJdto2q0xTXcVA2o3IIGS','user'),('cf1c44a449f74b46ba12dcc78317fddd','12','$2b$12$roSxgUPQvhLNbu23bG4nKuDXMx9TkksLSIgm8kPfuNKwwcOb21vqO','user'),('e7fd085785de42148fcf8f0aced1cd68','admin','$2b$12$OsQbx9/7xdFt2tENVw39cefJrdvXLSItXDYv6UJ4aOMHs4nzD8U9O','admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-02 18:13:04
