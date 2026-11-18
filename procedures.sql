
IF OBJECT_ID('AddAcademicMember', 'P') IS NOT NULL
    DROP PROCEDURE AddAcademicMember;
GO

CREATE OR ALTER PROCEDURE AddAcademicMember
    @FullName VARCHAR(150),
    @UniversityIDNo VARCHAR(50),
    @Email VARCHAR(150),
    @Phone VARCHAR(50),
    @AcademicRank VARCHAR(50),
    @EmploymentStatus VARCHAR(50),
    @AccountStatus VARCHAR(50),
    @FacultyID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY 
    IF @FullName IS NULL OR @FullName = ''
    BEGIN 
        SELECT 'Name cannot be Null' AS ConfirmationMessage; RETURN;
    END

    IF @UniversityIDNo IS NULL OR @UniversityIDNo = ''
    BEGIN 
        SELECT 'ID cannot be NULL' AS ConfirmationMessage; RETURN;
    END

    IF @Email IS NULL OR @Email = ''
    BEGIN
        SELECT 'E-mail cannot be NULL' AS ConfirmationMessage;RETURN;
    END

    IF @Email NOT LIKE '%@%' 
    BEGIN
        SELECT 'Wrong E-mail format' AS ConfirmationMessage; RETURN;
    END

    IF @AccountStatus IS NULL OR @AccountStatus NOT IN ('Active', 'Suspended', 'Deactivated')
    BEGIN
        SELECT 'Account status must be Active, Suspended or Deactivated' AS ConfirmationMessage; RETURN;
    END

    IF @FacultyID IS NULL OR NOT EXISTS(SELECT 1 FROM Faculty WHERE FacultyID = @FacultyID)
    BEGIN
        SELECT 'Faculty doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Academic_Member WHERE UniversityIDNo = @UniversityIDNo)
    BEGIN
        SELECT 'A member with this ID already exists' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Academic_Member WHERE Email = @Email)
    BEGIN
        SELECT 'A member with this Email already exists' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Academic_Member (
        FullName, UniversityIDNo, Email, Phone, 
        AcademicRank, EmploymentStatus, AccountStatus, FacultyID
    )
    VALUES (
        @FullName, @UniversityIDNo, @Email, @Phone, 
        @AcademicRank, @EmploymentStatus, @AccountStatus, @FacultyID
    );

    SELECT 'Academic member added successfully.' AS ConfirmationMessage, SCOPE_IDENTITY() AS NewMemberID;

    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO


CREATE OR ALTER FUNCTION ViewMemberInfo(
    @MemberID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Academic_Member
    WHERE MemberID = @MemberID
);
GO

CREATE OR ALTER PROCEDURE UpdateMemberContactInfo
    @MemberID INT,
    @Email VARCHAR(150),
    @Phone VARCHAR(50)

    AS
    BEGIN 
        SET NOCOUNT ON;

        BEGIN TRY
            IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
            BEGIN
                SELECT 'Member does not exist.' AS ConfirmationMessage; RETURN; 
            END

            IF @Email IS NULL OR @Email = ''
            BEGIN
                SELECT 'E-mail cannot be NULL' AS ConfirmationMessage;RETURN;
            END 

            IF EXISTS(SELECT 1 FROM Academic_Member WHERE @MemberID <> MemberID AND @EMAIL = Email)
            BEGIN
                SELECT 'Email already in use.' AS ConfirmationMessage; RETURN;
            END

            IF @Email NOT LIKE '%@%' 
            BEGIN
                SELECT 'Wrong E-mail format' AS ConfirmationMessage;RETURN;
            END
            


        UPDATE Academic_Member
        SET Email = @Email, Phone = @Phone
        WHERE MemberID = @MemberID;

        SELECT 'Contact information updated successfully.' AS ConfirmationMessage;

        END TRY

        BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
        END CATCH
    END;
    GO

CREATE OR ALTER PROCEDURE UpdateAccountStatus
    @MemberID INT,
    @AccountStatus VARCHAR(50)


    AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
        BEGIN
            SELECT 'Member does not exist.' AS ConfirmationMessage; RETURN; 
        END

        IF @AccountStatus IS NULL OR @AccountStatus = ''
        BEGIN
            SELECT 'Account status cannot be NULL' AS ConfirmationMessage;RETURN;
        END

        IF @AccountStatus NOT IN ('Active', 'Suspended', 'Deactivated')
        BEGIN
            SELECT 'Account status must be Active, Suspended or Deactivated' AS ConfirmationMessage; RETURN;
        END

         IF EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID AND AccountStatus = @AccountStatus)
         BEGIN
             SELECT 'Status already assigned.' AS ConfirmationMessage; RETURN;
         END

        UPDATE Academic_Member
        SET AccountStatus = @AccountStatus
        WHERE MemberID = @MemberID;


        SELECT 'Account status updated successfully.' AS ConfirmationMessage;
        END TRY

        BEGIN CATCH
            SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
        END CATCH
            
    END;
    GO

CREATE OR ALTER PROCEDURE AssignInstructorRole
    @MemberID INT,
    @ResearchArea VARCHAR(150),
    @OfficeLocation VARCHAR(50),
    @TeachingLoad INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    IF EXISTS(SELECT 1 FROM Academic_Instructor WHERE MemberID = @MemberID)
    BEGIN 
        SELECT 'Already an instructor' AS ConfirmationMessage; RETURN;
    END

    IF @TeachingLoad < 0
    BEGIN 
        SELECT 'Teaching load cannot be negative' AS ConfirmationMessage;RETURN;
    END
    
    IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Not an academic member' AS ConfirmationMessage;RETURN;
    END


    
    INSERT INTO Academic_Instructor (
        MemberID, 
        ResearchArea, 
        OfficeLocation, 
        TeachingLoad
    )
    VALUES (
        @MemberID, 
        @ResearchArea, 
        @OfficeLocation, 
        @TeachingLoad
    );

    SELECT 'Academic instructor role assigned successfully.' AS ConfirmationMessage;

    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH

END;
GO

