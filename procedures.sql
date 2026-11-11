
IF OBJECT_ID('AddAcademicMember', 'P') IS NOT NULL
    DROP PROCEDURE AddAcademicMember;
GO

CREATE PROCEDURE AddAcademicMember
    @FullName VARCHAR(150),
    @UniversityIDNo VARCHAR(55),
    @Email VARCHAR(150),
    @Phone VARCHAR(50),
    @AcademicRank VARCHAR(50),
    @EmploymentStatus VARCHAR(50),
    @AccountStatus VARCHAR(50),
    @FacultyID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AcademicMember (
        FullName, UniversityIDNo, Email, Phone, 
        AcademicRank, EmploymentStatus, AccountStatus, FacultyID
    )
    VALUES (
        @FullName, @UniversityIDNo, @Email, @Phone, 
        @AcademicRank, @EmploymentStatus, @AccountStatus, @FacultyID
    );

    SELECT 'Academic member added successfully.' AS ConfirmationMessage, SCOPE_IDENTITY() AS NewMemberID;
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
    FROM AcademicMember
    WHERE MemberID = @MemberID
);
GO

CREATE PROCEDURE UpdateMemberContactInfo
    @MemberID INT,
    @Email VARCHAR(150),
    @Phone VARCHAR(50)

    AS
    BEGIN 
        SET NOCOUNT ON;

        UPDATE AcademicMember
        SET Email = @Email, Phone = @Phone
        WHERE MemberID = @MemberID;

        SELECT 'Contact information updated successfully.' AS ConfirmationMessage;
    END;
    GO

CREATE PROCEDURE UpdateAccountStatus
    @MemberID INT,
    @AccountStatus VARCHAR(50)

    AS
    BEGIN
        SET NOCOUNT ON

        UPDATE AcademicMember
        SET AccountStatus = @AccountStatus
        WHERE MemberID = @MemberID;

        SELECT 'Account status updated successfully.' AS ConfirmationMessage;
    END;
    GO

CREATE PROCEDURE AssignInstructorRole
    @MemberID INT,
    @ResearchArea VARCHAR(150),
    @OfficeLocation VARCHAR(50),
    @TeachingLoad INT
AS
BEGIN
    SET NOCOUNT ON;

    
    INSERT INTO AcademicInstructor (
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
END;
GO

CREATE PROCEDURE AssignTeachingAssistantRole
    @MemberID INT,
    @AssistantLevel VARCHAR(50),
    @SupervisorID INT
AS
BEGIN
    SET NOCOUNT ON;

   
    INSERT INTO TeachingAssistant (
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
END;
GO

CREATE PROCEDURE AssignDean
    @MemberID INT,
    @FacultyID INT,
    @ApprovalAuthorityScope VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    
    INSERT INTO Dean (
        MemberID, 
        FacultyID, 
        ApprovalAuthorityScope
    )
    VALUES (
        @MemberID, 
        @FacultyID, 
        @ApprovalAuthorityScope
    );

    SELECT 'Dean assigned successfully.' AS ConfirmationMessage;
END;
GO

CREATE PROCEDURE AssignManagementRole
    @MemberID INT,
    @ManagementTitle VARCHAR(150),
    @DecisionAuthorityLevel VARCHAR(50),
    @GovernanceScope VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    
    INSERT INTO UniversityManagement (
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
END;
GO

CREATE PROCEDURE AssignReviewerRole
    @MemberID INT,
    @ReviewDomain VARCHAR(150),
    @ReviewAuthorityLevel VARCHAR(50),
    @CommitteeMembership VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

   
    INSERT INTO CurriculumReviewer (
        MemberID,
        ReviewDomain, 
        ReviewAuthorityLevel, 
        CommitteeMembership
    )
    VALUES (
        @MemberID, 
        @ReviewDomain, 
        @ReviewAuthorityLevel, 
        @CommitteeMembership
    );

    SELECT 'Curriculum reviewer role assigned successfully.' AS ConfirmationMessage;
END;
GO

CREATE PROCEDURE GrantAccessScope
    @MemberID INT,
    @AccessScope VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    
    INSERT INTO MemberAccessScope (
        MemberID, 
        AccessScope
    )
    VALUES (
        @MemberID, 
        @AccessScope
    );

    SELECT 'Access scope granted successfully.' AS ConfirmationMessage;
END;
GO

CREATE PROCEDURE RevokeAccessScope
    @MemberID INT,
    @AccessScope VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM MemberAccessScope
    WHERE MemberID = @MemberID AND AccessScope = @AccessScope;

    SELECT 'Access scope revoked successfully.' AS ConfirmationMessage;
END;
GO

CREATE PROCEDURE AddFaculty
    @Name VARCHAR(150),
    @Description VARCHAR(1000), 
    @EstablishmentDate DATE,
    @DeanID INT

AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Faculty(
        FacultyName,
        FacultyFacDescription,
        EstablishmentDate,
        DeanID
    )

    VALUES(
        @FacultyName,
        @FacultyDescription,
        @EstablishmentDate,
        @DeanID
    );

    SELECT ' New faculty addedsuccessfully.' AS ConfirmationMessage;
END;
GO

CREATE PROCEDURE AddProgram
    @ProgramName VARCHAR(150),
    @DegreeLevel VARCHAR(50),
    @TotalCreditHours INT,
    @StandardDuration VARCHAR(50),
    @ProgramDescription VARCHAR(1000),
    @FacultyID INT
AS
BEGIN
    SET NOCOUNT ON;

    
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

   
    SELECT 
        'Program added successfully.' AS ConfirmationMessage,
        SCOPE_IDENTITY() AS NewProgramID;
END;
GO

CREATE PROCEDURE AddCourse
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

    
    INSERT INTO Course (
        CourseCode, 
        Title, 
        CourseDescription, 
        CreditHours, 
        CourseLevel, 
        CourseType, 
        DefaultStudySemester, 
        RequiredForProgram, 
        ElectivePool, 
        MinSelectionRule
    )
    VALUES (
        @CourseCode, 
        @Title, 
        @CourseDescription, 
        @CreditHours, 
        @CourseLevel, 
        @CourseType, 
        @DefaultStudySemester, 
        @RequiredForProgram, 
        @ElectivePool, 
        @MinSelectionRule
    );

    SELECT 'Course added successfully.' AS ConfirmationMessage;
END;
GO

CREATE PROCEDURE AddCourseRequisite
    @CourseCode VARCHAR(20),
    @RequisiteCode VARCHAR(20),
    @RequisiteType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    
    INSERT INTO CourseRequisite (
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

   
    INSERT INTO DeanTerm (
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

    INSERT INTO CourseOffering (
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
    JOIN Instructor i ON m.MemberID = i.MemberID
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