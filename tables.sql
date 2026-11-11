/* =====================================================================
   GCAIMP - Milestone 2
   Tables.sql  (Microsoft SQL Server)
   Run order: Tables.sql -> Insertions.sql -> Procedures.sql -> Executions.sql
   ===================================================================== */

-- Uncomment the next two lines if you want to create a fresh database
-- CREATE DATABASE GCAIMP;
-- GO
-- USE GCAIMP;
-- GO

/* ---------------------------------------------------------------------
   0. Clean re-run support (drops everything in dependency order)
   --------------------------------------------------------------------- */
IF OBJECT_ID('FK_Faculty_Dean', 'F') IS NOT NULL
    ALTER TABLE Faculty DROP CONSTRAINT FK_Faculty_Dean;
GO

DROP TABLE IF EXISTS Audit_Log;
DROP TABLE IF EXISTS Notification_Recipient;
DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS Review_Evidence;
DROP TABLE IF EXISTS Review_Assessment;
DROP TABLE IF EXISTS Review_Mapping;
DROP TABLE IF EXISTS Accreditation_Review;
DROP TABLE IF EXISTS Training_Requirement;
DROP TABLE IF EXISTS Session_Attendance;
DROP TABLE IF EXISTS In_Person_Training;
DROP TABLE IF EXISTS Online_Training;
DROP TABLE IF EXISTS Training_Session;
DROP TABLE IF EXISTS Student_Feedback;
DROP TABLE IF EXISTS Outcome_Report;
DROP TABLE IF EXISTS Evidence;
DROP TABLE IF EXISTS Milestone;
DROP TABLE IF EXISTS Initiative_Tool;
DROP TABLE IF EXISTS Teaching_Methodology;
DROP TABLE IF EXISTS AI_Tool;
DROP TABLE IF EXISTS Approval_Record;
DROP TABLE IF EXISTS Initiative_Member;
DROP TABLE IF EXISTS Assessment_Redesign;
DROP TABLE IF EXISTS Methodology_Change;
DROP TABLE IF EXISTS AI_Tool_Integration;
DROP TABLE IF EXISTS Modification_Proposal;
DROP TABLE IF EXISTS Innovation_Initiative;
DROP TABLE IF EXISTS Tool;
DROP TABLE IF EXISTS Outcome_Assessment;
DROP TABLE IF EXISTS Outcome_Mapping;
DROP TABLE IF EXISTS Offering_TA;
DROP TABLE IF EXISTS Course_Offering;
DROP TABLE IF EXISTS ILO;
DROP TABLE IF EXISTS Course_Requisite;
DROP TABLE IF EXISTS Version_Course;
DROP TABLE IF EXISTS Elective_Course;
DROP TABLE IF EXISTS Core_Course;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Curriculum_Version;
DROP TABLE IF EXISTS PLO;
DROP TABLE IF EXISTS Program;
DROP TABLE IF EXISTS Dean_Term;
DROP TABLE IF EXISTS Semester;
DROP TABLE IF EXISTS Reviewer_Committee;
DROP TABLE IF EXISTS Curriculum_Reviewer;
DROP TABLE IF EXISTS University_Management;
DROP TABLE IF EXISTS Dean;
DROP TABLE IF EXISTS Teaching_Assistant;
DROP TABLE IF EXISTS Academic_Instructor;
DROP TABLE IF EXISTS Member_Access_Scope;
DROP TABLE IF EXISTS Academic_Member;
DROP TABLE IF EXISTS Faculty;
GO

/* =====================================================================
   1. PEOPLE & ORGANISATION
   ===================================================================== */

-- Faculty.DeanID -> Dean.MemberID is added at the end of this section
-- (Faculty and Dean reference each other through Academic_Member).
CREATE TABLE Faculty (
    FacultyID         INT IDENTITY(1,1) NOT NULL,
    FacultyName              VARCHAR(150)  NOT NULL,
    FacultyDescription       VARCHAR(1000) NULL,
    EstablishmentDate DATE          NULL,
    DeanID            INT           NULL,
    CONSTRAINT PK_Faculty      PRIMARY KEY (FacultyID),
    CONSTRAINT UQ_Faculty_Name UNIQUE (FacultyName)
);
GO

CREATE TABLE Academic_Member (
    MemberID         INT IDENTITY(1,1) NOT NULL,
    FullName         VARCHAR(150) NOT NULL,
    UniversityIDNo   VARCHAR(50)  NOT NULL,
    Email            VARCHAR(150) NOT NULL,
    Phone            VARCHAR(50)  NULL,
    AcademicRank     VARCHAR(50)  NULL,
    EmploymentStatus VARCHAR(50)  NULL,
    AccountStatus    VARCHAR(50)  NOT NULL CONSTRAINT DF_Member_AccountStatus DEFAULT 'Active',
    FacultyID        INT          NOT NULL,
    CONSTRAINT PK_Academic_Member PRIMARY KEY (MemberID),
    CONSTRAINT UQ_Member_UniID    UNIQUE (UniversityIDNo),
    CONSTRAINT UQ_Member_Email    UNIQUE (Email),
    CONSTRAINT CK_Member_AccountStatus CHECK (AccountStatus IN ('Active','Suspended','Deactivated')),
    CONSTRAINT FK_Member_Faculty  FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
GO

CREATE TABLE Member_Access_Scope (
    MemberID    INT         NOT NULL,
    AccessScope VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Member_Access_Scope PRIMARY KEY (MemberID, AccessScope),
    CONSTRAINT FK_MAS_Member FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID)
);
GO