CREATE OR ALTER PROCEDURE AssignTeachingAssistantRole
    @MemberID INT,
    @AssistantLevel VARCHAR(50),
    @SupervisorID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Not an academic member' AS ConfirmationMessage;RETURN;
    END

    IF @SupervisorID IS NULL
    BEGIN
        SELECT 'SupervisorID cannot be null' AS ConfirmationMessage;RETURN;
    END

    IF @MemberID = @SupervisorID
    BEGIN
        SELECT 'A TA cannot supervise themselves' AS ConfirmationMessage;RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Academic_Instructor WHERE MemberID = @SupervisorID)
    BEGIN
        SELECT 'Supervisor is not an instructor' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Teaching_Assistant WHERE MemberID = @MemberID)
    BEGIN 
        SELECT 'Already a TA' AS ConfirmationMessage; RETURN;
    END


   
    INSERT INTO Teaching_Assistant (
        MemberID,
        AssistantLevel, 
        SupervisorID
    )
    VALUES (
        @MemberID, 
        @AssistantLevel, 
        @SupervisorID
    );

    SELECT 'Teaching assistant role assigned successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH 
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AssignDean
    @MemberID INT,
    @FacultyID INT,
    @ApprovalAuthorityScope VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Not an academic member' AS ConfirmationMessage;RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Faculty WHERE FacultyID = @FacultyID)
    BEGIN
        SELECT 'Not a faculty' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Faculty WHERE FacultyID = @FacultyID AND DeanID IS NOT NULL)
    BEGIN
        SELECT 'Faculty already has a dean' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Faculty WHERE DeanID = @MemberID)
    BEGIN
        SELECT 'Dean already assigned to a faculty' AS ConfirmationMessage;RETURN;
    END

    BEGIN TRAN;

    IF NOT EXISTS(SELECT 1 FROM Dean WHERE MemberID = @MemberID)
        INSERT INTO Dean (
            MemberID,
            ApprovalAuthorityScope
        )
        VALUES (
            @MemberID,
            @ApprovalAuthorityScope
        );
    ELSE
        UPDATE Dean
        SET ApprovalAuthorityScope = @ApprovalAuthorityScope
        WHERE MemberID = @MemberID;

    UPDATE Faculty
    SET DeanID = @MemberID
    WHERE FacultyID = @FacultyID;

    COMMIT;

    SELECT 'Dean assigned successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AssignManagementRole
    @MemberID INT,
    @ManagementTitle VARCHAR(150),
    @DecisionAuthorityLevel VARCHAR(50),
    @GovernanceScope VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Not an academic member' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM University_Management WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Member already exists' AS ConfirmationMessage;RETURN;
    END
    
    INSERT INTO University_Management (
        MemberID,
        ManagementTitle, 
        DecisionAuthorityLevel, 
        GovernanceScope
    )
    VALUES (
        @MemberID, 
        @ManagementTitle, 
        @DecisionAuthorityLevel, 
        @GovernanceScope
    );

    SELECT 'University management role assigned successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
        
END;
GO

CREATE OR ALTER PROCEDURE AssignReviewerRole
    @MemberID INT,
    @ReviewDomain VARCHAR(150),
    @ReviewAuthorityLevel VARCHAR(50),
    @CommitteeMembership VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
    BEGIN 
        SELECT 'Academic Member Doesnt Exist' AS ConfirmationMessage;RETURN;
    END

    IF @CommitteeMembership IS NULL OR  @CommitteeMembership = ''
    BEGIN
        SELECT 'CommitteeMembership cannot be empty' AS ConfirmationMessage;RETURN;
    END
    
    IF EXISTS(SELECT 1 FROM Curriculum_Reviewer WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Member is already a curriculum reviewer' AS ConfirmationMessage;RETURN;
    END

    BEGIN TRAN;

    INSERT INTO Curriculum_Reviewer (MemberID, ReviewDomain, ReviewAuthorityLevel)
    VALUES (@MemberID, @ReviewDomain, @ReviewAuthorityLevel);

    INSERT INTO Reviewer_Committee (MemberID, CommitteeMembership)
    VALUES (@MemberID, @CommitteeMembership);

    COMMIT;

    SELECT 'Curriculum reviewer role assigned successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
    
END;
GO

CREATE OR ALTER PROCEDURE GrantAccessScope
    @MemberID INT,
    @AccessScope VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Not an academic member' AS ConfirmationMessage;RETURN;
    END

    IF @AccessScope IS NULL OR @AccessScope = ''
    BEGIN
        SELECT 'Access scope cannot be NULL' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Member_Access_Scope WHERE MemberID = @MemberID AND AccessScope = @AccessScope)
    BEGIN
        SELECT 'Member already holds this scope' AS ConfirmationMessage;RETURN;
    END


    
    INSERT INTO Member_Access_Scope (
        MemberID, 
        AccessScope
    )
    VALUES (
        @MemberID, 
        @AccessScope
    );

    SELECT 'Access scope granted successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE RevokeAccessScope
    @MemberID INT,
    @AccessScope VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Member_Access_Scope WHERE MemberID = @MemberID AND AccessScope = @AccessScope)
    BEGIN
        SELECT 'Member doesnt hold such access scope' AS ConfirmationMessage;RETURN;
    END

    DELETE FROM Member_Access_Scope
    WHERE MemberID = @MemberID AND AccessScope = @AccessScope;

    SELECT 'Access scope revoked successfully.' AS ConfirmationMessage;

    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
        
END;
GO

