create database mes_test_db;
use mes_test_db;

show tables;

CREATE TABLE production_lines (
 id INT PRIMARY KEY AUTO_INCREMENT,
 name VARCHAR(100) NOT NULL UNIQUE,
 location VARCHAR(100) NOT NULL
);

CREATE TABLE products (
 id INT PRIMARY KEY AUTO_INCREMENT,
 sku VARCHAR(30) NOT NULL UNIQUE,
 name VARCHAR(100) NOT NULL,
 standard_cycle_seconds INT NOT NULL
);

CREATE TABLE machines (
 id INT PRIMARY KEY AUTO_INCREMENT,
 line_id INT NOT NULL,
 code VARCHAR(30) NOT NULL UNIQUE,
 name VARCHAR(100) NOT NULL,
 status ENUM('RUNNING','IDLE','MAINTENANCE') NOT NULL,
 FOREIGN KEY (line_id) REFERENCES production_lines(id)
);

CREATE TABLE employees (
 id INT PRIMARY KEY AUTO_INCREMENT,
 full_name VARCHAR(100) NOT NULL,
 department VARCHAR(50) NOT NULL,
 line_id INT NULL,
 salary DECIMAL(12,2) NOT NULL,
 FOREIGN KEY (line_id) REFERENCES production_lines(id)
);

CREATE TABLE work_orders (
 id INT PRIMARY KEY AUTO_INCREMENT,
 order_code VARCHAR(30) NOT NULL UNIQUE,
 product_id INT NOT NULL,
 line_id INT NOT NULL,
 planned_quantity INT NOT NULL,
 status ENUM('PLANNED','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL,
 start_date DATE NOT NULL,
 due_date DATE NOT NULL,
 FOREIGN KEY (product_id) REFERENCES products(id),
 FOREIGN KEY (line_id) REFERENCES production_lines(id)
);

CREATE TABLE production_logs (
 id INT PRIMARY KEY AUTO_INCREMENT,
 work_order_id INT NOT NULL,
 machine_id INT NOT NULL,
 employee_id INT NULL,
 produced_at DATETIME NOT NULL,
 good_quantity INT NOT NULL,
 defect_quantity INT NOT NULL,
 FOREIGN KEY (work_order_id) REFERENCES work_orders(id),
 FOREIGN KEY (machine_id) REFERENCES machines(id),
 FOREIGN KEY (employee_id) REFERENCES employees(id)
);

INSERT INTO production_lines (id,name,location) VALUES
(1,'Assembly A','Factory 1'),(2,'Assembly B','Factory 1'),(3,'Packaging C','Factory 2'),(4,'Testing D','Factory 2');
INSERT INTO products (id,sku,name,standard_cycle_seconds) VALUES
(1,'P-100','Sensor Module',30),(2,'P-200','Control Board',45),(3,'P-300','Motor Driver',60),(4,'P-400','Display Panel',50),(5,'P-500','Battery Pack',40);
INSERT INTO machines (id,line_id,code,name,status) VALUES
(1,1,'MC-01','Assembler 01','RUNNING'),(2,1,'MC-02','Assembler 02','IDLE'),
(3,2,'MC-03','Soldering 01','RUNNING'),(4,2,'MC-04','Soldering 02','MAINTENANCE'),
(5,3,'MC-05','Packer 01','RUNNING'),(6,3,'MC-06','Packer 02','IDLE'),
(7,4,'MC-07','Tester 01','IDLE'),(8,4,'MC-08','Tester 02','MAINTENANCE');
INSERT INTO employees (id,full_name,department,line_id,salary) VALUES
(1,'An','Production',1,11000000),(2,'Binh','Production',1,12000000),
(3,'Chi','Production',2,12500000),(4,'Dung','Production',2,10500000),
(5,'Ha','Production',3,11500000),(6,'Khanh','Quality',NULL,15000000),
(7,'Linh','Production',4,13000000),(8,'Minh','IT',NULL,18000000);
INSERT INTO work_orders (id,order_code,product_id,line_id,planned_quantity,status,start_date,due_date) VALUES
(1,'WO-001',1,1,1000,'COMPLETED','2026-10-01','2026-10-03'),
(2,'WO-002',2,2,800,'IN_PROGRESS','2026-10-02','2026-10-07'),
(3,'WO-003',3,2,600,'COMPLETED','2026-10-03','2026-10-08'),
(4,'WO-004',1,1,1200,'IN_PROGRESS','2026-10-05','2026-10-12'),
(5,'WO-005',4,3,500,'PLANNED','2026-10-08','2026-10-15'),
(6,'WO-006',5,3,700,'CANCELLED','2026-10-09','2026-10-16'),
(7,'WO-007',2,4,900,'PLANNED','2026-10-10','2026-10-18'),
(8,'WO-008',3,2,400,'IN_PROGRESS','2026-10-11','2026-10-20');
INSERT INTO production_logs (id,work_order_id,machine_id,employee_id,produced_at,good_quantity,defect_quantity) VALUES
(1,1,1,1,'2026-10-01 08:00:00',450,10),
(2,1,1,2,'2026-10-02 08:00:00',550,15),
(3,2,3,3,'2026-10-02 09:00:00',200,8),
(4,2,3,4,'2026-10-03 09:00:00',300,12),
(5,3,3,3,'2026-10-03 10:00:00',350,5),
(6,3,3,4,'2026-10-04 10:00:00',250,10),
(7,4,1,1,'2026-10-05 08:30:00',400,20),
(8,4,2,2,'2026-10-06 08:30:00',300,10),
(9,8,3,3,'2026-10-11 11:00:00',150,5),
(10,8,3,NULL,'2026-10-12 11:00:00',100,0);
