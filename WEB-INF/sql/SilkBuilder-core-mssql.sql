-- ======================================================
-- System: Builder Structure
-- Project: /silk-builder/Data Model
-- ======================================================
-- SQL File: Data_Model_2026-01-09T16:22.sql
-- ======================================================

-- ------------------------------------------------------
-- TABLE: silkSystem
-- ------------------------------------------------------
create table silkSystem (
	silkSystemID int primary key identity (1,1),
	silkSystemUUID varchar(36),
	systemName varchar(100),
	theme varchar(50) default 'default',
	langList varchar(100) default ',en,',
	menuLink varchar(150),
	loginLink varchar(150),
	databaseList varchar(50),
	silkDatabaseID tinyint default 0,
	testController varchar(50),
	testdb varchar(50),
	testdb1 varchar(50),
	testdb2 varchar(50),
	testdb3 varchar(50),
	testdb4 varchar(50),
	systemStatus tinyint default 0,
	creationDate datetime default getDate(),
	operationDate datetime default getDate(),
	operationUser int,
	operationAction varchar(20) 
);

create index silkSystem_silkSystemUUID on silkSystem(silkSystemUUID);

-- ------------------------------------------------------
-- TABLE: silkDatabase
-- ------------------------------------------------------
create table silkDatabase (
	silkDatabaseID int primary key,
	databaseName varchar(100),
	shortName varchar(10),
	databaseController varchar(100) 
);

-- ------------------------------------------------------
-- TABLE: silkLang
-- ------------------------------------------------------
create table silkLang (
	silkLangID int primary key identity (1,1),
	langID char(2),
	langName nvarchar(100),
	enName varchar(100),
	status tinyint default 0
);

-- ------------------------------------------------------
-- TABLE: silkProject
-- ------------------------------------------------------
create table silkProject (
	silkProjectID int primary key identity (1,1),
	projectUUID varchar(36),
	silkSystemID int,
	parentID int,
	projectLevel tinyint default 0,
	projectName varchar(100),
	nodeType varchar(10),
	content nvarchar(max),
	lastSyncID int,
	status tinyint default 0,
	operationAction varchar(20),
	operationDate datetime,
	operationUser int,
	foreign key (silkSystemID) references silkSystem (silkSystemID) on delete Cascade 
);

create index silkProject_projectUUID on silkProject(projectUUID);
create index silkProject_silkSystemID on silkProject(silkSystemID);
create index silkProject_parentID on silkProject(parentID);
create index silkProject_nodeType on silkProject(nodeType);

-- ------------------------------------------------------
-- TABLE: silkNode
-- ------------------------------------------------------
create table silkNode (
	nodeType varchar(10) primary key,
	name varchar(50),
	fileName varchar(50),
	extension varchar(10),
	nodeLevel tinyint default 0,
	parent tinyint,
	editor tinyint,
	saveMode tinyint,
	import tinyint,
	parentFilter varchar(20),
	iconName varchar(30),
	iconColor varchar(20),
	template nvarchar(max),
	recordOrder tinyint default 0,
	sync tinyint default 0
);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int primary key identity (1,1),
	silkSystemID int,
	parentID int,
	tagLevel tinyint default 0,
	tagName varchar(50),
	tagType tinyint default 0,
	tagIntValue tinyint,
	content nvarchar(max),
	contentType tinyint default 0,
	folderOnly tinyint default 0,
	position tinyint default 0,
	syncDate datetime,
	operationAction varchar(20),
	operationDate datetime default getDate(),
	operationUser int 
);

create index silkTag_silkSystemID on silkTag(silkSystemID);
create index silkTag_parentID on silkTag(parentID);
create index silkTag_tagIntValue on silkTag(tagIntValue);

-- ------------------------------------------------------
-- TABLE: silkTarget
-- ------------------------------------------------------
create table silkTarget (
	silkTargetID int primary key identity (1,1),
	silkSystemID int,
	targetURL varchar(200),
	langList varchar(100) default ',en,',
	defaultLangID char(2) default 'en',
	accessToken varchar(36) default 0,
	targetdb varchar(50),
	targetdb1 varchar(50),
	targetdb2 varchar(50),
	targetdb3 varchar(50),
	targetdb4 varchar(50),
	syncDate datetime,
	operationAction varchar(20),
	operationDate datetime,
	operationUser int,
	foreign key (silkSystemID) references silkSystem (silkSystemID) on delete Cascade 
);