CREATE TABLE Academic_Instructor (
    MemberID       INT          NOT NULL,
    ResearchArea   VARCHAR(150) NULL,
    OfficeLocation VARCHAR(50)  NULL,
    TeachingLoad   INT          NULL,
    CONSTRAINT PK_Academic_Instructor PRIMARY KEY (MemberID),
    CONSTRAINT CK_Instructor_Load CHECK (TeachingLoad IS NULL OR TeachingLoad >= 0),
    CONSTRAINT FK_Instructor_Member FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID)
);
GO

CREATE TABLE Teaching_Assistant (
    MemberID       INT         NOT NULL,
    AssistantLevel VARCHAR(50) NULL,
    SupervisorID   INT         NOT NULL,
    CONSTRAINT PK_Teaching_Assistant PRIMARY KEY (MemberID),
    CONSTRAINT FK_TA_Member     FOREIGN KEY (MemberID)     REFERENCES Academic_Member(MemberID),
    CONSTRAINT FK_TA_Supervisor FOREIGN KEY (SupervisorID) REFERENCES Academic_Instructor(MemberID),
    CONSTRAINT CK_TA_NotSelf    CHECK (MemberID <> SupervisorID)
);
GO

CREATE TABLE Dean (
    MemberID                INT          NOT NULL,
    ApprovalAuthorityScope  VARCHAR(150) NULL,
    CONSTRAINT PK_Dean PRIMARY KEY (MemberID),
    CONSTRAINT FK_Dean_Member FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID)
);
GO

-- Now that Dean exists, close the Faculty <-> Dean loop.
ALTER TABLE Faculty
    ADD CONSTRAINT FK_Faculty_Dean FOREIGN KEY (DeanID) REFERENCES Dean(MemberID);
GO

-- A faculty has one dean, and a person is dean of at most one faculty.
CREATE UNIQUE INDEX UX_Faculty_DeanID ON Faculty(DeanID) WHERE DeanID IS NOT NULL;
GO

CREATE TABLE University_Management (
    MemberID               INT          NOT NULL,
    ManagementTitle        VARCHAR(150) NULL,
    DecisionAuthorityLevel VARCHAR(50)  NULL,
    GovernanceScope        VARCHAR(150) NULL,
    CONSTRAINT PK_University_Management PRIMARY KEY (MemberID),
    CONSTRAINT FK_UM_Member FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID)
);
GO

CREATE TABLE Curriculum_Reviewer (
    MemberID             INT          NOT NULL,
    ReviewDomain         VARCHAR(150) NULL,
    ReviewAuthorityLevel VARCHAR(50)  NULL,
    CONSTRAINT PK_Curriculum_Reviewer PRIMARY KEY (MemberID),
    CONSTRAINT FK_Reviewer_Member FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID)
);
GO

CREATE TABLE Reviewer_Committee (
    MemberID            INT          NOT NULL,
    CommitteeMembership VARCHAR(150) NOT NULL,
    CONSTRAINT PK_Reviewer_Committee PRIMARY KEY (MemberID, CommitteeMembership),
    CONSTRAINT FK_RC_Reviewer FOREIGN KEY (MemberID) REFERENCES Curriculum_Reviewer(MemberID)
);
GO

CREATE TABLE Semester (
    SemesterID   INT IDENTITY(1,1) NOT NULL,
    SemesterName         VARCHAR(50) NOT NULL,
    AcademicYear VARCHAR(50) NOT NULL,
    StartDate    DATE        NOT NULL,
    EndDate      DATE        NOT NULL,
    CONSTRAINT PK_Semester PRIMARY KEY (SemesterID),
    CONSTRAINT UQ_Semester_NameYear UNIQUE (SemesterName, AcademicYear),
    CONSTRAINT CK_Semester_Dates CHECK (EndDate > StartDate)
);
GO

CREATE TABLE Dean_Term (
    DeanID     INT NOT NULL,
    SemesterID INT NOT NULL,
    CONSTRAINT PK_Dean_Term PRIMARY KEY (DeanID, SemesterID),
    CONSTRAINT FK_DT_Dean     FOREIGN KEY (DeanID)     REFERENCES Dean(MemberID),
    CONSTRAINT FK_DT_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID)
);
GO

/* =====================================================================
   2. CURRICULUM
   ===================================================================== */

