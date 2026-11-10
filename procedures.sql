
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
    @FacultyID int,
    @ApprovalAuthorityScope varchar(150)

AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Teaching_Assistant(
        MemberID,
        FacultyID,
        ApprovalAuthorityScope
    )
    VALUES (
        @MemberID,
        @FacultyID,
        @ApprovalAuthorityScope
    )

    SELECT 'Teaching Assistant role assigned successfully.' AS ConfirmationMessage;

END;
GO

CREATE PROCEDURE AssignDean
    @MemberID INT,
    @FacultyID INT,
    @ApprovalAuthorityScope VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert the dean appointment details
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
