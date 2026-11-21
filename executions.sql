SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =====================================================================
-- Executions.sql
-- One example call for every stored procedure (EXEC) and function (SELECT).
-- Run after Tables.sql, Insertions.sql and Procedures.sql.
-- The calls run in order and some depend on earlier ones: a call that uses
-- a "new" ID (for example Faculty 4 or Initiative 8) uses the ID created by
-- the earlier call that is named in its comment.
-- =====================================================================


-- =====================================================================
-- 1) System Administrator
-- =====================================================================

-- 1.1 ViewMemberInfo: details, roles and scopes of Member 4 (an instructor).
SELECT * FROM ViewMemberInfo(4);

-- 1.2 AddAcademicMember: adds a new member to Faculty 1 (becomes Member 17).
EXEC AddAcademicMember
    @FullName = 'Nadia Hamed',
    @UniversityIDNo = 'GIU-1017',
    @Email = 'nadia.hamed@giu-demo.edu',
    @Phone = '01000001017',
    @AcademicRank = 'Lecturer',
    @EmploymentStatus = 'Full-time',
    @AccountStatus = 'Active',
    @FacultyID = 1;

-- 1.3 UpdateMemberContactInfo: new email and phone for Member 16.
EXEC UpdateMemberContactInfo
    @MemberID = 16,
    @Email = 'heba.lotfy.new@giu-demo.edu',
    @Phone = '01000002016';

-- 1.4 UpdateAccountStatus: re-activates Member 15 (was Suspended).
EXEC UpdateAccountStatus
    @MemberID = 15,
    @AccountStatus = 'Active';

-- 1.5 AssignInstructorRole: Member 16 becomes an instructor.
EXEC AssignInstructorRole
    @MemberID = 16,
    @ResearchArea = 'Mechatronics Design',
    @OfficeLocation = 'E2.215',
    @TeachingLoad = 8;

-- 1.6 AssignTeachingAssistantRole: Member 17 (added in 1.2) becomes a TA under Instructor 4.
EXEC AssignTeachingAssistantRole
    @MemberID = 17,
    @AssistantLevel = 'Junior',
    @SupervisorID = 4;

-- 1.12 AddFaculty (run here, before 1.7, because AssignDean needs a faculty without a dean): creates Faculty 4.
EXEC AddFaculty
    @Name = 'Faculty of Applied Arts',
    @Description = 'Design and media programs',
    @EstablishmentDate = '2020-09-01',
    @DeanID = NULL;

-- 1.7 AssignDean: Member 15 becomes the dean of Faculty 4 (created just above).
EXEC AssignDean
    @MemberID = 15,
    @FacultyID = 4,
    @ApprovalAuthorityScope = 'Faculty of Applied Arts';

-- 1.8 AssignManagementRole: Member 16 joins University Management.
EXEC AssignManagementRole
    @MemberID = 16,
    @ManagementTitle = 'Director of Student Affairs',
    @DecisionAuthorityLevel = 'Senior',
    @GovernanceScope = 'Student services';

-- 1.9 AssignReviewerRole: Member 16 becomes a curriculum reviewer with a committee.
EXEC AssignReviewerRole
    @MemberID = 16,
    @ReviewDomain = 'Engineering Curricula',
    @ReviewAuthorityLevel = 'Standard',
    @CommitteeMembership = 'Engineering Curriculum Committee';

-- 1.10 GrantAccessScope: gives Member 16 the scope 'Submit Proposals'.
EXEC GrantAccessScope
    @MemberID = 16,
    @AccessScope = 'Submit Proposals';

-- 1.11 RevokeAccessScope: takes that scope away again.
EXEC RevokeAccessScope
    @MemberID = 16,
    @AccessScope = 'Submit Proposals';

-- 1.12 AddFaculty: already executed above (before 1.7).

-- 1.13 AddProgram: adds a program to Faculty 1 (becomes Program 5).
EXEC AddProgram
    @Name = 'BSc Data Science',
    @DegreeLevel = 'Bachelor',
    @TotalCreditHours = 180,
    @StandardDuration = '8 semesters',
    @Description = 'Data and statistics program',
    @FacultyID = 1;

