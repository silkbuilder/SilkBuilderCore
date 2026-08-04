-- ======================================================
-- System: Builder Structure
-- Project: /silk-builder/Data Model
-- ======================================================
-- SQL File: Data_Model_2026-01-09T16:23.sql
-- ======================================================

-- ------------------------------------------------------
-- TABLE: silkSystem
-- ------------------------------------------------------
create table silkSystem (
	silkSystemID int generated always as identity primary key,
	silkSystemUUID varchar2(36),
	systemName varchar2(100),
	theme varchar2(50) default 'default',
	langList varchar2(100) default ',en,',
	menuLink varchar2(150),
	loginLink varchar2(150),
	databaseList varchar2(50),
	silkDatabaseID smallint default 0,
	testController varchar2(50),
	testdb varchar2(50),
	testdb1 varchar2(50),
	testdb2 varchar2(50),
	testdb3 varchar2(50),
	testdb4 varchar2(50),
	systemStatus smallint default 0,
	creationDate timestamp default CURRENT_TIMESTAMP,
	operationDate timestamp default CURRENT_TIMESTAMP,
	operationUser int,
	operationAction varchar2(20) 
);

create index silkSystem_silkSystemUUID on silkSystem(silkSystemUUID);

-- ------------------------------------------------------
-- TABLE: silkDatabase
-- ------------------------------------------------------
create table silkDatabase (
	silkDatabaseID int primary key,
	databaseName varchar2(100),
	shortName varchar2(10),
	databaseController varchar2(100) 
);

-- ------------------------------------------------------
-- TABLE: silkLang
-- ------------------------------------------------------
create table silkLang (
	silkLangID int generated always as identity primary key,
	langID char(2),
	langName nvarchar2(100),
	enName varchar2(100),
	status smallint default 0
);

-- ------------------------------------------------------
-- TABLE: silkProject
-- ------------------------------------------------------
create table silkProject (
	silkProjectID int generated always as identity primary key,
	projectUUID varchar2(36),
	silkSystemID int,
	parentID int,
	projectLevel smallint default 0,
	projectName varchar2(100),
	nodeType varchar2(10),
	content clob,
	lastSyncID int,
	status smallint default 0,
	operationAction varchar2(20),
	operationDate timestamp,
	operationUser int,
	lockStatus smallint default 0,
	lockUser int,
	lockDate timestamp,
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
	nodeType varchar2(10) primary key,
	name varchar2(50),
	fileName varchar2(50),
	extension varchar2(10),
	nodeLevel smallint default 0,
	parent smallint,
	editor smallint,
	saveMode smallint,
	import smallint,
	parentFilter varchar(20),
	iconName varchar2(30),
	iconColor varchar2(20),
	template clob,
	recordOrder smallint default 0,
	sync smallint default 0
);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int generated always as identity primary key,
	silkSystemID int,
	parentID int,
	tagLevel smallint default 0,
	tagName varchar2(50),
	tagType smallint default 0,
	tagIntValue smallint,
	content clob,
	contentType smallint default 0,
	folderOnly smallint default 0,
	position smallint default 0,
	syncDate timestamp,
	operationAction varchar2(20),
	operationDate timestamp default CURRENT_TIMESTAMP,
	operationUser int 
);

create index silkTag_silkSystemID on silkTag(silkSystemID);
create index silkTag_parentID on silkTag(parentID);
create index silkTag_tagIntValue on silkTag(tagIntValue);

-- ------------------------------------------------------
-- TABLE: silkTarget
-- ------------------------------------------------------
create table silkTarget (
	silkTargetID int generated always as identity primary key,
	silkSystemID int,
	targetURL varchar2(200),
	langList varchar2(100) default ',en,',
	defaultLangID char(2) default 'en',
	accessToken varchar2(36) default 0,
	targetdb varchar2(50),
	targetdb1 varchar2(50),
	targetdb2 varchar2(50),
	targetdb3 varchar2(50),
	targetdb4 varchar2(50),
	syncDate timestamp,
	operationAction varchar2(20),
	operationDate timestamp,
	operationUser int,
	foreign key (silkSystemID) references silkSystem (silkSystemID) on delete Cascade 
);

