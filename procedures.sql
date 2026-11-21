
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

CREATE OR ALTER FUNCTION ViewMemberInfo (@MemberID INT)
RETURNS TABLE
AS RETURN
(
    SELECT M.*,
           I.MemberID AS InstructorID, I.ResearchArea, I.OfficeLocation, I.TeachingLoad,
           T.MemberID AS TAID, T.AssistantLevel, T.SupervisorID,
           D.MemberID AS DeanID, D.ApprovalAuthorityScope,
           U.MemberID AS ManagementID, U.ManagementTitle, U.DecisionAuthorityLevel, U.GovernanceScope,
           R.MemberID AS ReviewerID, R.ReviewDomain, R.ReviewAuthorityLevel,
           S.AccessScope
    FROM Academic_Member M
    LEFT OUTER JOIN Academic_Instructor  I ON I.MemberID = M.MemberID
    LEFT OUTER JOIN Teaching_Assistant   T ON T.MemberID = M.MemberID
    LEFT OUTER JOIN Dean                 D ON D.MemberID = M.MemberID
    LEFT OUTER JOIN University_Management U ON U.MemberID = M.MemberID
    LEFT OUTER JOIN Curriculum_Reviewer  R ON R.MemberID = M.MemberID
    LEFT OUTER JOIN Member_Access_Scope  S ON S.MemberID = M.MemberID
    WHERE M.MemberID = @MemberID
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
    @Name VARCHAR(50),
    @AcademicYear VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF @Name IS NULL OR @Name = '' 
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

    IF @EndDate <= @StartDate
    BEGIN   
        SELECT 'Start date cannot be after end date' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Semester WHERE SemesterName = @Name AND AcademicYear = @AcademicYear)
    BEGIN 
        SELECT 'Semester already exists for this academic year' AS ConfirmationMessage;RETURN;
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
    IF NOT EXISTS(SELECT 1 FROM Dean WHERE MemberID = @DeanID)
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

    IF NOT EXISTS(SELECT 1 FROM Academic_Instructor WHERE MemberID = @InstructorID)
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

    IF EXISTS(SELECT 1 FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
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

    IF NOT EXISTS(SELECT 1 FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
    BEGIN
        SELECT 'Section id does not exist' AS ConfirmationMessage; RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Teaching_Assistant WHERE MemberID = @TAID)
    BEGIN
        SELECT 'Teaching assistant not found' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Offering_TA WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID AND TAID = @TAID)
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
    IF @Name IS NULL OR @Name = ''
    BEGIN
        SELECT 'Tool name cannot be NULL or empty' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Tool WHERE ToolName = @Name)
    BEGIN
        SELECT 'Tool name already exists' AS ConfirmationMessage;RETURN;
    END

    IF @ToolType IS NULL OR @ToolType NOT IN ('AI Tool', 'Teaching Methodology')
    BEGIN
        SELECT 'Invalid Tool type' AS ConfirmationMessage;RETURN;
    END

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
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 'Error: ' + ERROR_MESSAGE() AS ConfirmationMessage;
    END CATCH
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

--TEACHING ASSISTANT
--1
CREATE OR ALTER FUNCTION ViewSupportedOfferings(@TAID INT)
RETURNS TABLE
AS
    RETURN
    
        SELECT
            c.title AS CourseTitle,
            s.SemesterName,
            co.SectionID AS SectionID,
            m.Fullname AS InstructorName

        FROM Course_Offering co
        
        INNER JOIN Offering_TA ot ON 
        co.CourseCode = ot.CourseCode 
        AND co.SemesterID = ot.SemesterID 
        AND co.SectionID = ot.SectionID
        
        INNER JOIN Teaching_Assistant ta ON 
        ot.TAID = ta.MemberID

        INNER JOIN Course c ON 
        co.CourseCode = c.CourseCode

        INNER JOIN Semester s ON
        co.SemesterID = s.SemesterID

        INNER JOIN Academic_Member m ON
        co.InstructorID = m.MemberID

        WHERE ot.TAID = @TAID
GO

--2
CREATE OR ALTER FUNCTION ViewMySupervisor(@TAID INT)
RETURNS TABLE
AS
    RETURN 
        SELECT
            m.FullName AS SupervisorName,
            m.Email AS SupervisorEmail,
            i.OfficeLocation AS SupervisorOffice

        FROM Teaching_Assistant ta
        
        INNER JOIN Academic_Member m ON
        ta.SupervisorID = m.MemberID

        INNER JOIN Academic_Instructor i ON
        ta.SupervisorID = i.MemberID

        WHERE ta.MemberID = @TAID
GO

--3
CREATE OR ALTER FUNCTION ViewCourseILOs(@CourseCode varchar(20))
RETURNS TABLE
AS
    RETURN
        SELECT
            i.ILOCode AS ILOCode,
            i.ILOStatement AS ILOStatement,
            i.CognitiveLevel AS CognitiveLevel
        FROM ILO i
        WHERE i.CourseCode = @CourseCode
GO


--4
CREATE OR ALTER FUNCTION ViewOfferingAssessments (@CourseCode varchar(20), @SemesterID INT, @SectionID varchar(20))
RETURNS TABLE
AS
    RETURN
        SELECT
            oa.Instrument AS Instrument,
            oa.TargetThreshold AS TargetThreshold,
            oa.AttainedValue AS AttainedValue,
            oa.TargetMet AS TargetMet
        FROM Outcome_Assessment oa
        WHERE oa.CourseCode = @CourseCode
          AND oa.SemesterID = @SemesterID
          AND oa.SectionID = @SectionID
GO


