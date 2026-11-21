SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* =====================================================================
   1. PEOPLE & ORGANISATION
   ===================================================================== */


INSERT INTO Faculty (FacultyName, FacultyDescription, EstablishmentDate, DeanID) VALUES
('Faculty of Informatics and Computer Science', 'Computer science, software and data programs', '2008-09-01', NULL),
('Faculty of Engineering', 'Mechatronics and industrial engineering programs', '2009-09-01', NULL),
('Faculty of Business Informatics', 'Business, management and information systems programs', '2011-09-01', NULL);
GO

INSERT INTO Academic_Member (FullName, UniversityIDNo, Email, Phone, AcademicRank, EmploymentStatus, AccountStatus, FacultyID) VALUES
('Mona Farouk',    'GIU-1001', 'mona.farouk@giu-demo.edu',    '01000001001', 'Professor',           'Full-time', 'Active',    1),  -- 1  dean, faculty 1
('Karim Nabil',    'GIU-1002', 'karim.nabil@giu-demo.edu',    '01000001002', 'Professor',           'Full-time', 'Active',    2),  -- 2  dean, faculty 2
('Hala Samir',     'GIU-1003', 'hala.samir@giu-demo.edu',     '01000001003', 'Professor',           'Full-time', 'Active',    3),  -- 3  dean, faculty 3
('Youssef Adel',   'GIU-1004', 'youssef.adel@giu-demo.edu',   '01000001004', 'Associate Professor', 'Full-time', 'Active',    1),  -- 4  instructor
('Rania Mostafa',  'GIU-1005', 'rania.mostafa@giu-demo.edu',  '01000001005', 'Assistant Professor', 'Full-time', 'Active',    1),  -- 5  instructor
('Tarek Salem',    'GIU-1006', 'tarek.salem@giu-demo.edu',    '01000001006', 'Associate Professor', 'Full-time', 'Active',    2),  -- 6  instructor
('Dina Wahba',     'GIU-1007', 'dina.wahba@giu-demo.edu',     '01000001007', 'Assistant Professor', 'Full-time', 'Active',    3),  -- 7  instructor
('Omar Fathy',     'GIU-1008', 'omar.fathy@giu-demo.edu',     '01000001008', 'Teaching Assistant',  'Full-time', 'Active',    1),  -- 8  TA of 4
('Salma Ibrahim',  'GIU-1009', 'salma.ibrahim@giu-demo.edu',  '01000001009', 'Teaching Assistant',  'Part-time', 'Active',    1),  -- 9  TA of 5
('Nour Hesham',    'GIU-1010', 'nour.hesham@giu-demo.edu',    '01000001010', 'Teaching Assistant',  'Full-time', 'Active',    2),  -- 10 TA of 6
('Ahmed Zaki',     'GIU-1011', 'ahmed.zaki@giu-demo.edu',     '01000001011', 'Professor',           'Full-time', 'Active',    1),  -- 11 university management
('Laila Kamal',    'GIU-1012', 'laila.kamal@giu-demo.edu',    '01000001012', 'Professor',           'Full-time', 'Active',    2),  -- 12 university management
('Hassan Ragab',   'GIU-1013', 'hassan.ragab@giu-demo.edu',   '01000001013', 'Associate Professor', 'Full-time', 'Active',    1),  -- 13 curriculum reviewer
('Sara Eid',       'GIU-1014', 'sara.eid@giu-demo.edu',       '01000001014', 'Associate Professor', 'Full-time', 'Active',    1),  -- 14 instructor + reviewer
('Mahmoud Gaber',  'GIU-1015', 'mahmoud.gaber@giu-demo.edu',  '01000001015', 'Lecturer',            'Part-time', 'Suspended', 3),  -- 15 no role yet
('Heba Lotfy',     'GIU-1016', 'heba.lotfy@giu-demo.edu',     '01000001016', 'Lecturer',            'Full-time', 'Active',    2);  -- 16 no role yet
GO

INSERT INTO Member_Access_Scope (MemberID, AccessScope) VALUES
(1,  'Approve Initiatives'),
(1,  'Approve Proposals'),
(2,  'Approve Initiatives'),
(2,  'Approve Proposals'),
(3,  'Approve Initiatives'),
(3,  'Approve Proposals'),
(4,  'Submit Proposals'),
(5,  'Submit Proposals'),
(6,  'Submit Proposals'),
(7,  'Submit Proposals'),
(14, 'Submit Proposals'),
(13, 'Review Curriculum'),
(14, 'Review Curriculum'),
(11, 'University Decisions'),
(12, 'University Decisions');
GO

INSERT INTO Academic_Instructor (MemberID, ResearchArea, OfficeLocation, TeachingLoad) VALUES
(4,  'Software Engineering',      'C5.101', 12),
(5,  'Algorithms and Data Structures', 'C5.104', 12),
(6,  'Control Systems',           'E2.210', 10),
(7,  'Enterprise Information Systems', 'B1.305', 9),
(14, 'Machine Learning',          'C5.112', 9);
GO

INSERT INTO Teaching_Assistant (MemberID, AssistantLevel, SupervisorID) VALUES
(8,  'Senior', 4),
(9,  'Junior', 5),
(10, 'Junior', 6);
GO

INSERT INTO Dean (MemberID, ApprovalAuthorityScope) VALUES
(1, 'Faculty of Informatics and Computer Science'),
(2, 'Faculty of Engineering'),
(3, 'Faculty of Business Informatics');
GO

-- Close the Faculty <-> Dean loop
UPDATE Faculty SET DeanID = 1 WHERE FacultyID = 1;
UPDATE Faculty SET DeanID = 2 WHERE FacultyID = 2;
UPDATE Faculty SET DeanID = 3 WHERE FacultyID = 3;
GO