CREATE OR ALTER PROCEDURE AddFaculty
    @Name VARCHAR(150),
    @Description VARCHAR(1000),
    @EstablishmentDate DATE,
    @DeanID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Name IS NULL OR @Name = ''
        BEGIN
            SELECT 'Error: faculty name cannot be NULL or blank.' AS ConfirmationMessage; RETURN;
        END

        IF EXISTS (SELECT 1 FROM Faculty WHERE FacultyName = @Name)
        BEGIN
            SELECT 'Error: a faculty with this name already exists.' AS ConfirmationMessage; RETURN;
        END

        IF @DeanID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Dean WHERE MemberID = @DeanID)
        BEGIN
            SELECT 'Error: Dean doesnt exist' AS ConfirmationMessage; RETURN;
        END

        IF @DeanID IS NOT NULL AND EXISTS (SELECT 1 FROM Faculty WHERE DeanID = @DeanID)
        BEGIN
            SELECT 'Error: This person is already a Dean of a faculty' AS ConfirmationMessage; RETURN;
        END

        INSERT INTO Faculty (
            FacultyName,
            FacultyDescription,
            EstablishmentDate,
            DeanID
        )
        VALUES (
            @Name,
            @Description,
            @EstablishmentDate,
            @DeanID
        );

        SELECT 'Faculty added successfully.' AS ConfirmationMessage, SCOPE_IDENTITY() AS NewFacultyID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddProgram
    @Name VARCHAR(150),
    @DegreeLevel VARCHAR(50),
    @TotalCreditHours INT,
    @StandardDuration VARCHAR(50),
    @Description VARCHAR(1000),
    @FacultyID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF @Name IS NULL or @Name = ''
    BEGIN
        SELECT 'Program name cannot be Null or blank' AS ConfirmationMessage; RETURN;
    END

    IF @FacultyID IS NULL
    BEGIN
        SELECT 'Faculty ID cannot be Null' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Faculty WHERE FacultyID = @FacultyID)
    BEGIN 
        SELECT 'Faculty doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF @TotalCreditHours <= 0
    BEGIN 
        SELECT 'Invalid Credit hours value' AS ConfirmationMessage; RETURN;
    END
    
    INSERT INTO Program (
        ProgramName, 
        DegreeLevel, 
        TotalCreditHours, 
        StandardDuration, 
        ProgramDescription, 
        FacultyID
    )
    VALUES (
        @Name, 
        @DegreeLevel, 
        @TotalCreditHours, 
        @StandardDuration, 
        @Description, 
        @FacultyID
    );

    SELECT 'Program added successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewProgramID;

    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH

   

END;
GO

CREATE OR ALTER PROCEDURE AddCourse
    @CourseCode VARCHAR(20),
    @Title VARCHAR(150),
    @Description VARCHAR(1000),
    @CreditHours INT,
    @Level VARCHAR(50),
    @CourseType VARCHAR(20),
    @DefaultStudySemester INT,
    @RequiredForProgram VARCHAR(150),
    @ElectivePool VARCHAR(150),
    @MinSelectionRule VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY

    IF @CourseCode IS NULL OR @CourseCode = ''
    BEGIN
        SELECT 'Course code cannot be NULL or blank' AS ConfirmationMessage; RETURN;
    END

    IF @Title IS NULL OR @Title = ''
    BEGIN
        SELECT 'Title cannot be NULL or blank' AS ConfirmationMessage; RETURN;
    END

    IF @CourseType IS NULL OR @CourseType NOT IN ('Core', 'Elective')
    BEGIN
        SELECT 'Course must be either Core or Elective' AS ConfirmationMessage; RETURN; 
    END

    IF @CreditHours IS NULL OR @CreditHours <= 0 
    BEGIN 
        SELECT 'Credit hours must be greater than zero' AS ConfirmationMessage; RETURN; 
    END

    IF EXISTS (SELECT 1 FROM Course WHERE CourseCode = @CourseCode) 
    BEGIN 
        SELECT 'Course already exists' AS ConfirmationMessage; RETURN; 
    END

    BEGIN TRAN;


    
    INSERT INTO Course (
        CourseCode, 
        Title, 
        CourseDescription, 
        CreditHours, 
        CourseLevel
    )
    VALUES (
        @CourseCode, 
        @Title, 
        @Description, 
        @CreditHours, 
        @Level
    );

    IF @CourseType = 'Core'
    BEGIN
        INSERT INTO Core_Course(CourseCode, DefaultStudySemester, RequiredForProgram)
        VALUES (@CourseCode, @DefaultStudySemester, @RequiredForProgram);
    END
    ELSE
    BEGIN 
        INSERT INTO Elective_Course(CourseCode, ElectivePool, MinSelectionRule)
        VALUES (@CourseCode, @ElectivePool, @MinSelectionRule);
    END

    COMMIT;

    SELECT 'Course added successfully.' AS ConfirmationMessage;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;

    END CATCH

END;
GO

CREATE OR ALTER PROCEDURE AddCourseRequisite
    @CourseCode VARCHAR(20),
    @RequisiteCode VARCHAR(20),
    @RequisiteType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN 
        SELECT 'Course doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Course WHERE CourseCode = @RequisiteCode)
    BEGIN 
        SELECT 'Course doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF @CourseCode = @RequisiteCode
    BEGIN 
        SELECT 'Course cannot be a requisite to itself' AS ConfirmationMessage; RETURN;
    END

    IF @RequisiteType IS NULL OR @RequisiteType NOT IN ('Prerequisite', 'Corequisite')
    BEGIN
        SELECT 'Requisite type must be Prerequisite or Corequisite' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS (SELECT 1 FROM Course_Requisite WHERE CourseCode = @CourseCode AND RequisiteCode = @RequisiteCode)
    BEGIN
        SELECT 'This requisite link already exists' AS ConfirmationMessage; RETURN;
    END
    
    INSERT INTO Course_Requisite (
        CourseCode, 
        RequisiteCode, 
        RequisiteType
    )
    VALUES (
        @CourseCode, 
        @RequisiteCode, 
        @RequisiteType
    );

    SELECT 'Course requisite added successfully.' AS ConfirmationMessage;

    END TRY

    BEGIN CATCH
    SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddSemester
<<<<<<< HEAD
    @Name VARCHAR(50),
=======
    @SemesterName VARCHAR(50),
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    @AcademicYear VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

<<<<<<< HEAD
    IF @Name IS NULL OR @Name = '' 
=======
    IF @SemesterName IS NULL OR @SemesterName = '' 
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Semester name cannot be blank' AS ConfirmationMessage;RETURN;
    END

    IF @AcademicYear IS NULL OR @AcademicYear = '' 
    BEGIN
        SELECT 'Academic Year cannot be blank' AS ConfirmationMessage;RETURN;
    END

    IF @StartDate IS NULL 
    BEGIN
        SELECT 'Start date cannot be null' AS ConfirmationMessage;RETURN;
    END

    IF @EndDate IS NULL 
    BEGIN
        SELECT 'End date cannot be null' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
    IF @EndDate <= @StartDate
=======
    IF @EndDate <= StartDate
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN   
        SELECT 'Start date cannot be after end date' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
    IF EXISTS(SELECT 1 FROM Semester WHERE SemesterName = @Name AND AcademicYear = @AcademicYear)
    BEGIN 
        SELECT 'Semester already exists for this academic year' AS ConfirmationMessage;RETURN;
