--@Zyad_ashraf

CREATE OR REPLACE PROCEDURE sp_ManageBranch
(
    p_Action VARCHAR(20),
    p_BranchID INT DEFAULT NULL,
    p_BranchName VARCHAR(100) DEFAULT NULL,
    p_Location VARCHAR(200) DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_Action = 'INSERT' THEN

        INSERT INTO Branch
        (
            BranchName,
            Location
        )
        VALUES
        (
            p_BranchName,
            p_Location
        );

    ELSIF p_Action = 'UPDATE' THEN

        UPDATE Branch
        SET
            BranchName = p_BranchName,
            Location = p_Location
        WHERE BranchID = p_BranchID;

    ELSIF p_Action = 'DELETE' THEN

        DELETE FROM Branch
        WHERE BranchID = p_BranchID;

    END IF;

END;
$$;