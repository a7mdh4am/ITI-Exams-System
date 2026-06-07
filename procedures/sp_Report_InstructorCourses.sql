CREATE OR REPLACE PROCEDURE sp_Report_InstructorCourses(
    p_instructor_id INT
)
LANGUAGE plpgsql
AS $$
/*
  Purpose    : Returns all courses taught by an instructor with enrolled student count.
  Parameters :
    p_instructor_id - The InstructorID to report on
  Returns    : CourseName, TrackName, BranchName, StudentCount
*/
BEGIN

    IF p_instructor_id IS NULL THEN
        RAISE EXCEPTION 'ERROR 3001: InstructorID is required.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = p_instructor_id) THEN
        RAISE EXCEPTION 'ERROR 3002: InstructorID % does not exist.', p_instructor_id;
    END IF;

    -- Report: courses + student count per course
    SELECT
        c.CourseID,
        c.CourseName,
        t.TrackName,
        b.BranchName,
        COUNT(s.StudentID)  AS StudentCount
    FROM       Course      c
    JOIN       Track       t  ON c.TrackID  = t.TrackID
    JOIN       Branch      b  ON t.BranchID = b.BranchID
    LEFT JOIN  Student     s  ON s.TrackID  = c.TrackID   -- students enrolled in same track
    WHERE      c.InstructorID = p_instructor_id
    GROUP BY   c.CourseID, c.CourseName, t.TrackName, b.BranchName
    ORDER BY   c.CourseName;

END;
$$;