=======
    IF EXISTS(SELECT 1 FROM Semester WHERE SemesterName = @SemesterName)
    BEGIN 
        SELECT 'Semester name already exists' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Semester WHERE AcademicYear = @AcademicYear)
    BEGIN 
        SELECT 'Academic year already exists' AS ConfirmationMessage;RETURN;
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    END
    
    INSERT INTO Semester (
        SemesterName, 
        AcademicYear, 
        StartDate, 
        EndDate
    )
    VALUES (
        @Name, 
        @AcademicYear, 
        @StartDate, 
        @EndDate
    );

    
    SELECT 
        'Academic semester added successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewSemesterID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE RecordDeanTerm
    @DeanID INT,
    @SemesterID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
<<<<<<< HEAD
    IF NOT EXISTS(SELECT 1 FROM Dean WHERE MemberID = @DeanID)
=======
    IF NOT EXISTS(SELECT 1 FROM Dean WHERE DeanID = @DeanID)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Dean does not exist' AS ConfirmationMessage;RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Semester WHERE SemesterID = @SemesterID)
    BEGIN
        SELECT 'Semester does not exist' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Dean_Term WHERE DeanID = @DeanID AND SemesterID = @SemesterID)
    BEGIN
        SELECT 'Term already exists' AS ConfirmationMessage;RETURN;
    END
    
    
   
    INSERT INTO Dean_Term (
        DeanID, 
        SemesterID
    )
    VALUES (
        @DeanID, 
        @SemesterID
    );

    SELECT 'Dean term recorded successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE CreateCourseOffering
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @DeliveryMode VARCHAR(50),
    @EnrolledCount INT,
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        SELECT 'Course code does not exist' AS ConfirmationMessage;RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Semester WHERE SemesterID = @SemesterID)
    BEGIN
        SELECT 'Semester does not exist' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
    IF NOT EXISTS(SELECT 1 FROM Academic_Instructor WHERE MemberID = @InstructorID)
=======
    IF NOT EXISTS(SELECT 1 FROM Academic_Instructor WHERE InstructorID = @InstructorID)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Instructor does not exist' AS ConfirmationMessage;RETURN;
    END

    IF @SectionID IS NULL OR @SectionID = ''
    BEGIN
        SELECT 'Section cannot be blank' AS ConfirmationMessage;RETURN;
    END

    IF @EnrolledCount IS NULL or @EnrolledCount < 0
    BEGIN
        SELECT 'Count cannot be null or less than zero' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
    IF EXISTS(SELECT 1 FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
=======
    IF EXISTS(SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        SELECT 'Course already exists' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Semester WHERE SemesterID = @SemesterID)
    BEGIN
        SELECT 'Semester already exists' AS ConfirmationMessage;RETURN;
    END

     IF EXISTS(SELECT 1 FROM Course_Offering WHERE SectionID = @SectionID)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Section already exists' AS ConfirmationMessage;RETURN;
    END
    

    INSERT INTO Course_Offering (
        CourseCode, 
        SemesterID, 
        SectionID, 
        DeliveryMode, 
        EnrolledCount, 
        InstructorID
    )
    VALUES (
        @CourseCode, 
        @SemesterID, 
        @SectionID, 
        @DeliveryMode, 
        @EnrolledCount, 
        @InstructorID
    );

    SELECT 'Course offering created successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AssignTAToOffering
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @TAID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        SELECT 'Course code does not exist' AS ConfirmationMessage;RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Semester WHERE SemesterID = @SemesterID)
    BEGIN
        SELECT 'Semester does not exist' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
    IF NOT EXISTS(SELECT 1 FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
=======
    IF NOT EXISTS(SELECT 1 FROM Course_Offering WHERE SectionID = @SectionID)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Section id does not exist' AS ConfirmationMessage; RETURN;
    END

<<<<<<< HEAD
    IF NOT EXISTS(SELECT 1 FROM Teaching_Assistant WHERE MemberID = @TAID)
=======
    IF NOT EXISTS(SELECT 1 FROM Teaching_Assistant WHERE TAID = @TAID)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Teaching assistant not found' AS ConfirmationMessage; RETURN;
    END

<<<<<<< HEAD
    IF EXISTS(SELECT 1 FROM Offering_TA WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID AND TAID = @TAID)
=======
    IF EXISTS(SELECT 1 FROM Course_Offering WHERE TAID = @TAID)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Teaching assistant already exists' AS ConfirmationMessage; RETURN;
    END


    
    INSERT INTO Offering_TA (
        CourseCode, 
        SemesterID, 
        SectionID, 
        TAID
    )
    VALUES (
        @CourseCode, 
        @SemesterID, 
        @SectionID, 
        @TAID
    );

    SELECT 'Teaching assistant assigned to course offering successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH

END;
GO


CREATE OR ALTER PROCEDURE AddTool
    @Name VARCHAR(150),
    @Description VARCHAR(1000),
    @Category VARCHAR(50),
    @Status VARCHAR(50),
    @ToolType VARCHAR(30), 
    @Provider VARCHAR(150),
    @ModelVersion VARCHAR(50),
    @LicenseType VARCHAR(50),
    @HostingMode VARCHAR(50),
    @CostModel VARCHAR(50),
    @OriginatingFramework VARCHAR(150),
    @ReferenceSource VARCHAR(150),
    @RequiredResources VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
<<<<<<< HEAD
    IF @Name IS NULL OR @Name = ''
=======
    IF @ToolName IS NULL OR @ToolName = ''
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Tool name cannot be NULL or empty' AS ConfirmationMessage; RETURN;
    END

<<<<<<< HEAD
    IF EXISTS(SELECT 1 FROM Tool WHERE ToolName = @Name)
=======
    IF EXISTS(SELECT 1 FROM Tool WHERE ToolName = @ToolName)
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Tool name already exists' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
    IF @ToolType IS NULL OR @ToolType NOT IN ('AI Tool', 'Teaching Methodology')
=======
    IF @ToolType NOT IN ('AI_Tool', 'Teaching Methodology')
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    BEGIN
        SELECT 'Invalid Tool type' AS ConfirmationMessage;RETURN;
    END

<<<<<<< HEAD
=======


>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
    DECLARE @NewToolID INT;

    BEGIN TRAN;

    INSERT INTO Tool (
        ToolName, 
        ToolDescription, 
        Category, 
        ToolStatus
    )
    VALUES (
        @Name, 
        @Description, 
        @Category, 
        ISNULL(@Status, 'Under Review')
    );

    SET @NewToolID = SCOPE_IDENTITY();

    IF @ToolType = 'AI Tool'
    BEGIN
        INSERT INTO AI_Tool (
            ToolID, 
            ToolProvider, 
            ModelVersion, 
            LicenseType, 
            HostingMode, 
            CostModel
        )
        VALUES (
            @NewToolID, 
            @Provider, 
            @ModelVersion, 
            @LicenseType, 
            @HostingMode, 
            @CostModel
        );
    END
    ELSE
    BEGIN
        INSERT INTO Teaching_Methodology (
            ToolID, 
            OriginatingFramework, 
            ReferenceSource, 
            RequiredResources
        )
        VALUES (
            @NewToolID, 
            @OriginatingFramework, 
            @ReferenceSource, 
            @RequiredResources
        );
    END

    COMMIT;

    SELECT 
        'Tool added successfully.' AS ConfirmationMessage,
        @NewToolID AS NewToolID;
<<<<<<< HEAD
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
=======
        END TRY

        BEGIN CATCH
            SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
        END CATCH
>>>>>>> 3a68e72d52fde52bdf099820f49e8116d47e097a
END;
GO


CREATE OR ALTER FUNCTION ViewAuditLog
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        al.ActionType,
        m.FullName AS Actor, 
        CASE 
            WHEN al.ProposalID IS NOT NULL THEN 'Proposal'
            WHEN al.ApprovalID IS NOT NULL THEN 'Approval'
            WHEN al.InitiativeID IS NOT NULL THEN 'Initiative'
            WHEN al.AssessmentID IS NOT NULL THEN 'Assessment'
            WHEN al.EvidenceID IS NOT NULL THEN 'Evidence' 
        END AS AffectedItemType,
        COALESCE(al.ProposalID, al.ApprovalID, al.InitiativeID, al.AssessmentID, al.EvidenceID) AS AffectedItemID,
        al.LoggedAt AS LogTimestamp,
        al.ChangeSummary
    FROM Audit_Log al
    LEFT JOIN Academic_Member m ON al.ActorID = m.MemberID
    WHERE al.LoggedAt >= @StartDate 
      AND al.LoggedAt < DATEADD(DAY, 1, @EndDate)
);
GO

