--@Zyad_ashraf

CREATE TABLE Instructor (
    InstructorID SERIAL PRIMARY KEY,
    FullName VARCHAR(150) NOT NULL,
    DepartmentNo INT NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE
);