CREATE TABLE Program (
    ProgramID         INT IDENTITY(1,1) NOT NULL,
    ProgramName              VARCHAR(150)  NOT NULL,
    DegreeLevel       VARCHAR(50)   NULL,
    TotalCreditHours  INT           NULL,
    StandardDuration  VARCHAR(50)   NULL,
    ProgramDescription       VARCHAR(1000) NULL,
    FacultyID         INT           NOT NULL,
    CONSTRAINT PK_Program PRIMARY KEY (ProgramID),
    CONSTRAINT CK_Program_Credits CHECK (TotalCreditHours IS NULL OR TotalCreditHours > 0),
    CONSTRAINT FK_Program_Faculty FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
GO

CREATE TABLE PLO (
    ProgramID INT           NOT NULL,
    PLOCode   VARCHAR(20)   NOT NULL,
    Statement VARCHAR(1000) NOT NULL,
    Category  VARCHAR(50)   NULL,
    CONSTRAINT PK_PLO PRIMARY KEY (ProgramID, PLOCode),
    CONSTRAINT FK_PLO_Program FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);
GO

CREATE TABLE Curriculum_Version (
    ProgramID       INT         NOT NULL,
    VersionLabel    VARCHAR(20) NOT NULL,
    AcademicYear    VARCHAR(50) NOT NULL,
    EffectivePeriod VARCHAR(50) NULL,
    VersionStatus          VARCHAR(50) NOT NULL CONSTRAINT DF_CV_Status DEFAULT 'Draft',
    ApprovalDate    DATE        NULL,
    CONSTRAINT PK_Curriculum_Version PRIMARY KEY (ProgramID, VersionLabel, AcademicYear),
    CONSTRAINT CK_CV_Status CHECK (VersionStatus IN ('Draft','Active','Archived')),
    CONSTRAINT FK_CV_Program FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);
GO

CREATE TABLE Course (
    CourseCode  VARCHAR(20)   NOT NULL,
    Title       VARCHAR(150)  NOT NULL,
    CourseDescription VARCHAR(1000) NULL,
    CreditHours INT           NOT NULL,
    CourseLevel       VARCHAR(50)   NULL,
    CONSTRAINT PK_Course PRIMARY KEY (CourseCode),
    CONSTRAINT CK_Course_Credits CHECK (CreditHours > 0)
);
GO

CREATE TABLE Core_Course (
    CourseCode           VARCHAR(20)  NOT NULL,
    DefaultStudySemester INT          NULL,
    RequiredForProgram   VARCHAR(150) NULL,
    CONSTRAINT PK_Core_Course PRIMARY KEY (CourseCode),
    CONSTRAINT FK_Core_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode)
);
GO

CREATE TABLE Elective_Course (
    CourseCode       VARCHAR(20)  NOT NULL,
    ElectivePool     VARCHAR(150) NULL,
    MinSelectionRule VARCHAR(150) NULL,
    CONSTRAINT PK_Elective_Course PRIMARY KEY (CourseCode),
    CONSTRAINT FK_Elective_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode)
);
GO

CREATE TABLE Version_Course (
    ProgramID       INT         NOT NULL,
    VersionLabel    VARCHAR(20) NOT NULL,
    AcademicYear    VARCHAR(50) NOT NULL,
    CourseCode      VARCHAR(20) NOT NULL,
    StudySemesterNo INT         NOT NULL,
    IsMandatory     BIT         NOT NULL CONSTRAINT DF_VC_Mandatory DEFAULT 1,
    CONSTRAINT PK_Version_Course PRIMARY KEY (ProgramID, VersionLabel, AcademicYear, CourseCode),
    CONSTRAINT CK_VC_Semester CHECK (StudySemesterNo > 0),
    CONSTRAINT FK_VC_Version FOREIGN KEY (ProgramID, VersionLabel, AcademicYear)
        REFERENCES Curriculum_Version(ProgramID, VersionLabel, AcademicYear),
    CONSTRAINT FK_VC_Course  FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode)
);
GO

CREATE TABLE Course_Requisite (
    CourseCode    VARCHAR(20) NOT NULL,
    RequisiteCode VARCHAR(20) NOT NULL,
    RequisiteType VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Course_Requisite PRIMARY KEY (CourseCode, RequisiteCode),
    CONSTRAINT CK_Requisite_Type   CHECK (RequisiteType IN ('Prerequisite','Corequisite')),
    CONSTRAINT CK_Requisite_NotSelf CHECK (CourseCode <> RequisiteCode),
    CONSTRAINT FK_CR_Course    FOREIGN KEY (CourseCode)    REFERENCES Course(CourseCode),
    CONSTRAINT FK_CR_Requisite FOREIGN KEY (RequisiteCode) REFERENCES Course(CourseCode)
);
GO

CREATE TABLE ILO (
    CourseCode     VARCHAR(20)   NOT NULL,
    ILOCode        VARCHAR(20)   NOT NULL,
    Statement      VARCHAR(1000) NOT NULL,
    CognitiveLevel VARCHAR(50)   NULL,
    CONSTRAINT PK_ILO PRIMARY KEY (CourseCode, ILOCode),
    CONSTRAINT FK_ILO_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode)
);
GO

