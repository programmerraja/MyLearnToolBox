Table of Contents
4. SQL Syntax 
4.1. Lexical Structure 
4.1.1. Identifiers and Key Words 
4.1.2. Constants 
4.1.3. Operators 
4.1.4. Special Characters 
4.1.5. Comments 
4.1.6. Operator Precedence 
4.2. Value Expressions 
4.2.1. Column References 
4.2.2. Positional Parameters 
4.2.3. Subscripts 
4.2.4. Field Selection 
4.2.5. Operator Invocations 
4.2.6. Function Calls 
4.2.7. Aggregate Expressions 
4.2.8. Window Function Calls 
4.2.9. Type Casts 
4.2.10. Collation Expressions 
4.2.11. Scalar Subqueries 
4.2.12. Array Constructors 
4.2.13. Row Constructors 
4.2.14. Expression Evaluation Rules 
4.3. Calling Functions 
4.3.1. Using Positional Notation 
4.3.2. Using Named Notation 
4.3.3. Using Mixed Notation 
5. Data Definition 
5.1. Table Basics 
5.2. Default Values 
5.3. Identity Columns 
5.4. Generated Columns 
5.5. Constraints 
5.5.1. Check Constraints 
5.5.2. Not-Null Constraints 
5.5.3. Unique Constraints 
5.5.4. Primary Keys 
5.5.5. Foreign Keys 
5.5.6. Exclusion Constraints 
5.6. System Columns 
5.7. Modifying Tables 
5.7.1. Adding a Column 
5.7.2. Removing a Column 
5.7.3. Adding a Constraint 
5.7.4. Removing a Constraint 
5.7.5. Changing a Column's Default Value 
5.7.6. Changing a Column's Data Type 
5.7.7. Renaming a Column 
5.7.8. Renaming a Table 
5.8. Privileges 
5.9. Row Security Policies 
5.10. Schemas 
5.10.1. Creating a Schema 
5.10.2. The Public Schema 
5.10.3. The Schema Search Path 
26
The SQL Language
5.10.4. Schemas and Privileges 
5.10.5. The System Catalog Schema 
5.10.6. Usage Patterns 
5.10.7. Portability 
5.11. Inheritance 
5.11.1. Caveats 
5.12. Table Partitioning 
5.12.1. Overview 
5.12.2. Declarative Partitioning 
5.12.3. Partitioning Using Inheritance 
5.12.4. Partition Pruning 
5.12.5. Partitioning and Constraint Exclusion 
5.12.6. Best Practices for Declarative Partitioning 
5.13. Foreign Data 
5.14. Other Database Objects 
5.15. Dependency Tracking 
6. Data Manipulation 
6.1. Inserting Data 
6.2. Updating Data 
6.3. Deleting Data 
6.4. Returning Data from Modified Rows 
7. Queries 
7.1. Overview 
7.2. Table Expressions 
7.2.1. The FROM Clause 
7.2.2. The WHERE Clause 
7.2.3. The GROUP BY and HAVING Clauses 
7.2.4. GROUPING SETS, CUBE, and ROLLUP
7.2.5. Window Function Processing 
7.3. Select Lists 
7.3.1. Select-List Items 
7.3.2. Column Labels 
7.3.3. DISTINCT
7.4. Combining Queries (UNION, INTERSECT, EXCEPT) 
7.5. Sorting Rows (ORDER BY) 
7.6. LIMIT and OFFSET
7.7. VALUES Lists 
7.8. WITH Queries (Common Table Expressions) 
7.8.1. SELECT in WITH 
7.8.2. Recursive Queries 
7.8.3. Common Table Expression Materialization 
7.8.4. Data-Modifying Statements in WITH 
8. Data Types 
8.1. Numeric Types 
8.1.1. Integer Types 
8.1.2. Arbitrary Precision Numbers 
8.1.3. Floating-Point Types 
8.1.4. Serial Types 
8.2. Monetary Types 
8.3. Character Types 
8.4. Binary Data Types 
8.4.1. bytea Hex Format 
8.4.2. bytea Escape Format 
8.5. Date/Time Types 
8.5.1. Date/Time Input 
8.5.2. Date/Time Output 
8.5.3. Time Zones 
8.5.4. Interval Input 
27
The SQL Language
8.5.5. Interval Output 
8.6. Boolean Type 
8.7. Enumerated Types 
8.7.1. Declaration of Enumerated Types 
8.7.2. Ordering 
8.7.3. Type Safety 
8.7.4. Implementation Details 
8.8. Geometric Types 
8.8.1. Points 
8.8.2. Lines 
8.8.3. Line Segments 
8.8.4. Boxes 
8.8.5. Paths 
8.8.6. Polygons 
8.8.7. Circles 
8.9. Network Address Types 
8.9.1. inet
8.9.2. cidr
8.9.3. inet vs. cidr
8.9.4. macaddr
8.9.5. macaddr8
8.10. Bit String Types 
8.11. Text Search Types 
8.11.1. tsvector
8.11.2. tsquery
8.12. UUID Type 
8.13. XML Type 
8.13.1. Creating XML Values 
8.13.2. Encoding Handling 
8.13.3. Accessing XML Values 
8.14. JSON Types 
8.14.1. JSON Input and Output Syntax 
8.14.2. Designing JSON Documents 
8.14.3. jsonb Containment and Existence 
8.14.4. jsonb Indexing 
8.14.5. jsonb Subscripting 
8.14.6. Transforms 
8.14.7. jsonpath Type 
8.15. Arrays 
8.15.1. Declaration of Array Types 
8.15.2. Array Value Input 
8.15.3. Accessing Arrays 
8.15.4. Modifying Arrays 
8.15.5. Searching in Arrays 
8.15.6. Array Input and Output Syntax 
8.16. Composite Types 
8.16.1. Declaration of Composite Types 
8.16.2. Constructing Composite Values 
8.16.3. Accessing Composite Types 
8.16.4. Modifying Composite Types 
8.16.5. Using Composite Types in Queries 
8.16.6. Composite Type Input and Output Syntax 
8.17. Range Types 
8.17.1. Built-in Range and Multirange Types 
8.17.2. Examples 
8.17.3. Inclusive and Exclusive Bounds 
8.17.4. Infinite (Unbounded) Ranges 
8.17.5. Range Input/Output 
28
The SQL Language
8.17.6. Constructing Ranges and Multiranges 
8.17.7. Discrete Range Types 
8.17.8. Defining New Range Types 
8.17.9. Indexing 
8.17.10. Constraints on Ranges 
8.18. Domain Types 
8.19. Object Identifier Types 
8.20. pg_lsn Type 
8.21. Pseudo-Types 
9. Functions and Operators 
9.1. Logical Operators 
9.2. Comparison Functions and Operators 
9.3. Mathematical Functions and Operators 
9.4. String Functions and Operators 
9.4.1. format
9.5. Binary String Functions and Operators 
9.6. Bit String Functions and Operators 
9.7. Pattern Matching 
9.7.1. LIKE
9.7.2. SIMILAR TO Regular Expressions 
9.7.3. POSIX Regular Expressions 
9.8. Data Type Formatting Functions 
9.9. Date/Time Functions and Operators 
9.9.1. EXTRACT, date_part
9.9.2. date_trunc
9.9.3. date_bin
9.9.4. AT TIME ZONE and AT LOCAL
9.9.5. Current Date/Time 
9.9.6. Delaying Execution 
9.10. Enum Support Functions 
9.11. Geometric Functions and Operators 
9.12. Network Address Functions and Operators 
9.13. Text Search Functions and Operators 
9.14. UUID Functions 
9.15. XML Functions 
9.15.1. Producing XML Content 
9.15.2. XML Predicates 
9.15.3. Processing XML 
9.15.4. Mapping Tables to XML 
9.16. JSON Functions and Operators 
9.16.1. Processing and Creating JSON Data 
9.16.2. The SQL/JSON Path Language 
9.16.3. SQL/JSON Query Functions 
9.16.4. JSON_TABLE 
9.17. Sequence Manipulation Functions 
9.18. Conditional Expressions 
9.18.1. CASE
9.18.2. COALESCE
9.18.3. NULLIF
9.18.4. GREATEST and LEAST
9.19. Array Functions and Operators 
9.20. Range/Multirange Functions and Operators 
9.21. Aggregate Functions 
9.22. Window Functions 
9.23. Merge Support Functions 
9.24. Subquery Expressions 
9.24.1. EXISTS
9.24.2. IN
29
The SQL Language
9.24.3. NOT IN
9.24.4. ANY/SOME
9.24.5. ALL 
9.24.6. Single-Row Comparison 
9.25. Row and Array Comparisons 
9.25.1. IN
9.25.2. NOT IN
9.25.3. ANY/SOME (array) 
9.25.4. ALL (array) 
9.25.5. Row Constructor Comparison 
9.25.6. Composite Type Comparison 
9.26. Set Returning Functions 
9.27. System Information Functions and Operators 
9.27.1. Session Information Functions 
9.27.2. Access Privilege Inquiry Functions 
9.27.3. Schema Visibility Inquiry Functions 
9.27.4. System Catalog Information Functions 
9.27.5. Object Information and Addressing Functions 
9.27.6. Comment Information Functions 
9.27.7. Data Validity Checking Functions 
9.27.8. Transaction ID and Snapshot Information Functions 
9.27.9. Committed Transaction Information Functions 
9.27.10. Control Data Functions 
9.27.11. Version Information Functions 
9.27.12. WAL Summarization Information Functions 
9.28. System Administration Functions 
9.28.1. Configuration Settings Functions 
9.28.2. Server Signaling Functions 
9.28.3. Backup Control Functions 
9.28.4. Recovery Control Functions 
9.28.5. Snapshot Synchronization Functions 
9.28.6. Replication Management Functions 
9.28.7. Database Object Management Functions 
9.28.8. Index Maintenance Functions 
9.28.9. Generic File Access Functions 
9.28.10. Advisory Lock Functions 
9.29. Trigger Functions 
9.30. Event Trigger Functions 
9.30.1. Capturing Changes at Command End 
9.30.2. Processing Objects Dropped by a DDL Command 
9.30.3. Handling a Table Rewrite Event 
9.31. Statistics Information Functions 
9.31.1. Inspecting MCV Lists 
10. Type Conversion 
10.1. Overview 
10.2. Operators 
10.3. Functions 
10.4. Value Storage 
10.5. UNION, CASE, and Related Constructs 
10.6. SELECT Output Columns 
11. Indexes 
11.1. Introduction 
11.2. Index Types 
11.2.1. B-Tree 
11.2.2. Hash 
11.2.3. GiST 
11.2.4. SP-GiST 
11.2.5. GIN 
30
The SQL Language
11.2.6. BRIN 
11.3. Multicolumn Indexes 
11.4. Indexes and ORDER BY
11.5. Combining Multiple Indexes 
11.6. Unique Indexes 
11.7. Indexes on Expressions 
11.8. Partial Indexes 
11.9. Index-Only Scans and Covering Indexes 
11.10. Operator Classes and Operator Families 
11.11. Indexes and Collations 
11.12. Examining Index Usage 
12. Full Text Search 
12.1. Introduction 
12.1.1. What Is a Document? 
12.1.2. Basic Text Matching 
12.1.3. Configurations 
12.2. Tables and Indexes 
12.2.1. Searching a Table 
12.2.2. Creating Indexes 
12.3. Controlling Text Search 
12.3.1. Parsing Documents 
12.3.2. Parsing Queries 
12.3.3. Ranking Search Results 
12.3.4. Highlighting Results 
12.4. Additional Features 
12.4.1. Manipulating Documents 
12.4.2. Manipulating Queries 
12.4.3. Triggers for Automatic Updates 
12.4.4. Gathering Document Statistics 
12.5. Parsers 
12.6. Dictionaries 
12.6.1. Stop Words 
12.6.2. Simple Dictionary 
12.6.3. Synonym Dictionary 
12.6.4. Thesaurus Dictionary 
12.6.5. Ispell Dictionary 
12.6.6. Snowball Dictionary 
12.7. Configuration Example 
12.8. Testing and Debugging Text Search 
12.8.1. Configuration Testing 
12.8.2. Parser Testing 
12.8.3. Dictionary Testing 
12.9. Preferred Index Types for Text Search 
12.10. psql Support 
12.11. Limitations 
13. Concurrency Control 
13.1. Introduction 
13.2. Transaction Isolation 
13.2.1. Read Committed Isolation Level 
13.2.2. Repeatable Read Isolation Level 
13.2.3. Serializable Isolation Level 
13.3. Explicit Locking 
13.3.1. Table-Level Locks 
13.3.2. Row-Level Locks 
13.3.3. Page-Level Locks 
13.3.4. Deadlocks 
13.3.5. Advisory Locks 
13.4. Data Consistency Checks at the Application Level 
31
The SQL Language
13.4.1. Enforcing Consistency with Serializable Transactions 
13.4.2. Enforcing Consistency with Explicit Blocking Locks 
13.5. Serialization Failure Handling 
13.6. Caveats 
13.7. Locking and Indexes 
14. Performance Tips 
14.1. Using EXPLAIN
14.1.1. EXPLAIN Basics 
14.1.2. EXPLAIN ANALYZE 
14.1.3. Caveats 
14.2. Statistics Used by the Planner 
14.2.1. Single-Column Statistics 
14.2.2. Extended Statistics 
14.3. Controlling the Planner with Explicit JOIN Clauses 
14.4. Populating a Database 
14.4.1. Disable Autocommit 
14.4.2. Use COPY
14.4.3. Remove Indexes 
14.4.4. Remove Foreign Key Constraints 
14.4.5. Increase maintenance_work_mem
14.4.6. Increase max_wal_size
14.4.7. Disable WAL Archival and Streaming Replication 
14.4.8. Run ANALYZE Afterwards 
14.4.9. Some Notes about pg_dump 
14.5. Non-Durable Settings 
15. Parallel Query 
15.1. How Parallel Query Works 
15.2. When Can Parallel Query Be Used? 
15.3. Parallel Plans 
15.3.1. Parallel Scans 
15.3.2. Parallel Joins 
15.3.3. Parallel Aggregation 
15.3.4. Parallel Append 
15.3.5. Parallel Plan Tips 
15.4. Parallel Safety 
15.4.1. Parallel Labeling for Functions and Aggregates 
32