create index silkTarget_silkSystemID on silkTarget(silkSystemID);
create index silkTarget_operationUser on silkTarget(operationUser);

-- ------------------------------------------------------
-- TABLE: silkTesting
-- ------------------------------------------------------
create table silkTesting (
	silkTestingID int primary key identity (1,1),
	silkDeveloperID int,
	silkSystemID int,
	testName nvarchar(50),
	silkUserID varchar(50),
	variableList nvarchar(500),
	roleList varchar(500),
	position tinyint default 0,
	foreign key (silkSystemID) references silkSystem (silkSystemID) on delete Cascade 
);

create index silkTesting_silkDeveloperID on silkTesting(silkDeveloperID);
create index silkTesting_silkSystemID on silkTesting(silkSystemID);

-- ------------------------------------------------------
-- TABLE: silkCodeHistory
-- ------------------------------------------------------
create table silkCodeHistory (
	silkCodeHistoryID int primary key identity (1,1),
	silkProjectID int,
	content nvarchar(max),
	operationDate datetime,
	operationUser int,
	commitFlag tinyint default 0,
	commitDate datetime,
	commitUser int 
);
create index silkCodeHistory_silkProjectID on silkCodeHistory(silkProjectID);

-- ------------------------------------------------------
-- PROGRAM: init-tables
-- ------------------------------------------------------
--
-- Create silkSession 
--
create table silkSession (
	silkSessionID int primary key identity (1,1),
	silkAccessID int,
	silkUserID int,
	ipAddress varchar(50),
	httpSession varchar(255),
	sessionToken varchar(500),
	sessionType tinyint default 0,
	sessionDate datetime,
	lastTransactionDate datetime,
	deviceType varchar(20),
	userAgent varchar(255),
	disabled tinyint default 0
);

create index silkSession_silkAccessID on silkSession(silkAccessID);
create index silkSession_silkUserID on silkSession(silkUserID);
create index silkSession_ipAddress on silkSession(ipAddress);
create index silkSession_httpSession on silkSession(httpSession);
create index silkSession_sessionToken on silkSession(sessionToken);

--
-- Create readLanguage Function
--
GO
create function readLanguage (@dataText nvarchar(max), @lang nvarchar(10) )
returns nvarchar(max) as
begin
	Declare @startTag nvarchar(20);
	Declare @endTag nvarchar(20);
	Declare @startPos int;
	Declare @endPos int;
	
	--
	-- If dataText is empty returns
	--
	if Len(@dataText)=0
		return ''
	
	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if charIndex(N'<lang-',@dataText)=0
		return @dataText
	
	-- 
	-- Creates received lang tag
	--
	set @startTag  = N'<lang-'+@lang+'>';
	set @endTag  = N'</lang-'+@lang+'>';
	
	--
	-- Search tag in dataText
	--
	set @startPos = charIndex(@startTag,@dataText);

	if @startPos=0
	begin
		--
		-- If lang does not exist search for english as base language
		--
		set @startTag  = N'<lang-en>';
		set @endTag  = N'</lang-en>';
		
		--
		-- Search tag in dataText
		--
		set @startPos = charIndex(@startTag,@dataText);
		
		if @startPos=0
		Begin
			--
			-- If lang does not exist search for any existing language
			--
			set @startPos = charIndex('<lang-',@dataText);

			if @startPos=0
				return '';
			
			set @endPos = charIndex('>',@dataText);
			
			set @lang = substring(@dataText,@startPos+6,@endPos-7);
			
			set @startTag  = N'<lang-'+@lang+'>';
			set @endTag  = N'</lang-'+@lang+'>';	
		
		End
	End	

	set @startPos = @startPos+Len(@startTag);
	set @endPos = charIndex(@endTag,@dataText)-@startPos;

	return substring(@dataText,@startPos,@endPos);

end;