CREATE TABLE Course_Offering (
    CourseCode    VARCHAR(20) NOT NULL,
    SemesterID    INT         NOT NULL,
    SectionID     VARCHAR(20) NOT NULL,
    DeliveryMode  VARCHAR(50) NULL,
    EnrolledCount INT         NOT NULL CONSTRAINT DF_CO_Enrolled DEFAULT 0,
    OfferingStatus        VARCHAR(50) NOT NULL CONSTRAINT DF_CO_Status DEFAULT 'Open',
    InstructorID  INT         NOT NULL,
    CONSTRAINT PK_Course_Offering PRIMARY KEY (CourseCode, SemesterID, SectionID),
    CONSTRAINT CK_CO_Enrolled CHECK (EnrolledCount >= 0),
    CONSTRAINT FK_CO_Course     FOREIGN KEY (CourseCode)   REFERENCES Course(CourseCode),
    CONSTRAINT FK_CO_Semester   FOREIGN KEY (SemesterID)   REFERENCES Semester(SemesterID),
    CONSTRAINT FK_CO_Instructor FOREIGN KEY (InstructorID) REFERENCES Academic_Instructor(MemberID)
);
GO

CREATE TABLE Offering_TA (
    CourseCode VARCHAR(20) NOT NULL,
    SemesterID INT         NOT NULL,
    SectionID  VARCHAR(20) NOT NULL,
    TAID       INT         NOT NULL,
    CONSTRAINT PK_Offering_TA PRIMARY KEY (CourseCode, SemesterID, SectionID, TAID),
    CONSTRAINT FK_OTA_Offering FOREIGN KEY (CourseCode, SemesterID, SectionID)
        REFERENCES Course_Offering(CourseCode, SemesterID, SectionID),
    CONSTRAINT FK_OTA_TA FOREIGN KEY (TAID) REFERENCES Teaching_Assistant(MemberID)
);
GO

/* =====================================================================
   3. OUTCOMES & PROPOSALS
   ===================================================================== */

CREATE TABLE Outcome_Mapping (
    MappingID         INT IDENTITY(1,1) NOT NULL,
    CoverageLevel     VARCHAR(50) NOT NULL,
    IsAssessmentPoint BIT         NOT NULL CONSTRAINT DF_OM_AssessPt DEFAULT 0,
    MappingStatus     VARCHAR(50) NOT NULL CONSTRAINT DF_OM_Status DEFAULT 'Pending',
    CourseCode        VARCHAR(20) NOT NULL,
    ILOCode           VARCHAR(20) NOT NULL,
    ProgramID         INT         NOT NULL,
    PLOCode           VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Outcome_Mapping PRIMARY KEY (MappingID),
    CONSTRAINT CK_OM_Coverage CHECK (CoverageLevel IN ('Introduced','Reinforced','Mastered')),
    CONSTRAINT CK_OM_Status   CHECK (MappingStatus IN ('Pending','Approved','Rejected')),
    CONSTRAINT UQ_OM_Link UNIQUE (CourseCode, ILOCode, ProgramID, PLOCode),
    CONSTRAINT FK_OM_ILO FOREIGN KEY (CourseCode, ILOCode) REFERENCES ILO(CourseCode, ILOCode),
    CONSTRAINT FK_OM_PLO FOREIGN KEY (ProgramID, PLOCode)  REFERENCES PLO(ProgramID, PLOCode)
);
GO

CREATE TABLE Outcome_Assessment (
    AssessmentID     INT IDENTITY(1,1) NOT NULL,
    Instrument       VARCHAR(150)  NOT NULL,
    AssessmentDescription      VARCHAR(1000) NULL,
    TargetThreshold  DECIMAL(10,2) NOT NULL,
    AttainedValue    DECIMAL(10,2) NOT NULL,
    SampleSize       INT           NULL,
    -- Calculated automatically from the two values above
    TargetMet AS (CASE WHEN AttainedValue >= TargetThreshold THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END) PERSISTED,
    AnalysisNotes    VARCHAR(1000) NULL,
    CorrectiveAction VARCHAR(1000) NULL,
    CourseCode       VARCHAR(20)   NOT NULL,
    ILOCode          VARCHAR(20)   NOT NULL,
    SemesterID       INT           NOT NULL,
    SectionID        VARCHAR(20)   NOT NULL,
    MappingID        INT           NOT NULL,
    CONSTRAINT PK_Outcome_Assessment PRIMARY KEY (AssessmentID),
    CONSTRAINT CK_OA_Sample CHECK (SampleSize IS NULL OR SampleSize >= 0),
    CONSTRAINT FK_OA_ILO FOREIGN KEY (CourseCode, ILOCode) REFERENCES ILO(CourseCode, ILOCode),
    CONSTRAINT FK_OA_Offering FOREIGN KEY (CourseCode, SemesterID, SectionID)
        REFERENCES Course_Offering(CourseCode, SemesterID, SectionID),
    CONSTRAINT FK_OA_Mapping FOREIGN KEY (MappingID) REFERENCES Outcome_Mapping(MappingID)
);
GO

