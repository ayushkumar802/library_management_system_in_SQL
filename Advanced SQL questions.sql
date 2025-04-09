 --------Library Management System Part 3---------

--- Advanced SQL Question ---

--Q11. Create a Table of Books with Rental Price Above a Certain Threshold:

Create table expensive_books AS
select book_title, rental_price from book where rental_price >=6.5


--Q12. Retrieve the List of Books Not Yet Returned 

select * from 
return_status as r
RIGHT JOIN 
issued_status as i
ON r.issued_id = i.issued_id
WHERE r.return_id is NULL

--Q13.  Identify Members with Overdue Books
--      Write a query to identify members who have overdue books (assume a 30-day return period). 
--      Display the member's_id, member's name, book title, issue date, and days overdue.

WITH temp AS(
select * from 
return_status as r
RIGHT JOIN 
issued_status as i
ON r.issued_id = i.issued_id
WHERE r.return_id is NULL)

select m.member_id, m.member_name, t.issued_book_name, t.issued_date, ABS(t.issued_date - CURRENT_DATE) as days from 
temp as t
join members as m
on m.member_id = t.issued_member_id
where ABS(t.issued_date - CURRENT_DATE) >= 366               -- 1 years


--Q14. Write a query to update the status of books in the books table to "Yes" when they are returned 
--     (based on entries in the return_status table)


CREATE OR REPLACE PROCEDURE add_retur_record(p_return_id VARCHAR(5),p_issued_id VARCHAR(5))
LANGUAGE plpgsql
AS $$
DECLARE
 temp_isbn VARCHAR(50);
 temp_book_name VARCHAR(70);
 
BEGIN
	INSERT INTO return_status(return_id,issued_id,return_date)
	VALUES(p_return_id,p_issued_id,CURRENT_DATE);
 
	SELECT issued_book_isbn, issued_book_name INTO temp_isbn, temp_book_name
	from issued_status where issued_id = p_issued_id ;

	UPDATE book 
	SET status = 'yes'
	WHERE isbn = temp_isbn;
	
	RAISE NOTICE 'The updation of book % is done succesfully', temp_book_name;
	
END
$$

-- Testig procedure
--  issued_id = IS135 ad new generated return_id = RS138
select * from issued_status where issued_id = 'IS135'
select * from return_status where issued_id = 'IS135'
select * from book where isbn = '978-0-307-58837-1'

CALL add_retur_record('RS138','IS135')


/* Q15. Branch Performance Report 
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals. */ 

CREATE TABLE branch_reports
AS (
select b.branch_id,
count(*) as number_of_issued_book, 
count(r.return_id) as number_of_return_book, 
sum(bk.rental_price) from
branch as b join employee as e on b.branch_id = e.branch_id
join issued_status as i on i.issued_emp_id = e.emp_id
left join return_status as r on r.issued_id = i.issued_id
join book as bk on bk.isbn = i.issued_book_isbn
Group by b.branch_id);

select * from branch_reports


/* Q16. CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one 
book in the last 12 months and 15 days. */

CREATE table active_members as
select * from members where member_id IN (
SELECT distinct issued_member_id from issued_status
where issued_date < CURRENT_DATE - INTERVAL '12 month 15 days')


/* Q17. Find Employees with the Most Book Issues Processed
		Write a query to find the top 3 employees who have processed the most book issues.
		Display the employee name, number of books processed, and their branch. */

WITH temp as(
select issued_emp_id, count(*) as counts from issued_status group by 1 order by 2 DESC LIMIT 3)

select issued_emp_id, emp_name, branch_id, counts from employee as e join temp as t  on t.issued_emp_id = e.emp_id


/* Q18. Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should 
be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'),
the procedure should return an error message indicating that the book is currently not available.*/

CREATE OR REPLACE PROCEDURE status_updator(p_issued_id VARCHAR(7), p_issued_member_id VARCHAR(6), p_issued_emp_id VARCHAR(60),p_isbn VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
temp_status VARCHAR(5);
temp_book_title VARCHAR(50);
BEGIN 
	select status,book_title into temp_status, temp_book_title from book where isbn = p_isbn;
	IF temp_status = 'yes' 
	THEN INSERT into issued_status VALUES(p_issued_id, p_issued_member_id, temp_book_title, CURRENT_DATE, p_isbn, p_issued_emp_id);
		  UPDATE book SET status = 'no' WHERE isbn = p_isbn;
	ELSE RAISE NOTICE 'The book % is not available currently',temp_book_title;
	END IF;
	RAISE NOTICE 'The book % is succesfully issued',temp_book_title;
END
$$
--

CALL status_updator('IS141','C108','E105','978-0-14-143951-8')
select * from issued_status


/* Q.19: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to 
identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued 
but not returned within 12 month 15 days. The table should include: The number of overdue books. The total fines, with 
each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: 
Member ID Number of overdue books Total fines */

Create table fine_table AS
WITH temp AS(
SELECT issued_member_id, 1 as counts ,rental_price,((CURRENT_DATE - INTERVAL '12 month 15 day') - issued_date)::text  as overdue_days 
from issued_status as i 
join 
book as b 
on i.issued_book_isbn = b.isbn 
where issued_date < CURRENT_DATE - INTERVAL '12 month 15 day')

select issued_member_id,
sum(counts) as overdue_books, 
sum(rental_price) as total_rental_price,
sum(fine) as total_fine,
sum(total) as total_charge
from(
	select *,
	fine + rental_price as total 
	from (select *,
		  SPLIT_PART(overdue_days,' ',1)::numeric * 0.5 as fine 
		  from temp)
	  )
group by 1
order by 5 DESC