CREATE OR ALTER FUNCTION GetFacultyMemberStats()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        f.FacultyName AS Faculty,
        'Instructor' AS Role,
        COUNT(DISTINCT m.MemberID) AS MemberCount
    FROM Faculty f
    JOIN Academic_Member m ON f.FacultyID = m.FacultyID
    JOIN Academic_Instructor i ON m.MemberID = i.MemberID
    GROUP BY f.FacultyName

    UNION ALL

    SELECT 
        f.FacultyName AS Faculty,
        'Teaching Assistant' AS Role,
        COUNT(DISTINCT m.MemberID) AS MemberCount
    FROM Faculty f
    JOIN Academic_Member m ON f.FacultyID = m.FacultyID
    JOIN Teaching_Assistant ta ON m.MemberID = ta.MemberID
    GROUP BY f.FacultyName

    UNION ALL

    SELECT 
        f.FacultyName AS Faculty,
        'Dean' AS Role,
        COUNT(DISTINCT m.MemberID) AS MemberCount
    FROM Faculty f
    JOIN Academic_Member m ON f.FacultyID = m.FacultyID
    JOIN Dean de ON m.MemberID = de.MemberID
    GROUP BY f.FacultyName

    UNION ALL

    SELECT 
        f.FacultyName AS Faculty,
        'Management' AS Role,
        COUNT(DISTINCT m.MemberID) AS MemberCount
    FROM Faculty f
    JOIN Academic_Member m ON f.FacultyID = m.FacultyID
    JOIN University_Management uniM ON m.MemberID = uniM.MemberID
    GROUP BY f.FacultyName

    UNION ALL

    SELECT 
        f.FacultyName AS Faculty,
        'Curriculum Reviewer' AS Role,
        COUNT(DISTINCT m.MemberID) AS MemberCount
    FROM Faculty f
    JOIN Academic_Member m ON f.FacultyID = m.FacultyID
    JOIN Curriculum_Reviewer cr ON m.MemberID = cr.MemberID
    GROUP BY f.FacultyName

);
GO



CREATE OR ALTER FUNCTION ViewMyCourseOfferings(
    @InstructorID INT,
    @SemesterID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        co.CourseCode,
        c.Title AS CourseTitle,
        co.SectionID,
        co.DeliveryMode,
        co.EnrolledCount
    FROM Course_Offering co
    JOIN Course c ON co.CourseCode = c.CourseCode
    WHERE co.InstructorID = @InstructorID
      AND co.SemesterID = @SemesterID
);
GO

