-- @a7mdh4am
CREATE TABLE Exam (
    ExamID SERIAL PRIMARY KEY,
    ExamName VARCHAR (200) NOT NULL,
    CourseID INT NOT NULL,
    ExamDate DATE NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Course (CourseID)
)