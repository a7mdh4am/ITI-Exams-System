-- @a7mdh4am
CREATE TABLE StudentAnswer (
    AnswerID INT PRIMARY KEY AUTO_INCREMENT,
    StudentExamID INT NOT NULL,
    ExamQID INT NOT NULL,
    ChosenOptionID INT NOT NULL,
    Grade DECIMAL(6, 2),
    FOREIGN KEY (StudentExamID) REFERENCES StudentExam (StudentExamID),
    FOREIGN KEY (ExamQID) REFERENCES ExamQuestion (ExamQID),
    FOREIGN KEY (ChosenOptionID) REFERENCES Option (OptionID)
)