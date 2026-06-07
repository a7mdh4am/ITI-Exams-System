--Ashraf_mohamed

CREATE TABLE ModelAnswer (
    ModelAnswerID SERIAL PRIMARY KEY,
    QuestionID INT NOT NULL REFERENCES Question (QuestionID) ON DELETE CASCADE,
    CorrectOptionID INT NOT NULL REFERENCES Option (OptionID) ON DELETE CASCADE,
    UNIQUE (QuestionID)
);