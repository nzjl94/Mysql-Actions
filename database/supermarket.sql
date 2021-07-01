-- phpMyAdmin SQL Dump
-- version 4.9.2deb1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 24, 2020 at 11:11 PM
-- Server version: 8.0.19-0ubuntu4
-- PHP Version: 7.3.15-3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `supermarket`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`local_admin`@`localhost` PROCEDURE `convert_money` (IN `table_name` VARCHAR(50), IN `currency_amount` MEDIUMINT)  BEGIN
IF table_name= "sell" THEN
	SELECT id,(total_price-(total_price*(total_discount/100)))/currency_amount as 'new_currency' FROM `sell` WHERE `deleted_at` is null;
ELSEIF table_name="purches" THEN
	SELECT id,(total_price)/currency_amount as 'new_currency' FROM `purches` WHERE `deleted_at` is null;
END IF;

END$$

CREATE DEFINER=`local_admin`@`localhost` PROCEDURE `execute_table` (IN `table_name` VARCHAR(30), IN `table_limit` SMALLINT(3), IN `table_date` DATE)  BEGIN
 SET @t1 =CONCAT('SELECT * FROM ',table_name,' where deleted_at is null and CAST(created_at as DATE)="',table_date,'" ', 'limit ',table_limit);
 PREPARE stmt3 FROM @t1;
 EXECUTE stmt3;
 DEALLOCATE PREPARE stmt3;
END$$

--
-- Functions
--
CREATE DEFINER=`local_admin`@`localhost` FUNCTION `total_money_in_capital` () RETURNS DECIMAL(10,2) NO SQL
BEGIN
	DECLARE sell DECIMAL(10,2);
	DECLARE purches DECIMAL(10,2);
     
	SELECT 
    	sum(`total_price`-(`total_price`*(`total_discount`/100))) into sell 
    FROM 
    	`sell` 
    WHERE 
    	`deleted_at` is null;
    SELECT 
    	sum(`total_price`) into purches 
    FROM 
    	`purches` 
    WHERE 
    	`deleted_at` is null;
        
    RETURN sell-purches;
END$$

CREATE DEFINER=`local_admin`@`localhost` FUNCTION `total_user_in_system` () RETURNS INT NO SQL
BEGIN
	 DECLARE v_total INT;
    SELECT SUM(id) INTO v_total FROM admin;
    RETURN v_total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `failed_count` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `username`, `password`, `failed_count`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'test1', '1234567', 0, '2020-03-24 14:01:25', NULL, NULL),
(2, 'test2', '123456', 0, '2020-03-24 23:02:50', NULL, NULL),
(3, 'test3', '123456', 0, '2020-03-24 23:02:50', NULL, NULL);

--
-- Triggers `admin`
--
DELIMITER $$
CREATE TRIGGER `after_admin_delete` AFTER UPDATE ON `admin` FOR EACH ROW IF (NEW.deleted_at is not null) THEN
	INSERT INTO system_log(process_type,user_id,table_name) VALUES ('delete',OLD.id,'admin');
END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_admin_insert` AFTER INSERT ON `admin` FOR EACH ROW INSERT INTO system_log(process_type,user_id,table_name) VALUES ('insert',NEW.id,'admin')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_admin_update` AFTER UPDATE ON `admin` FOR EACH ROW IF (NEW.deleted_at is null) THEN
	INSERT INTO system_log(process_type,user_id,table_name) VALUES ('update',OLD.id,'admin');
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `address` varchar(100) NOT NULL,
  `phone_number` varchar(40) NOT NULL,
  `type` enum('normal','special') NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`id`, `name`, `address`, `phone_number`, `type`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'test1', 'Hi', '+9647501234567', 'normal', '2020-03-24 18:59:10', NULL, NULL),
