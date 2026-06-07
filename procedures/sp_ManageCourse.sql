CREATE OR REPLACE PROCEDURE sp_ManageCourse(
    p_action        VARCHAR(10),   -- 'INSERT', 'UPDATE', 'DELETE', 'GET'
    p_course_id     INT     DEFAULT NULL,
    p_course_name   VARCHAR(100) DEFAULT NULL,
    p_track_id      INT     DEFAULT NULL,
    p_instructor_id INT     DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
/*
  Purpose    : Full CRUD operations for the Course table.
  Parameters :
    p_action        - Operation to perform: INSERT | UPDATE | DELETE | GET
    p_course_id     - Required for UPDATE, DELETE, GET
    p_course_name   - Course name (INSERT / UPDATE)
    p_track_id      - FK to Track (INSERT / UPDATE)
    p_instructor_id - FK to Instructor (INSERT / UPDATE)
*/
BEGIN

    -- ══════════════════════════════
    --  INSERT
    -- ══════════════════════════════
    IF p_action = 'INSERT' THEN

        -- Validate required fields
        IF p_course_name IS NULL OR p_track_id IS NULL OR p_instructor_id IS NULL THEN
            RAISE EXCEPTION 'ERROR 1001: CourseName, TrackID, and InstructorID are required for INSERT.';
        END IF;

        -- Validate TrackID exists
        IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = p_track_id) THEN
            RAISE EXCEPTION 'ERROR 1002: TrackID % does not exist.', p_track_id;
        END IF;

        -- Validate InstructorID exists
        IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = p_instructor_id) THEN
            RAISE EXCEPTION 'ERROR 1003: InstructorID % does not exist.', p_instructor_id;
        END IF;

        INSERT INTO Course (CourseName, TrackID, InstructorID)
        VALUES (p_course_name, p_track_id, p_instructor_id);

        RAISE NOTICE 'SUCCESS: Course "%" inserted successfully.', p_course_name;

    -- ══════════════════════════════
    --  UPDATE
    -- ══════════════════════════════
    ELSIF p_action = 'UPDATE' THEN

        IF p_course_id IS NULL THEN
            RAISE EXCEPTION 'ERROR 1004: CourseID is required for UPDATE.';
        END IF;

        IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = p_course_id) THEN
            RAISE EXCEPTION 'ERROR 1005: CourseID % does not exist.', p_course_id;
        END IF;

        -- Validate FK if provided
        IF p_track_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = p_track_id) THEN
            RAISE EXCEPTION 'ERROR 1002: TrackID % does not exist.', p_track_id;
        END IF;

        IF p_instructor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = p_instructor_id) THEN
            RAISE EXCEPTION 'ERROR 1003: InstructorID % does not exist.', p_instructor_id;
        END IF;

        UPDATE Course
        SET
            CourseName   = COALESCE(p_course_name,   CourseName),
            TrackID      = COALESCE(p_track_id,      TrackID),
            InstructorID = COALESCE(p_instructor_id, InstructorID)
        WHERE CourseID = p_course_id;

        RAISE NOTICE 'SUCCESS: CourseID % updated successfully.', p_course_id;

    -- ══════════════════════════════
    --  DELETE
    -- ══════════════════════════════
    ELSIF p_action = 'DELETE' THEN

        IF p_course_id IS NULL THEN
            RAISE EXCEPTION 'ERROR 1004: CourseID is required for DELETE.';
        END IF;

        IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = p_course_id) THEN
            RAISE EXCEPTION 'ERROR 1005: CourseID % does not exist.', p_course_id;
        END IF;

        DELETE FROM Course WHERE CourseID = p_course_id;

        RAISE NOTICE 'SUCCESS: CourseID % deleted successfully.', p_course_id;

    -- ══════════════════════════════
    --  GET
    -- ══════════════════════════════
    ELSIF p_action = 'GET' THEN

        IF p_course_id IS NOT NULL THEN
            -- Get single course
            SELECT c.CourseID, c.CourseName,
                   t.TrackName, i.FullName AS InstructorName
            FROM   Course c
            JOIN   Track      t ON c.TrackID      = t.TrackID
            JOIN   Instructor i ON c.InstructorID = i.InstructorID
            WHERE  c.CourseID = p_course_id;
        ELSE
            -- Get all courses
            SELECT c.CourseID, c.CourseName,
                   t.TrackName, i.FullName AS InstructorName
            FROM   Course c
            JOIN   Track      t ON c.TrackID      = t.TrackID
            JOIN   Instructor i ON c.InstructorID = i.InstructorID
            ORDER  BY c.CourseID;
        END IF;

    ELSE
        RAISE EXCEPTION 'ERROR 1000: Invalid action "%". Use INSERT | UPDATE | DELETE | GET.', p_action;
    END IF;

END;
$$;