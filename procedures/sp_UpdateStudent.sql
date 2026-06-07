--@Zyad_ashraf

CREATE OR REPLACE PROCEDURE sp_UpdateStudent
(
    p_StudentID INT,
    p_FullName VARCHAR(150),
    p_Email VARCHAR(150),
    p_BranchID INT,
    p_TrackID INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Student
        WHERE Email = p_Email
        AND StudentID <> p_StudentID
    )
    THEN
        RAISE EXCEPTION 'Email already exists';
    END IF;

    UPDATE Student
    SET
        FullName = p_FullName,
        Email = p_Email,
        BranchID = p_BranchID,
        TrackID = p_TrackID
    WHERE StudentID = p_StudentID;

END;
$$;