-- 1.14 AddCourse: adds the core course CSEN330 (Computer Networks).
EXEC AddCourse
    @CourseCode = 'CSEN330',
    @Title = 'Computer Networks',
    @Description = 'Network protocols and architecture',
    @CreditHours = 6,
    @Level = 'Level 3',
    @CourseType = 'Core',
    @DefaultStudySemester = 5,
    @RequiredForProgram = 'BSc Computer Science',
    @ElectivePool = NULL,
    @MinSelectionRule = NULL;

-- 1.15 AddCourseRequisite: CSEN201 is a prerequisite of CSEN330.
EXEC AddCourseRequisite
    @CourseCode = 'CSEN330',
    @RequisiteCode = 'CSEN201',
    @RequisiteType = 'Prerequisite';

-- 1.16 AddSemester: adds Spring 2026/2027 (becomes Semester 6).
EXEC AddSemester
    @Name = 'Spring',
    @AcademicYear = '2026/2027',
    @StartDate = '2027-02-15',
    @EndDate = '2027-06-30';

-- 1.17 RecordDeanTerm: Dean 3 also served in Semester 3.
EXEC RecordDeanTerm
    @DeanID = 3,
    @SemesterID = 3;

-- 1.18 CreateCourseOffering: CSEN330, Semester 5, Section S1, taught by Instructor 4.
EXEC CreateCourseOffering
    @CourseCode = 'CSEN330',
    @SemesterID = 5,
    @SectionID = 'S1',
    @DeliveryMode = 'In-person',
    @EnrolledCount = 30,
    @InstructorID = 4;

-- 1.19 AssignTAToOffering: TA 8 supports the offering created in 1.18.
EXEC AssignTAToOffering
    @CourseCode = 'CSEN330',
    @SemesterID = 5,
    @SectionID = 'S1',
    @TAID = 8;

-- 1.20 AddTool: adds an AI tool (becomes Tool 7).
EXEC AddTool
    @Name = 'Quiz Generator AI',
    @Description = 'Creates practice quizzes from lecture notes',
    @Category = 'Generative AI',
    @Status = 'Under Review',
    @ToolType = 'AI Tool',
    @Provider = 'QuizWorks',
    @ModelVersion = '1.2',
    @LicenseType = 'Subscription',
    @HostingMode = 'Cloud',
    @CostModel = 'Per user',
    @OriginatingFramework = NULL,
    @ReferenceSource = NULL,
    @RequiredResources = NULL;

-- 1.21 ViewAuditLog: all audit entries of 2026.
SELECT * FROM ViewAuditLog('2026-01-01', '2026-12-31');

-- 1.22 GetFacultyMemberStats: number of members per faculty and role.
SELECT * FROM GetFacultyMemberStats();


-- =====================================================================
-- 2) Academic Instructor
-- =====================================================================

-- 2.1 ViewMyCourseOfferings: offerings of Instructor 4 in Semester 5.
SELECT * FROM ViewMyCourseOfferings(4, 5);

-- 2.2 AddILO: adds ILO1 to CSEN330.
EXEC AddILO
    @CourseCode = 'CSEN330',
    @ILOCode = 'ILO1',
    @Statement = 'Explain the layers of the network protocol stack',
    @CognitiveLevel = 'Understand';

-- 2.3 UpdateILO: changes the statement and level of that ILO.
EXEC UpdateILO
    @CourseCode = 'CSEN330',
    @ILOCode = 'ILO1',
    @Statement = 'Explain and compare the layers of the network protocol stack',
    @CognitiveLevel = 'Analyze';

-- 2.4 MapILOToPLO: maps CSEN330 ILO1 to PLO1 of Program 1 (becomes Mapping 15, Pending).
EXEC MapILOToPLO
    @CourseCode = 'CSEN330',
    @ILOCode = 'ILO1',
    @ProgramID = 1,
    @PLOCode = 'PLO1',
    @CoverageLevel = 'Introduced',
    @IsAssessmentPoint = 1;