CREATE OR ALTER PROCEDURE AddILO
    @CourseCode VARCHAR(20),
    @ILOCode VARCHAR(20),
    @Statement VARCHAR(1000),
    @CognitiveLevel VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        SELECT 'Course doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO ILO (
        CourseCode,
        ILOCode,
        ILOStatement,
        CognitiveLevel
    )
    VALUES (
        @CourseCode,
        @ILOCode,
        @Statement,
        @CognitiveLevel
    );

    SELECT 'ILO added successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE UpdateILO
    @CourseCode VARCHAR(20),
    @ILOCode VARCHAR(20),
    @Statement VARCHAR(1000),
    @CognitiveLevel VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM ILO WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode)
    BEGIN
        SELECT 'ILO doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF @Statement IS NULL AND @CognitiveLevel IS NULL
    BEGIN
        SELECT 'Statement and cognitive level cannot both be NULL' AS ConfirmationMessage; RETURN;
    END

    IF @Statement IS NOT NULL AND @Statement = ''
    BEGIN
        SELECT 'Statement cannot be blank' AS ConfirmationMessage; RETURN;
    END

    UPDATE ILO
    SET ILOStatement = ISNULL(@Statement, ILOStatement),
        CognitiveLevel = ISNULL(@CognitiveLevel, CognitiveLevel)
    WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode;

    SELECT 'ILO updated successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE MapILOToPLO
    @CourseCode VARCHAR(20),
    @ILOCode VARCHAR(20),
    @ProgramID INT,
    @PLOCode VARCHAR(20),
    @CoverageLevel VARCHAR(50),
    @IsAssessmentPoint BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM ILO WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode)
    BEGIN
        SELECT 'ILO doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Outcome_Mapping (
        CoverageLevel,
        IsAssessmentPoint,
        CourseCode,
        ILOCode,
        ProgramID,
        PLOCode
    )
    VALUES (
        @CoverageLevel,
        @IsAssessmentPoint,
        @CourseCode,
        @ILOCode,
        @ProgramID,
        @PLOCode
    );

    SELECT 'ILO mapped to PLO successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewMappingID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE RecordOutcomeAssessment
    @CourseCode VARCHAR(20),
    @ILOCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @MappingID INT,
    @Instrument VARCHAR(150),
    @Description VARCHAR(1000),
    @TargetThreshold DECIMAL(10,2),
    @AttainedValue DECIMAL(10,2),
    @SampleSize INT,
    @AnalysisNotes VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
    BEGIN
        SELECT 'Course offering doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Outcome_Mapping WHERE MappingID = @MappingID AND CourseCode = @CourseCode AND ILOCode = @ILOCode)
    BEGIN
        SELECT 'Mapping doesnt exist for this course and ILO' AS ConfirmationMessage; RETURN;
    END

    DECLARE @NewAssessmentID INT;

    INSERT INTO Outcome_Assessment (
        Instrument,
        AssessmentDescription,
        TargetThreshold,
        AttainedValue,
        SampleSize,
        AnalysisNotes,
        CourseCode,
        ILOCode,
        SemesterID,
        SectionID,
        MappingID
    )
    VALUES (
        @Instrument,
        @Description,
        @TargetThreshold,
        @AttainedValue,
        @SampleSize,
        @AnalysisNotes,
        @CourseCode,
        @ILOCode,
        @SemesterID,
        @SectionID,
        @MappingID
    );

    SET @NewAssessmentID = SCOPE_IDENTITY();

    SELECT
        CASE
            WHEN TargetMet = 1 THEN 'Outcome assessment recorded successfully. Target was met.'
            ELSE 'Outcome assessment recorded successfully. Target was not met.'
        END AS ConfirmationMessage,
        AssessmentID AS NewAssessmentID
    FROM Outcome_Assessment
    WHERE AssessmentID = @NewAssessmentID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddCorrectiveAction
    @AssessmentID INT,
    @CorrectiveAction VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID)
    BEGIN
        SELECT 'Assessment doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID AND TargetMet = 1)
    BEGIN
        SELECT 'Target was met, no corrective action needed' AS ConfirmationMessage; RETURN;
    END

    IF @CorrectiveAction IS NULL OR @CorrectiveAction = ''
    BEGIN
        SELECT 'Corrective action cannot be NULL or blank' AS ConfirmationMessage; RETURN;
    END

    UPDATE Outcome_Assessment
    SET CorrectiveAction = @CorrectiveAction
    WHERE AssessmentID = @AssessmentID;

    SELECT 'Corrective action added successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER FUNCTION ViewUnmetAssessments(
    @InstructorID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        oa.AssessmentID,
        oa.ILOCode,
        i.ILOStatement,
        oa.CourseCode,
        oa.SemesterID,
        oa.SectionID,
        oa.TargetThreshold,
        oa.AttainedValue,
        oa.CorrectiveAction
    FROM Outcome_Assessment oa
    JOIN Course_Offering co ON oa.CourseCode = co.CourseCode
        AND oa.SemesterID = co.SemesterID
        AND oa.SectionID = co.SectionID
    JOIN ILO i ON oa.CourseCode = i.CourseCode AND oa.ILOCode = i.ILOCode
    WHERE co.InstructorID = @InstructorID
      AND oa.TargetMet = 0
);
GO

CREATE OR ALTER PROCEDURE SubmitModificationProposal
    @ProposerID INT,
    @Title VARCHAR(150),
    @Rationale VARCHAR(1000),
    @ModificationType VARCHAR(50),
    @CurrentStateSummary VARCHAR(1000),
    @ProposedStateSummary VARCHAR(1000),
    @CourseCode VARCHAR(20),
    @ProgramID INT,
    @VersionLabel VARCHAR(20),
    @AcademicYear VARCHAR(50),
    @AssessmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Academic_Instructor WHERE MemberID = @ProposerID)
    BEGIN
        SELECT 'Proposer is not an instructor' AS ConfirmationMessage; RETURN;
    END

    IF (@VersionLabel IS NOT NULL OR @AcademicYear IS NOT NULL)
       AND NOT EXISTS(SELECT 1 FROM Curriculum_Version WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel AND AcademicYear = @AcademicYear)
    BEGIN
        SELECT 'Curriculum version doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Modification_Proposal (
        Title,
        Rationale,
        ModificationType,
        CurrentStateSummary,
        ProposedStateSummary,
        ProposerID,
        CourseCode,
        ProgramID,
        VersionLabel,
        AcademicYear,
        AssessmentID
    )
    VALUES (
        @Title,
        @Rationale,
        @ModificationType,
        @CurrentStateSummary,
        @ProposedStateSummary,
        @ProposerID,
        @CourseCode,
        @ProgramID,
        @VersionLabel,
        @AcademicYear,
        @AssessmentID
    );

    SELECT 'Modification proposal submitted successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewProposalID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ReviseModificationProposal
    @ProposalID INT,
    @Rationale VARCHAR(1000),
    @ProposedStateSummary VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Modification_Proposal WHERE ProposalID = @ProposalID)
    BEGIN
        SELECT 'Proposal doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Approval_Record
                  WHERE ApprovalID = (SELECT MAX(ApprovalID) FROM Approval_Record WHERE ProposalID = @ProposalID)
                    AND Decision = 'Returned for Revision')
    BEGIN
        SELECT 'Proposal was not returned for revision' AS ConfirmationMessage; RETURN;
    END

    IF @Rationale IS NULL AND @ProposedStateSummary IS NULL
    BEGIN
        SELECT 'Rationale and proposed state summary cannot both be NULL' AS ConfirmationMessage; RETURN;
    END

    UPDATE Modification_Proposal
    SET Rationale = ISNULL(@Rationale, Rationale),
        ProposedStateSummary = ISNULL(@ProposedStateSummary, ProposedStateSummary)
    WHERE ProposalID = @ProposalID;

    SELECT 'Modification proposal revised successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER FUNCTION ViewProposalStatus(
    @ProposalID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ar.Decision,
        ar.DecisionLevel,
        m.FullName AS Approver,
        ar.DecisionDate,
        ar.Comments
    FROM Approval_Record ar
    JOIN Academic_Member m ON ar.DeciderID = m.MemberID
    WHERE ar.ProposalID = @ProposalID
);
GO