create index silkTarget_silkSystemID on silkTarget(silkSystemID);
create index silkTarget_operationUser on silkTarget(operationUser);

-- ------------------------------------------------------
-- TABLE: silkTesting
-- ------------------------------------------------------
create table silkTesting (
	silkTestingID int generated always as identity primary key,
	silkDeveloperID int,
	silkSystemID int,
	testName varchar2(50),
	silkUserID varchar(50),
	variableList varchar2(1000),
	roleList varchar2(1000),
	position smallint default 0,
	foreign key (silkSystemID) references silkSystem (silkSystemID) on delete Cascade 
);

create index silkTesting_silkDeveloperID on silkTesting(silkDeveloperID);
create index silkTesting_silkSystemID on silkTesting(silkSystemID);

-- ------------------------------------------------------
-- TABLE: silkCodeHistory
-- ------------------------------------------------------
create table silkCodeHistory (
	silkCodeHistoryID int generated always as identity primary key,
	silkProjectID int,
	content clob,
	operationDate timestamp,
	operationUser int,
	commitFlag smallint default 0,
	commitDate timestamp,
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
	silkSessionID int generated always as identity primary key,
	silkAccessID int,
	silkUserID int,
	ipAddress varchar2(50),
	httpSession varchar2(255),
	sessionToken varchar2(500),
	sessionType smallint default 0,
	sessionDate timestamp,
	lastTransactionDate timestamp,
	deviceType varchar2(20),
	userAgent varchar2(255),
	disabled smallint default 0
);

create index silkSession_silkAccessID on silkSession(silkAccessID);
create index silkSession_silkUserID on silkSession(silkUserID);
create index silkSession_ipAddress on silkSession(ipAddress);
create index silkSession_httpSession on silkSession(httpSession);
create index silkSession_sessionToken on silkSession(sessionToken);

--
-- Create readLanguage Function
--
create or replace function readLanguage (dataText nvarchar2, lang char)
return nvarchar2
is
	startTag nvarchar2(20);
	endTag nvarchar2(20);
	startPos smallint;
	endPos smallint;
    lang2 char(2);
begin

	--
	-- If dataText is empty returns
	--
	if length(dataText)=0 then
		return '';
	end if;

	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if instr(dataText, '<lang-')=0 then
		return dataText;
	end if;

	-- 
	-- Creates received lang tag
	--
	startTag := '<lang-'||lang||'>';
	endTag := '</lang-'||lang||'>';

	--
	-- Search tag in dataText
	--
	startPos := instr(dataText, startTag);
	
	if startPos=0 then
		--
		-- If lang does not exist search for english as base language
		--
		startTag := '<lang-en>';
		endTag := '</lang-en>';

		--
		-- Search tag in dataText
		--
		startPos := instr(dataText, startTag);
	end if;

	if startPos=0 then
		--
		-- If lang does not exist search for any existing language
		--
		startPos := instr(dataText, '<lang-');
		
		if startPos=0 then
			return '';
		end if;
		
		lang2 := substr(dataText,startPos+6,2);
		startTag := '<lang-'||lang2||'>';
		endTag := '</lang-'||lang2||'>';
		
	end if;	

	startPos := startPos+length(startTag);
	endPos := instr(dataText, endTag)-startPos;
	
	return substr(dataText,startPos,endPos);

end;
/

--
-- Create writeLanguage Function
--
create or replace function writeLanguage (oldEntry nvarchar2, dataText nvarchar2, lang char)
return nvarchar2
is
	startTag nvarchar2(20);
	endTag nvarchar2(20);
	startPos smallint;
	endPos smallint;
    oldText nvarchar2(32767);
begin

	-- -----------
	-- If old text is null it is set to empty.
	-- -----------
	oldText := coalesce(oldEntry,'');
	
	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if instr(oldText,'<lang-')=0 then
		return oldText;
	end if;

	-- -----------
	-- Initializes the tag limits.
	-- -----------
	startTag := '<lang-'||lang||'>';
	endTag := '</lang-'||lang||'>';

	-- -----------
	-- Finds the position of the open lang tag.
	-- -----------
	startPos := instr(oldText, startTag);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if startPos=0 then
		return oldText||startTag||dataText||endTag;
	end if;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	startPos := startPos+length(startTag)-1;
	endPos := length(oldText) - instr(oldText, endTag) + 1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	return substr(oldText,1,startPos)||dataText||substr(oldText,-1*endPos,endPos);