--5
CREATE OR ALTER PROCEDURE UpdateEnrolledCount
@CourseCode varchar(20), 
@SemesterID int, 
@SectionID varchar(20), 
@EnrolledCount int
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Course_Offering
                   WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID)
    BEGIN
        SELECT 'Course offering does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @EnrolledCount IS NULL OR @EnrolledCount < 0
    BEGIN
        SELECT 'Enrolled count cannot be NULL or negative.' AS ConfirmationMessage;
        RETURN;
    END

    UPDATE Course_Offering
    SET EnrolledCount = @EnrolledCount
    WHERE CourseCode = @CourseCode
        AND SemesterID = @SemesterID
        AND SectionID = @SectionID;

    SELECT 'Enrolled count updated successfully.' AS ConfirmationMessage; 
END;
GO

--6
CREATE OR ALTER PROCEDURE UpdateMilestoneStatus
@InitiativeID INT,
@SeqNo INT,
@Status VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo)
    BEGIN
        SELECT 'Milestone does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Status IS NULL OR @Status NOT IN ('Pending', 'In Progress', 'Completed', 'Delayed')
    BEGIN
        SELECT 'Status must be Pending, In Progress, Completed or Delayed.' AS ConfirmationMessage;
        RETURN;
    END

    UPDATE Milestone
    SET MilestoneStatus = @Status
    WHERE InitiativeID = @InitiativeID
        AND SeqNo = @SeqNo;

    SELECT 'Milestone status updated successfully.' AS ConfirmationMessage;
END;
GO

--7
CREATE OR ALTER FUNCTION ViewInitiativeEvidence(
    @InitiativeID INT
)
RETURNS TABLE
AS
    RETURN
        SELECT 
          e.Title AS EvidenceTitle,  
          e.ArtifactType AS ArtifactType,
          m.Title AS MilestoneTitle,
          e.UploadDate AS UploadDate

        FROM Evidence e
        LEFT JOIN Milestone m ON e.InitiativeID = m.InitiativeID 
        AND e.MilestoneSeqNo = m.SeqNo
        WHERE e.InitiativeID = @InitiativeID
GO

--Curriculum Reviewer
--1
CREATE OR ALTER FUNCTION ViewProgramCurriculumMap(@ProgramID int)
RETURNS TABLE
AS
    RETURN
        SELECT
            om.PLOCode AS PLOCode,
            c.Title AS CourseTitle,
            c.CourseCode AS CourseCode,
            om.ILOCode AS ILOCode,
            om.CoverageLevel AS CoverageLevel,
            om.IsAssessmentPoint AS IsAssessmentPoint
            
        FROM Outcome_Mapping om
        
        INNER JOIN Course c ON om.CourseCode = c.CourseCode
        WHERE om.ProgramID = @ProgramID AND om.MappingStatus <> 'Rejected'
GO

--2
CREATE OR ALTER FUNCTION GetUncoveredPLOs(@ProgramID int)
RETURNS TABLE
AS
    RETURN
        SELECT
            p.PLOCode AS PLOCode,
            p.PLOStatement AS PLOStatement
        FROM PLO p
        WHERE p.ProgramID = @ProgramID 
        AND NOT EXISTS (
            SELECT 1
            FROM Outcome_Mapping om
            WHERE om.ProgramID = @ProgramID
            AND om.PLOCode = p.PLOCode
            AND om.MappingStatus = 'Approved')
GO

--3
CREATE OR ALTER FUNCTION GetPLOCoverageSummary(@ProgramID int)
RETURNS TABLE
AS
    RETURN
        SELECT
            om.PLOCode AS PLOCode,
            om.CoverageLevel AS CoverageLevel,
            COUNT(DISTINCT om.CourseCode) AS CourseCount,
            (SELECT COUNT(*)
             FROM Outcome_Mapping om2
             WHERE om2.ProgramID = om.ProgramID
               AND om2.PLOCode = om.PLOCode
               AND om2.MappingStatus = 'Approved'
               AND om2.IsAssessmentPoint = 1) AS AssessmentPoints
        FROM Outcome_Mapping om
        WHERE om.ProgramID = @ProgramID AND om.MappingStatus = 'Approved'
        GROUP BY om.ProgramID, om.PLOCode, om.CoverageLevel
GO

--4
CREATE OR ALTER PROCEDURE ReviewOutcomeMapping
@MappingID INT,
@MappingStatus VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Outcome_Mapping WHERE MappingID = @MappingID)
    BEGIN
        SELECT 'Mapping does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @MappingStatus IS NULL OR @MappingStatus NOT IN ('Approved', 'Rejected')
    BEGIN
        SELECT 'Mapping status must be Approved or Rejected.' AS ConfirmationMessage;
        RETURN;
    END

    UPDATE Outcome_Mapping
    SET MappingStatus = @MappingStatus
    WHERE MappingID = @MappingID;

    SELECT 'Outcome mapping status updated successfully.' AS ConfirmationMessage;
END;
GO

