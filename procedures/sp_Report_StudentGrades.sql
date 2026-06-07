CREATE OR REPLACE PROCEDURE sp_Report_StudentGrades(
    p_StudentID INT,
    INOUT p_cursor REFCURSOR DEFAULT 'student_grades_cursor'
)
LANGUAGE plpgsql
AS $$
/*
  Purpose    : Returns all exam grades and percentages for a student.
  Parameters :
    p_StudentID - The StudentID to report on
    p_cursor    - OPEN'ed for the result set; caller FETCHes from it
                  (within the same transaction) to read:
                  ExamID, ExamName, CourseName, TotalGrade, MaxPoints, Percentage
*/
BEGIN

    IF p_StudentID IS NULL THEN
        RAISE EXCEPTION 'ERROR 4001: StudentID is required.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = p_StudentID) THEN
        RAISE EXCEPTION 'ERROR 4002: StudentID % does not exist.', p_StudentID;
    END IF;

    OPEN p_cursor FOR
        SELECT
            e.ExamID,
            e.ExamName,
            c.CourseName,
            se.TotalGrade,
            se.MaxPoints,
            se.Percentage
        FROM       StudentExam  se
        JOIN       Exam         e  ON e.ExamID   = se.ExamID
        JOIN       Course       c  ON c.CourseID = e.CourseID
        WHERE      se.StudentID = p_StudentID
        ORDER BY   e.ExamDate;

END;
$$;
