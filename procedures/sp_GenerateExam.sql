CREATE OR REPLACE PROCEDURE sp_GenerateExam(
    p_CourseID  INT,
    p_ExamName  VARCHAR(200),
    p_NumMCQ    INT,
    p_NumTF     INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ExamID       INT;
    v_AvailableMCQ INT;
    v_AvailableTF  INT;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = p_CourseID) THEN
        RAISE EXCEPTION 'CourseID % does not exist.', p_CourseID;
    END IF;

    SELECT COUNT(*) INTO v_AvailableMCQ
    FROM Question
    WHERE CourseID = p_CourseID AND Type = 'MCQ';

    SELECT COUNT(*) INTO v_AvailableTF
    FROM Question
    WHERE CourseID = p_CourseID AND Type = 'TF';

    IF v_AvailableMCQ < p_NumMCQ THEN
        RAISE EXCEPTION 'Not enough MCQ questions for CourseID % (need %, have %).',
            p_CourseID, p_NumMCQ, v_AvailableMCQ;
    END IF;

    IF v_AvailableTF < p_NumTF THEN
        RAISE EXCEPTION 'Not enough TF questions for CourseID % (need %, have %).',
            p_CourseID, p_NumTF, v_AvailableTF;
    END IF;

    -- Step 1: Create the Exam record
    INSERT INTO Exam (ExamName, CourseID, ExamDate)
    VALUES (p_ExamName, p_CourseID, CURRENT_DATE)
    RETURNING ExamID INTO v_ExamID;

    -- Step 2: Randomly pick MCQ questions for this course
    INSERT INTO ExamQuestion (ExamID, QuestionID)
    SELECT v_ExamID, QuestionID
    FROM Question
    WHERE CourseID = p_CourseID AND Type = 'MCQ'
    ORDER BY random()
    LIMIT p_NumMCQ;

    -- Step 3: Randomly pick TF questions for this course
    INSERT INTO ExamQuestion (ExamID, QuestionID)
    SELECT v_ExamID, QuestionID
    FROM Question
    WHERE CourseID = p_CourseID AND Type = 'TF'
    ORDER BY random()
    LIMIT p_NumTF;

    RAISE NOTICE 'SUCCESS: Exam % ("%") created with % MCQ and % TF questions.',
        v_ExamID, p_ExamName, p_NumMCQ, p_NumTF;

END;
$$;