--5
CREATE OR ALTER FUNCTION GetPLOAttainment(
    @ProgramID INT,
    @PLOCode VARCHAR(20),
    @SemesterID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
DECLARE @Total INT, @Met INT, @Result DECIMAL(5,2);
        
        SELECT @Total = COUNT(*)
        FROM Outcome_Assessment oa
        INNER JOIN Outcome_Mapping om ON oa.MappingID = om.MappingID
        WHERE om.ProgramID = @ProgramID 
        AND om.PLOCode = @PLOCode 
        AND oa.SemesterID = @SemesterID;

        SELECT @Met = COUNT(*)
        FROM Outcome_Assessment oa
        INNER JOIN Outcome_Mapping om ON oa.MappingID = om.MappingID
        WHERE om.ProgramID = @ProgramID 
        AND om.PLOCode = @PLOCode 
        AND oa.SemesterID = @SemesterID
        AND oa.TargetMet = 1;

        IF @Total > 0
            SET @Resukt = 100.0 * @Met / @Total;
        RETURN @Result;
END;
GO

--6
CREATE OR ALTER FUNCTION ViewAssessmentsBelowTarget (@ProgramID INT, @SemesterID INT)
RETURNS TABLE
AS
RETURN
    SELECT oa.AssessmentID,
           oa.CourseCode,
           oa.ILOCode,
           oa.TargetThreshold,
           oa.AttainedValue,
           oa.CorrectiveAction
    FROM Outcome_Assessment oa
    INNER JOIN Outcome_Mapping om ON om.MappingID = oa.MappingID
    WHERE om.ProgramID = @ProgramID
      AND oa.SemesterID = @SemesterID
      AND oa.TargetMet = 0;
GO

--7
CREATE OR ALTER FUNCTION TrackCorrectiveActionEffect (@CourseCode VARCHAR(20), @ILOCode VARCHAR(20))
RETURNS TABLE
AS
RETURN
    SELECT TOP 100 PERCENT
           s.SemesterName,
           s.AcademicYear,
           s.StartDate,
           oa.TargetThreshold,
           oa.AttainedValue,
           oa.TargetMet AS Result,
           oa.CorrectiveAction
    FROM Outcome_Assessment oa
    INNER JOIN Semester s ON s.SemesterID = oa.SemesterID
    WHERE oa.CourseCode = @CourseCode
      AND oa.ILOCode = @ILOCode
    ORDER BY s.StartDate;
GO

--8
CREATE OR ALTER FUNCTION ViewPendingProposals (@ProgramID INT)
RETURNS TABLE
AS
RETURN
    SELECT p.ProposalID,
           p.Title,
           m.FullName AS Proposer,
           p.SubmissionDate
    FROM Modification_Proposal p
    INNER JOIN Academic_Member m ON m.MemberID = p.ProposerID
    WHERE (p.ProgramID = @ProgramID
           OR p.CourseCode IN (SELECT vc.CourseCode
                               FROM Version_Course vc
                               WHERE vc.ProgramID = @ProgramID))
      AND NOT EXISTS (SELECT *
                      FROM Approval_Record ar
                      WHERE ar.ProposalID = p.ProposalID
                        AND ar.DecisionLevel IN ('Dean', 'University')
                        AND ar.Decision IN ('Approved', 'Rejected'));
GO

--9
CREATE OR ALTER PROCEDURE ReviewModificationProposal
    @ProposalID INT,
    @ReviewerID INT,
    @Decision VARCHAR(50),
    @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @ProposerID INT;

    SELECT @ProposerID = ProposerID
    FROM Modification_Proposal
    WHERE ProposalID = @ProposalID;

    IF @ProposerID IS NULL
    BEGIN
        SELECT 'Proposal does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Curriculum_Reviewer WHERE MemberID = @ReviewerID)
    BEGIN
        SELECT 'Member is not a curriculum reviewer.' AS ConfirmationMessage;
        RETURN;
    END

    IF @ProposerID = @ReviewerID
    BEGIN
        SELECT 'A reviewer cannot review their own proposal.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Decision IS NULL OR @Decision NOT IN ('Approved', 'Rejected', 'Returned for Revision')
    BEGIN
        SELECT 'Decision must be Approved, Rejected or Returned for Revision.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Approval_Record (Decision, DecisionLevel, Comments, DeciderID, ProposalID)
    VALUES (@Decision, 'Reviewer', @Comments, @ReviewerID, @ProposalID);

    SELECT 'Review decision recorded successfully.' AS ConfirmationMessage;
END;
GO

--10
CREATE OR ALTER FUNCTION ViewCourseProposalHistory (@CourseCode VARCHAR(20))
RETURNS TABLE
AS
RETURN
    SELECT p.ProposalID,
           p.Title,
           p.ModificationType,
           p.SubmissionDate,
           ar.Decision AS LatestDecision,
           ar.DecisionLevel,
           ar.DecisionDate
    FROM Modification_Proposal p
    LEFT OUTER JOIN Approval_Record ar
        ON ar.ProposalID = p.ProposalID
       AND ar.ApprovalID = (SELECT MAX(ar2.ApprovalID)
                            FROM Approval_Record ar2
                            WHERE ar2.ProposalID = p.ProposalID)
    WHERE p.CourseCode = @CourseCode;
GO

--11
CREATE OR ALTER PROCEDURE CreateAccreditationReview
    @ProgramID INT,
    @AccreditingBody VARCHAR(150),
    @ReviewType VARCHAR(50),
    @ReviewCycle VARCHAR(50),
    @NextReviewDue DATE
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Program WHERE ProgramID = @ProgramID)
    BEGIN
        SELECT 'Program does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @AccreditingBody IS NULL OR @AccreditingBody = ''
    BEGIN
        SELECT 'Accrediting body cannot be NULL or blank.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Accreditation_Review (AccreditingBody, ReviewType, ReviewCycle, NextReviewDue, ProgramID)
    VALUES (@AccreditingBody, @ReviewType, @ReviewCycle, @NextReviewDue, @ProgramID);

    SELECT 'Accreditation review created successfully.' AS ConfirmationMessage,
           MAX(ReviewID) AS NewReviewID
    FROM Accreditation_Review;
END;
GO

--12
CREATE OR ALTER PROCEDURE AttachMappingsToReview
    @ReviewID INT