--
-- Create writeLanguage Function
--
GO
create function writeLanguage(@oldText nvarchar(max),@dataText nvarchar(max), @lang nvarchar(10) )
returns nvarchar(max)
as
begin
	Declare @startTag nvarchar(20);
	Declare @endTag nvarchar(20);
	Declare @startPos int;
	Declare @endPos int;
	
	-- -----------
	-- If old text is null it is set to empty.
	-- -----------

	set @oldText = isNull(@oldText,'');
	
	-- -----------
	-- If the existing text does not have the lang tag it is clear to received the new data with the tag.
	-- -----------
	if charIndex(N'<lang-',@oldText)=0
		set @oldText=''

	-- -----------
	-- Initializes the tag limits.
	-- -----------
	set @startTag  = N'<lang-'+@lang+'>';
	set @endTag  = N'</lang-'+@lang+'>';

	-- -----------
	-- Finds the poisition of the open lang tag.
	-- -----------
	set @startPos = charIndex(@startTag,@oldText);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if @startPos=0
		return @oldText+@startTag+@dataText+@endTag;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	set @startPos = @startPos+Len(@startTag)-1;
	set @endPos = Len(@oldText)-charIndex(@endTag,@oldText)+1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	return left(@oldText,@startPos)+@dataText+right(@oldText,@endPos);

end;
GO
--
-- Silk Project
--
INSERT INTO silkProject (projectUUID, projectLevel, projectName, nodeType) VALUES ('PROJECT-ROOT', 0, 'Projects', 'ROOT' );

--
-- Silk Database
--
INSERT INTO silkDatabase (silkDatabaseID, databaseName, shortName, databaseController)
VALUES (1,'MS SQL Server','MSSQL',NULL);

INSERT INTO silkDatabase (silkDatabaseID, databaseName, shortName, databaseController)
VALUES (2,'MySQL','MySQL',NULL);

INSERT INTO silkDatabase (silkDatabaseID, databaseName, shortName, databaseController)
VALUES (3,'PostgreSQL','PgSQL',NULL);

INSERT INTO silkDatabase (silkDatabaseID, databaseName, shortName, databaseController)
VALUES (4,'Oracle','ORCLE',NULL);

--
-- Lang
--
INSERT INTO silkLang (langID, langName, enName, status)
VALUES ('en','English','English',1);

INSERT INTO silkLang (langID, langName, enName, status)
VALUES ('es','Español','Spanish',0);

INSERT INTO silkLang (langID, langName, enName, status)
VALUES ('fr','Française','French',0);