INSERT INTO University_Management (MemberID, ManagementTitle, DecisionAuthorityLevel, GovernanceScope) VALUES
(11, 'Vice President for Academic Affairs', 'Executive', 'Academic programs and curricula'),
(12, 'Director of Quality Assurance',        'Senior',    'Accreditation and quality');
GO

INSERT INTO Curriculum_Reviewer (MemberID, ReviewDomain, ReviewAuthorityLevel) VALUES
(13, 'Computer Science Curricula', 'Senior'),
(14, 'Artificial Intelligence',    'Standard');
GO

INSERT INTO Reviewer_Committee (MemberID, CommitteeMembership) VALUES
(13, 'Curriculum Committee'),
(13, 'Quality Assurance Committee'),
(14, 'Curriculum Committee');
GO

INSERT INTO Semester (SemesterName, AcademicYear, StartDate, EndDate) VALUES
('Winter', '2024/2025', '2024-09-15', '2025-01-31'),  -- 1
('Spring', '2024/2025', '2025-02-15', '2025-06-30'),  -- 2
('Winter', '2025/2026', '2025-09-15', '2026-01-31'),  -- 3
('Spring', '2025/2026', '2026-02-15', '2026-06-30'),  -- 4
('Winter', '2026/2027', '2026-09-15', '2027-01-31');  -- 5 (current)
GO

INSERT INTO Dean_Term (DeanID, SemesterID) VALUES
(1, 3), (1, 4), (1, 5),
(2, 3), (2, 4), (2, 5),
(3, 4), (3, 5);
GO

/* =====================================================================
   2. CURRICULUM
   ===================================================================== */

INSERT INTO Program (ProgramName, DegreeLevel, TotalCreditHours, StandardDuration, ProgramDescription, FacultyID) VALUES
('BSc Computer Science',          'Bachelor', 180, '8 semesters', 'Core computer science with elective tracks',          1),  -- 1
('BSc Mechatronics Engineering',  'Bachelor', 180, '8 semesters', 'Mechanical, electrical and software engineering',      2),  -- 2
('BSc Business Informatics',      'Bachelor', 180, '8 semesters', 'Information systems applied to business processes',    3),  -- 3
('MSc Artificial Intelligence',   'Master',    90, '4 semesters', 'Advanced machine learning and intelligent systems',    1);  -- 4
GO

INSERT INTO PLO (ProgramID, PLOCode, PLOStatement, Category) VALUES
(1, 'PLO1', 'Apply computing knowledge to solve practical problems',        'Knowledge'),
(1, 'PLO2', 'Design and evaluate software systems',                         'Skills'),
(1, 'PLO3', 'Communicate and work effectively in teams',                    'Competence'),
(1, 'PLO4', 'Apply ethical and professional principles in computing',       'Values'),
(2, 'PLO1', 'Apply mathematics and mechanics to engineering problems',      'Knowledge'),
(2, 'PLO2', 'Model and analyze dynamic systems',                            'Skills'),
(3, 'PLO1', 'Explain how information systems support business processes',   'Knowledge'),
(3, 'PLO2', 'Analyze business data to support decisions',                   'Skills'),
(4, 'PLO1', 'Explain and apply core machine learning methods',              'Knowledge');
GO

INSERT INTO Curriculum_Version (ProgramID, VersionLabel, AcademicYear, EffectivePeriod, VersionStatus, ApprovalDate) VALUES
(1, 'V1', '2023/2024', '2023-2026', 'Archived', '2023-06-30'),
(1, 'V2', '2025/2026', '2025-2028', 'Active',   '2025-06-15'),
(1, 'V3', '2026/2027', '2026-2029', 'Draft',    NULL),
(2, 'V1', '2024/2025', '2024-2027', 'Active',   '2024-06-20'),
(3, 'V1', '2024/2025', '2024-2027', 'Active',   '2024-07-01'),
(4, 'V1', '2025/2026', '2025-2027', 'Draft',    NULL);
GO

INSERT INTO Course (CourseCode, Title, CourseDescription, CreditHours, CourseLevel) VALUES
('CSEN101', 'Introduction to Computer Programming', 'Programming fundamentals: variables, control flow, functions',  6, 'Level 1'),
('CSEN201', 'Data Structures and Algorithms',       'Lists, trees, graphs, sorting and complexity analysis',         6, 'Level 2'),
('CSEN290', 'Legacy Systems Programming',           'Maintenance of legacy code bases',                              6, 'Level 2'),
('CSEN301', 'Database Systems',                     'Relational model, SQL and database design',                     6, 'Level 3'),
('CSEN310', 'Machine Learning',                     'Supervised and unsupervised learning methods',                  6, 'Level 3'),
('CSEN320', 'Cybersecurity Fundamentals',           'Threats, cryptography basics and secure design',                6, 'Level 3'),
('CSEN401', 'Software Engineering',                 'Software processes, design patterns and teamwork',              6, 'Level 4'),
('MATH101', 'Calculus I',                           'Limits, derivatives and integrals',                             6, 'Level 1'),
('MECH101', 'Engineering Mechanics',                'Statics and dynamics of rigid bodies',                          6, 'Level 1'),
('MECH201', 'Control Systems',                      'Modeling and control of dynamic systems',                       6, 'Level 2'),
('BINF101', 'Introduction to Business Informatics', 'Role of information systems in organizations',                  6, 'Level 1'),
('BINF201', 'Enterprise Systems',                   'ERP and enterprise application modules',                        6, 'Level 2'),
('BINF301', 'Business Analytics',                   'Data analysis for managerial decision making',                  6, 'Level 3');
GO