AS
BEGIN
    DECLARE @ProgramID INT;
    DECLARE @Count INT;

    SELECT @ProgramID = ProgramID
    FROM Accreditation_Review
    WHERE ReviewID = @ReviewID;

    IF @ProgramID IS NULL
    BEGIN
        SELECT 'Accreditation review does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    SELECT @Count = COUNT(*)
    FROM Outcome_Mapping om
    WHERE om.ProgramID = @ProgramID
      AND om.MappingStatus = 'Approved'
      AND om.MappingID NOT IN (SELECT rm.MappingID
                               FROM Review_Mapping rm
                               WHERE rm.ReviewID = @ReviewID);

    INSERT INTO Review_Mapping (ReviewID, MappingID)
    SELECT @ReviewID, om.MappingID
    FROM Outcome_Mapping om
    WHERE om.ProgramID = @ProgramID
      AND om.MappingStatus = 'Approved'
      AND om.MappingID NOT IN (SELECT rm.MappingID
                               FROM Review_Mapping rm
                               WHERE rm.ReviewID = @ReviewID);

    SELECT 'Approved mappings attached successfully.' AS ConfirmationMessage,
           @Count AS AttachedMappings;
END;
GO

--13
CREATE OR ALTER PROCEDURE AttachAssessmentToReview
    @ReviewID INT,
    @AssessmentID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
    BEGIN
        SELECT 'Accreditation review does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID)
    BEGIN
        SELECT 'Outcome assessment does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF EXISTS (SELECT * FROM Review_Assessment
               WHERE ReviewID = @ReviewID AND AssessmentID = @AssessmentID)
    BEGIN
        SELECT 'Assessment is already attached to this review.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Review_Assessment (ReviewID, AssessmentID)
    VALUES (@ReviewID, @AssessmentID);

    SELECT 'Assessment attached to review successfully.' AS ConfirmationMessage;
END;
GO

--14
CREATE OR ALTER PROCEDURE AttachEvidenceToReview
    @ReviewID INT,
    @EvidenceID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
    BEGIN
        SELECT 'Accreditation review does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Evidence WHERE EvidenceID = @EvidenceID)
    BEGIN
        SELECT 'Evidence does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF EXISTS (SELECT * FROM Review_Evidence
               WHERE ReviewID = @ReviewID AND EvidenceID = @EvidenceID)
    BEGIN
        SELECT 'Evidence is already attached to this review.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Review_Evidence (ReviewID, EvidenceID)
    VALUES (@ReviewID, @EvidenceID);

    SELECT 'Evidence attached to review successfully.' AS ConfirmationMessage;
END;
GO

--15
CREATE OR ALTER PROCEDURE UpdateAccreditationStatus
    @ReviewID INT,
    @Status VARCHAR(50),
    @Decision VARCHAR(50),
    @SubmissionDate DATE
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
    BEGIN
        SELECT 'Accreditation review does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Status IS NULL OR @Status = ''
    BEGIN
        SELECT 'Status cannot be NULL or blank.' AS ConfirmationMessage;
        RETURN;
    END

    UPDATE Accreditation_Review
    SET ReviewStatus = @Status,
        Decision = @Decision,
        SubmissionDate = @SubmissionDate
    WHERE ReviewID = @ReviewID;

    SELECT 'Accreditation status updated successfully.' AS ConfirmationMessage;
END;
GO

--16
CREATE OR ALTER FUNCTION GenerateAccreditationPack (@ReviewID INT)
RETURNS TABLE
AS
RETURN
    SELECT 'Mapping' AS ItemType,
           om.MappingID AS ItemID,
           om.CourseCode + ' ' + om.ILOCode + ' -> PLO ' + om.PLOCode AS Title,
           'Coverage: ' + om.CoverageLevel + ', status: ' + om.MappingStatus AS Detail,
           NULL AS TargetThreshold,
           NULL AS AttainedValue
    FROM Review_Mapping rm
    INNER JOIN Outcome_Mapping om ON om.MappingID = rm.MappingID
    WHERE rm.ReviewID = @ReviewID

    UNION ALL

    SELECT 'Assessment',
           oa.AssessmentID,
           oa.Instrument,
           'Course ' + oa.CourseCode + ', ILO ' + oa.ILOCode,
           oa.TargetThreshold,
           oa.AttainedValue
    FROM Review_Assessment ra
    INNER JOIN Outcome_Assessment oa ON oa.AssessmentID = ra.AssessmentID
    WHERE ra.ReviewID = @ReviewID

    UNION ALL

    SELECT 'Evidence',
           e.EvidenceID,
           e.Title,
           e.ArtifactType + ' - ' + e.FilePathOrURL,
           NULL,
           NULL
    FROM Review_Evidence re
    INNER JOIN Evidence e ON e.EvidenceID = re.EvidenceID
    WHERE re.ReviewID = @ReviewID;
GO

--17
CREATE OR ALTER FUNCTION GetUpcomingAccreditations (@DaysAhead INT)
RETURNS TABLE
AS
RETURN
    SELECT p.ProgramName AS Program,
           ar.AccreditingBody,
           ar.ReviewStatus AS Status,
           ar.NextReviewDue
    FROM Accreditation_Review ar
    INNER JOIN Program p ON p.ProgramID = ar.ProgramID
    WHERE ar.NextReviewDue > CURRENT_TIMESTAMP - 1
      AND ar.NextReviewDue <= CURRENT_TIMESTAMP + @DaysAhead;
GO

