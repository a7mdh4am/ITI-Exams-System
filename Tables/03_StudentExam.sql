-- @a7mdh4am
CREATE TABLE StudentExam (
    StudentExamID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME,
    TotalGrade DECIMAL(6, 2),
    MaxPoints DECIMAL(6, 2),
    FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exam (ExamID)
)