CREATE TABLE Modification_Proposal (
    ProposalID            INT IDENTITY(1,1) NOT NULL,
    Title                 VARCHAR(150)  NOT NULL,
    Rationale             VARCHAR(1000) NULL,
    ModificationType      VARCHAR(50)   NULL,
    CurrentStateSummary   VARCHAR(1000) NULL,
    ProposedStateSummary  VARCHAR(1000) NULL,
    SubmissionDate        DATE          NOT NULL CONSTRAINT DF_MP_SubDate DEFAULT (CAST(GETDATE() AS DATE)),
    ProposerID            INT           NOT NULL,
    CourseCode            VARCHAR(20)   NULL,
    ProgramID             INT           NULL,
    VersionLabel          VARCHAR(20)   NULL,
    AcademicYear          VARCHAR(50)   NULL,
    AssessmentID          INT           NULL,
    CONSTRAINT PK_Modification_Proposal PRIMARY KEY (ProposalID),
    CONSTRAINT FK_MP_Proposer FOREIGN KEY (ProposerID) REFERENCES Academic_Instructor(MemberID),
    CONSTRAINT FK_MP_Course   FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode),
    CONSTRAINT FK_MP_Program  FOREIGN KEY (ProgramID)  REFERENCES Program(ProgramID),
    CONSTRAINT FK_MP_Version  FOREIGN KEY (ProgramID, VersionLabel, AcademicYear)
        REFERENCES Curriculum_Version(ProgramID, VersionLabel, AcademicYear),
    CONSTRAINT FK_MP_Assessment FOREIGN KEY (AssessmentID) REFERENCES Outcome_Assessment(AssessmentID)
);
GO

/* =====================================================================
   4. INNOVATION
   ===================================================================== */

CREATE TABLE Innovation_Initiative (
    InitiativeID           INT IDENTITY(1,1) NOT NULL,
    Title                  VARCHAR(150)  NOT NULL,
    InitiativeDescription            VARCHAR(1000) NULL,
    Motivation             VARCHAR(1000) NULL,
    RegistrationDate       DATE          NOT NULL CONSTRAINT DF_II_RegDate DEFAULT (CAST(GETDATE() AS DATE)),
    ImplementationDeadline DATE          NULL,
    InitiativeStatus                 VARCHAR(50)   NOT NULL CONSTRAINT DF_II_Status DEFAULT 'Draft',
    CourseCode             VARCHAR(20)   NOT NULL,
    SemesterID             INT           NOT NULL,
    SectionID              VARCHAR(20)   NOT NULL,
    FacultyID              INT           NOT NULL,
    SubmitterID            INT           NOT NULL,
    TargetStartSemesterID  INT           NULL,
    AssessmentID           INT           NULL,
    CONSTRAINT PK_Innovation_Initiative PRIMARY KEY (InitiativeID),
    CONSTRAINT CK_II_Status CHECK (InitiativeStatus IN ('Draft','Pending Approval','Approved','Rejected',
                                              'Returned for Revision','Escalated','In Progress','Completed')),
    CONSTRAINT FK_II_Offering FOREIGN KEY (CourseCode, SemesterID, SectionID)
        REFERENCES Course_Offering(CourseCode, SemesterID, SectionID),
    CONSTRAINT FK_II_Faculty     FOREIGN KEY (FacultyID)             REFERENCES Faculty(FacultyID),
    CONSTRAINT FK_II_Submitter   FOREIGN KEY (SubmitterID)           REFERENCES Academic_Member(MemberID),
    CONSTRAINT FK_II_TargetStart FOREIGN KEY (TargetStartSemesterID) REFERENCES Semester(SemesterID),
    CONSTRAINT FK_II_Assessment  FOREIGN KEY (AssessmentID)          REFERENCES Outcome_Assessment(AssessmentID)
);
GO

CREATE TABLE AI_Tool_Integration (
    InitiativeID           INT           NOT NULL,
    IntegrationObjective   VARCHAR(1000) NULL,
    ToolCategory           VARCHAR(50)   NULL,
    DataPrivacyNotes       VARCHAR(1000) NULL,
    AcademicIntegrityNotes VARCHAR(1000) NULL,
    CONSTRAINT PK_AI_Tool_Integration PRIMARY KEY (InitiativeID),
    CONSTRAINT FK_ATI_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID)
);
GO

CREATE TABLE Methodology_Change (
    InitiativeID        INT           NOT NULL,
    PedagogicalApproach VARCHAR(150)  NULL,
    DeliveryChange      VARCHAR(1000) NULL,
    ReferenceFramework  VARCHAR(150)  NULL,
    CONSTRAINT PK_Methodology_Change PRIMARY KEY (InitiativeID),
    CONSTRAINT FK_MC_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID)
);
GO

CREATE TABLE Assessment_Redesign (
    InitiativeID             INT           NOT NULL,
    AssessmentTypeAffected   VARCHAR(50)   NULL,
    RubricWeightingChanges   VARCHAR(1000) NULL,
    FairnessSafeguards       VARCHAR(1000) NULL,
    CONSTRAINT PK_Assessment_Redesign PRIMARY KEY (InitiativeID),
    CONSTRAINT FK_AR_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID)
);
GO

CREATE TABLE Initiative_Member (
    InitiativeID INT         NOT NULL,
    MemberID     INT         NOT NULL,
    MemberRole         VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Initiative_Member PRIMARY KEY (InitiativeID, MemberID),
    CONSTRAINT FK_IM_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_IM_Member     FOREIGN KEY (MemberID)     REFERENCES Academic_Member(MemberID)
);
GO