--Dean 
--1
CREATE OR ALTER FUNCTION ViewFacultyPendingApprovals(@DeanID INT)
RETURNS TABLE
AS
    RETURN
    (
        SELECT 'Proposal' AS ItemType,
               p.ProposalID AS ItemID,
               p.Title AS Title,
               m.FullName AS Submitter,
               p.SubmissionDate AS SubmissionDate
        FROM Faculty f
        INNER JOIN Academic_Member m ON m.FacultyID = f.FacultyID
        INNER JOIN Modification_Proposal p ON p.ProposerID = m.MemberID
        WHERE f.DeanID = @DeanID
          AND EXISTS (SELECT * FROM Approval_Record ar
                      WHERE ar.ProposalID = p.ProposalID
                        AND ar.DecisionLevel = 'Reviewer'
                        AND ar.Decision = 'Approved'
                        AND ar.ApprovalID = (SELECT MAX(ApprovalID)
                                             FROM Approval_Record
                                             WHERE ProposalID = p.ProposalID))

        UNION ALL

        SELECT 'Initiative' AS ItemType,
               i.InitiativeID AS ItemID,
               i.Title AS Title,
               m.FullName AS Submitter,
               i.RegistrationDate AS SubmissionDate
        FROM Faculty f
        INNER JOIN Innovation_Initiative i ON i.FacultyID = f.FacultyID
        INNER JOIN Academic_Member m ON m.MemberID = i.SubmitterID
        WHERE f.DeanID = @DeanID
          AND i.InitiativeStatus = 'Pending Approval'
    );
GO


--2
CREATE OR ALTER PROCEDURE DecideOnProposal
    @ProposalID INT,
    @DeanID INT,
    @Decision VARCHAR(50),
    @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @ProposerID INT;
    DECLARE @ProposerFaculty INT;

    SELECT @ProposerID = p.ProposerID, @ProposerFaculty = m.FacultyID
    FROM Modification_Proposal p
    INNER JOIN Academic_Member m ON m.MemberID = p.ProposerID
    WHERE p.ProposalID = @ProposalID;

    IF @ProposerID IS NULL
    BEGIN
        SELECT 'Proposal does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Dean WHERE MemberID = @DeanID)
    BEGIN
        SELECT 'Member is not a dean.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @ProposerFaculty AND DeanID = @DeanID)
    BEGIN
        SELECT 'The proposal does not belong to your faculty.' AS ConfirmationMessage;
        RETURN;
    END

    IF @ProposerID = @DeanID
    BEGIN
        SELECT 'A dean cannot decide on their own proposal.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Decision IS NULL OR @Decision NOT IN ('Approved', 'Rejected', 'Returned for Revision')
    BEGIN
        SELECT 'Decision must be Approved, Rejected or Returned for Revision.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Approval_Record ar
                   WHERE ar.ProposalID = @ProposalID
                     AND ar.DecisionLevel = 'Reviewer'
                     AND ar.Decision = 'Approved'
                     AND ar.ApprovalID = (SELECT MAX(ar2.ApprovalID)
                                          FROM Approval_Record ar2
                                          WHERE ar2.ProposalID = @ProposalID))
    BEGIN
        SELECT 'The proposal is not awaiting a dean decision (it needs a reviewer approval first).' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Approval_Record (Decision, DecisionLevel, Comments, DeciderID, ProposalID)
    VALUES (@Decision, 'Dean', @Comments, @DeanID, @ProposalID);

    SELECT 'Dean decision recorded successfully.' AS ConfirmationMessage;
END;
GO

--3
CREATE OR ALTER PROCEDURE DecideOnInitiative
    @InitiativeID INT,
    @DeanID INT,
    @Decision VARCHAR(50),
    @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @InitFaculty INT;
    DECLARE @SubmitterID INT;
    DECLARE @Status VARCHAR(50);

    SELECT @InitFaculty = FacultyID, @SubmitterID = SubmitterID, @Status = InitiativeStatus
    FROM Innovation_Initiative
    WHERE InitiativeID = @InitiativeID;

    IF @InitFaculty IS NULL
    BEGIN
        SELECT 'Initiative does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Dean WHERE MemberID = @DeanID)
    BEGIN
        SELECT 'Member is not a dean.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @InitFaculty AND DeanID = @DeanID)
    BEGIN
        SELECT 'The initiative does not belong to your faculty.' AS ConfirmationMessage;
        RETURN;
    END

    IF @SubmitterID = @DeanID
    BEGIN
        SELECT 'A dean cannot decide on their own initiative.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Decision IS NULL OR @Decision NOT IN ('Approved', 'Rejected', 'Returned for Revision')
    BEGIN
        SELECT 'Decision must be Approved, Rejected or Returned for Revision.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Status <> 'Pending Approval'
    BEGIN
        SELECT 'Only an initiative that is Pending Approval can be decided.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Approval_Record (Decision, DecisionLevel, Comments, DeciderID, InitiativeID)
    VALUES (@Decision, 'Dean', @Comments, @DeanID, @InitiativeID);

    UPDATE Innovation_Initiative
    SET InitiativeStatus = @Decision
    WHERE InitiativeID = @InitiativeID;

    SELECT 'Dean decision recorded successfully.' AS ConfirmationMessage;
END;
GO

--4
CREATE OR ALTER PROCEDURE EscalateToUniversity
    @InitiativeID INT,
    @DeanID INT,
    @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @InitFaculty INT;
    DECLARE @Status VARCHAR(50);

    SELECT @InitFaculty = FacultyID, @Status = InitiativeStatus
    FROM Innovation_Initiative
    WHERE InitiativeID = @InitiativeID;

    IF @InitFaculty IS NULL
    BEGIN
        SELECT 'Initiative does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Dean WHERE MemberID = @DeanID)
    BEGIN
        SELECT 'Member is not a dean.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @InitFaculty AND DeanID = @DeanID)
    BEGIN
        SELECT 'The initiative does not belong to your faculty.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Status <> 'Pending Approval'
    BEGIN
        SELECT 'Only an initiative that is Pending Approval can be escalated.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Approval_Record (Decision, DecisionLevel, Comments, DeciderID, InitiativeID)
    VALUES ('Escalated', 'Dean', @Comments, @DeanID, @InitiativeID);

    UPDATE Innovation_Initiative
    SET InitiativeStatus = 'Escalated'
    WHERE InitiativeID = @InitiativeID;

    SELECT 'Initiative escalated to University Management successfully.' AS ConfirmationMessage;
END;
GO

