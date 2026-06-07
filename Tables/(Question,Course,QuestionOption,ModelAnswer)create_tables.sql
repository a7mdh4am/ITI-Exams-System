
CREATE TABLE Course (
    CourseID     SERIAL PRIMARY KEY,
    CourseName   VARCHAR(100) NOT NULL,
    TrackID      INT REFERENCES Track(TrackID)      ON DELETE SET NULL,
    InstructorID INT REFERENCES Instructor(InstructorID) ON DELETE SET NULL
);

CREATE TABLE Question (
    QuestionID   SERIAL PRIMARY KEY,
    QuestionText TEXT        NOT NULL,
    Type         VARCHAR(3)  NOT NULL CHECK (Type IN ('MCQ', 'TF')),
    CourseID     INT REFERENCES Course(CourseID) ON DELETE CASCADE
);

CREATE TABLE Option (
    OptionID     SERIAL PRIMARY KEY,
    OptionText   VARCHAR(500) NOT NULL,
    QuestionID   INT NOT NULL REFERENCES Question(QuestionID) ON DELETE CASCADE,
    OrderNo      SMALLINT NOT NULL
);

CREATE TABLE ModelAnswer (
    ModelAnswerID   SERIAL PRIMARY KEY,
    QuestionID      INT NOT NULL REFERENCES Question(QuestionID) ON DELETE CASCADE,
    CorrectOptionID INT NOT NULL REFERENCES Option(OptionID)    ON DELETE CASCADE,
    UNIQUE (QuestionID)          -- one correct answer per question
);