-- 2.5 RecordOutcomeAssessment: 60 attained against a target of 70, so the target is not met (becomes Assessment 14).
EXEC RecordOutcomeAssessment
    @CourseCode = 'CSEN330',
    @ILOCode = 'ILO1',
    @SemesterID = 5,
    @SectionID = 'S1',
    @MappingID = 15,
    @Instrument = 'Midterm Q1',
    @Description = 'Layered protocol questions',
    @TargetThreshold = 70.00,
    @AttainedValue = 60.00,
    @SampleSize = 30,
    @AnalysisNotes = 'Students mixed up the transport and network layers';

-- 2.6 AddCorrectiveAction: Assessment 14 missed its target, so a corrective action is allowed.
EXEC AddCorrectiveAction
    @AssessmentID = 14,
    @CorrectiveAction = 'Add a weekly packet-tracing lab';

-- 2.7 ViewUnmetAssessments: unmet assessments in the offerings of Instructor 4.
SELECT * FROM ViewUnmetAssessments(4);

-- 2.8 SubmitModificationProposal: Instructor 4 proposes a change linked to Assessment 14 (becomes Proposal 6).
EXEC SubmitModificationProposal
    @ProposerID = 4,
    @Title = 'Add a networking lab',
    @Rationale = 'Students need hands-on packet analysis',
    @ModificationType = 'Content Update',
    @CurrentStateSummary = 'No networking lab',
    @ProposedStateSummary = 'One weekly networking lab',
    @CourseCode = 'CSEN330',
    @ProgramID = 1,
    @VersionLabel = 'V2',
    @AcademicYear = '2025/2026',
    @AssessmentID = 14;

-- 2.9 ReviseModificationProposal: Proposal 3 was returned for revision, so it can be revised.
EXEC ReviseModificationProposal
    @ProposalID = 3,
    @Rationale = 'Industry demand for security skills, linked to PLO4 on ethics and professional practice',
    @ProposedStateSummary = 'CSEN320 added to the elective pool with a security ethics module';

-- 2.10 ViewProposalStatus: approval history of Proposal 1.
SELECT * FROM ViewProposalStatus(1);

-- 2.11 ViewCurriculumVersion: courses of Program 1, Version V2.
SELECT * FROM ViewCurriculumVersion(1, 'V2', '2025/2026');

-- 2.12 CompareCurriculumVersions: what changed between V1 and V2 of Program 1.
SELECT * FROM CompareCurriculumVersions(1, 'V1', '2023/2024', 'V2', '2025/2026');

-- 2.13 RegisterInnovationInitiative: Instructor 5 registers an initiative for CSEN201 S2 (becomes Initiative 8, Draft).
EXEC RegisterInnovationInitiative
    @SubmitterID = 5,
    @FacultyID = 1,
    @Title = 'Auto-Graded Programming Labs',
    @Description = 'Lab code is graded automatically with instant feedback',
    @Motivation = 'Slow feedback on lab work',
    @CourseCode = 'CSEN201',
    @SemesterID = 4,
    @SectionID = 'S2',
    @TargetStartSemesterID = 5,
    @ImplementationDeadline = '2027-03-01',
    @AssessmentID = NULL;

-- 2.14 AddAIToolIntegration: Initiative 8 is an AI tool integration.
EXEC AddAIToolIntegration
    @InitiativeID = 8,
    @IntegrationObjective = 'Give instant feedback on lab code',
    @ToolCategory = 'Generative AI',
    @DataPrivacyNotes = 'Only code is stored',
    @AcademicIntegrityNotes = 'Students must declare AI use';

-- 2.15 AddMethodologyChange: Initiative 5 also has a methodology change.
EXEC AddMethodologyChange
    @InitiativeID = 5,
    @PedagogicalApproach = 'Case-based learning',
    @DeliveryChange = 'Weekly case discussions replace one lecture',
    @ReferenceFramework = 'Experiential Learning';

-- 2.16 AddAssessmentRedesign: Initiative 8 also redesigns an assessment.
EXEC AddAssessmentRedesign
    @InitiativeID = 8,
    @AssessmentTypeAffected = 'Lab report',
    @RubricWeightingChanges = 'Lab weight raised from 10% to 15%',
    @FairnessSafeguards = 'Same rubric for all sections';