--5
CREATE OR ALTER PROCEDURE AddPLO
    @ProgramID INT,
    @PLOCode VARCHAR(20),
    @Statement VARCHAR(1000),
    @Category VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Program WHERE ProgramID = @ProgramID)
    BEGIN
        SELECT 'Program does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @PLOCode IS NULL OR @PLOCode = ''
    BEGIN
        SELECT 'PLO code is required.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Statement IS NULL OR @Statement = ''
    BEGIN
        SELECT 'PLO statement is required.' AS ConfirmationMessage;
        RETURN;
    END

    IF EXISTS (SELECT * FROM PLO WHERE ProgramID = @ProgramID AND PLOCode = @PLOCode)
    BEGIN
        SELECT 'This program already has a PLO with that code.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO PLO (ProgramID, PLOCode, PLOStatement, Category)
    VALUES (@ProgramID, @PLOCode, @Statement, @Category);

    SELECT 'PLO added successfully.' AS ConfirmationMessage;
END;
GO

--6
CREATE OR ALTER PROCEDURE CreateCurriculumVersion
    @ProgramID INT,
    @VersionLabel VARCHAR(20),
    @AcademicYear VARCHAR(50),
    @EffectivePeriod VARCHAR(50),
    @CopyFromVersionLabel VARCHAR(20),
    @CopyFromAcademicYear VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Program WHERE ProgramID = @ProgramID)
    BEGIN
        SELECT 'Program does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @VersionLabel IS NULL OR @VersionLabel = '' OR @AcademicYear IS NULL OR @AcademicYear = ''
    BEGIN
        SELECT 'Version label and academic year are required.' AS ConfirmationMessage;
        RETURN;
    END

    IF EXISTS (SELECT * FROM Curriculum_Version
               WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel AND AcademicYear = @AcademicYear)
    BEGIN
        SELECT 'This curriculum version already exists.' AS ConfirmationMessage;
        RETURN;
    END

    IF (@CopyFromVersionLabel IS NULL AND @CopyFromAcademicYear IS NOT NULL)
       OR (@CopyFromVersionLabel IS NOT NULL AND @CopyFromAcademicYear IS NULL)
    BEGIN
        SELECT 'Give both the version label and the academic year to copy from, or neither.' AS ConfirmationMessage;
        RETURN;
    END

    IF @CopyFromVersionLabel IS NOT NULL
       AND NOT EXISTS (SELECT * FROM Curriculum_Version
                       WHERE ProgramID = @ProgramID
                         AND VersionLabel = @CopyFromVersionLabel
                         AND AcademicYear = @CopyFromAcademicYear)
    BEGIN
        SELECT 'The version to copy from does not exist for this program.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO Curriculum_Version (ProgramID, VersionLabel, AcademicYear, EffectivePeriod, VersionStatus, ApprovalDate)
    VALUES (@ProgramID, @VersionLabel, @AcademicYear, @EffectivePeriod, 'Draft', NULL);

    IF @CopyFromVersionLabel IS NOT NULL
    BEGIN
        INSERT INTO Version_Course (ProgramID, VersionLabel, AcademicYear, CourseCode, StudySemesterNo, IsMandatory)
        SELECT @ProgramID, @VersionLabel, @AcademicYear, CourseCode, StudySemesterNo, IsMandatory
        FROM Version_Course
        WHERE ProgramID = @ProgramID
          AND VersionLabel = @CopyFromVersionLabel
          AND AcademicYear = @CopyFromAcademicYear;
    END

    SELECT 'Draft curriculum version created successfully.' AS ConfirmationMessage;
END;
GO

--7
CREATE OR ALTER PROCEDURE PlaceCourseInVersion
    @ProgramID INT,
    @VersionLabel VARCHAR(20),
    @AcademicYear VARCHAR(50),
    @CourseCode VARCHAR(20),
    @StudySemesterNo INT,
    @IsMandatory BIT
AS
BEGIN
    DECLARE @Status VARCHAR(50);

    SELECT @Status = VersionStatus
    FROM Curriculum_Version
    WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel AND AcademicYear = @AcademicYear;

    IF @Status IS NULL
    BEGIN
        SELECT 'Curriculum version does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Status <> 'Draft'
    BEGIN
        SELECT 'Courses can only be placed in a Draft curriculum version.' AS ConfirmationMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        SELECT 'Course does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @StudySemesterNo IS NULL OR @StudySemesterNo <= 0
    BEGIN
        SELECT 'Study semester must be a positive number.' AS ConfirmationMessage;
        RETURN;
    END

    IF @IsMandatory IS NULL
        SET @IsMandatory = 1;

    IF EXISTS (SELECT * FROM Version_Course
               WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
                 AND AcademicYear = @AcademicYear AND CourseCode = @CourseCode)
    BEGIN
        UPDATE Version_Course
        SET StudySemesterNo = @StudySemesterNo, IsMandatory = @IsMandatory
        WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
          AND AcademicYear = @AcademicYear AND CourseCode = @CourseCode;

        SELECT 'Course placement updated successfully.' AS ConfirmationMessage;
    END
    ELSE
    BEGIN
        INSERT INTO Version_Course (ProgramID, VersionLabel, AcademicYear, CourseCode, StudySemesterNo, IsMandatory)
        VALUES (@ProgramID, @VersionLabel, @AcademicYear, @CourseCode, @StudySemesterNo, @IsMandatory);

        SELECT 'Course placed in the curriculum version successfully.' AS ConfirmationMessage;
    END
END;
GO

--8
CREATE OR ALTER PROCEDURE ApproveCurriculumVersion
    @ProgramID INT,
    @VersionLabel VARCHAR(20),
    @AcademicYear VARCHAR(50)
