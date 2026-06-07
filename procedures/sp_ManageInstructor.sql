--@Zyad_ashraf

CREATE OR REPLACE PROCEDURE sp_ManageInstructor
(
    p_Action VARCHAR(20),
    p_InstructorID INT DEFAULT NULL,
    p_FullName VARCHAR(150) DEFAULT NULL,
    p_DepartmentNo INT DEFAULT NULL,
    p_Email VARCHAR(150) DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_Action = 'INSERT' THEN

        INSERT INTO Instructor
        (
            FullName,
            DepartmentNo,
            Email
        )
        VALUES
        (
            p_FullName,
            p_DepartmentNo,
            p_Email
        );

    ELSIF p_Action = 'UPDATE' THEN

        UPDATE Instructor
        SET
            FullName = p_FullName,
            DepartmentNo = p_DepartmentNo,
            Email = p_Email
        WHERE InstructorID = p_InstructorID;

    ELSIF p_Action = 'DELETE' THEN

        DELETE FROM Instructor
        WHERE InstructorID = p_InstructorID;

    END IF;

END;
$$;