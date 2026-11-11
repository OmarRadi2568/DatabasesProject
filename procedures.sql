
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
    IF EXISTS(SELECT 1 FROM Academic_Member WHERE UniversityIDNo = @UniversityIDNo)
    BEGIN
        SELECT 'A member with this ID already exists' AS ConfirmationMessage; RETURN;
    END

    IF EXISTS(SELECT 1 FROM Academic_Member WHERE Email = @Email)
    BEGIN
        SELECT 'A member with this Email already exists' AS ConfirmationMessage; RETURN;
    END

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
        SELECT 'Wrong E-mail format'
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


CREATE FUNCTION ViewMemberInfo(
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
                SELECT 'Member does not exist.' AS ErrorMessage; RETURN; 
            END

            IF @Email IS NULL OR @Email = ''
            BEGIN
                SELECT 'E-mail cannot be NULL' AS ErrorMessage;RETURN;
            END 

            IF EXISTS(SELECT 1 FROM Academic_Member WHERE @MemberID <> MemberID AND @EMAIL = Email)
            BEGIN
                SELECT 'Email already in use.' AS ErrorMessage; RETURN;
            END

            IF @Email NOT LIKE '%@%' 
            BEGIN
                SELECT 'Wrong E-mail format' AS ErrorMessage;RETURN;
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
        SET NOCOUNT ON

        BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Academic_Member WHERE MemberID = @MemberID)
        BEGIN
            SELECT 'Member does not exist.' AS ConfirmationMessage; RETURN; 
        END

        IF @AccountStatus IS NULL OR @AccountStatus = ''
        BEGIN
            SELECT 'Account status cannot be NULL' AS ConfirmationMessage;RETURN;
        END

         IF EXISTS(SELECT 1 FROM Academic_Member WHERE @MemberID <> MemberID AND @AccountStatus = AccountStatus)
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

    IF @SupervisorID IS NULL OR @SupervisorID = ''
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
        SELECT 'Memeber is already a curriculum reviewer' AS ConfirmationMessage;RETURN;
    END

    IF EXISTS(SELECT 1 FROM Reviewer_Committee WHERE MemberID = @MemberID)
    BEGIN
        SELECT 'Member is already part of the committee' AS ConfirmationMessage;RETURN;
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
        IF @@TRANCOUNT > 0 ROLLBACK
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
    @ProgramName VARCHAR(150),
    @DegreeLevel VARCHAR(50),
    @TotalCreditHours INT,
    @StandardDuration VARCHAR(50),
    @ProgramDescription VARCHAR(1000),
    @FacultyID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    IF @ProgramName IS NULL or @ProgramName = ''
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
        @ProgramName, 
        @DegreeLevel, 
        @TotalCreditHours, 
        @StandardDuration, 
        @ProgramDescription, 
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
    @CourseDescription VARCHAR(1000),
    @CreditHours INT,
    @CourseLevel VARCHAR(50),
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
        @CourseDescription, 
        @CreditHours, 
        @CourseLevel
    );

    IF @CourseType = 'Core'
    BEGIN
        INSERT INTO Core_Course(CourseCode, DefaultStudySemester, RequiredForProgram)
        VALUES (@CourseCode, @DefaultStudySemester, @RequiredForProgram)
    END
    ELSE
    BEGIN 
        INSERT INTO Elective_Course(CourseCode, ElectivePool, MinSelectionRule)
        VALUES (@CourseCode, @ElectivePool, @MinSelectionRule)
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

    IF NOT EXISTS(SELECT 1 FROM Course WHERE CourseCode = @RequisiteCode AND CourseCode = @CourseCode)
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

CREATE PROCEDURE AddSemester
    @SemesterName VARCHAR(50),
    @AcademicYear VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    
    INSERT INTO Semester (
        SemesterName, 
        AcademicYear, 
        StartDate, 
        EndDate
    )
    VALUES (
        @SemesterName, 
        @AcademicYear, 
        @StartDate, 
        @EndDate
    );

    
    SELECT 
        'Academic semester added successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewSemesterID;
END;
GO


CREATE PROCEDURE RecordDeanTerm
    @DeanID INT,
    @SemesterID INT
AS
BEGIN
    SET NOCOUNT ON;

   
    INSERT INTO Dean_Term (
        DeanID, 
        SemesterID
    )
    VALUES (
        @DeanID, 
        @SemesterID
    );

    SELECT 'Dean term recorded successfully.' AS ConfirmationMessage;
END;
GO


CREATE PROCEDURE CreateCourseOffering
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @DeliveryMode VARCHAR(50),
    @EnrolledCount INT,
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;

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
END;
GO

CREATE PROCEDURE AssignTAToOffering
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @TAID INT
AS
BEGIN
    SET NOCOUNT ON;

    
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
END;
GO


CREATE PROCEDURE AddTool
    @ToolName VARCHAR(150),
    @ToolDescription VARCHAR(1000),
    @Category VARCHAR(50),
    @ToolStatus VARCHAR(50),
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

    DECLARE @NewToolID INT;

   
    INSERT INTO Tool (
        ToolName, 
        ToolDescription, 
        Category, 
        ToolStatus
    )
    VALUES (
        @ToolName, 
        @ToolDescription, 
        @Category, 
        ISNULL(@ToolStatus, 'Under Review')
    );

    
    SET @NewToolID = SCOPE_IDENTITY();

    
    IF @ToolType = 'AI Tool' OR @ToolType = 'AI'
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
    ELSE IF @ToolType = 'Teaching Methodology' OR @ToolType = 'Methodology'
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

    
    SELECT 
        'Tool added successfully.' AS ConfirmationMessage,
        @NewToolID AS NewToolID;
END;
GO


CREATE FUNCTION ViewAuditLog
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
      AND al.LoggedAt <= @EndDate
);
GO

CREATE FUNCTION GetFacultyMemberStats()
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
    JOIN University_Management uniM ON m.MemberID = UniM.MemberID
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