AS
BEGIN
    DECLARE @Status VARCHAR(50);

    SELECT @Status = VersionStatus
    FROM Curriculum_Version
    WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel AND AcademicYear = @AcademicYear;

    IF @Status IS NULL
    BEGIN
        SELECT 'Curriculum version does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Status <> 'Draft'
    BEGIN
        SELECT 'Only a Draft curriculum version can be approved.' AS ConfirmationMessage;
        RETURN;
    END

    UPDATE Curriculum_Version
    SET VersionStatus = 'Archived'
    WHERE ProgramID = @ProgramID AND VersionStatus = 'Active';

    UPDATE Curriculum_Version
    SET VersionStatus = 'Active', ApprovalDate = CURRENT_TIMESTAMP
    WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel AND AcademicYear = @AcademicYear;

    SELECT 'Curriculum version approved and activated successfully.' AS ConfirmationMessage;
END;
GO

--9
CREATE OR ALTER FUNCTION ViewFacultyInitiatives (@FacultyID INT, @Status VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT i.InitiativeID,
           i.Title,
           i.CourseCode,
           s.SemesterName,
           i.SectionID,
           m.FullName AS Submitter,
           i.ImplementationDeadline,
           i.InitiativeStatus
    FROM Innovation_Initiative i
    INNER JOIN Semester s ON s.SemesterID = i.SemesterID
    INNER JOIN Academic_Member m ON m.MemberID = i.SubmitterID
    WHERE i.FacultyID = @FacultyID
      AND (@Status IS NULL OR i.InitiativeStatus = @Status)
);
GO

--10
CREATE OR ALTER FUNCTION ViewOverdueMilestones (@FacultyID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT i.InitiativeID,
           i.Title AS InitiativeTitle,
           ms.SeqNo,
           ms.Title AS MilestoneTitle,
           ms.DueDate,
           a.FullName AS AssignedMember
    FROM Innovation_Initiative i
    INNER JOIN Milestone ms ON ms.InitiativeID = i.InitiativeID
    LEFT OUTER JOIN Initiative_Member im ON im.InitiativeID = i.InitiativeID
    LEFT OUTER JOIN Academic_Member a ON a.MemberID = im.MemberID
    WHERE i.FacultyID = @FacultyID
      AND ms.MilestoneStatus <> 'Completed'
      AND ms.DueDate < CURRENT_TIMESTAMP - 1
);
GO

--11
CREATE OR ALTER PROCEDURE SendOverdueAlerts
    @FacultyID INT
AS
BEGIN
    DECLARE @MaxBefore INT;
    DECLARE @Sent INT;

    IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @FacultyID)
    BEGIN
        SELECT 'Faculty does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    SELECT @MaxBefore = MAX(NotificationID) FROM Notification;
    IF @MaxBefore IS NULL
        SET @MaxBefore = 0;

    INSERT INTO Notification (MessageContent, Urgency, Category)
    SELECT 'Initiative "' + i.Title + '" (ID ' + CAST(i.InitiativeID AS VARCHAR(10)) + ') has overdue milestones.',
           'High',
           'Overdue Alert'
    FROM Innovation_Initiative i
    WHERE i.FacultyID = @FacultyID
      AND EXISTS (SELECT * FROM Milestone ms
                  WHERE ms.InitiativeID = i.InitiativeID
                    AND ms.MilestoneStatus <> 'Completed'
                    AND ms.DueDate < CURRENT_TIMESTAMP - 1)
      AND EXISTS (SELECT * FROM Initiative_Member im
                  WHERE im.InitiativeID = i.InitiativeID);

    INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus)
    SELECT n.NotificationID, im.MemberID, 0
    FROM Notification n
    INNER JOIN Innovation_Initiative i
        ON n.MessageContent = 'Initiative "' + i.Title + '" (ID ' + CAST(i.InitiativeID AS VARCHAR(10)) + ') has overdue milestones.'
    INNER JOIN Initiative_Member im ON im.InitiativeID = i.InitiativeID
    WHERE n.NotificationID > @MaxBefore
      AND i.FacultyID = @FacultyID;

    SELECT @Sent = COUNT(*) FROM Notification_Recipient WHERE NotificationID > @MaxBefore;

    SELECT CAST(@Sent AS VARCHAR(10)) + ' overdue alert(s) sent.' AS ConfirmationMessage;
END;
GO

--12
CREATE OR ALTER PROCEDURE ScheduleTrainingSession
    @ToolID INT,
    @Title VARCHAR(150),
    @Topic VARCHAR(150),
    @Description VARCHAR(1000),
    @SessionDate DATE,
    @DurationMinutes INT,
    @Trainer VARCHAR(150),
    @Capacity INT,
    @Mode VARCHAR(20),
    @Platform VARCHAR(50),
    @MeetingLink VARCHAR(1000),
    @RecordingAvailable BIT,
    @Venue VARCHAR(150),
    @Campus VARCHAR(50),
    @RequiredEquipment VARCHAR(1000)
