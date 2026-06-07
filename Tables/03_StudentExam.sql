-- @a7mdh4am
CREATE TABLE StudentExam (
    StudentExamID SERIAL PRIMARY KEY,
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    StartTime TIMESTAMP NOT NULL,
    EndTime TIMESTAMP,
    TotalGrade DECIMAL(6, 2),
    MaxPoints DECIMAL(6, 2),
    Percentage DECIMAL(5, 2),
    FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exam (ExamID)
)