--@Zyad_ashraf

CREATE OR REPLACE PROCEDURE sp_ManageTrack
(
    p_Action VARCHAR(20),
    p_TrackID INT DEFAULT NULL,
    p_TrackName VARCHAR(100) DEFAULT NULL,
    p_BranchID INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_Action = 'INSERT' THEN

        INSERT INTO Track
        (
            TrackName,
            BranchID
        )
        VALUES
        (
            p_TrackName,
            p_BranchID
        );

    ELSIF p_Action = 'UPDATE' THEN

        UPDATE Track
        SET
            TrackName = p_TrackName,
            BranchID = p_BranchID
        WHERE TrackID = p_TrackID;

    ELSIF p_Action = 'DELETE' THEN

        DELETE FROM Track
        WHERE TrackID = p_TrackID;

    END IF;

END;
$$;