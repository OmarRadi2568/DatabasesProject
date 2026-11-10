CREATE Database GCAIMP;
GO
USE GCAIMP;
GO

CREATE TABLE faculty(
	FacultyID INT PRIMARY KEY,
	FacultyName VARCHAR(20),
	FacultyDescription TEXT,
	EstablishmentDate DATE,
	DeanID INT

);

CREATE TABLE academic_member(
	MemberID INT PRIMARY KEY,
	FullName VARCHAR(40),
	UniversityIDNo INT,
	email VARCHAR(50),
	phone VARCHAR(12),
	Academic_rank VARCHAR(10),
	EmploymentStatus VARCHAR(10),
	AccountStatus VARCHAR(10),
	FacultyID INT
);

CREATE TABLE member_access_scope(
	MemberID INT,
	AccessScope VARCHAR(20) PRIMARY KEY
);

CREATE TABLE academic_instructor(
	MemberID INT PRIMARY KEY,
	ResearchArea VARCHAR(20),
	OfficeLocation VARCHAR(20),
	TeachingLoad VARCHAR(20)

);

CREATE TABLE teaching_assistant(
	MemberID INT PRIMARY KEY,
	AssistantLevel VARCHAR(20),
	SupervisorID INT

);

CREATE TABLE dean(
	MemberID INT PRIMARY KEY,
	ApprovalAuthorityScope VARCHAR(20)

);

CREATE TABLE university_management(
	MemberID INT PRIMARY KEY,
	ManagementTitle VARCHAR(20),
	DecisionAuthorityLevel VARCHAR(20),
	GovernanceScope VARCHAR(20)
);

CREATE TABLE Curriculum_Reviewer(
	MemberID INT PRIMARY KEY,
	ReviewDomain VARCHAR(20),
	ReviewAuthorityLevel VARCHAR(20)
 
);

CREATE TABLE Reviewer_Committee(
	MemberID INT,
	CommiteeMembership VARCHAR(20),


	PRIMARY KEY(MemberID, CommitteeMembership)
);

CREATE TABLE semester(
	SemesterID INT PRIMARY KEY,
	SemesterName VARCHAR(20),
	AcademicYear INT,
	StartDate DATE,
	EndDate DATE

);

CREATE TABLE dean_term(
	DeanID INT,
	SemesterID INT,

	PRIMARY KEY(DeanID, SemesterID)

);
ALTER TABLE Faculty
ADD CONSTRAINT FK_Faculty_Dean 
FOREIGN KEY (DeanID) REFERENCES Dean(MemberID);

ALTER TABLE Academic_Member
ADD CONSTRAINT FK_AcademicMember_Faculty 
FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID);

ALTER TABLE Member_Access_Scope
ADD CONSTRAINT FK_MemberAccessScope_Member 
FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID);

ALTER TABLE Academic_Instructor
ADD CONSTRAINT FK_AcademicInstructor_Member 
FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID);

ALTER TABLE Teaching_Assistant
ADD CONSTRAINT FK_TeachingAssistant_Member 
FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID);

ALTER TABLE Teaching_Assistant
ADD CONSTRAINT FK_TeachingAssistant_Supervisor 
FOREIGN KEY (SupervisorID) REFERENCES Academic_Instructor(MemberID);

ALTER TABLE Dean
ADD CONSTRAINT FK_Dean_AcademicMember 
FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID);

ALTER TABLE University_Management
ADD CONSTRAINT FK_UniversityManagement_Member 
FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID);

ALTER TABLE Curriculum_Reviewer
ADD CONSTRAINT FK_CurriculumReviewer_Member 
FOREIGN KEY (MemberID) REFERENCES Academic_Member(MemberID);

ALTER TABLE Reviewer_Committee
ADD CONSTRAINT FK_ReviewerCommittee_Reviewer 
FOREIGN KEY (MemberID) REFERENCES Curriculum_Reviewer(MemberID);

ALTER TABLE Dean_Term
ADD CONSTRAINT FK_DeanTerm_Dean 
FOREIGN KEY (DeanID) REFERENCES Dean(MemberID);

ALTER TABLE Dean_Term
ADD CONSTRAINT FK_DeanTerm_Semester 
FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID);



