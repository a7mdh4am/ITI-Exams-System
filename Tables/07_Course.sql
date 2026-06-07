--Ashraf_mohamed

CREATE TABLE Course (
    CourseID SERIAL PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    TrackID INT REFERENCES Track (TrackID) ON DELETE SET NULL,
    InstructorID INT REFERENCES Instructor (InstructorID) ON DELETE SET NULL
);