INSERT INTO Core_Course (CourseCode, DefaultStudySemester, RequiredForProgram) VALUES
('CSEN101', 1, 'BSc Computer Science'),
('CSEN201', 3, 'BSc Computer Science'),
('CSEN290', 3, 'BSc Computer Science'),
('CSEN301', 4, 'BSc Computer Science'),
('CSEN401', 6, 'BSc Computer Science'),
('MATH101', 1, 'BSc Computer Science'),
('MECH101', 1, 'BSc Mechatronics Engineering'),
('MECH201', 3, 'BSc Mechatronics Engineering'),
('BINF101', 1, 'BSc Business Informatics'),
('BINF201', 3, 'BSc Business Informatics');
GO

INSERT INTO Elective_Course (CourseCode, ElectivePool, MinSelectionRule) VALUES
('CSEN310', 'CS Electives',       'Choose at least 1 course from the pool'),
('CSEN320', 'CS Electives',       'Choose at least 1 course from the pool'),
('BINF301', 'Business Electives', 'Choose at least 1 course from the pool');
GO

INSERT INTO Version_Course (ProgramID, VersionLabel, AcademicYear, CourseCode, StudySemesterNo, IsMandatory) VALUES
-- Program 1, V1 (archived)
(1, 'V1', '2023/2024', 'CSEN101', 1, 1),
(1, 'V1', '2023/2024', 'MATH101', 1, 1),
(1, 'V1', '2023/2024', 'CSEN201', 2, 1),
(1, 'V1', '2023/2024', 'CSEN290', 3, 1),
(1, 'V1', '2023/2024', 'CSEN301', 4, 1),
(1, 'V1', '2023/2024', 'CSEN310', 5, 0),
-- Program 1, V2 (active): CSEN201 moved, CSEN290 removed, CSEN401 and CSEN320 added
(1, 'V2', '2025/2026', 'CSEN101', 1, 1),
(1, 'V2', '2025/2026', 'MATH101', 1, 1),
(1, 'V2', '2025/2026', 'CSEN201', 3, 1),
(1, 'V2', '2025/2026', 'CSEN301', 4, 1),
(1, 'V2', '2025/2026', 'CSEN310', 5, 0),
(1, 'V2', '2025/2026', 'CSEN401', 6, 1),
(1, 'V2', '2025/2026', 'CSEN320', 6, 0),
-- Program 1, V3 (draft, still being built)
(1, 'V3', '2026/2027', 'CSEN101', 1, 1),
(1, 'V3', '2026/2027', 'MATH101', 1, 1),
(1, 'V3', '2026/2027', 'CSEN201', 3, 1),
-- Programs 2, 3 and 4
(2, 'V1', '2024/2025', 'MATH101', 1, 1),
(2, 'V1', '2024/2025', 'MECH101', 1, 1),
(2, 'V1', '2024/2025', 'MECH201', 3, 1),
(3, 'V1', '2024/2025', 'BINF101', 1, 1),
(3, 'V1', '2024/2025', 'MATH101', 2, 1),
(3, 'V1', '2024/2025', 'BINF201', 3, 1),
(3, 'V1', '2024/2025', 'BINF301', 5, 0),
(4, 'V1', '2025/2026', 'CSEN310', 1, 1);
GO

INSERT INTO Course_Requisite (CourseCode, RequisiteCode, RequisiteType) VALUES
('CSEN201', 'CSEN101', 'Prerequisite'),
('CSEN301', 'CSEN201', 'Prerequisite'),
('CSEN401', 'CSEN301', 'Prerequisite'),
('CSEN310', 'MATH101', 'Corequisite'),
('MECH201', 'MECH101', 'Prerequisite'),
('BINF201', 'BINF101', 'Prerequisite');
GO

INSERT INTO ILO (CourseCode, ILOCode, ILOStatement, CognitiveLevel) VALUES
('CSEN101', 'ILO1', 'Write programs using variables, loops and functions',     'Apply'),
('CSEN101', 'ILO2', 'Trace and debug simple programs',                         'Analyze'),
('CSEN201', 'ILO1', 'Implement fundamental data structures',                   'Apply'),
('CSEN201', 'ILO2', 'Analyze the time complexity of algorithms',               'Analyze'),
('CSEN301', 'ILO1', 'Design a relational schema from requirements',            'Create'),
('CSEN301', 'ILO2', 'Write SQL queries over a relational database',            'Apply'),
('CSEN401', 'ILO1', 'Apply software design patterns',                          'Apply'),
('CSEN401', 'ILO2', 'Work in a team following an agile process',               'Apply'),
('CSEN310', 'ILO1', 'Explain core machine learning concepts',                  'Understand'),
('MATH101', 'ILO1', 'Differentiate and integrate common functions',            'Apply'),
('MECH201', 'ILO1', 'Model dynamic systems with differential equations',       'Apply'),
('BINF201', 'ILO1', 'Explain the main modules of an enterprise system',        'Understand');
GO