-- 2.17 AdoptTool: Initiative 8 adopts Tool 1 (LLM Programming Tutor).
EXEC AdoptTool
    @InitiativeID = 8,
    @ToolID = 1;

-- 2.18 AssignInitiativeMember: TA 8 supports Initiative 8.
EXEC AssignInitiativeMember
    @InitiativeID = 8,
    @MemberID = 8,
    @Role = 'Supporting TA';

-- 2.19 AddTrainingRequirement: Initiative 8 requires training on Tool 1.
EXEC AddTrainingRequirement
    @InitiativeID = 8,
    @ToolID = 1,
    @Description = 'Complete the LLM tutor training',
    @TargetAudience = 'Instructors and TAs',
    @RequiredByDate = '2027-01-15',
    @IsMandatory = 1;

-- 2.20 AddMilestone: first milestone of Initiative 8 (SeqNo 1 is assigned automatically).
EXEC AddMilestone
    @InitiativeID = 8,
    @Title = 'Pick the pilot labs',
    @Description = 'Choose two lab groups',
    @DueDate = '2027-01-31';

-- 2.21 CompleteMilestone: Milestone 2 of Initiative 2 is finished.
EXEC CompleteMilestone
    @InitiativeID = 2,
    @SeqNo = 2,
    @CompletionDate = '2026-11-20';

-- 2.22 UploadEvidence: evidence for Milestone 2 of Initiative 2.
EXEC UploadEvidence
    @InitiativeID = 2,
    @MilestoneSeqNo = 2,
    @Title = 'Flipped session survey',
    @ArtifactType = 'Survey',
    @FilePathOrURL = 'https://example.edu/evidence/flipped-survey.xlsx',
    @Description = 'End of term survey results';

-- 2.23 SubmitOutcomeReport: measured impact of Initiative 2 in Semester 5.
EXEC SubmitOutcomeReport
    @InitiativeID = 2,
    @SemesterID = 5,
    @MetricType = 'Attendance Rate',
    @QuantitativeValue = 91.00,
    @BaselineValue = 84.00,
    @QualitativeSummary = 'Higher attendance in flipped sessions';

-- 2.24 RecordStudentFeedback: an anonymous rating for Initiative 2.
EXEC RecordStudentFeedback
    @InitiativeID = 2,
    @SemesterID = 5,
    @Rating = 4,
    @Comment = 'Short videos were easy to follow',
    @CategorySentiment = 'Positive',
    @CollectionMethod = 'Survey';

-- 2.25 RequestInitiativeApproval: the submitter (Member 5) sends Draft Initiative 8 to the dean.
EXEC RequestInitiativeApproval
    @InitiativeID = 8,
    @MemberID = 5;

-- 2.26 ViewInitiativeProgress: milestones of Initiative 1, with overdue flag.
SELECT * FROM ViewInitiativeProgress(1);

-- 2.27 CalculateInitiativeCompletion: percentage of completed milestones of Initiative 1.
SELECT dbo.CalculateInitiativeCompletion(1) AS CompletionPercentage;


-- =====================================================================
-- 3) Teaching Assistant
-- =====================================================================

-- 3.1 ViewSupportedOfferings: offerings that TA 8 supports.
SELECT * FROM ViewSupportedOfferings(8);

-- 3.2 ViewMySupervisor: supervisor of TA 8.
SELECT * FROM ViewMySupervisor(8);

-- 3.3 ViewCourseILOs: ILOs of CSEN101.
SELECT * FROM ViewCourseILOs('CSEN101');

-- 3.4 ViewOfferingAssessments: assessments of CSEN101, Semester 3, Section S1.
SELECT * FROM ViewOfferingAssessments('CSEN101', 3, 'S1');

-- 3.5 UpdateEnrolledCount: new enrolment number for CSEN101, Semester 4, Section S1.
EXEC UpdateEnrolledCount
    @CourseCode = 'CSEN101',
    @SemesterID = 4,
    @SectionID = 'S1',
    @EnrolledCount = 42;

-- 3.6 UpdateMilestoneStatus: Milestone 3 of Initiative 1 starts.
EXEC UpdateMilestoneStatus
    @InitiativeID = 1,
    @SeqNo = 3,
    @Status = 'In Progress';