-- A decision targets either a proposal or an initiative (exactly one of the two).
CREATE TABLE Approval_Record (
    ApprovalID    INT IDENTITY(1,1) NOT NULL,
    Decision      VARCHAR(50)   NOT NULL,
    DecisionLevel VARCHAR(50)   NOT NULL,
    DecisionDate  DATE          NOT NULL CONSTRAINT DF_AP_Date DEFAULT (CAST(GETDATE() AS DATE)),
    Comments      VARCHAR(1000) NULL,
    DeciderID     INT           NOT NULL,
    ProposalID    INT           NULL,
    InitiativeID  INT           NULL,
    CONSTRAINT PK_Approval_Record PRIMARY KEY (ApprovalID),
    CONSTRAINT CK_AP_Level  CHECK (DecisionLevel IN ('Reviewer','Dean','University')),
    CONSTRAINT CK_AP_Target CHECK ((ProposalID IS NOT NULL AND InitiativeID IS NULL)
                                OR (ProposalID IS NULL AND InitiativeID IS NOT NULL)),
    CONSTRAINT FK_AP_Decider    FOREIGN KEY (DeciderID)    REFERENCES Academic_Member(MemberID),
    CONSTRAINT FK_AP_Proposal   FOREIGN KEY (ProposalID)   REFERENCES Modification_Proposal(ProposalID),
    CONSTRAINT FK_AP_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID)
);
GO

CREATE TABLE Tool (
    ToolID      INT IDENTITY(1,1) NOT NULL,
    ToolName        VARCHAR(150)  NOT NULL,
    ToolDescription VARCHAR(1000) NULL,
    Category    VARCHAR(50)   NULL,
    ToolStatus      VARCHAR(50)   NOT NULL CONSTRAINT DF_Tool_Status DEFAULT 'Under Review',
    CONSTRAINT PK_Tool PRIMARY KEY (ToolID),
    CONSTRAINT UQ_Tool_Name UNIQUE (ToolName)
);
GO

CREATE TABLE AI_Tool (
    ToolID       INT          NOT NULL,
    Provider     VARCHAR(150) NULL,
    ModelVersion VARCHAR(50)  NULL,
    LicenseType  VARCHAR(50)  NULL,
    HostingMode  VARCHAR(50)  NULL,
    CostModel    VARCHAR(50)  NULL,
    CONSTRAINT PK_AI_Tool PRIMARY KEY (ToolID),
    CONSTRAINT FK_AITool_Tool FOREIGN KEY (ToolID) REFERENCES Tool(ToolID)
);
GO

CREATE TABLE Teaching_Methodology (
    ToolID                INT           NOT NULL,
    OriginatingFramework  VARCHAR(150)  NULL,
    ReferenceSource       VARCHAR(150)  NULL,
    RequiredResources     VARCHAR(1000) NULL,
    CONSTRAINT PK_Teaching_Methodology PRIMARY KEY (ToolID),
    CONSTRAINT FK_TM_Tool FOREIGN KEY (ToolID) REFERENCES Tool(ToolID)
);
GO

CREATE TABLE Initiative_Tool (
    InitiativeID INT NOT NULL,
    ToolID       INT NOT NULL,
    CONSTRAINT PK_Initiative_Tool PRIMARY KEY (InitiativeID, ToolID),
    CONSTRAINT FK_IT_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_IT_Tool       FOREIGN KEY (ToolID)       REFERENCES Tool(ToolID)
);
GO

CREATE TABLE Milestone (
    InitiativeID   INT           NOT NULL,
    SeqNo          INT           NOT NULL,
    Title          VARCHAR(150)  NOT NULL,
    MilestoneDescription    VARCHAR(1000) NULL,
    DueDate        DATE          NOT NULL,
    CompletionDate DATE          NULL,
    MilestoneStatus         VARCHAR(50)   NOT NULL CONSTRAINT DF_MS_Status DEFAULT 'Pending',
    CONSTRAINT PK_Milestone PRIMARY KEY (InitiativeID, SeqNo),
    CONSTRAINT CK_MS_Seq    CHECK (SeqNo > 0),
    CONSTRAINT CK_MS_Status CHECK (MilestoneStatus IN ('Pending','In Progress','Completed','Delayed')),
    CONSTRAINT FK_MS_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID)
);
GO

CREATE TABLE Evidence (
    EvidenceID     INT IDENTITY(1,1) NOT NULL,
    Title          VARCHAR(150)  NOT NULL,
    ArtifactType   VARCHAR(50)   NULL,
    FilePathOrURL  VARCHAR(1000) NOT NULL,
    UploadDate     DATE          NOT NULL CONSTRAINT DF_EV_Upload DEFAULT (CAST(GETDATE() AS DATE)),
    EvidenceDescription    VARCHAR(1000) NULL,
    InitiativeID   INT           NOT NULL,
    MilestoneSeqNo INT           NULL,   -- optional: evidence may belong to a specific milestone
    CONSTRAINT PK_Evidence PRIMARY KEY (EvidenceID),
    CONSTRAINT FK_EV_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_EV_Milestone  FOREIGN KEY (InitiativeID, MilestoneSeqNo)
        REFERENCES Milestone(InitiativeID, SeqNo)
);
GO