INSERT INTO Course_Offering (CourseCode, SemesterID, SectionID, DeliveryMode, EnrolledCount, OfferingStatus, InstructorID) VALUES
('CSEN101', 3, 'S1', 'In-person', 45, 'Closed', 4),
('CSEN101', 4, 'S1', 'In-person', 40, 'Closed', 4),
('CSEN201', 3, 'S1', 'In-person', 38, 'Closed', 5),
('CSEN201', 4, 'S2', 'Hybrid',    35, 'Closed', 5),
('CSEN301', 4, 'S1', 'In-person', 42, 'Closed', 14),
('CSEN301', 5, 'S1', 'In-person', 44, 'Open',   4),
('CSEN401', 5, 'S1', 'Hybrid',    30, 'Open',   5),
('CSEN310', 4, 'S1', 'Online',    28, 'Closed', 14),
('CSEN310', 5, 'S1', 'Online',    31, 'Open',   14),
('MATH101', 3, 'S1', 'In-person', 60, 'Closed', 6),
('MECH201', 4, 'S1', 'In-person', 25, 'Closed', 6),
('MECH201', 5, 'S1', 'In-person', 27, 'Open',   6),
('BINF201', 4, 'S1', 'Hybrid',    33, 'Closed', 7),
('BINF201', 5, 'S1', 'Hybrid',    36, 'Open',   7);
GO

INSERT INTO Offering_TA (CourseCode, SemesterID, SectionID, TAID) VALUES
('CSEN101', 3, 'S1', 8),
('CSEN201', 3, 'S1', 9),
('CSEN201', 4, 'S2', 9),
('CSEN301', 5, 'S1', 8),
('CSEN401', 5, 'S1', 9),
('CSEN310', 5, 'S1', 8),
('MECH201', 5, 'S1', 10);
GO

/* =====================================================================
   3. OUTCOMES & PROPOSALS
   ===================================================================== */

INSERT INTO Outcome_Mapping (CoverageLevel, IsAssessmentPoint, MappingStatus, CourseCode, ILOCode, ProgramID, PLOCode) VALUES
('Introduced', 0, 'Approved', 'CSEN101', 'ILO1', 1, 'PLO1'),  -- 1
('Introduced', 1, 'Approved', 'CSEN101', 'ILO2', 1, 'PLO1'),  -- 2
('Reinforced', 0, 'Approved', 'CSEN201', 'ILO1', 1, 'PLO1'),  -- 3
('Reinforced', 1, 'Approved', 'CSEN201', 'ILO2', 1, 'PLO2'),  -- 4
('Mastered',   1, 'Approved', 'CSEN301', 'ILO1', 1, 'PLO2'),  -- 5
('Reinforced', 0, 'Approved', 'CSEN301', 'ILO2', 1, 'PLO1'),  -- 6
('Mastered',   1, 'Approved', 'CSEN401', 'ILO1', 1, 'PLO2'),  -- 7
('Reinforced', 1, 'Pending',  'CSEN401', 'ILO2', 1, 'PLO3'),  -- 8
('Introduced', 0, 'Rejected', 'CSEN310', 'ILO1', 1, 'PLO3'),  -- 9
('Introduced', 1, 'Approved', 'MECH201', 'ILO1', 2, 'PLO2'),  -- 10
('Reinforced', 1, 'Approved', 'MATH101', 'ILO1', 2, 'PLO1'),  -- 11
('Introduced', 1, 'Approved', 'BINF201', 'ILO1', 3, 'PLO1'),  -- 12
('Mastered',   1, 'Pending',  'BINF201', 'ILO1', 3, 'PLO2'),  -- 13
('Introduced', 0, 'Approved', 'CSEN310', 'ILO1', 4, 'PLO1');  -- 14
GO

INSERT INTO Outcome_Assessment (Instrument, AssessmentDescription, TargetThreshold, AttainedValue, SampleSize, AnalysisNotes, CorrectiveAction, CourseCode, ILOCode, SemesterID, SectionID, MappingID) VALUES
('Final Exam Q3',       'Programming question on loops and functions',  70.00, 78.50, 45, 'Target met comfortably',                   NULL,                                  'CSEN101', 'ILO1', 3, 'S1', 1),   -- 1
('Final Exam Q5',       'Debugging question',                           70.00, 62.00, 45, 'Many students missed off-by-one errors',    'Add two guided debugging labs',        'CSEN101', 'ILO2', 3, 'S1', 2),   -- 2
('Final Exam Q5',       'Debugging question',                           70.00, 71.00, 40, 'Improved after the extra labs',             NULL,                                  'CSEN101', 'ILO2', 4, 'S1', 2),   -- 3
('Midterm Q2',          'Big-O analysis of given algorithms',           65.00, 58.00, 38, 'Complexity of recursive functions was weak', 'Weekly complexity quizzes',            'CSEN201', 'ILO2', 3, 'S1', 4),   -- 4
('Midterm Q2',          'Big-O analysis of given algorithms',           65.00, 69.00, 35, 'Quizzes helped',                            NULL,                                  'CSEN201', 'ILO2', 4, 'S2', 4),   -- 5
('Lab Practical 1',     'Implement a linked list and a stack',          70.00, 74.00, 38, NULL,                                        NULL,                                  'CSEN201', 'ILO1', 3, 'S1', 3),   -- 6
('Project Phase 1',     'Schema design for a given scenario',           75.00, 68.00, 42, 'Normalisation mistakes were common',         NULL,                                  'CSEN301', 'ILO1', 4, 'S1', 5),   -- 7
('Project Phase 1',     'Schema design for a given scenario',           75.00, 79.00, 44, 'Better than last year',                     NULL,                                  'CSEN301', 'ILO1', 5, 'S1', 5),   -- 8
('Lab Exam',            'Model a mass-spring-damper system',            60.00, 66.00, 25, NULL,                                        NULL,                                  'MECH201', 'ILO1', 4, 'S1', 10),  -- 9
('Case Study Report',   'Map a business process to ERP modules',        70.00, 55.00, 33, 'Students confused module responsibilities',  'Run a case study workshop',            'BINF201', 'ILO1', 4, 'S1', 12),  -- 10
('Case Study Report',   'Map a business process to ERP modules',        70.00, 73.00, 36, NULL,                                        NULL,                                  'BINF201', 'ILO1', 5, 'S1', 12),  -- 11
('Final Exam Q1',       'Differentiation and integration problems',     65.00, 64.00, 60, 'Just below target',                         NULL,                                  'MATH101', 'ILO1', 3, 'S1', 11),  -- 12
('Term Paper',          'Explain a learning algorithm in own words',    70.00, 82.00, 28, NULL,                                        NULL,                                  'CSEN310', 'ILO1', 4, 'S1', 14);  -- 13
GO