CREATE OR ALTER FUNCTION ViewCurriculumVersion(
    @ProgramID INT,
    @VersionLabel VARCHAR(20),
    @AcademicYear VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        vc.StudySemesterNo AS StudySemester,
        vc.CourseCode,
        c.Title,
        c.CreditHours,
        vc.IsMandatory
    FROM Version_Course vc
    JOIN Course c ON vc.CourseCode = c.CourseCode
    WHERE vc.ProgramID = @ProgramID
      AND vc.VersionLabel = @VersionLabel
      AND vc.AcademicYear = @AcademicYear
);
GO

CREATE OR ALTER FUNCTION CompareCurriculumVersions(
    @ProgramID INT,
    @OldVersionLabel VARCHAR(20),
    @OldAcademicYear VARCHAR(50),
    @NewVersionLabel VARCHAR(20),
    @NewAcademicYear VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        COALESCE(o.CourseCode, n.CourseCode) AS CourseCode,
        c.Title,
        CASE
            WHEN o.CourseCode IS NULL THEN 'Added'
            WHEN n.CourseCode IS NULL THEN 'Removed'
            ELSE 'Moved'
        END AS ChangeType,
        o.StudySemesterNo AS OldStudySemester,
        n.StudySemesterNo AS NewStudySemester
    FROM (SELECT CourseCode, StudySemesterNo
          FROM Version_Course
          WHERE ProgramID = @ProgramID AND VersionLabel = @OldVersionLabel AND AcademicYear = @OldAcademicYear) o
    FULL OUTER JOIN (SELECT CourseCode, StudySemesterNo
                     FROM Version_Course
                     WHERE ProgramID = @ProgramID AND VersionLabel = @NewVersionLabel AND AcademicYear = @NewAcademicYear) n
        ON o.CourseCode = n.CourseCode
    JOIN Course c ON c.CourseCode = COALESCE(o.CourseCode, n.CourseCode)
    WHERE o.CourseCode IS NULL
       OR n.CourseCode IS NULL
       OR o.StudySemesterNo <> n.StudySemesterNo
);
GO

