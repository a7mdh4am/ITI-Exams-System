--@Zyad_ashraf

CREATE OR REPLACE PROCEDURE sp_InsertStudent
(
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
    )
    THEN
        RAISE EXCEPTION 'Email already exists';
    END IF;

    INSERT INTO Student
    (
        FullName,
        Email,
        BranchID,
        TrackID
    )
    VALUES
    (
        p_FullName,
        p_Email,
        p_BranchID,
        p_TrackID
    );

END;
$$;