INSERT INTO Modification_Proposal (Title, Rationale, ModificationType, CurrentStateSummary, ProposedStateSummary, SubmissionDate, ProposerID, CourseCode, ProgramID, VersionLabel, AcademicYear, AssessmentID) VALUES
('Add debugging labs to CSEN101',
 'Debugging outcome missed its target in Winter 2025/2026',
 'Content Update', 'No dedicated debugging practice', 'Two guided debugging labs per term',
 '2026-10-05', 4, 'CSEN101', 1, 'V2', '2025/2026', 2),                                          -- 1  reviewer approved, still pending at dean level
('Move Data Structures to semester 3',
 'Students need more programming practice before data structures',
 'Semester Change', 'CSEN201 in study semester 2', 'CSEN201 in study semester 3',
 '2026-05-12', 5, 'CSEN201', 1, 'V2', '2025/2026', 4),                                          -- 2  fully approved
('Add Cybersecurity Fundamentals elective',
 'Industry demand for security skills',
 'Course Addition', 'No security course', 'CSEN320 added to the elective pool',
 '2026-10-20', 14, 'CSEN320', 1, 'V3', '2026/2027', NULL),                                      -- 3  returned for revision
('Revise Business Analytics prerequisites',
 'Students lack basic statistics',
 'Prerequisite Change', 'No prerequisite', 'Add a statistics prerequisite',
 '2026-11-02', 7, 'BINF301', 3, 'V1', '2024/2025', NULL),                                       -- 4  no decision yet
('Redesign the Control Systems lab',
 'Lab equipment is outdated',
 'Content Update', 'Lab based on analog kits', 'Lab based on simulation software',
 '2026-09-20', 6, 'MECH201', 2, 'V1', '2024/2025', 9);                                          -- 5  rejected by the dean
GO

/* =====================================================================
   4. INNOVATION
   ===================================================================== */

INSERT INTO Innovation_Initiative (Title, InitiativeDescription, Motivation, RegistrationDate, ImplementationDeadline, InitiativeStatus, CourseCode, SemesterID, SectionID, FacultyID, SubmitterID, TargetStartSemesterID, AssessmentID) VALUES
('AI Tutor for Programming Labs',        'Students get hints from an AI tutor during lab sessions',          'Debugging outcome below target',                   '2026-09-10', '2027-01-15', 'In Progress',      'CSEN101', 4, 'S1', 1, 4,  5, 2),     -- 1
('Flipped Classroom for Algorithms',     'Lecture videos before class, problem solving in class',            'Complexity outcome below target',                  '2026-09-12', '2027-01-20', 'Approved',         'CSEN201', 4, 'S2', 1, 5,  5, 4),     -- 2
('Oral Exams Instead of Written Quizzes','Short oral exams to check schema design understanding',            'Schema design outcome below target',               '2026-10-15', '2027-02-01', 'Pending Approval', 'CSEN301', 5, 'S1', 1, 4,  5, 7),     -- 3
('Simulation Software for Control Labs', 'Replace analog kits with simulation software',                     'Outdated lab equipment',                           '2026-09-25', '2027-01-30', 'Escalated',        'MECH201', 5, 'S1', 2, 6,  5, NULL),  -- 4
('Case-Based Learning in Enterprise Systems', 'Weekly business cases solved in groups',                      'Module responsibilities outcome below target',     '2026-11-01', '2027-02-10', 'Draft',            'BINF201', 5, 'S1', 3, 7,  5, 10),    -- 5
('Notebook Assistant for Machine Learning', 'AI assistant inside the course notebooks',                      'Help students debug model code',                   '2026-10-01', '2027-01-25', 'Returned for Revision', 'CSEN310', 5, 'S1', 1, 14, 5, NULL),  -- 6
('Peer Review Rubrics for Databases',    'Students review each other''s schema designs using a rubric',      'Improve feedback quality',                         '2026-02-20', '2026-06-15', 'Completed',        'CSEN301', 4, 'S1', 1, 14, 4, NULL);  -- 7
GO

INSERT INTO AI_Tool_Integration (InitiativeID, IntegrationObjective, ToolCategory, DataPrivacyNotes, AcademicIntegrityNotes) VALUES
(1, 'Give hints without writing full solutions', 'Generative AI', 'No student identifiers are sent to the provider',  'Tutor refuses to output complete solutions'),
(6, 'Explain errors in notebook cells',          'Generative AI', 'Only code snippets are shared',                 'Assistant use is declared in submissions');
GO

INSERT INTO Methodology_Change (InitiativeID, PedagogicalApproach, DeliveryChange, ReferenceFramework) VALUES
(2, 'Flipped classroom',   'Move lectures online and use class time for exercises', 'Active Learning'),
(4, 'Simulation-based lab','Replace analog kits with simulation software',           'Experiential Learning'),
(7, 'Peer instruction',    'Students review designs in pairs',                      'Peer Instruction');
GO

INSERT INTO Assessment_Redesign (InitiativeID, AssessmentTypeAffected, RubricWeightingChanges, FairnessSafeguards) VALUES
(3, 'Quiz',        'Written quizzes 20% replaced by oral exams 20%',  'Same question bank and two examiners per student'),
(5, 'Case report', 'Case report weight raised from 10% to 20%',        'Shared rubric published at the start of term');
GO