-- 3.7 ViewInitiativeEvidence: evidence uploaded for Initiative 1.
SELECT * FROM ViewInitiativeEvidence(1);


-- =====================================================================
-- 4) Curriculum Reviewer
-- =====================================================================

-- 4.1 ViewProgramCurriculumMap: ILO to PLO map of Program 1.
SELECT * FROM ViewProgramCurriculumMap(1);

-- 4.2 GetUncoveredPLOs: PLOs of Program 1 with no approved mapping.
SELECT * FROM GetUncoveredPLOs(1);

-- 4.3 GetPLOCoverageSummary: coverage levels and assessment points per PLO of Program 1.
SELECT * FROM GetPLOCoverageSummary(1);

-- 4.4 ReviewOutcomeMapping: approves the pending Mapping 8.
EXEC ReviewOutcomeMapping
    @MappingID = 8,
    @MappingStatus = 'Approved';

-- 4.5 GetPLOAttainment: attainment of PLO1 of Program 1 in Semester 3.
SELECT dbo.GetPLOAttainment(1, 'PLO1', 3) AS PLOAttainment;

-- 4.6 ViewAssessmentsBelowTarget: assessments of Program 1 below target in Semester 3.
SELECT * FROM ViewAssessmentsBelowTarget(1, 3);

-- 4.7 TrackCorrectiveActionEffect: attainment of CSEN101 ILO2 over the semesters.
SELECT * FROM TrackCorrectiveActionEffect('CSEN101', 'ILO2');

-- 4.8 ViewPendingProposals: proposals of Program 1 with no final decision.
SELECT * FROM ViewPendingProposals(1);

-- 4.9 ReviewModificationProposal: Reviewer 13 approves Proposal 6.
EXEC ReviewModificationProposal
    @ProposalID = 6,
    @ReviewerID = 13,
    @Decision = 'Approved',
    @Comments = 'Clear link to the unmet assessment';

-- 4.10 ViewCourseProposalHistory: proposals and latest decisions for CSEN201.
SELECT * FROM ViewCourseProposalHistory('CSEN201');

-- 4.11 CreateAccreditationReview: opens a review for Program 4 (becomes Review 5).
EXEC CreateAccreditationReview
    @ProgramID = 4,
    @AccreditingBody = 'ABET',
    @ReviewType = 'Program Accreditation',
    @ReviewCycle = '6 years',
    @NextReviewDue = '2027-09-01';

-- 4.12 AttachMappingsToReview: attaches the approved mappings of Program 4 to Review 5.
EXEC AttachMappingsToReview
    @ReviewID = 5;

-- 4.13 AttachAssessmentToReview: attaches Assessment 13 to Review 5.
EXEC AttachAssessmentToReview
    @ReviewID = 5,
    @AssessmentID = 13;

-- 4.14 AttachEvidenceToReview: attaches Evidence 2 to Review 5.
EXEC AttachEvidenceToReview
    @ReviewID = 5,
    @EvidenceID = 2;

-- 4.15 UpdateAccreditationStatus: Review 5 is submitted.
EXEC UpdateAccreditationStatus
    @ReviewID = 5,
    @Status = 'Submitted',
    @Decision = NULL,
    @SubmissionDate = '2026-11-20';

-- 4.16 GenerateAccreditationPack: everything attached to Review 5.
SELECT * FROM GenerateAccreditationPack(5);

-- 4.17 GetUpcomingAccreditations: reviews due within 365 days.
SELECT * FROM GetUpcomingAccreditations(365);


-- =====================================================================
-- 5) Dean
-- =====================================================================

-- 5.1 ViewFacultyPendingApprovals: items waiting for Dean 1.
SELECT * FROM ViewFacultyPendingApprovals(1);

-- 5.2 DecideOnProposal: Dean 1 approves Proposal 1 (the reviewer already approved it).
EXEC DecideOnProposal
    @ProposalID = 1,
    @DeanID = 1,
    @Decision = 'Approved',
    @Comments = 'Approved for the next version';

-- 5.3 DecideOnInitiative: Dean 1 approves Initiative 3 (it is Pending Approval).
EXEC DecideOnInitiative
    @InitiativeID = 3,
    @DeanID = 1,
    @Decision = 'Approved',
    @Comments = 'Good plan';