CREATE OR ALTER PROCEDURE RegisterInnovationInitiative
    @SubmitterID INT,
    @FacultyID INT,
    @Title VARCHAR(150),
    @Description VARCHAR(1000),
    @Motivation VARCHAR(1000),
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @TargetStartSemesterID INT,
    @ImplementationDeadline DATE,
    @AssessmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
    BEGIN
        SELECT 'Course offering doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Innovation_Initiative (
        Title,
        InitiativeDescription,
        Motivation,
        ImplementationDeadline,
        CourseCode,
        SemesterID,
        SectionID,
        FacultyID,
        SubmitterID,
        TargetStartSemesterID,
        AssessmentID
    )
    VALUES (
        @Title,
        @Description,
        @Motivation,
        @ImplementationDeadline,
        @CourseCode,
        @SemesterID,
        @SectionID,
        @FacultyID,
        @SubmitterID,
        @TargetStartSemesterID,
        @AssessmentID
    );

    SELECT 'Innovation initiative registered successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewInitiativeID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddAIToolIntegration
    @InitiativeID INT,
    @IntegrationObjective VARCHAR(1000),
    @ToolCategory VARCHAR(50),
    @DataPrivacyNotes VARCHAR(1000),
    @AcademicIntegrityNotes VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO AI_Tool_Integration (
        InitiativeID,
        IntegrationObjective,
        ToolCategory,
        DataPrivacyNotes,
        AcademicIntegrityNotes
    )
    VALUES (
        @InitiativeID,
        @IntegrationObjective,
        @ToolCategory,
        @DataPrivacyNotes,
        @AcademicIntegrityNotes
    );

    SELECT 'AI tool integration added successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddMethodologyChange
    @InitiativeID INT,
    @PedagogicalApproach VARCHAR(150),
    @DeliveryChange VARCHAR(1000),
    @ReferenceFramework VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Methodology_Change (
        InitiativeID,
        PedagogicalApproach,
        DeliveryChange,
        ReferenceFramework
    )
    VALUES (
        @InitiativeID,
        @PedagogicalApproach,
        @DeliveryChange,
        @ReferenceFramework
    );

    SELECT 'Methodology change added successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddAssessmentRedesign
    @InitiativeID INT,
    @AssessmentTypeAffected VARCHAR(50),
    @RubricWeightingChanges VARCHAR(1000),
    @FairnessSafeguards VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Assessment_Redesign (
        InitiativeID,
        AssessmentTypeAffected,
        RubricWeightingChanges,
        FairnessSafeguards
    )
    VALUES (
        @InitiativeID,
        @AssessmentTypeAffected,
        @RubricWeightingChanges,
        @FairnessSafeguards
    );

    SELECT 'Assessment redesign added successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AdoptTool
    @InitiativeID INT,
    @ToolID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Initiative_Tool (
        InitiativeID,
        ToolID
    )
    VALUES (
        @InitiativeID,
        @ToolID
    );

    SELECT 'Tool adopted successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AssignInitiativeMember
    @InitiativeID INT,
    @MemberID INT,
    @Role VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Initiative_Member (
        InitiativeID,
        MemberID,
        MemberRole
    )
    VALUES (
        @InitiativeID,
        @MemberID,
        @Role
    );

    SELECT 'Initiative member assigned successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddTrainingRequirement
    @InitiativeID INT,
    @ToolID INT,
    @Description VARCHAR(1000),
    @TargetAudience VARCHAR(150),
    @RequiredByDate DATE,
    @IsMandatory BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Training_Requirement (
        RequirementDescription,
        TargetAudience,
        RequiredByDate,
        IsMandatory,
        InitiativeID,
        ToolID
    )
    VALUES (
        @Description,
        @TargetAudience,
        @RequiredByDate,
        @IsMandatory,
        @InitiativeID,
        @ToolID
    );

    SELECT 'Training requirement added successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddMilestone
    @InitiativeID INT,
    @Title VARCHAR(150),
    @Description VARCHAR(1000),
    @DueDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    DECLARE @NewSeqNo INT;

    BEGIN TRAN;

    SELECT @NewSeqNo = ISNULL(MAX(SeqNo), 0) + 1
    FROM Milestone WITH (UPDLOCK, HOLDLOCK)
    WHERE InitiativeID = @InitiativeID;

    INSERT INTO Milestone (
        InitiativeID,
        SeqNo,
        Title,
        MilestoneDescription,
        DueDate
    )
    VALUES (
        @InitiativeID,
        @NewSeqNo,
        @Title,
        @Description,
        @DueDate
    );

    COMMIT;

    SELECT 'Milestone added successfully with sequence number ' + CAST(@NewSeqNo AS VARCHAR(10)) + '.' AS ConfirmationMessage,
        @NewSeqNo AS NewSeqNo;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE CompleteMilestone
    @InitiativeID INT,
    @SeqNo INT,
    @CompletionDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo)
    BEGIN
        SELECT 'Milestone doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF @CompletionDate IS NULL
    BEGIN
        SELECT 'Completion date cannot be NULL' AS ConfirmationMessage; RETURN;
    END

    UPDATE Milestone
    SET CompletionDate = @CompletionDate,
        MilestoneStatus = 'Completed'
    WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo;

    SELECT 'Milestone completed successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE UploadEvidence
    @InitiativeID INT,
    @MilestoneSeqNo INT,
    @Title VARCHAR(150),
    @ArtifactType VARCHAR(50),
    @FilePathOrURL VARCHAR(1000),
    @Description VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Evidence (
        Title,
        ArtifactType,
        FilePathOrURL,
        EvidenceDescription,
        InitiativeID,
        MilestoneSeqNo
    )
    VALUES (
        @Title,
        @ArtifactType,
        @FilePathOrURL,
        @Description,
        @InitiativeID,
        @MilestoneSeqNo
    );

    SELECT 'Evidence uploaded successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewEvidenceID;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE SubmitOutcomeReport
    @InitiativeID INT,
    @SemesterID INT,
    @MetricType VARCHAR(50),
    @QuantitativeValue DECIMAL(10,2),
    @BaselineValue DECIMAL(10,2),
    @QualitativeSummary VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Outcome_Report (
        MetricType,
        QuantitativeValue,
        BaselineValue,
        QualitativeSummary,
        InitiativeID,
        SemesterID
    )
    VALUES (
        @MetricType,
        @QuantitativeValue,
        @BaselineValue,
        @QualitativeSummary,
        @InitiativeID,
        @SemesterID
    );

    SELECT 'Outcome report submitted successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE RecordStudentFeedback
    @InitiativeID INT,
    @SemesterID INT,
    @Rating INT,
    @Comment VARCHAR(1000),
    @CategorySentiment VARCHAR(50),
    @CollectionMethod VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF @Rating IS NULL OR @Rating NOT BETWEEN 1 AND 5
    BEGIN
        SELECT 'Rating must be between 1 and 5' AS ConfirmationMessage; RETURN;
    END

    INSERT INTO Student_Feedback (
        Rating,
        FeedbackComment,
        CategorySentiment,
        CollectionMethod,
        InitiativeID,
        SemesterID
    )
    VALUES (
        @Rating,
        @Comment,
        @CategorySentiment,
        @CollectionMethod,
        @InitiativeID,
        @SemesterID
    );

    SELECT 'Student feedback recorded successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE RequestInitiativeApproval
    @InitiativeID INT,
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
    BEGIN
        SELECT 'Initiative doesnt exist' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID AND SubmitterID = @MemberID)
       AND NOT EXISTS(SELECT 1 FROM Initiative_Member WHERE InitiativeID = @InitiativeID AND MemberID = @MemberID)
    BEGIN
        SELECT 'Member is not the submitter or an assigned member of this initiative' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID AND InitiativeStatus IN ('Draft', 'Returned for Revision'))
    BEGIN
        SELECT 'Only a Draft or Returned for Revision initiative can be sent for approval' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Innovation_Initiative i
              JOIN Faculty f ON i.FacultyID = f.FacultyID
              WHERE i.InitiativeID = @InitiativeID AND f.DeanID IS NULL)
    BEGIN
        SELECT 'The initiative faculty has no dean' AS ConfirmationMessage; RETURN;
    END

    UPDATE Innovation_Initiative
    SET InitiativeStatus = 'Pending Approval'
    WHERE InitiativeID = @InitiativeID;

    SELECT 'Initiative approval requested successfully.' AS ConfirmationMessage;
    END TRY

    BEGIN CATCH
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
END;
GO

CREATE OR ALTER FUNCTION ViewInitiativeProgress(
    @InitiativeID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        m.SeqNo,
        m.Title,
        m.DueDate,
        m.CompletionDate,
        m.MilestoneStatus,
        CAST(CASE
            WHEN m.MilestoneStatus <> 'Completed' AND m.DueDate < CAST(GETDATE() AS DATE) THEN 1
            ELSE 0
        END AS BIT) AS IsOverdue
    FROM Milestone m
    WHERE m.InitiativeID = @InitiativeID
);
GO

CREATE OR ALTER FUNCTION CalculateInitiativeCompletion(
    @InitiativeID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total INT;
    DECLARE @Completed INT;

    SELECT
        @Total = COUNT(*),
        @Completed = SUM(CASE WHEN MilestoneStatus = 'Completed' THEN 1 ELSE 0 END)
    FROM Milestone
    WHERE InitiativeID = @InitiativeID;

    IF @Total = 0
        RETURN 0;

    RETURN CAST((@Completed * 100.0) / @Total AS DECIMAL(5,2));
END;
GO