INSERT INTO Initiative_Member (InitiativeID, MemberID, MemberRole) VALUES
(1, 4,  'Lead'),
(1, 5,  'Contributor'),
(1, 8,  'Supporting TA'),
(2, 5,  'Lead'),
(2, 9,  'Supporting TA'),
(3, 4,  'Lead'),
(3, 8,  'Supporting TA'),
(4, 6,  'Lead'),
(4, 10, 'Supporting TA'),
(5, 7,  'Lead'),
(6, 14, 'Lead'),
(6, 8,  'Contributor'),
(7, 14, 'Lead'),
(7, 9,  'Contributor');
GO

-- A decision targets either a proposal or an initiative.
INSERT INTO Approval_Record (Decision, DecisionLevel, DecisionDate, Comments, DeciderID, ProposalID, InitiativeID) VALUES
('Approved',               'Reviewer',   '2026-10-12', 'Fits the program outcomes',                    13, 1,    NULL),  -- 1
('Approved',               'Reviewer',   '2026-05-20', 'Good sequencing change',                       13, 2,    NULL),  -- 2
('Approved',               'Dean',       '2026-05-27', 'Approved for the next version',                1,  2,    NULL),  -- 3
('Approved',               'University', '2026-06-05', 'Approved university-wide',                     11, 2,    NULL),  -- 4
('Returned for Revision',  'Reviewer',   '2026-10-28', 'Explain how this fits PLO4',                   13, 3,    NULL),  -- 5
('Approved',               'Reviewer',   '2026-09-28', 'Lab update is justified',                      14, 5,    NULL),  -- 6
('Rejected',               'Dean',       '2026-10-05', 'No budget this year',                          2,  5,    NULL),  -- 7
('Approved',               'Dean',       '2026-09-20', 'Good link to the assessment result',           1,  NULL, 1),     -- 8
('Approved',               'Dean',       '2026-09-25', 'Approved',                                     1,  NULL, 2),     -- 9
('Escalated',              'Dean',       '2026-10-10', 'Needs a university-level budget decision',     2,  NULL, 4),     -- 10
('Returned for Revision',  'Dean',       '2026-10-22', 'Add a clear evaluation plan',                  1,  NULL, 6),     -- 11
('Approved',               'Dean',       '2026-02-28', 'Approved',                                     1,  NULL, 7);     -- 12
GO

INSERT INTO Tool (ToolName, ToolDescription, Category, ToolStatus) VALUES
('LLM Programming Tutor',  'Chat tutor that gives hints for programming exercises', 'Generative AI', 'Approved'),      -- 1
('Code Completion Assistant','Code suggestions inside the editor',                  'Generative AI', 'Under Review'),  -- 2
('Notebook AI Assistant',  'Explains errors and outputs in notebooks',              'Generative AI', 'Under Review'),  -- 3
('Flipped Classroom',      'Pre-class videos with in-class problem solving',        'Pedagogy',      'Approved'),      -- 4
('Case-Based Learning',    'Learning through real business cases',                  'Pedagogy',      'Approved'),      -- 5
('Peer Instruction',       'Concept questions answered individually then in pairs', 'Pedagogy',      'Approved');      -- 6
GO

INSERT INTO AI_Tool (ToolID, ToolProvider, ModelVersion, LicenseType, HostingMode, CostModel) VALUES
(1, 'EduAI Labs',      'v4',  'Institutional', 'Cloud',       'Per user'),
(2, 'CodeWorks',       '2.1', 'Subscription',  'Cloud',       'Per user'),
(3, 'NotebookAI Inc',  '1.0', 'Open Source',   'On-premise',  'Free');
GO

INSERT INTO Teaching_Methodology (ToolID, OriginatingFramework, ReferenceSource, RequiredResources) VALUES
(4, 'Active Learning',      'Faculty teaching guide 2025', 'Recording equipment and a video platform'),
(5, 'Experiential Learning','Faculty teaching guide 2025', 'A bank of business cases'),
(6, 'Peer Instruction',     'Faculty teaching guide 2025', 'Voting cards or a polling tool');
GO

INSERT INTO Initiative_Tool (InitiativeID, ToolID) VALUES
(1, 1),
(1, 2),
(2, 4),
(4, 6),
(5, 5),
(6, 3),
(7, 6);
GO

INSERT INTO Milestone (InitiativeID, SeqNo, Title, MilestoneDescription, DueDate, CompletionDate, MilestoneStatus) VALUES
(1, 1, 'Select the AI tutor',            'Compare candidate tools and choose one',       '2026-09-30', '2026-09-28', 'Completed'),
(1, 2, 'Pilot in two lab groups',        'Run the tutor in two lab groups',               '2026-10-31', NULL,         'Delayed'),      -- overdue
(1, 3, 'Evaluate the pilot',             'Analyze results and feedback',                  '2027-01-15', NULL,         'Pending'),
(2, 1, 'Record lecture videos',          'Record the first six lectures',                 '2026-10-15', '2026-10-12', 'Completed'),
(2, 2, 'Run flipped sessions',           'Run weekly in-class problem solving',           '2026-12-10', NULL,         'In Progress'),
(2, 3, 'Collect the student survey',     'Survey at the end of term',                     '2027-01-10', NULL,         'Pending'),
(3, 1, 'Draft the oral exam rubric',     'Rubric reviewed by the two examiners',          '2026-12-01', NULL,         'Pending'),
(4, 1, 'Install the simulation software','Install on lab computers',                      '2026-11-01', NULL,         'In Progress'),  -- overdue
(4, 2, 'Train lab staff',                'One workshop for lab staff',                    '2026-12-15', NULL,         'Pending'),
(6, 1, 'Prepare the notebooks',          'Add the assistant to the course notebooks',     '2026-11-10', NULL,         'Pending'),      -- overdue
(7, 1, 'Create the peer review rubric',  'Rubric for schema design reviews',              '2026-03-15', '2026-03-10', 'Completed'),
(7, 2, 'Apply the rubric in sections',   'Use the rubric in two sections',                '2026-05-30', '2026-05-28', 'Completed');
GO

