 --------Library Management System Part 2---------

------ Basic SQL Question Solving -------

--Q1. Create a new book record -- "978-1-60129-456-2','To Killa Mockigbird,'Classic",6.00,'yes','haroer Leeiooicott &','J.C>L' co.')"

INSERT INTO book VALUES ('978-1-60129-456-2','To Killa Mockigbird','Classic',6.00,'yes','haroer Lee','Liooicott & J.C Lco.')

SELECT * from book

--Q2. Update an Existing Memeber's address?

Select * from members

Update members
SET member_address = '456 Qlm St'
WHERE member_id = 'C102'

--Q3. Delete a record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS106' from issued_status table

DELETE FROM issued_status
where issued_id = 'IS106'

Select * from issued_status

--Q4. Retrieve all books issued by a specific employee

SELECT * FROM issued_status
Where issued_emp_id = 'E101'

--Q5. List members who have issued more than one book 

WITH temp as(SELECT issued_book_name, count(*) from issued_status group by issued_book_name order by 2 DESC LIMIT 2)

SELECT * FROM issued_status WHERE issued_book_name IN (SELECT issued_book_name from temp)


--Q6. Create Summary table used CTAS to generate new table based on query result - each book and total_book_issued_cnt

CREATE table book_cnts as
SELECT b.isbn, COUNT(ist.issued_id) as no_issued
FROM book as b
JOIN
issued_status as ist
on b.isbn = ist.issued_book_isbn
group by 1

--Q7. Retrieve all books in a specific category

SELECT * from book where category = 'Classic'


--Q8. Find Total Rental Income by categories

Select category,SUM(rental_price) as Total_Rental_Income from 
book as a
join
issued_status as b
on b.issued_book_isbn = a.isbn
Group by 1

--Q9. List members who registered in last 2 Years

Select * from members where reg_date >= CURRENT_DATE - INTERVAL '2 years'


--Q10. List Employee with their branch manager's name and gheir branch details

SELECT e1.*, b.branch_id, e2.emp_name as manager
FROM employee as e1
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN employee as e2
ON b.manager_id = e2.emp_id