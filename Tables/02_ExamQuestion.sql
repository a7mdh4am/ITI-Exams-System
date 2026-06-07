-- @a7mdh4am
CREATE TABLE ExamQuestion (
    ExamQID INT PRIMARY KEY AUTO_INCREMENT,
    ExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    FOREIGN KEY (ExamID) REFERENCES Exam (ExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question (QuestionID)
)