INSERT INTO Evidence (Title, ArtifactType, FilePathOrURL, UploadDate, EvidenceDescription, InitiativeID, MilestoneSeqNo) VALUES
('AI tutor selection report',     'Report',       'https://example.edu/evidence/ai-tutor-selection.pdf',    '2026-09-28', 'Comparison of three tools',            1, 1),  -- 1
('Pilot lab survey results',      'Survey',       'https://example.edu/evidence/pilot-survey.xlsx',         '2026-11-05', 'First results from the pilot groups',  1, 2),  -- 2
('Lecture video playlist',        'Video',        'https://example.edu/evidence/lecture-videos',            '2026-10-12', 'Videos for lectures 1 to 6',           2, 1),  -- 3
('Flipped session observation',   'Notes',        'https://example.edu/evidence/flipped-observation.docx',  '2026-11-12', 'Peer observation of one session',      2, 2),  -- 4
('Peer review rubric',            'Document',     'https://example.edu/evidence/peer-rubric.pdf',           '2026-03-10', 'Final rubric',                         7, 1),  -- 5
('Rubric application results',    'Report',       'https://example.edu/evidence/rubric-results.pdf',        '2026-05-28', 'Summary of the review sessions',       7, 2),  -- 6
('Initiative overview slides',    'Presentation', 'https://example.edu/evidence/oral-exams-overview.pptx',  '2026-10-16', 'Overview shown to the faculty board',  3, NULL);  -- 7
GO

INSERT INTO Outcome_Report (MetricType, QuantitativeValue, BaselineValue, QualitativeSummary, InitiativeID, SemesterID) VALUES
('Pass Rate',         82.00, 70.00, 'Pilot groups improved clearly',            1, 5),
('Average Lab Score', 74.50, 68.00, 'Higher scores in the pilot groups',        1, 5),
('Pass Rate',         88.00, 75.00, 'Fewer students failed the midterm',        2, 5),
('Average Lab Score', 80.00, 72.00, 'Better problem solving in class',          2, 5),
('Pass Rate',         91.00, 85.00, 'Clear improvement in design quality',      7, 4),
('Pass Rate',         79.00, 79.00, 'No change in the following semester',      7, 5);
GO

INSERT INTO Student_Feedback (Rating, FeedbackComment, CategorySentiment, CollectionMethod, InitiativeID, SemesterID) VALUES
(5, 'The tutor helped me find my bug quickly',   'Positive', 'Survey',      1, 5),
(4, 'Useful, but sometimes too vague',           'Positive', 'Survey',      1, 5),
(2, 'I prefer asking the TA directly',           'Negative', 'Focus Group', 1, 5),
(5, 'Videos let me learn at my own pace',        'Positive', 'Survey',      2, 5),
(3, 'Class time felt rushed',                    'Neutral',  'Survey',      2, 5),
(4, 'Reviews taught me a lot about my own design','Positive','Survey',      7, 4),
(3, 'Rubric was long',                           'Neutral',  'Survey',      7, 4),
(4, 'Good practice',                             'Positive', 'Survey',      7, 5);
GO

/* =====================================================================
   5. TRAINING
   ===================================================================== */

INSERT INTO Training_Session (Title, Topic, SessionDescription, SessionDate, DurationMinutes, Trainer, Capacity, SessionStatus, ToolID) VALUES
('Using the LLM Programming Tutor',   'AI tools',          'Hands-on introduction for instructors and TAs', '2026-12-02', 90,  'Dr. Mona Farouk',  3,  'Scheduled', 1),  -- 1  full
('Code Assistant Workshop',           'AI tools',          'Orientation to the code completion assistant',  '2026-10-20', 120, 'Eng. Omar Fathy',  20, 'Completed', 2),  -- 2
('Flipped Classroom Basics',          'Teaching methods',  'Planning a flipped session',                    '2026-12-09', 60,  'Dr. Rania Mostafa',25, 'Scheduled', 4),  -- 3
('Peer Instruction Practice',         'Teaching methods',  'Running concept questions in class',            '2026-09-10', 90,  'Dr. Sara Eid',     15, 'Completed', 6),  -- 4
('Notebook AI Assistant Introduction','AI tools',          'Setting up the assistant in notebooks',         '2026-12-15', 60,  'Dr. Sara Eid',     10, 'Scheduled', 3),  -- 5
('Case-Based Learning Clinic',        'Teaching methods',  'Writing and running business cases',            '2026-12-20', 120, 'Dr. Dina Wahba',   12, 'Scheduled', 5);  -- 6
GO

INSERT INTO Online_Training (SessionID, TrainingPlatform, MeetingLink, RecordingAvailable) VALUES
(1, 'Zoom',  'https://example.edu/meet/llm-tutor',        1),
(3, 'Teams', 'https://example.edu/meet/flipped-basics',   0),
(5, 'Zoom',  'https://example.edu/meet/notebook-ai',      1);
GO