--
-- Nodes
--
INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('APP','Private App',NULL,'.jsp',3,1,1,2,1,'SRV','fa-solid fa-rocket','#81dafc','<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>' + CHAR(13) + CHAR(10) + '<%@page contentType="text/html;charset=UTF-8" %>' + CHAR(13) + CHAR(10) + '<silk:App title="">' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '	<silk:Screen>' + CHAR(13) + CHAR(10) + '		<%@ include file="" %>' + CHAR(13) + CHAR(10) + '	</silk:Screen>' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '</silk:App>',8,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CMF','Conceptual Model',NULL,NULL,2,1,0,0,0,'PRJ','fa-solid fa-book','#bc7e49',NULL,13,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CSF','Private Service',NULL,'.jsp',3,1,1,2,1,'SRV','fa-solid fa-satellite-dish','#81dafc','<%@page contentType="text/html;charset=UTF-8" import="com.oopsclick.silk.dbo.*,java.io.*" trimDirectiveWhitespaces="true" %>' + CHAR(13) + CHAR(10) + '<%' + CHAR(13) + CHAR(10) + '	' + CHAR(13) + CHAR(10) + '%>',10,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CSFP','Public Service',NULL,'.srv',3,1,1,2,1,'SRV','fa-solid fa-satellite-dish','#a0e7a0','<%@page contentType="text/html;charset=UTF-8" import="com.oopsclick.silk.dbo.*,java.io.*" trimDirectiveWhitespaces="true" %>' + CHAR(13) + CHAR(10) + '<%' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '%>',13,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('DBD','Data Diagram',NULL,NULL,3,0,3,0,0,'DMF','fa-solid fa-sitemap','#FF6666',NULL,6,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('DBPR','Operation Object',NULL,'',3,0,5,0,0,'DMF','fa-solid fa-cogs','#ffc500',NULL,8,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('DBTR','Trigger',NULL,NULL,3,0,5,0,0,'ORM','fa-solid fa-magic','#ffc500',NULL,8,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('DBVW','View Object',NULL,NULL,3,0,5,0,0,'DMF','fa-solid fa-eye','#ffc500',NULL,7,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('DMF','Data Model',NULL,NULL,2,1,0,0,0,'PRJ','fa-solid fa-briefcase','#5cb85c',NULL,4,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('EMAIL','Email Template',NULL,NULL,3,0,7,4,0,'SRV','fa-solid fa-envelope','#d8d8cf','{' + CHAR(13) + CHAR(10) + '  "head": {' + CHAR(13) + CHAR(10) + '    "silkEmaillID": "",' + CHAR(13) + CHAR(10) + '    "wrapper": "default.eml",' + CHAR(13) + CHAR(10) + '    "sentFrom": "",' + CHAR(13) + CHAR(10) + '    "replyTo": "",' + CHAR(13) + CHAR(10) + '    "copyTo": "",' + CHAR(13) + CHAR(10) + '    "blindTo": "",' + CHAR(13) + CHAR(10) + '    "emailUUID": ""' + CHAR(13) + CHAR(10) + '  },' + CHAR(13) + CHAR(10) + '  "body": [' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "langID": "en",' + CHAR(13) + CHAR(10) + '      "subject": "",' + CHAR(13) + CHAR(10) + '      "message": ""' + CHAR(13) + CHAR(10) + '    }' + CHAR(13) + CHAR(10) + '  ]' + CHAR(13) + CHAR(10) + '}',15,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('HTML','Document',NULL,NULL,3,1,2,0,0,'CMF,HTML','fa-solid fa-file','#eeeeee',NULL,16,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('MOD','App Module',NULL,'.jsp',3,0,1,2,1,'APP,CSF,PUB,CSFP','fa-solid fa-code','#e4e3a4','<silk:Module >' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '	<silk:Page id="xListPage" stage="A1"' + CHAR(13) + CHAR(10) + '		smLayout="A1"' + CHAR(13) + CHAR(10) + '		mdLayout="A1"' + CHAR(13) + CHAR(10) + '		rgLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '		lgLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '		xlLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '		xxLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '	>' + CHAR(13) + CHAR(10) + '		<silk:Head >' + CHAR(13) + CHAR(10) + '			List Attribute Title' + CHAR(13) + CHAR(10) + '		</silk:Head>' + CHAR(13) + CHAR(10) + '		<silk:Content>' + CHAR(13) + CHAR(10) + '			List content goes here...' + CHAR(13) + CHAR(10) + '		</silk:Content>' + CHAR(13) + CHAR(10) + '	</silk:Page>' + CHAR(13) + CHAR(10) + '		' + CHAR(13) + CHAR(10) + '	<silk:Page id="xFormPage" stage="A2"' + CHAR(13) + CHAR(10) + '		smLayout="A2:*:b"' + CHAR(13) + CHAR(10) + '		mdLayout="A2:*:b"' + CHAR(13) + CHAR(10) + '		rgLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '		lgLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '		xlLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '		xxLayout="A1:500px,A2"' + CHAR(13) + CHAR(10) + '	>' + CHAR(13) + CHAR(10) + '		<silk:Head >' + CHAR(13) + CHAR(10) + '			Form Attribute Title' + CHAR(13) + CHAR(10) + '		</silk:Head>' + CHAR(13) + CHAR(10) + '		<silk:Content>' + CHAR(13) + CHAR(10) + '			Form content goes here...' + CHAR(13) + CHAR(10) + '		</silk: Content>' + CHAR(13) + CHAR(10) + '	</silk:Page>' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '	<silk:JScode>' + CHAR(13) + CHAR(10) + '	' + CHAR(13) + CHAR(10) + '	</silk:JScode>' + CHAR(13) + CHAR(10) + '	' + CHAR(13) + CHAR(10) + '	<silk:JQcode>' + CHAR(13) + CHAR(10) + '	' + CHAR(13) + CHAR(10) + '	</silk:JQcode>' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '</silk:Module >',9,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ORM','ORM Table Object',NULL,'.orm',3,1,4,1,1,'DMF','fa-solid fa-database','#ffc500','{' + CHAR(13) + CHAR(10) + '  "table": {' + CHAR(13) + CHAR(10) + '    "tableName": "",' + CHAR(13) + CHAR(10) + '    "pkMode": "Auto",' + CHAR(13) + CHAR(10) + '    "insertAuthorization": "",' + CHAR(13) + CHAR(10) + '    "updateAuthorization": "",' + CHAR(13) + CHAR(10) + '    "deleteAuthorization": "",' + CHAR(13) + CHAR(10) + '    "pkSql1": "",' + CHAR(13) + CHAR(10) + '    "dbType": "0",' + CHAR(13) + CHAR(10) + '    "description": ""' + CHAR(13) + CHAR(10) + '  },' + CHAR(13) + CHAR(10) + '  "column": [],' + CHAR(13) + CHAR(10) + '  "select": [],' + CHAR(13) + CHAR(10) + '  "operation": [],' + CHAR(13) + CHAR(10) + '  "authorization": [],' + CHAR(13) + CHAR(10) + '  "fk": [],' + CHAR(13) + CHAR(10) + '  "queryType": "SQL"' + CHAR(13) + CHAR(10) + '}',5,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ORMF','ORM Folder Object',NULL,'.orm',3,0,4,1,1,'DMF','fa-solid fa-database','#ffc500','{' + CHAR(13) + CHAR(10) + '  "table": {' + CHAR(13) + CHAR(10) + '    "tableName": "",' + CHAR(13) + CHAR(10) + '    "pkMode": "Auto",' + CHAR(13) + CHAR(10) + '    "insertAuthorization": "",' + CHAR(13) + CHAR(10) + '    "updateAuthorization": "",' + CHAR(13) + CHAR(10) + '    "deleteAuthorization": "",' + CHAR(13) + CHAR(10) + '    "pkSql1": "",' + CHAR(13) + CHAR(10) + '    "dbType": "0",' + CHAR(13) + CHAR(10) + '    "description": ""' + CHAR(13) + CHAR(10) + '  },' + CHAR(13) + CHAR(10) + '  "column": [' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "fileID",' + CHAR(13) + CHAR(10) + '      "type": "S",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "String",' + CHAR(13) + CHAR(10) + '      "pk": 1,' + CHAR(13) + CHAR(10) + '      "id": "dbc9531a-5d90-4566-940d-e8ac1331c4fd",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 0' + CHAR(13) + CHAR(10) + '    },' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "filePath",' + CHAR(13) + CHAR(10) + '      "type": "S",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "String",' + CHAR(13) + CHAR(10) + '      "id": "3ca1cb96-85a8-4eac-a245-24a91b0321f2",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 1' + CHAR(13) + CHAR(10) + '    },' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "folderPath",' + CHAR(13) + CHAR(10) + '      "type": "S",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "String",' + CHAR(13) + CHAR(10) + '      "id": "d5b5033b-fb5c-4396-8598-849994ad0e05",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 2' + CHAR(13) + CHAR(10) + '    },' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "fileName",' + CHAR(13) + CHAR(10) + '      "type": "S",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "String",' + CHAR(13) + CHAR(10) + '      "id": "3200d087-34ff-400f-9e53-ad1a214364ba",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 3' + CHAR(13) + CHAR(10) + '    },' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "size",' + CHAR(13) + CHAR(10) + '      "type": "I",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "Integer",' + CHAR(13) + CHAR(10) + '      "id": "87b418d6-c94a-4f5f-a2d1-7ace4314b98a",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 4' + CHAR(13) + CHAR(10) + '    },' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "type",' + CHAR(13) + CHAR(10) + '      "type": "S",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "String",' + CHAR(13) + CHAR(10) + '      "id": "d4ca8037-3b37-4c58-a27a-05374f428535",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 5' + CHAR(13) + CHAR(10) + '    },' + CHAR(13) + CHAR(10) + '    {' + CHAR(13) + CHAR(10) + '      "columnName": "content",' + CHAR(13) + CHAR(10) + '      "type": "S",' + CHAR(13) + CHAR(10) + '      "columnTypeLabel": "String",' + CHAR(13) + CHAR(10) + '      "id": "e97620de-4c48-427c-b624-0b5df329372c",' + CHAR(13) + CHAR(10) + '      "_recordIndex": 6' + CHAR(13) + CHAR(10) + '    }' + CHAR(13) + CHAR(10) + '  ],' + CHAR(13) + CHAR(10) + '  "select": [' + CHAR(13) + CHAR(10) + '    ' + CHAR(13) + CHAR(10) + '  ],' + CHAR(13) + CHAR(10) + '  "operation": [' + CHAR(13) + CHAR(10) + '    ' + CHAR(13) + CHAR(10) + '  ],' + CHAR(13) + CHAR(10) + '  "authorization": [' + CHAR(13) + CHAR(10) + '    ' + CHAR(13) + CHAR(10) + '  ],' + CHAR(13) + CHAR(10) + '  "fk": [' + CHAR(13) + CHAR(10) + '    ' + CHAR(13) + CHAR(10) + '  ],' + CHAR(13) + CHAR(10) + '  "queryType": "Folder"' + CHAR(13) + CHAR(10) + '}',5,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('OSL','Private Data Outlet',NULL,'.jsp',3,0,6,3,1,'SRV','fa-solid fa-plug','#81dafc','{"ormPath":"","selectName":"","parameter":""}',11,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('OSLP','Public Data Outlet',NULL,'.srv',3,0,6,3,1,'SRV','fa-solid fa-plug','#a0e7a0','ormPath:' + CHAR(13) + CHAR(10) + 'selectName:' + CHAR(13) + CHAR(10) + '',14,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('PRJ','Project',NULL,NULL,1,1,0,0,0,'ROOT','fa-solid fa-box-open','#FABC3C',NULL,1,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('PUB','Public App',NULL,'.srv',3,1,1,2,1,'SRV','fa-solid fa-rocket','#a0e7a0','<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>' + CHAR(13) + CHAR(10) + '<%@page contentType="text/html;charset=UTF-8" %>' + CHAR(13) + CHAR(10) + '<silk:App title="">' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '    <silk:Screen>' + CHAR(13) + CHAR(10) + '        <%@ include file="" %>' + CHAR(13) + CHAR(10) + '    </silk:Screen>' + CHAR(13) + CHAR(10) + '' + CHAR(13) + CHAR(10) + '</silk:App>',12,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ROOT',NULL,NULL,NULL,0,1,0,0,0,NULL,NULL,'#FF6666',NULL,0,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('SRV','Service Poll',NULL,NULL,2,1,0,0,0,'PRJ','fa-solid fa-cubes','#E2FF3E',NULL,7,1);

--
-- Silk Tag
--
INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-button-ok',0,NULL,'<lang-en>OK</lang-en><lang-es>OK</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-button-cancel',0,NULL,'<lang-en>Cancel</lang-en><lang-es>Cancelar</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-button-submit',0,NULL,'<lang-en>Submit</lang-en><lang-es>Enviar</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-button-delete',0,NULL,'<lang-en>Submit</lang-en><lang-es>Enviar</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-form-adding',0,NULL,'<lang-en>Adding</lang-en><lang-es>Añadiendo</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-form-editing',0,NULL,'<lang-en>Editing</lang-en><lang-es>Editando</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-form-deleting',0,NULL,'<lang-en>Deleting</lang-en><lang-es>Borrando</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-form-created',0,NULL,'<lang-en>Created</lang-en><lang-es>Creado</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-form-edited',0,NULL,'<lang-en>Edited</lang-en><lang-es>Editado</lang-es>',0,NULL,0);

INSERT INTO silkTag (silkSystemID, parentID, tagLevel, tagName, tagType, tagIntValue, content, contentType, folderOnly, position)
VALUES (0,0,1,'global-form-deleted',0,NULL,'<lang-en>Deleted</lang-en><lang-es>Borrado</lang-es>',0,NULL,0);

-- ------------------------------------------------------
-- VIEW: vwSilkProjectService
-- ------------------------------------------------------
GO
create view vwSilkProjectService AS
select
	pr1.silkProjectID AS silkProjectID,
	pr1.silkSystemID AS silkSystemID,
	sys.systemName+'/'+pr2.projectName+'/'+pr1.projectName AS projectName
from silkproject pr1
join silkproject pr2 on pr1.parentID = pr2.silkProjectID
join silksystem sys on pr1.silkSystemID = sys.silkSystemID
where pr1.nodeType = 'SRV'
and pr1.status = 0;

-- ------------------------------------------------------
-- VIEW: silkVariable
-- ------------------------------------------------------
GO
create view silkVariable as
select
	tg.silkSystemID,
	pr.tagName as groupName,
	tg.tagIntValue as value,
	tg.content as label,
	tg.tagName as keyValue,
	tg.position
from silkTag tg
join silktag pr on tg.parentID = pr.silkTagID
where tg.tagType=1;
GO

-- ======================================================
-- SQL script end
-- ======================================================