-- 5.4 EscalateToUniversity: Dean 1 escalates Initiative 8 (requested in 2.25).
EXEC EscalateToUniversity
    @InitiativeID = 8,
    @DeanID = 1,
    @Comments = 'Needs a university budget decision';

-- 5.5 AddPLO: adds PLO5 to Program 1.
EXEC AddPLO
    @ProgramID = 1,
    @PLOCode = 'PLO5',
    @Statement = 'Use modern tools to analyze and manage data',
    @Category = 'Skills';

-- 5.6 CreateCurriculumVersion: new draft V4 for Program 1, copying the courses of V2.
EXEC CreateCurriculumVersion
    @ProgramID = 1,
    @VersionLabel = 'V4',
    @AcademicYear = '2027/2028',
    @EffectivePeriod = '2027-2030',
    @CopyFromVersionLabel = 'V2',
    @CopyFromAcademicYear = '2025/2026';

-- 5.7 PlaceCourseInVersion: places CSEN330 in semester 5 of the draft V4.
EXEC PlaceCourseInVersion
    @ProgramID = 1,
    @VersionLabel = 'V4',
    @AcademicYear = '2027/2028',
    @CourseCode = 'CSEN330',
    @StudySemesterNo = 5,
    @IsMandatory = 1;

-- 5.8 ApproveCurriculumVersion: V4 becomes Active and the old Active version is archived.
EXEC ApproveCurriculumVersion
    @ProgramID = 1,
    @VersionLabel = 'V4',
    @AcademicYear = '2027/2028';

-- 5.9 ViewFacultyInitiatives: Approved initiatives of Faculty 1.
SELECT * FROM ViewFacultyInitiatives(1, 'Approved');

-- 5.10 ViewOverdueMilestones: overdue milestones in Faculty 1.
SELECT * FROM ViewOverdueMilestones(1);

-- 5.11 SendOverdueAlerts: notifies the members of initiatives with overdue milestones in Faculty 1.
EXEC SendOverdueAlerts
    @FacultyID = 1;

-- 5.12 ScheduleTrainingSession: online session for Tool 7 (becomes Session 7).
EXEC ScheduleTrainingSession
    @ToolID = 7,
    @Title = 'Quiz Generator Workshop',
    @Topic = 'AI tools',
    @Description = 'Creating quizzes with AI',
    @SessionDate = '2027-02-20',
    @DurationMinutes = 90,
    @Trainer = 'Dr. Rania Mostafa',
    @Capacity = 20,
    @Mode = 'Online',
    @Platform = 'Zoom',
    @MeetingLink = 'https://example.edu/meet/quiz-gen',
    @RecordingAvailable = 1,
    @Venue = NULL,
    @Campus = NULL,
    @RequiredEquipment = NULL;

-- 5.13 ViewTrainingAttendance: who is registered for Session 1.
SELECT * FROM ViewTrainingAttendance(1);

-- 5.14 GetFacultyTrainingCompliance: training requirements and attendance in Faculty 1.
SELECT * FROM GetFacultyTrainingCompliance(1);

-- 5.15 GetInitiativeImpact: reports of Initiative 1 compared with the baseline.
SELECT * FROM GetInitiativeImpact(1);

-- 5.16 GetAverageFeedbackRating: average rating of Initiative 1 in Semester 5.
SELECT dbo.GetAverageFeedbackRating(1, 5) AS AverageRating;

-- 5.17 GetFacultyDashboard: dashboard of Faculty 1 for Semester 5.
SELECT * FROM GetFacultyDashboard(1, 5);


-- =====================================================================
-- 6) University Management
-- =====================================================================

-- 6.1 ViewEscalatedItems: initiatives waiting for a university decision (4 and 8).
SELECT * FROM ViewEscalatedItems();

-- 6.2 MakeUniversityDecision: Manager 11 approves the escalated Initiative 4.
EXEC MakeUniversityDecision
    @ItemType = 'Initiative',
    @ItemID = 4,
    @ManagerID = 11,
    @Decision = 'Approved',
    @Comments = 'Budget approved for the simulation software';