CREATE TABLE Outcome_Report (
    ReportID           INT IDENTITY(1,1) NOT NULL,
    MetricType         VARCHAR(50)   NOT NULL,
    QuantitativeValue  DECIMAL(10,2) NULL,
    BaselineValue      DECIMAL(10,2) NULL,
    QualitativeSummary VARCHAR(1000) NULL,
    InitiativeID       INT           NOT NULL,
    SemesterID         INT           NOT NULL,
    CONSTRAINT PK_Outcome_Report PRIMARY KEY (ReportID),
    CONSTRAINT FK_OR_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_OR_Semester   FOREIGN KEY (SemesterID)   REFERENCES Semester(SemesterID)
);
GO

-- Feedback is anonymous: no student/member reference is stored.
CREATE TABLE Student_Feedback (
    FeedbackID        INT IDENTITY(1,1) NOT NULL,
    Rating            INT           NOT NULL,
    FeedbackComment           VARCHAR(1000) NULL,
    CategorySentiment VARCHAR(50)   NULL,
    CollectionMethod  VARCHAR(50)   NULL,
    InitiativeID      INT           NOT NULL,
    SemesterID        INT           NOT NULL,
    CONSTRAINT PK_Student_Feedback PRIMARY KEY (FeedbackID),
    CONSTRAINT CK_SF_Rating CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT FK_SF_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_SF_Semester   FOREIGN KEY (SemesterID)   REFERENCES Semester(SemesterID)
);
GO

/* =====================================================================
   5. TRAINING
   ===================================================================== */

CREATE TABLE Training_Session (
    SessionID       INT IDENTITY(1,1) NOT NULL,
    Title           VARCHAR(150)  NOT NULL,
    Topic           VARCHAR(150)  NULL,
    SessionDescription     VARCHAR(1000) NULL,
    SessionDate     DATE          NOT NULL,
    DurationMinutes INT           NULL,
    Trainer         VARCHAR(150)  NULL,
    Capacity        INT           NOT NULL,
    SessionStatus          VARCHAR(50)   NOT NULL CONSTRAINT DF_TS_Status DEFAULT 'Scheduled',
    ToolID          INT           NOT NULL,
    CONSTRAINT PK_Training_Session PRIMARY KEY (SessionID),
    CONSTRAINT CK_TS_Duration CHECK (DurationMinutes IS NULL OR DurationMinutes > 0),
    CONSTRAINT CK_TS_Capacity CHECK (Capacity >= 0),
    CONSTRAINT FK_TS_Tool FOREIGN KEY (ToolID) REFERENCES Tool(ToolID)
);
GO

CREATE TABLE Online_Training (
    SessionID          INT           NOT NULL,
    Platform           VARCHAR(50)   NULL,
    MeetingLink        VARCHAR(1000) NULL,
    RecordingAvailable BIT           NOT NULL CONSTRAINT DF_OT_Rec DEFAULT 0,
    CONSTRAINT PK_Online_Training PRIMARY KEY (SessionID),
    CONSTRAINT FK_OT_Session FOREIGN KEY (SessionID) REFERENCES Training_Session(SessionID)
);
GO

CREATE TABLE In_Person_Training (
    SessionID         INT           NOT NULL,
    Venue             VARCHAR(150)  NULL,
    Campus            VARCHAR(50)   NULL,
    RequiredEquipment VARCHAR(1000) NULL,
    CONSTRAINT PK_In_Person_Training PRIMARY KEY (SessionID),
    CONSTRAINT FK_IPT_Session FOREIGN KEY (SessionID) REFERENCES Training_Session(SessionID)
);
GO

CREATE TABLE Session_Attendance (
    SessionID INT NOT NULL,
    MemberID  INT NOT NULL,
    CONSTRAINT PK_Session_Attendance PRIMARY KEY (SessionID, MemberID),
    CONSTRAINT FK_SA_Session FOREIGN KEY (SessionID) REFERENCES Training_Session(SessionID),
    CONSTRAINT FK_SA_Member  FOREIGN KEY (MemberID)  REFERENCES Academic_Member(MemberID)
);
GO

CREATE TABLE Training_Requirement (
    RequirementID INT IDENTITY(1,1) NOT NULL,
    RequirementDescription   VARCHAR(1000) NULL,
    TargetAudience VARCHAR(150) NULL,
    RequiredByDate DATE         NULL,
    IsMandatory   BIT           NOT NULL CONSTRAINT DF_TR_Mand DEFAULT 1,
    InitiativeID  INT           NOT NULL,
    ToolID        INT           NOT NULL,
    CONSTRAINT PK_Training_Requirement PRIMARY KEY (RequirementID),
    CONSTRAINT FK_TR_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_TR_Tool       FOREIGN KEY (ToolID)       REFERENCES Tool(ToolID)
);
GO

/* =====================================================================
   6. ACCREDITATION & GOVERNANCE
   ===================================================================== */

