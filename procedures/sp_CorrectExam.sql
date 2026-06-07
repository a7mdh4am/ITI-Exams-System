CREATE OR REPLACE PROCEDURE sp_CorrectExam(
    p_StudentExamID INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ExamID     INT;
    v_MaxPoints  DECIMAL(6, 2);
    v_TotalGrade DECIMAL(6, 2);
BEGIN

    IF NOT EXISTS (SELECT 1 FROM StudentExam WHERE StudentExamID = p_StudentExamID) THEN
        RAISE EXCEPTION 'StudentExamID % does not exist.', p_StudentExamID;
    END IF;

    SELECT ExamID INTO v_ExamID
    FROM StudentExam
    WHERE StudentExamID = p_StudentExamID;

    -- Step 1: Grade each answer by comparing it to the question's ModelAnswer
    UPDATE StudentAnswer sa
    SET Grade = CASE WHEN sa.ChosenOptionID = ma.CorrectOptionID THEN 1 ELSE 0 END
    FROM ExamQuestion eq
    JOIN ModelAnswer  ma ON ma.QuestionID = eq.QuestionID
    WHERE sa.ExamQID = eq.ExamQID
      AND sa.StudentExamID = p_StudentExamID;

    -- Step 2: Aggregate the results
    SELECT COUNT(*) INTO v_MaxPoints
    FROM ExamQuestion
    WHERE ExamID = v_ExamID;

    SELECT COALESCE(SUM(Grade), 0) INTO v_TotalGrade
    FROM StudentAnswer
    WHERE StudentExamID = p_StudentExamID;

    -- Step 3: Update the StudentExam with the final grade and percentage
    UPDATE StudentExam
    SET TotalGrade = v_TotalGrade,
        MaxPoints  = v_MaxPoints,
        Percentage = CASE WHEN v_MaxPoints > 0
                          THEN ROUND((v_TotalGrade / v_MaxPoints) * 100, 2)
                          ELSE 0
                     END
    WHERE StudentExamID = p_StudentExamID;

    RAISE NOTICE 'SUCCESS: StudentExam % corrected. TotalGrade = % out of %.',
        p_StudentExamID, v_TotalGrade, v_MaxPoints;

END;
$$;