-- 6.3 GetUniversityDashboard: every faculty for Semester 5.
SELECT * FROM GetUniversityDashboard(5);

-- 6.4 GetInitiativeStatsByType: initiatives per type and status.
SELECT * FROM GetInitiativeStatsByType();

-- 6.5 GetToolAdoptionReport: initiatives, faculties and trained members per tool.
SELECT * FROM GetToolAdoptionReport();

-- 6.6 GetApprovalTurnaround: average days from submission to final decision in Faculty 1.
SELECT dbo.GetApprovalTurnaround(1) AS AverageDays;

-- 6.7 GetAccreditationOverview: latest review of every program.
SELECT * FROM GetAccreditationOverview();

-- 6.8 GetAttainmentTrend: percentage of assessments that met their target per semester, Program 1.
SELECT * FROM GetAttainmentTrend(1);

-- 6.9 RankInitiativesByImpact: initiatives ranked by improvement of the metric 'Pass Rate'.
SELECT * FROM RankInitiativesByImpact('Pass Rate');

-- 6.10 UpdateToolStatus: Tool 2 becomes Approved.
EXEC UpdateToolStatus
    @ToolID = 2,
    @Status = 'Approved';

-- 6.11 BroadcastNotification: announcement for all instructors.
EXEC BroadcastNotification
    @MessageContent = 'Curriculum review week starts next Sunday',
    @Urgency = 'Normal',
    @Category = 'Announcement',
    @TargetRole = 'Instructor';

-- 6.12 ViewItemAuditTrail: audit trail of Initiative 4.
SELECT * FROM ViewItemAuditTrail('Initiative', 4);


-- =====================================================================
-- 7) Academic Member
-- =====================================================================

-- 7.1 ViewMyProfile: profile, roles and scopes of Member 4.
SELECT * FROM ViewMyProfile(4);

-- 7.2 ViewMyNotifications: unread notifications of Member 4.
SELECT * FROM ViewMyNotifications(4, 1);

-- 7.3 GetUnreadNotificationCount: number of unread notifications of Member 4.
SELECT dbo.GetUnreadNotificationCount(4) AS UnreadCount;

-- 7.4 MarkNotificationRead: Member 4 reads Notification 1.
EXEC MarkNotificationRead
    @NotificationID = 1,
    @MemberID = 4;

-- 7.5 ViewMyInitiatives: initiatives submitted by or assigned to Member 4.
SELECT * FROM ViewMyInitiatives(4);

-- 7.6 ViewAvailableTrainingSessions: upcoming sessions for Tool 7.
SELECT * FROM ViewAvailableTrainingSessions(7);

-- 7.7 GetRemainingSeats: free seats in Session 3.
SELECT dbo.GetRemainingSeats(3) AS RemainingSeats;

-- 7.8 RegisterForTraining: Member 4 registers for Session 7 (created in 5.12).
EXEC RegisterForTraining
    @SessionID = 7,
    @MemberID = 4;

-- 7.9 CancelTrainingRegistration: Member 4 cancels it before the session takes place.
EXEC CancelTrainingRegistration
    @SessionID = 7,
    @MemberID = 4;

-- 7.10 ViewMyTrainingHistory: sessions Member 4 attended (already held).
SELECT * FROM ViewMyTrainingHistory(4);

-- 7.11 ViewMyPendingTraining: mandatory training Member 4 still needs.
SELECT * FROM ViewMyPendingTraining(4);

-- 7.12 NotifyApprovalDecision: tells Member 4 about the decision on their Proposal 1.
EXEC NotifyApprovalDecision
    @MemberID = 4,
    @ItemType = 'Proposal',
    @ItemID = 1,
    @Decision = 'Approved';

-- 7.13 NotifyOverdueMilestone: tells Member 4 that Milestone 2 of Initiative 1 is overdue.
EXEC NotifyOverdueMilestone
    @MemberID = 4,
    @InitiativeID = 1,
    @SeqNo = 2;

-- 7.14 NotifyAccreditationDeadline: reviews of Program 4 due within 365 days (Review 5, created in 4.11).
EXEC NotifyAccreditationDeadline
    @ProgramID = 4,
    @DaysAhead = 365;