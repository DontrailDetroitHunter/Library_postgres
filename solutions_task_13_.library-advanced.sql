-- SQL PROJECT Library Management System --

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


/*
Task 13:
---Identify Members with Overdue Books--- then...
--Write a query to identify members who have overdue books (assume a 30-day return period).--
--Display the member's_id, member's name, book title, issue date, and days overdue. --
*/

-- steps--
-- issued_status == members == books == return_status --
-- filter books that have been return
-- overduer greater than 30 days
/*
Join books and members table together
*/
select
    ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
--	rs.return_date,
	CURRENT_DATE - ist.issued_date as over_dues
	 
from
	issued_status as ist
inner join
	members as m
ON
	m.member_id = ist.issued_member_id
JOIN
	books as bk
ON
	bk.isbn = ist.issued_book_isbn
LEFT JOIN
	return_status as rs
ON
	rs.issued_id = ist.issued_id
where rs.return_date is null
	and
CURRENT_DATE - ist.issued_date > 30
order by 1

select * from books;	
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;
/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

select * 
from issued_status
where issued_book_isbn = '978-0-451-52994-2'

select 
	*
from
	books
where
	isbn = '978-0-451-52994-2'

update books
set status = 'no'
where isbn = '978-0-451-52994-2'

select * from
return_status
WHERE
issued_id = 'IS130'

--


INSERT INTO retuRn_status (return_id,issued_id,return_date,book_quality)
values
('RS125','IS130',CURRENT_DATE,'GOOD');
SELECT * FROM RETURN_STATUS
WHERE issued_id ='IS130';

UPDATE books
set status = 'yes'
where isbn = 'IS130'

-- store procedures --
-------------------------------------------------------------------
create or replace procedure add_return_records(
	 p_return_id VARCHAR(10),
     p_issued_id VARCHAR(10),
	 p_book_quality VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_isbn varchar(50);
	v_book_name varchar(80);
begin
	-- put all the logic for code in here --
	-- INSERTING INTO RETURSN BASED ON USERS INPUT
	INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
	VALUES(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
	
	SELECT
		issued_book_isbn,
		issued_book_name
		into
		v_isbn,
		v_book_name
	from issued_status
	where issued_id = p_issued_id;
	
	UPDATE books
	set status = 'yes'
	where isbn = v_isbn;

	raise notice ' Thank you for returning the book:%', v_book_name;
END;
$$

-- TESTING FUNCTION --
-------------------------
issued_id = 'IS135'
ISBN = '978-0-307-58837-1'
-------------------------

select * from return_status
where issued_id = 'IS135';

SELECT * FROM BOOKS
WHERE isbn = '978-0-330-25864-8';

SELECT * FROM ISSUED_STATUS
WHERE ISSUED_BOOK_ISBN = 'IS140' 

select * from books;

-- CALLING FUNCITONS -- 
CALL add_return_records('R138','IS135','Good'); 
CALL add_return_records('R148','IS140','GREAT'); 


/*
Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of
books returned, and the total revenue from book rentals --
*/

select * from branch;
select * from issued_status;
select * from members;
select * from employees;
select * from issued_status;
select * from return_status;
select * from books;

-- Branch Perfomance Report --

create table branch_reports
AS
SELECT 
		b.branch_id,
		b.manager_id,																
		count(ist.issued_id) as number_of_book_issued,
		count(rs.return_id)  as number_of_book_return	,
		sum(bk.rental_price) as total_revenue	
FROM
	issued_status as ist
JOIN
	employees as e
ON
	e.emp_id = ist.issued_emp_id
join
	branch as b
ON
	e.branch_id = b.branch_id
 left JOIN
	return_status as rs
ON
	rs.issued_id = ist.issued_id
JOIN
	books as bk
ON
	ist.issued_book_isbn = bk.isbn
GROUP 
	BY
	1,2
ORDER
	BY
	total_revenue desc;

SELECT * FROM BRANCH_REPORTS;
/*
CTAS: Create a Table of Active Members
Use the Create Table AS (CTAS) statement to create a new table active_members containg members
who have issued at least one book in the last 6 months
*/

CREATE TABLE active_members
AS
SELECT * FROM members
where member_id IN(SELECT  		
					DISTINCT issued_member_id
				FROM 
					issued_status
				WHERE
					issued_date >= CURRENT_DATE - INTERVAL '2 MONTHS')

SELECT * FROM active_members;

/*
Find Employees with the Most Book Issues Processed
Write a Query to find the top 3 who have processed the most book issues. Display the employee name
number of books processed, and the total revenue generated from book rentals.
*/

--select--
-- employee_name, number of books processed, and their branch --

select * from employees;
select * from issued_status;
select * from branch;


select 
	e.emp_name,
	count(ist.issued_id) as books_processed,
	b.branch_id
from
	employees as e
join
	issued_status as ist
ON  
	e.emp_id = ist.issued_emp_id
join
	branch as b
ON
	e.branch_id = b.branch_id
GROUP 
	BY
	1,3
order
	by
	books_processed desc

/*
Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should first check if the book is available  (status = 'yes').
If the book is avaiable, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status - 'no'), the procedure should return an error message indicating 
that the book is currently not avaialable.
*/


CREATE OR REPLACE PROCEDURE issue_book(
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(30),
    p_issued_book_isbn VARCHAR(30),
    p_issued_emp_id VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status = 'No'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn: %', p_issued_book_isbn;
    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn %', p_issued_book_isbn;
    END IF;
END;
$$;
	
SELECT * FROM books
WHERE ISBN = '978-0-375-41398-8'
-- 978-0-553-29698-2 --	  'yes'
-- 978-0-375-41398-8 --  'no'

SELECT * FROM issued_status;


CALL issue_book('IS156','C108','978-0-375-41398-8 ','E104');




