

CREATE TABLE Course (
    CourseID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    TrackID INT NOT NULL,
    InstructorID INT NOT NULL
);


CREATE TABLE Question (
    QuestionID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    QuestionText TEXT NOT NULL,
    Type VARCHAR(3) NOT NULL
        CHECK (Type IN ('MCQ', 'TF')),
    CourseID INT NOT NULL,

    CONSTRAINT FK_Question_Course
        FOREIGN KEY (CourseID)
        REFERENCES Course(CourseID)
        ON DELETE CASCADE
);


CREATE TABLE QuestionOption (
    OptionID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    OptionText VARCHAR(500) NOT NULL,
    QuestionID INT NOT NULL,
    OrderNo SMALLINT NOT NULL,

    CONSTRAINT FK_Option_Question
        FOREIGN KEY (QuestionID)
        REFERENCES Question(QuestionID)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Question_Option_Order
        UNIQUE (QuestionID, OrderNo)
);

CREATE TABLE ModelAnswer (
    ModelAnswerID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    QuestionID INT NOT NULL UNIQUE,
    CorrectOptionID INT NOT NULL,

    CONSTRAINT FK_ModelAnswer_Question
        FOREIGN KEY (QuestionID)
        REFERENCES Question(QuestionID)
        ON DELETE CASCADE,

    CONSTRAINT FK_ModelAnswer_Option
        FOREIGN KEY (CorrectOptionID)
        REFERENCES QuestionOption(OptionID)
);