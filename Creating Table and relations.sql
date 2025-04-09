 --------Library Management System Part 1--------

--Creating table branch
DROP table IF EXISTS branch ;
Create table branch(
	branch_id varchar(5) PRIMARY KEY,
	manager_id	varchar(5),   --fk
	branch_address	varchar(20),
	contact_no varchar(15)
)


--Creating table book
DROP table IF EXISTS book ;
Create table book(
	isbn varchar(20) PRIMARY KEY,
	book_title	varchar(70),
	category varchar(60),
	rental_price float,
	status	varchar(5),
	author varchar(30),
	publisher varchar(30)
	)

--Creating table employee
DROP table IF EXISTS employee ;
Create table employee(
	emp_id	varchar(10) PRIMARY KEY,
	emp_name varchar(30),
	positions varchar(16),
	salary int,
	branch_id varchar(25)   --fk
)


--Creating table Issued Status
DROP table IF EXISTS issued_status ;
Create table issued_status(
	issued_id varchar(6) PRIMARY KEY,
	issued_member_id varchar(5),   --fk
	issued_book_name varchar(60),
	issued_date date,
	issued_book_isbn varchar(25),    --fk
	issued_emp_id varchar(5)  --fk
)


--Creating table Members
DROP table IF EXISTS members ;
Create table members(
	member_id varchar(5) PRIMARY KEY,
	member_name varchar(20),
	member_address varchar(20),
	reg_date date
)


--Creating table return status
DROP table IF EXISTS return_status ;
Create table return_status(
	return_id	varchar(5) PRIMARY KEY,
	issued_id	varchar(5),    --fk
	return_book_name varchar(10),
	return_date date,
	return_book_isbn varchar(10))   --fk


-- Adding Foreign key

ALter table issued_status
ADD CONSTRAINT fk_member
foreign key (issued_member_id)
references members(member_id)

ALter table issued_status
ADD CONSTRAINT fk_issued_book_isbn
foreign key (issued_book_isbn)
references book(isbn)

ALter table issued_status
ADD CONSTRAINT fk_issued_emp_id
foreign key (issued_emp_id)
references employee(emp_id)


ALter table employee
ADD CONSTRAINT fk_branch_id
foreign key (branch_id)
references branch(branch_id)

ALter table return_status
ADD CONSTRAINT fk_issued_id
foreign key (issued_id)
references issued_status(issued_id)


ALter table return_status
ADD CONSTRAINT fk_return_book_isbn
foreign key (return_book_isbn)
references book(isbn)


ALter table branch
ADD CONSTRAINT fk_manager_id
foreign key (manager_id)
references members(member_id)

ALTER table branch
DROP constraint fk_manager_id