AS
BEGIN
    DECLARE @SessionID INT;

    IF NOT EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID)
    BEGIN
        SELECT 'Tool does not exist.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Title IS NULL OR @Title = ''
    BEGIN
        SELECT 'Session title is required.' AS ConfirmationMessage;
        RETURN;
    END

    IF @SessionDate IS NULL OR @SessionDate < CURRENT_TIMESTAMP - 1
    BEGIN
        SELECT 'Session date must be today or in the future.' AS ConfirmationMessage;
        RETURN;
    END

    IF @DurationMinutes IS NOT NULL AND @DurationMinutes <= 0
    BEGIN
        SELECT 'Duration must be a positive number of minutes.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Capacity IS NULL OR @Capacity <= 0
    BEGIN
        SELECT 'Capacity must be a positive number.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Mode IS NULL OR @Mode NOT IN ('Online', 'In Person', 'In-Person')
    BEGIN
        SELECT 'Mode must be Online or In Person.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Mode = 'Online' AND (@MeetingLink IS NULL OR @MeetingLink = '')
    BEGIN
        SELECT 'An online session needs a meeting link.' AS ConfirmationMessage;
        RETURN;
    END

    IF @Mode <> 'Online' AND (@Venue IS NULL OR @Venue = '')
    BEGIN
        SELECT 'An in-person session needs a venue.' AS ConfirmationMessage;
        RETURN;
    END

    IF @RecordingAvailable IS NULL
        SET @RecordingAvailable = 0;

    INSERT INTO Training_Session (Title, Topic, SessionDescription, SessionDate, DurationMinutes, Trainer, Capacity, SessionStatus, ToolID)
    VALUES (@Title, @Topic, @Description, @SessionDate, @DurationMinutes, @Trainer, @Capacity, 'Scheduled', @ToolID);

    SELECT @SessionID = MAX(SessionID) FROM Training_Session;

    IF @Mode = 'Online'
        INSERT INTO Online_Training (SessionID, TrainingPlatform, MeetingLink, RecordingAvailable)
        VALUES (@SessionID, @Platform, @MeetingLink, @RecordingAvailable);
    ELSE
        INSERT INTO In_Person_Training (SessionID, Venue, Campus, RequiredEquipment)
        VALUES (@SessionID, @Venue, @Campus, @RequiredEquipment);

    SELECT 'Training session scheduled successfully.' AS ConfirmationMessage, @SessionID AS SessionID;
END;
GO

--13
CREATE OR ALTER FUNCTION ViewTrainingAttendance (@SessionID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT m.FullName,
           m.AcademicRank,
           m.Email
    FROM Session_Attendance sa
    INNER JOIN Academic_Member m ON m.MemberID = sa.MemberID
    WHERE sa.SessionID = @SessionID
);
GO

--14
CREATE OR ALTER FUNCTION GetFacultyTrainingCompliance (@FacultyID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT i.InitiativeID,
           i.Title AS InitiativeTitle,
           tr.RequirementID,
           tr.RequirementDescription,
           (SELECT COUNT(*)
            FROM Initiative_Member im
            WHERE im.InitiativeID = i.InitiativeID) AS AssignedMembers,
           (SELECT COUNT(*)
            FROM Initiative_Member im
            WHERE im.InitiativeID = i.InitiativeID
              AND EXISTS (SELECT *
                          FROM Session_Attendance sa
                          INNER JOIN Training_Session ts ON ts.SessionID = sa.SessionID
                          WHERE sa.MemberID = im.MemberID
                            AND ts.ToolID = tr.ToolID
                            AND ts.SessionStatus = 'Completed')) AS AttendedMembers
    FROM Innovation_Initiative i
    INNER JOIN Training_Requirement tr ON tr.InitiativeID = i.InitiativeID
    WHERE i.FacultyID = @FacultyID
);
GO

--15
CREATE OR ALTER FUNCTION GetInitiativeImpact (@InitiativeID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT s.SemesterName,
           r.MetricType,
           r.BaselineValue,
           r.QuantitativeValue AS MeasuredValue,
           ROUND(100.0 * (r.QuantitativeValue - r.BaselineValue) / r.BaselineValue, 2) AS PercentageChange
    FROM Outcome_Report r
    INNER JOIN Semester s ON s.SemesterID = r.SemesterID
    WHERE r.InitiativeID = @InitiativeID
      AND r.BaselineValue > 0
      AND r.QuantitativeValue IS NOT NULL

    UNION ALL

    SELECT s.SemesterName,
           r.MetricType,
           r.BaselineValue,
           r.QuantitativeValue,
           NULL
    FROM Outcome_Report r
    INNER JOIN Semester s ON s.SemesterID = r.SemesterID
    WHERE r.InitiativeID = @InitiativeID
      AND (r.BaselineValue IS NULL OR r.BaselineValue = 0 OR r.QuantitativeValue IS NULL)
);
GO

--16
CREATE OR ALTER FUNCTION GetAverageFeedbackRating (@InitiativeID INT, @SemesterID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @Average DECIMAL(3,2);

    SELECT @Average = AVG(1.0 * Rating)
    FROM Student_Feedback
    WHERE InitiativeID = @InitiativeID
      AND SemesterID = @SemesterID;

    RETURN @Average;
END;
GO

--17
CREATE OR ALTER FUNCTION GetFacultyDashboard (@FacultyID INT, @SemesterID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        (SELECT COUNT(*)
         FROM Innovation_Initiative i
         WHERE i.FacultyID = @FacultyID
           AND i.SemesterID = @SemesterID
           AND i.InitiativeStatus = 'In Progress') AS ActiveInitiatives,

        (SELECT COUNT(*)
         FROM ViewFacultyPendingApprovals((SELECT DeanID FROM Faculty WHERE FacultyID = @FacultyID))) AS PendingApprovals,

        (SELECT COUNT(*)
         FROM Innovation_Initiative i
         INNER JOIN Milestone ms ON ms.InitiativeID = i.InitiativeID
         WHERE i.FacultyID = @FacultyID
           AND i.SemesterID = @SemesterID
           AND ms.MilestoneStatus <> 'Completed'
           AND ms.DueDate < CURRENT_TIMESTAMP - 1) AS OverdueMilestones,

        (SELECT AVG(100.0 * oa.TargetMet)
         FROM Outcome_Assessment oa
         INNER JOIN Outcome_Mapping om ON om.MappingID = oa.MappingID
         INNER JOIN Program p ON p.ProgramID = om.ProgramID
         WHERE p.FacultyID = @FacultyID
           AND oa.SemesterID = @SemesterID) AS PercentAssessmentsMetTarget
);
GO
