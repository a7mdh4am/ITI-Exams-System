--Ashraf_mohamed

CREATE TABLE Option (
    OptionID SERIAL PRIMARY KEY,
    OptionText VARCHAR(500) NOT NULL,
    QuestionID INT NOT NULL REFERENCES Question (QuestionID) ON DELETE CASCADE,
    OrderNo SMALLINT NOT NULL
);