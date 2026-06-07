--Ashraf_mohamed

CREATE OR REPLACE PROCEDURE sp_ManageQuestion(
    p_action          VARCHAR(10),      -- 'INSERT', 'UPDATE', 'DELETE'
    p_question_id     INT          DEFAULT NULL,
    p_question_text   TEXT         DEFAULT NULL,
    p_type            VARCHAR(3)   DEFAULT NULL,   -- 'MCQ' or 'TF'
    p_course_id       INT          DEFAULT NULL,
    -- Option texts (MCQ: all 4 required | TF: opt1='True', opt2='False')
    p_option1         VARCHAR(500) DEFAULT NULL,
    p_option2         VARCHAR(500) DEFAULT NULL,
    p_option3         VARCHAR(500) DEFAULT NULL,   -- MCQ only
    p_option4         VARCHAR(500) DEFAULT NULL,   -- MCQ only
    p_correct_order   SMALLINT     DEFAULT NULL    -- 1-4 for MCQ, 1-2 for TF
)
LANGUAGE plpgsql
AS $$
/*
  Purpose    : Manage questions (MCQ & T/F) with their options and model answers.
  Parameters :
    p_action        - INSERT | UPDATE | DELETE
    p_question_id   - Required for UPDATE, DELETE
    p_question_text - The question body
    p_type          - 'MCQ' (4 options) or 'TF' (2 options)
    p_course_id     - FK to Course
    p_option1..4    - Option texts (p_option3/4 only for MCQ)
    p_correct_order - Order number of the correct option (1–4 MCQ, 1–2 TF)
*/
DECLARE
    v_question_id    INT;
    v_option1_id     INT;
    v_option2_id     INT;
    v_option3_id     INT;
    v_option4_id     INT;
    v_correct_opt_id INT;