(2, 'test2', 'test2', '+9647504444444', 'normal', '2020-03-23 18:59:10', NULL, NULL),
(3, 'test3', 'test3', '+9647501234512', 'special', '2020-03-24 18:59:10', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `category_id` int NOT NULL,
  `base_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id`, `name`, `category_id`, `base_price`, `description`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'banner', 2, '1000.00', 'banner', '2020-03-24 21:43:49', NULL, NULL),
(2, 'orange', 2, '1000.00', 'orange', '2020-03-24 21:43:49', NULL, NULL),
(3, 'onion', 1, '500.00', 'hi', '2020-03-24 23:03:24', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_category`
--

CREATE TABLE `product_category` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_category`
--

INSERT INTO `product_category` (`id`, `name`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'vegetables', '2020-03-24 21:42:41', NULL, NULL),
(2, 'Fruit', '2020-03-24 21:42:41', NULL, NULL),
(3, 'Clothes', '2020-03-24 21:42:41', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `purches`
--

CREATE TABLE `purches` (
  `id` int NOT NULL,
  `buyer_id` int NOT NULL,
  `supplier_id` int NOT NULL,
  `total_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `date` date NOT NULL,
  `note` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `purches`
--

INSERT INTO `purches` (`id`, `buyer_id`, `supplier_id`, `total_price`, `date`, `note`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 1, '100000.00', '2020-03-24', 'hi', '2020-03-24 21:45:25', NULL, NULL),
(2, 2, 3, '10000.00', '2020-03-25', 'buying onion', '2020-03-24 23:07:59', NULL, NULL),
(3, 2, 3, '10000.00', '2020-03-25', 'buying onion', '2020-03-24 23:07:59', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `purches_detail`
--

CREATE TABLE `purches_detail` (
  `id` int NOT NULL,
  `product_id` int NOT NULL,
  `purches_id` int NOT NULL,
  `total_qty` mediumint NOT NULL DEFAULT '0',
  `remain_qty` mediumint NOT NULL DEFAULT '0',
  `expire_date` date NOT NULL,
  `note` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `purches_detail`
--

INSERT INTO `purches_detail` (`id`, `product_id`, `purches_id`, `total_qty`, `remain_qty`, `expire_date`, `note`, `created_at`, `updated_at`, `deleted_at`) VALUES
(11, 1, 1, 50, 40, '2020-03-27', 'hi', '2020-03-24 21:55:19', NULL, NULL),
(13, 2, 1, 50, 40, '2020-03-30', 'hi', '2020-03-24 21:56:29', NULL, NULL),
(14, 3, 3, 20, 20, '2020-03-31', 'hi', '2020-03-24 23:09:08', NULL, NULL),
(15, 3, 3, 20, 20, '2020-03-31', 'hello', '2020-03-24 23:09:08', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sell`
--

CREATE TABLE `sell` (
  `id` int NOT NULL,
  `admin_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `total_price` decimal(10,0) NOT NULL DEFAULT '0',
  `total_discount` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `note` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sell`
--

INSERT INTO `sell` (`id`, `admin_id`, `customer_id`, `total_price`, `total_discount`, `note`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 1, '10000', 25, 'hi', '2020-03-24 21:57:56', NULL, NULL),
(2, 1, 2, '10000', 0, 'hi', '2020-03-24 21:57:56', NULL, NULL),
(3, 2, 3, '1000', 0, 'hi', '2020-03-24 23:09:46', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sell_detail`
--

CREATE TABLE `sell_detail` (
  `id` int NOT NULL,
  `sell_id` int NOT NULL,
  `purches_detail_id` int NOT NULL,
  `qty` mediumint NOT NULL DEFAULT '0',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sell_detail`
--

INSERT INTO `sell_detail` (`id`, `sell_id`, `purches_detail_id`, `qty`, `price`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 11, 5, '1000.00', '2020-03-24 22:00:30', NULL, NULL),
(2, 1, 13, 5, '1000.00', '2020-03-24 22:00:30', NULL, NULL),
(3, 2, 11, 5, '1000.00', '2020-03-24 22:01:09', NULL, NULL),
(4, 2, 13, 5, '1000.00', '2020-03-24 22:01:09', NULL, NULL),
(5, 3, 15, 2, '500.00', '2020-03-24 23:10:57', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `id` int NOT NULL,
  `company_name` varchar(100) NOT NULL,
  `phone_number` varchar(40) NOT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(100) NOT NULL,
  `note` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`id`, `company_name`, `phone_number`, `email`, `address`, `note`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'fruit seller', '+9647504140867', 'hi@gmail.com', 'hi', 'hi', '2020-03-24 21:44:59', NULL, NULL),
(2, 'company 1', '+9647501234567', 'hi@gmail.com', 'hello', 'hello', '2020-03-24 23:06:04', NULL, NULL),
(3, 'Company 2', '+9647504444567', 'hello@gmail.com', 'Hawler', 'Hawler', '2020-03-24 23:06:04', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `system_log`
--

CREATE TABLE `system_log` (
  `id` int NOT NULL,
  `process_type` enum('insert','update','delete') NOT NULL,
  `user_id` int NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `system_log`
--

INSERT INTO `system_log` (`id`, `process_type`, `user_id`, `table_name`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'insert', 1, 'admin', '2020-03-24 14:01:25', NULL, NULL),
(2, 'update', 1, 'admin', '2020-03-24 14:07:23', NULL, NULL),
(3, 'update', 1, 'admin', '2020-03-24 14:11:27', NULL, NULL),
(4, 'update', 1, 'admin', '2020-03-24 21:25:49', NULL, NULL),
(5, 'insert', 2, 'admin', '2020-03-24 23:02:50', NULL, NULL),
(6, 'insert', 3, 'admin', '2020-03-24 23:02:50', NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `product_category`
--
ALTER TABLE `product_category`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `purches`
--
ALTER TABLE `purches`
  ADD PRIMARY KEY (`id`),
  ADD KEY `buyer_id` (`buyer_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `purches_detail`
--
ALTER TABLE `purches_detail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `purches_id` (`purches_id`) USING BTREE;

--
-- Indexes for table `sell`
--
ALTER TABLE `sell`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `sell_detail`
--
ALTER TABLE `sell_detail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sell_id` (`sell_id`),
  ADD KEY `purches_detail_id` (`purches_detail_id`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `system_log`
--
ALTER TABLE `system_log`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `product_category`
--
ALTER TABLE `product_category`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `purches`
--
ALTER TABLE `purches`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `purches_detail`
--
ALTER TABLE `purches_detail`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `sell`
--
ALTER TABLE `sell`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `sell_detail`
--
ALTER TABLE `sell_detail`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `system_log`
--
ALTER TABLE `system_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `product_category` (`id`);

--
-- Constraints for table `purches`
--
ALTER TABLE `purches`
  ADD CONSTRAINT `purches_ibfk_1` FOREIGN KEY (`buyer_id`) REFERENCES `admin` (`id`),
  ADD CONSTRAINT `purches_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`id`);

--
-- Constraints for table `purches_detail`
--
ALTER TABLE `purches_detail`
  ADD CONSTRAINT `purches_detail_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  ADD CONSTRAINT `purches_detail_ibfk_2` FOREIGN KEY (`purches_id`) REFERENCES `purches` (`id`);

--
-- Constraints for table `sell`
--
ALTER TABLE `sell`
  ADD CONSTRAINT `sell_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`id`),
  ADD CONSTRAINT `sell_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`);

--
-- Constraints for table `sell_detail`
--
ALTER TABLE `sell_detail`
  ADD CONSTRAINT `sell_detail_ibfk_1` FOREIGN KEY (`purches_detail_id`) REFERENCES `purches_detail` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `sell_detail_ibfk_2` FOREIGN KEY (`sell_id`) REFERENCES `sell` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
