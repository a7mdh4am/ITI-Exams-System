--Ashraf_mohamed

CREATE TABLE Question (
    QuestionID SERIAL PRIMARY KEY,
    QuestionText TEXT NOT NULL,
    Type VARCHAR(3) NOT NULL CHECK (Type IN ('MCQ', 'TF')),
    CourseID INT REFERENCES Course (CourseID) ON DELETE CASCADE
);