INSERT INTO In_Person_Training (SessionID, Venue, Campus, RequiredEquipment) VALUES
(2, 'Lab C5.201', 'Main Campus', 'Laptop'),
(4, 'Hall B1.10', 'Main Campus', 'Voting cards'),
(6, 'Room B1.305','Main Campus', 'Printed case studies');
GO

INSERT INTO Session_Attendance (SessionID, MemberID) VALUES
(1, 4), (1, 5), (1, 9),     -- session 1 is full (capacity 3)
(2, 4), (2, 8),
(3, 5), (3, 9),
(4, 14), (4, 9),
(5, 14);
GO

INSERT INTO Training_Requirement (RequirementDescription, TargetAudience, RequiredByDate, IsMandatory, InitiativeID, ToolID) VALUES
('Complete the LLM tutor training',        'Instructors and TAs', '2026-12-05', 1, 1, 1),
('Attend the code assistant orientation',  'All members',         '2026-11-30', 1, 1, 2),
('Complete the flipped classroom basics',  'Instructors and TAs', '2026-12-10', 1, 2, 4),
('Complete the peer instruction practice', 'Instructors and TAs', '2026-09-30', 1, 7, 6),
('Attend the notebook assistant intro',    'Instructors',         '2026-12-14', 0, 6, 3),
('Attend the case-based learning clinic',  'Instructors',         '2026-12-15', 1, 5, 5);
GO

/* =====================================================================
   6. ACCREDITATION & GOVERNANCE
   ===================================================================== */

INSERT INTO Accreditation_Review (AccreditingBody, ReviewType, ReviewCycle, ReviewStatus, Decision, SubmissionDate, NextReviewDue, ProgramID) VALUES
('ABET',  'Interim Review',        'Annual',  'Completed',    'Accredited', '2024-02-01', '2025-12-01', 1),  -- 1
('ABET',  'Program Accreditation', '6 years', 'Submitted',    NULL,         '2026-03-01', '2026-12-15', 1),  -- 2  due soon
('ASIIN', 'Program Accreditation', '5 years', 'Under Review', NULL,         '2026-10-01', '2027-03-01', 2),  -- 3
('ACBSP', 'Program Accreditation', '6 years', 'Open',         NULL,         NULL,         '2027-06-30', 3);  -- 4
GO

INSERT INTO Review_Mapping (ReviewID, MappingID) VALUES
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7),
(3, 10), (3, 11);
GO

INSERT INTO Review_Assessment (ReviewID, AssessmentID) VALUES
(2, 1), (2, 3), (2, 5), (2, 8),
(3, 9);
GO

INSERT INTO Review_Evidence (ReviewID, EvidenceID) VALUES
(2, 1), (2, 3), (2, 5), (2, 6);
GO

INSERT INTO Notification (MessageContent, CreatedAt, Urgency, Category) VALUES
('Milestone "Pilot in two lab groups" is overdue.',               '2026-11-10 09:00', 'High',   'Milestone'),
('Initiative approved: Flipped Classroom for Algorithms',         '2026-09-25 10:30', 'Normal', 'Approval'),
('Accreditation review is due in December',                       '2026-11-15 08:00', 'High',   'Accreditation'),
('New training session scheduled: Flipped Classroom Basics',      '2026-11-12 12:00', 'Normal', 'Training'),
('Curriculum review week begins on the 25th',                     '2026-11-18 09:00', 'Low',    'Announcement');
GO

INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus) VALUES
(1, 4, 0), (1, 8, 0),
(2, 5, 1), (2, 9, 1),
(3, 13, 0), (3, 1, 1),
(4, 4, 0), (4, 5, 0), (4, 9, 1),
(5, 4, 0), (5, 5, 1), (5, 13, 0), (5, 1, 0);
GO

-- Each log row points at (at most) one affected item.
INSERT INTO Audit_Log (ActionType, LoggedAt, ChangeSummary, ActorID, ProposalID, ApprovalID, InitiativeID, AssessmentID, EvidenceID) VALUES
('Proposal Submitted',   '2026-10-05 11:00', 'Proposal 1 submitted',              4,  1,    NULL, NULL, NULL, NULL),
('Proposal Submitted',   '2026-05-12 09:30', 'Proposal 2 submitted',              5,  2,    NULL, NULL, NULL, NULL),
('Proposal Submitted',   '2026-10-20 14:10', 'Proposal 3 submitted',              14, 3,    NULL, NULL, NULL, NULL),
('Decision Recorded',    '2026-10-12 10:00', 'Reviewer approved proposal 1',      13, NULL, 1,    NULL, NULL, NULL),
('Decision Recorded',    '2026-05-27 12:15', 'Dean approved proposal 2',          1,  NULL, 3,    NULL, NULL, NULL),
('Decision Recorded',    '2026-06-05 13:40', 'University approved proposal 2',    11, NULL, 4,    NULL, NULL, NULL),
('Initiative Registered','2026-09-10 08:45', 'Initiative 1 registered',           4,  NULL, NULL, 1,    NULL, NULL),
('Initiative Registered','2026-09-12 09:05', 'Initiative 2 registered',           5,  NULL, NULL, 2,    NULL, NULL),
('Assessment Recorded',  '2026-01-20 15:00', 'Assessment 2 recorded',             4,  NULL, NULL, NULL, 2,    NULL),
('Assessment Recorded',  '2026-01-22 15:20', 'Assessment 4 recorded',             5,  NULL, NULL, NULL, 4,    NULL),
('Evidence Uploaded',    '2026-09-28 16:00', 'Evidence 1 uploaded',               4,  NULL, NULL, NULL, NULL, 1),
('Initiative Escalated', '2026-10-10 11:00', 'Dean escalated initiative 4',       2,  NULL, 10,   4,    NULL, NULL);
GO