CREATE TABLE Accreditation_Review (
    ReviewID        INT IDENTITY(1,1) NOT NULL,
    AccreditingBody VARCHAR(150) NOT NULL,
    ReviewType      VARCHAR(50)  NULL,
    ReviewCycle     VARCHAR(50)  NULL,
    ReviewStatus          VARCHAR(50)  NOT NULL CONSTRAINT DF_AccR_Status DEFAULT 'Open',
    Decision        VARCHAR(50)  NULL,
    SubmissionDate  DATE         NULL,
    NextReviewDue   DATE         NULL,
    ProgramID       INT          NOT NULL,
    CONSTRAINT PK_Accreditation_Review PRIMARY KEY (ReviewID),
    CONSTRAINT FK_AccR_Program FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);
GO

CREATE TABLE Review_Mapping (
    ReviewID  INT NOT NULL,
    MappingID INT NOT NULL,
    CONSTRAINT PK_Review_Mapping PRIMARY KEY (ReviewID, MappingID),
    CONSTRAINT FK_RM_Review  FOREIGN KEY (ReviewID)  REFERENCES Accreditation_Review(ReviewID),
    CONSTRAINT FK_RM_Mapping FOREIGN KEY (MappingID) REFERENCES Outcome_Mapping(MappingID)
);
GO

CREATE TABLE Review_Assessment (
    ReviewID     INT NOT NULL,
    AssessmentID INT NOT NULL,
    CONSTRAINT PK_Review_Assessment PRIMARY KEY (ReviewID, AssessmentID),
    CONSTRAINT FK_RA_Review     FOREIGN KEY (ReviewID)     REFERENCES Accreditation_Review(ReviewID),
    CONSTRAINT FK_RA_Assessment FOREIGN KEY (AssessmentID) REFERENCES Outcome_Assessment(AssessmentID)
);
GO

CREATE TABLE Review_Evidence (
    ReviewID   INT NOT NULL,
    EvidenceID INT NOT NULL,
    CONSTRAINT PK_Review_Evidence PRIMARY KEY (ReviewID, EvidenceID),
    CONSTRAINT FK_RE_Review   FOREIGN KEY (ReviewID)   REFERENCES Accreditation_Review(ReviewID),
    CONSTRAINT FK_RE_Evidence FOREIGN KEY (EvidenceID) REFERENCES Evidence(EvidenceID)
);
GO

CREATE TABLE Notification (
    NotificationID INT IDENTITY(1,1) NOT NULL,
    MessageContent VARCHAR(1000) NOT NULL,
    CreatedAt      DATETIME      NOT NULL CONSTRAINT DF_N_Created DEFAULT GETDATE(),
    Urgency        VARCHAR(50)   NULL,
    Category       VARCHAR(50)   NULL,
    CONSTRAINT PK_Notification PRIMARY KEY (NotificationID)
);
GO

CREATE TABLE Notification_Recipient (
    NotificationID INT NOT NULL,
    MemberID       INT NOT NULL,
    ReadStatus     BIT NOT NULL CONSTRAINT DF_NR_Read DEFAULT 0,
    CONSTRAINT PK_Notification_Recipient PRIMARY KEY (NotificationID, MemberID),
    CONSTRAINT FK_NR_Notification FOREIGN KEY (NotificationID) REFERENCES Notification(NotificationID),
    CONSTRAINT FK_NR_Member       FOREIGN KEY (MemberID)       REFERENCES Academic_Member(MemberID)
);
GO

-- Each log row points at (at most) one affected item through the nullable FKs.
CREATE TABLE Audit_Log (
    LogID         INT IDENTITY(1,1) NOT NULL,
    ActionType    VARCHAR(50)   NOT NULL,
    LoggedAt      DATETIME      NOT NULL CONSTRAINT DF_AL_LoggedAt DEFAULT GETDATE(),
    ChangeSummary VARCHAR(1000) NULL,
    ActorID       INT           NOT NULL,
    ProposalID    INT           NULL,
    ApprovalID    INT           NULL,
    InitiativeID  INT           NULL,
    AssessmentID  INT           NULL,
    EvidenceID    INT           NULL,
    CONSTRAINT PK_Audit_Log PRIMARY KEY (LogID),
    CONSTRAINT FK_AL_Actor      FOREIGN KEY (ActorID)      REFERENCES Academic_Member(MemberID),
    CONSTRAINT FK_AL_Proposal   FOREIGN KEY (ProposalID)   REFERENCES Modification_Proposal(ProposalID),
    CONSTRAINT FK_AL_Approval   FOREIGN KEY (ApprovalID)   REFERENCES Approval_Record(ApprovalID),
    CONSTRAINT FK_AL_Initiative FOREIGN KEY (InitiativeID) REFERENCES Innovation_Initiative(InitiativeID),
    CONSTRAINT FK_AL_Assessment FOREIGN KEY (AssessmentID) REFERENCES Outcome_Assessment(AssessmentID),
    CONSTRAINT FK_AL_Evidence   FOREIGN KEY (EvidenceID)   REFERENCES Evidence(EvidenceID)
);
GO