BEGIN

    -- ══════════════════════════════
    --  INSERT
    -- ══════════════════════════════
    IF p_action = 'INSERT' THEN

        -- Validate required fields
        IF p_question_text IS NULL OR p_type IS NULL OR p_course_id IS NULL THEN
            RAISE EXCEPTION 'ERROR 2001: QuestionText, Type, and CourseID are required.';
        END IF;

        IF p_type NOT IN ('MCQ', 'TF') THEN
            RAISE EXCEPTION 'ERROR 2002: Type must be MCQ or TF. Got: %', p_type;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = p_course_id) THEN
            RAISE EXCEPTION 'ERROR 2003: CourseID % does not exist.', p_course_id;
        END IF;

        IF p_correct_order IS NULL THEN
            RAISE EXCEPTION 'ERROR 2004: p_correct_order is required (1-4 for MCQ, 1-2 for TF).';
        END IF;

        -- MCQ validations
        IF p_type = 'MCQ' THEN
            IF p_option1 IS NULL OR p_option2 IS NULL OR p_option3 IS NULL OR p_option4 IS NULL THEN
                RAISE EXCEPTION 'ERROR 2005: MCQ requires all 4 options.';
            END IF;
            IF p_correct_order NOT BETWEEN 1 AND 4 THEN
                RAISE EXCEPTION 'ERROR 2006: p_correct_order must be 1–4 for MCQ.';
            END IF;
        END IF;

        -- TF validations
        IF p_type = 'TF' THEN
            IF p_option1 IS NULL OR p_option2 IS NULL THEN
                RAISE EXCEPTION 'ERROR 2007: T/F requires 2 options (True / False).';
            END IF;
            IF p_correct_order NOT BETWEEN 1 AND 2 THEN
                RAISE EXCEPTION 'ERROR 2008: p_correct_order must be 1 or 2 for TF.';
            END IF;
        END IF;

        -- Step 1: Insert Question
        INSERT INTO Question (QuestionText, Type, CourseID)
        VALUES (p_question_text, p_type, p_course_id)
        RETURNING QuestionID INTO v_question_id;

        -- Step 2: Insert Options
        INSERT INTO Option (OptionText, QuestionID, OrderNo)
        VALUES (p_option1, v_question_id, 1)
        RETURNING OptionID INTO v_option1_id;

        INSERT INTO Option (OptionText, QuestionID, OrderNo)
        VALUES (p_option2, v_question_id, 2)
        RETURNING OptionID INTO v_option2_id;

        IF p_type = 'MCQ' THEN
            INSERT INTO Option (OptionText, QuestionID, OrderNo)
            VALUES (p_option3, v_question_id, 3)
            RETURNING OptionID INTO v_option3_id;

            INSERT INTO Option (OptionText, QuestionID, OrderNo)
            VALUES (p_option4, v_question_id, 4)
            RETURNING OptionID INTO v_option4_id;
        END IF;

        -- Step 3: Resolve correct OptionID from order number
        v_correct_opt_id := CASE p_correct_order
            WHEN 1 THEN v_option1_id
            WHEN 2 THEN v_option2_id
            WHEN 3 THEN v_option3_id
            WHEN 4 THEN v_option4_id
        END;

        -- Step 4: Insert ModelAnswer
        INSERT INTO ModelAnswer (QuestionID, CorrectOptionID)
        VALUES (v_question_id, v_correct_opt_id);

        RAISE NOTICE 'SUCCESS: % Question inserted with ID=%, % options, and model answer set to option %.', 
                      p_type, v_question_id, 
                      CASE p_type WHEN 'MCQ' THEN 4 ELSE 2 END,
                      p_correct_order;

    -- ══════════════════════════════
    --  UPDATE  (question text only)
    -- ══════════════════════════════
    ELSIF p_action = 'UPDATE' THEN

        IF p_question_id IS NULL THEN
            RAISE EXCEPTION 'ERROR 2009: QuestionID is required for UPDATE.';
        END IF;

        IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = p_question_id) THEN
            RAISE EXCEPTION 'ERROR 2010: QuestionID % does not exist.', p_question_id;
        END IF;

        -- Block update if exam is already started (model answer lock rule)
        IF EXISTS (
            SELECT 1
            FROM   ModelAnswer   ma
            JOIN   ExamQuestion  eq ON eq.QuestionID = ma.QuestionID
            JOIN   StudentExam   se ON se.ExamID     = eq.ExamID
            WHERE  ma.QuestionID = p_question_id
        ) THEN
            RAISE EXCEPTION 'ERROR 2011: Cannot update question % — it belongs to an exam that has been started.', p_question_id;
        END IF;

        UPDATE Question
        SET
            QuestionText = COALESCE(p_question_text, QuestionText),
            CourseID     = COALESCE(p_course_id,     CourseID)
        WHERE QuestionID = p_question_id;

        RAISE NOTICE 'SUCCESS: QuestionID % updated.', p_question_id;

    -- ══════════════════════════════
    --  DELETE
    -- ══════════════════════════════
    ELSIF p_action = 'DELETE' THEN

        IF p_question_id IS NULL THEN
            RAISE EXCEPTION 'ERROR 2009: QuestionID is required for DELETE.';
        END IF;

        IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = p_question_id) THEN
            RAISE EXCEPTION 'ERROR 2010: QuestionID % does not exist.', p_question_id;
        END IF;

        -- Block delete if ModelAnswer exists (RESTRICT rule from SRS)
        IF EXISTS (SELECT 1 FROM ModelAnswer WHERE QuestionID = p_question_id) THEN
            RAISE EXCEPTION 'ERROR 2012: Cannot delete QuestionID % — a ModelAnswer exists. Remove it first.', p_question_id;
        END IF;

        -- Cascade: Options deleted via FK ON DELETE CASCADE
        DELETE FROM Question WHERE QuestionID = p_question_id;

        RAISE NOTICE 'SUCCESS: QuestionID % and its options deleted.', p_question_id;

    ELSE
        RAISE EXCEPTION 'ERROR 2000: Invalid action "%". Use INSERT | UPDATE | DELETE.', p_action;
    END IF;

END;
$$;