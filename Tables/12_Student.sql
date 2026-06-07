--@Zyad_ashraf

CREATE TABLE Student (
    StudentID SERIAL PRIMARY KEY,
    FullName VARCHAR(150) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    CONSTRAINT FK_Student_Branch FOREIGN KEY (BranchID) REFERENCES Branch (BranchID),
    CONSTRAINT FK_Student_Track FOREIGN KEY (TrackID) REFERENCES Track (TrackID)
);