end;
/

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
	('APP','Private App',NULL,'.jsp',3,1,1,2,1,'SRV','fa-solid fa-rocket','#81dafc','<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>' || chr(13) || chr(10) || '<%@page contentType="text/html;charset=UTF-8" %>' || chr(13) || chr(10) || '<silk:App title="">' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '	<silk:Screen>' || chr(13) || chr(10) || '		<%@ include file="" %>' || chr(13) || chr(10) || '	</silk:Screen>' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '</silk:App>',8,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CMF','Conceptual Model',NULL,NULL,2,1,0,0,0,'PRJ','fa-solid fa-book','#bc7e49',NULL,13,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CSF','Private Service',NULL,'.jsp',3,1,1,2,1,'SRV','fa-solid fa-satellite-dish','#81dafc','<%@page contentType="text/html;charset=UTF-8" import="com.oopsclick.silk.dbo.*,java.io.*" trimDirectiveWhitespaces="true" %>' || chr(13) || chr(10) || '<%' || chr(13) || chr(10) || '	' || chr(13) || chr(10) || '%>',10,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CSFP','Public Service',NULL,'.srv',3,1,1,2,1,'SRV','fa-solid fa-satellite-dish','#a0e7a0','<%@page contentType="text/html;charset=UTF-8" import="com.oopsclick.silk.dbo.*,java.io.*" trimDirectiveWhitespaces="true" %>' || chr(13) || chr(10) || '<%' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '%>',13,1);

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
	('EMAIL','Email Template',NULL,NULL,3,0,7,4,0,'SRV','fa-solid fa-envelope','#d8d8cf','{' || chr(13) || chr(10) || '  "head": {' || chr(13) || chr(10) || '    "silkEmaillID": "",' || chr(13) || chr(10) || '    "wrapper": "default.eml",' || chr(13) || chr(10) || '    "sentFrom": "",' || chr(13) || chr(10) || '    "replyTo": "",' || chr(13) || chr(10) || '    "copyTo": "",' || chr(13) || chr(10) || '    "blindTo": "",' || chr(13) || chr(10) || '    "emailUUID": ""' || chr(13) || chr(10) || '  },' || chr(13) || chr(10) || '  "body": [' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "langID": "en",' || chr(13) || chr(10) || '      "subject": "",' || chr(13) || chr(10) || '      "message": ""' || chr(13) || chr(10) || '    }' || chr(13) || chr(10) || '  ]' || chr(13) || chr(10) || '}',15,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('HTML','Document',NULL,NULL,3,1,2,0,0,'CMF,HTML','fa-solid fa-file','#eeeeee',NULL,16,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('MOD','App Module',NULL,'.jsp',3,0,1,2,1,'APP,CSF,PUB,CSFP','fa-solid fa-code','#e4e3a4','<silk:Module >' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '	<silk:Page id="xListPage" stage="A1"' || chr(13) || chr(10) || '		smLayout="A1"' || chr(13) || chr(10) || '		mdLayout="A1"' || chr(13) || chr(10) || '		rgLayout="A1:500px,A2"' || chr(13) || chr(10) || '		lgLayout="A1:500px,A2"' || chr(13) || chr(10) || '		xlLayout="A1:500px,A2"' || chr(13) || chr(10) || '		xxLayout="A1:500px,A2"' || chr(13) || chr(10) || '	>' || chr(13) || chr(10) || '		<silk:Head >' || chr(13) || chr(10) || '			List Attribute Title' || chr(13) || chr(10) || '		</silk:Head>' || chr(13) || chr(10) || '		<silk:Content>' || chr(13) || chr(10) || '			List content goes here...' || chr(13) || chr(10) || '		</silk:Content>' || chr(13) || chr(10) || '	</silk:Page>' || chr(13) || chr(10) || '		' || chr(13) || chr(10) || '	<silk:Page id="xFormPage" stage="A2"' || chr(13) || chr(10) || '		smLayout="A2:*:b"' || chr(13) || chr(10) || '		mdLayout="A2:*:b"' || chr(13) || chr(10) || '		rgLayout="A1:500px,A2"' || chr(13) || chr(10) || '		lgLayout="A1:500px,A2"' || chr(13) || chr(10) || '		xlLayout="A1:500px,A2"' || chr(13) || chr(10) || '		xxLayout="A1:500px,A2"' || chr(13) || chr(10) || '	>' || chr(13) || chr(10) || '		<silk:Head >' || chr(13) || chr(10) || '			Form Attribute Title' || chr(13) || chr(10) || '		</silk:Head>' || chr(13) || chr(10) || '		<silk:Content>' || chr(13) || chr(10) || '			Form content goes here...' || chr(13) || chr(10) || '		</silk: Content>' || chr(13) || chr(10) || '	</silk:Page>' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '	<silk:JScode>' || chr(13) || chr(10) || '	' || chr(13) || chr(10) || '	</silk:JScode>' || chr(13) || chr(10) || '	' || chr(13) || chr(10) || '	<silk:JQcode>' || chr(13) || chr(10) || '	' || chr(13) || chr(10) || '	</silk:JQcode>' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '</silk:Module >',9,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ORM','ORM Table Object',NULL,'.orm',3,1,4,1,1,'DMF','fa-solid fa-database','#ffc500','{' || chr(13) || chr(10) || '  "table": {' || chr(13) || chr(10) || '    "tableName": "",' || chr(13) || chr(10) || '    "pkMode": "Auto",' || chr(13) || chr(10) || '    "insertAuthorization": "",' || chr(13) || chr(10) || '    "updateAuthorization": "",' || chr(13) || chr(10) || '    "deleteAuthorization": "",' || chr(13) || chr(10) || '    "pkSql1": "",' || chr(13) || chr(10) || '    "dbType": "0",' || chr(13) || chr(10) || '    "description": ""' || chr(13) || chr(10) || '  },' || chr(13) || chr(10) || '  "column": [],' || chr(13) || chr(10) || '  "select": [],' || chr(13) || chr(10) || '  "operation": [],' || chr(13) || chr(10) || '  "authorization": [],' || chr(13) || chr(10) || '  "fk": [],' || chr(13) || chr(10) || '  "queryType": "SQL"' || chr(13) || chr(10) || '}',5,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ORMF','ORM Folder Object',NULL,'.orm',3,0,4,1,1,'DMF','fa-solid fa-database','#ffc500','{' || chr(13) || chr(10) || '  "table": {' || chr(13) || chr(10) || '    "tableName": "",' || chr(13) || chr(10) || '    "pkMode": "Auto",' || chr(13) || chr(10) || '    "insertAuthorization": "",' || chr(13) || chr(10) || '    "updateAuthorization": "",' || chr(13) || chr(10) || '    "deleteAuthorization": "",' || chr(13) || chr(10) || '    "pkSql1": "",' || chr(13) || chr(10) || '    "dbType": "0",' || chr(13) || chr(10) || '    "description": ""' || chr(13) || chr(10) || '  },' || chr(13) || chr(10) || '  "column": [' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "fileID",' || chr(13) || chr(10) || '      "type": "S",' || chr(13) || chr(10) || '      "columnTypeLabel": "String",' || chr(13) || chr(10) || '      "pk": 1,' || chr(13) || chr(10) || '      "id": "dbc9531a-5d90-4566-940d-e8ac1331c4fd",' || chr(13) || chr(10) || '      "_recordIndex": 0' || chr(13) || chr(10) || '    },' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "filePath",' || chr(13) || chr(10) || '      "type": "S",' || chr(13) || chr(10) || '      "columnTypeLabel": "String",' || chr(13) || chr(10) || '      "id": "3ca1cb96-85a8-4eac-a245-24a91b0321f2",' || chr(13) || chr(10) || '      "_recordIndex": 1' || chr(13) || chr(10) || '    },' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "folderPath",' || chr(13) || chr(10) || '      "type": "S",' || chr(13) || chr(10) || '      "columnTypeLabel": "String",' || chr(13) || chr(10) || '      "id": "d5b5033b-fb5c-4396-8598-849994ad0e05",' || chr(13) || chr(10) || '      "_recordIndex": 2' || chr(13) || chr(10) || '    },' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "fileName",' || chr(13) || chr(10) || '      "type": "S",' || chr(13) || chr(10) || '      "columnTypeLabel": "String",' || chr(13) || chr(10) || '      "id": "3200d087-34ff-400f-9e53-ad1a214364ba",' || chr(13) || chr(10) || '      "_recordIndex": 3' || chr(13) || chr(10) || '    },' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "size",' || chr(13) || chr(10) || '      "type": "I",' || chr(13) || chr(10) || '      "columnTypeLabel": "Integer",' || chr(13) || chr(10) || '      "id": "87b418d6-c94a-4f5f-a2d1-7ace4314b98a",' || chr(13) || chr(10) || '      "_recordIndex": 4' || chr(13) || chr(10) || '    },' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "type",' || chr(13) || chr(10) || '      "type": "S",' || chr(13) || chr(10) || '      "columnTypeLabel": "String",' || chr(13) || chr(10) || '      "id": "d4ca8037-3b37-4c58-a27a-05374f428535",' || chr(13) || chr(10) || '      "_recordIndex": 5' || chr(13) || chr(10) || '    },' || chr(13) || chr(10) || '    {' || chr(13) || chr(10) || '      "columnName": "content",' || chr(13) || chr(10) || '      "type": "S",' || chr(13) || chr(10) || '      "columnTypeLabel": "String",' || chr(13) || chr(10) || '      "id": "e97620de-4c48-427c-b624-0b5df329372c",' || chr(13) || chr(10) || '      "_recordIndex": 6' || chr(13) || chr(10) || '    }' || chr(13) || chr(10) || '  ],' || chr(13) || chr(10) || '  "select": [' || chr(13) || chr(10) || '    ' || chr(13) || chr(10) || '  ],' || chr(13) || chr(10) || '  "operation": [' || chr(13) || chr(10) || '    ' || chr(13) || chr(10) || '  ],' || chr(13) || chr(10) || '  "authorization": [' || chr(13) || chr(10) || '    ' || chr(13) || chr(10) || '  ],' || chr(13) || chr(10) || '  "fk": [' || chr(13) || chr(10) || '    ' || chr(13) || chr(10) || '  ],' || chr(13) || chr(10) || '  "queryType": "Folder"' || chr(13) || chr(10) || '}',5,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('OSL','Private Data Outlet',NULL,'.jsp',3,0,6,3,1,'SRV','fa-solid fa-plug','#81dafc','{"ormPath":"","selectName":"","parameter":""}',11,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('OSLP','Public Data Outlet',NULL,'.srv',3,0,6,3,1,'SRV','fa-solid fa-plug','#a0e7a0','ormPath:' || chr(13) || chr(10) || 'selectName:' || chr(13) || chr(10) || '',14,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('PRJ','Project',NULL,NULL,1,1,0,0,0,'ROOT','fa-solid fa-box-open','#FABC3C',NULL,1,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('PUB','Public App',NULL,'.srv',3,1,1,2,1,'SRV','fa-solid fa-rocket','#a0e7a0','<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>' || chr(13) || chr(10) || '<%@page contentType="text/html;charset=UTF-8" %>' || chr(13) || chr(10) || '<silk:App title="">' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '    <silk:Screen>' || chr(13) || chr(10) || '        <%@ include file="" %>' || chr(13) || chr(10) || '    </silk:Screen>' || chr(13) || chr(10) || '' || chr(13) || chr(10) || '</silk:App>',12,1);

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
create view vwSilkProjectService AS
select
	pr1.silkProjectID AS silkProjectID,
	pr1.silkSystemID AS silkSystemID,
	sys.systemName||'/'||pr2.projectName||'/'||pr1.projectName AS projectName
from silkproject pr1
join silkproject pr2 on pr1.parentID = pr2.silkProjectID
join silksystem sys on pr1.silkSystemID = sys.silkSystemID
where pr1.nodeType = 'SRV'
and pr1.status = 0;

-- ------------------------------------------------------
-- VIEW: silkVariable
-- ------------------------------------------------------
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
where tg.tagType=1
order by position;

-- ======================================================
-- SQL script end
-- ======================================================