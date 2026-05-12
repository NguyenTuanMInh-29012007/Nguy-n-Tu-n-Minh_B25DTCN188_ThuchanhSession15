CREATE DATABASE thuchanh15;
use thuchanh15;


CREATE TABLE Students(
	student_id VARCHAR(5) primary key,
    full_name VARCHAR(50) NOT NULL,
    total_debt DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE Subjects(
	subject_id VARCHAR(5) primary key,
    subject_name VARCHAR(50) NOT NULL,
    credits INT CHECK(credits > 0)
);

CREATE TABLE Grades(
	PRIMARY KEY(student_id, subject_id),
	student_id VARCHAR(5),
    foreign key(student_id) references Students(student_id),
    subject_id VARCHAR(5),
    foreign key(subject_id) references Subjects(subject_id),
    score DECIMAL(4,2) CHECK(score BETWEEN 0 AND 10)
);

CREATE TABLE Grade_log(
	log_id INT PRIMARY KEY auto_increment,
    student_id VARCHAR(5),
    foreign key(student_id) references Students(student_id),
    old_score DECIMAL(4,2),
    new_score DECIMAL(4,2),
    change_date DATETIME DEFAULT current_timestamp
);


-- Phần A : cơ bản
-- câu 1:
DELIMITER //
CREATE TRIGGER tg_check_score
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
	IF NEW.score < 0 THEN
		SET NEW.score = 0;
	ELSEIF NEW>score > 10 THEN
		SET NEW.score = 10;
	ELSE 
		INSERT INTO Grades(score)
        VALUES(NEW.score);
	END IF;
END //
DELIMITER ;


-- câu 2:
DELIMITER //
CREATE PROCEDURE addStudent(
	IN p_student_id VARCHAR(5),
    IN p_full_name VARCHAR(50),
    IN p_total_debt DECIMAL(10,2))
BEGIN
	IF EXISTS(
		SELECT 1
        FROM students
        WHERE student_id = p_student_id
    ) THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Sinh viên này đã tồn tại';
	ELSE 
		START TRANSACTION;
        
        INSERT INTO students(student_id, full_name, total_debt)
		VALUES(p_student_id, p_full_name, p_total_debt);
        
        COMMIT;
	END IF;
END //
DELIMITER ;

INSERT INTO students
VALUES('SV02', 'Hà Bich Ngoc', 5000000);



-- Phần B: Khá
-- Câu 3:
DELIMITER //
CREATE TRIGGER tg_log_grade_update
AFTER UPDATE ON Grades
FOR EACH ROW
BEGIN
	INSERT INTO Grade_log(student_id, old_score, new_score)
    VALUES(OLD.student_id, OLD.old_score, NEW.new_score);
END //
DELIMITER ;


-- Câu 4
DELIMITER //
CREATE PROCEDURE sp_pay_tuition(
	IN p_student_id VARCHAR(5),
    IN p_total_debt DECIMAL(10,2)
)
BEGIN
	DECLARE v_total_debt DECIMAL(10,2);
    
    START TRANSACTION;
      
    SELECT total_debt INTO v_total_debt
    FROM students
    WHERE student_id = p_student_id;
    
    UPDATE students
	SET total_debt = total_debt - p_total_debt
	WHERE student_id = p_student_id;
    
    
    IF v_total_debt - p_total_debt < 0 THEN 
		ROLLBACK;
	ELSE
		UPDATE students
		SET total_debt = total_debt - p_total_debt
		WHERE student_id = p_student_id;
    
		COMMIT;
	END IF;
	
END //
DELIMITER ;



CALL  sp_pay_tuition('SV02', 9000000);





SELECT * FROM Students;
SELECT * FROM Subjects;
SELECT * FROM Grades;
SELECT * FROM Grade_log;