CREATE OR REPLACE PROCEDURE sp_SubmitExamAnswers(
    p_StudentID  INT,
    p_ExamID     INT,
    p_EndTime    TIMESTAMP,
    p_AnswersXML XML
)
LANGUAGE plpgsql
AS $$
/*
    p_AnswersXML sample:
    <Answers>
        <Answer ExamQID="101" OptionID="305"/>
        <Answer ExamQID="102" OptionID="310"/>
    </Answers>
*/
DECLARE
    v_StudentExamID INT;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = p_StudentID) THEN
        RAISE EXCEPTION 'StudentID % does not exist.', p_StudentID;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = p_ExamID) THEN
        RAISE EXCEPTION 'ExamID % does not exist.', p_ExamID;
    END IF;

    IF EXISTS (
        SELECT 1 FROM StudentExam
        WHERE StudentID = p_StudentID AND ExamID = p_ExamID
    ) THEN
        RAISE EXCEPTION 'Student % has already submitted Exam %.', p_StudentID, p_ExamID;
    END IF;

    -- Reject the whole submission if any answer references a question not on this exam
    IF EXISTS (
        SELECT 1
        FROM XMLTABLE('/Answers/Answer' PASSING p_AnswersXML
            COLUMNS ExamQID INT PATH '@ExamQID') AS x
        LEFT JOIN ExamQuestion eq
               ON eq.ExamQID = x.ExamQID AND eq.ExamID = p_ExamID
        WHERE eq.ExamQID IS NULL
    ) THEN
        RAISE EXCEPTION 'AnswersXML contains ExamQID values that do not belong to ExamID %.', p_ExamID;
    END IF;

    -- Step 1: Create the StudentExam attempt record
    INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime)
    VALUES (p_StudentID, p_ExamID, NOW(), p_EndTime)
    RETURNING StudentExamID INTO v_StudentExamID;

    -- Step 2: Parse the XML and insert all StudentAnswer rows atomically
    INSERT INTO StudentAnswer (StudentExamID, ExamQID, ChosenOptionID)
    SELECT v_StudentExamID, x.ExamQID, x.ChosenOptionID
    FROM XMLTABLE('/Answers/Answer' PASSING p_AnswersXML
        COLUMNS
            ExamQID        INT PATH '@ExamQID',
            ChosenOptionID INT PATH '@OptionID'
    ) AS x;

    RAISE NOTICE 'SUCCESS: StudentExam % created for Student % on Exam % with % answers recorded.',
        v_StudentExamID, p_StudentID, p_ExamID,
        (SELECT COUNT(*) FROM StudentAnswer WHERE StudentExamID = v_StudentExamID);

END;
$$;