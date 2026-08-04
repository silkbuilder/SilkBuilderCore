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
	silkSystemID int primary key generated always as identity,
	silkSystemUUID varchar(36),
	systemName varchar(100),
	theme varchar(50) default 'default',
	langList varchar(100) default ',en,',
	menuLink varchar(150),
	loginLink varchar(150),
	databaseList varchar(50),
	silkDatabaseID smallint default 0,
	testController varchar(50),
	testdb varchar(50),
	testdb1 varchar(50),
	testdb2 varchar(50),
	testdb3 varchar(50),
	testdb4 varchar(50),
	systemStatus smallint default 0,
	creationDate timestamp default CURRENT_TIMESTAMP,
	operationDate timestamp default CURRENT_TIMESTAMP,
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
	silkLangID int primary key generated always as identity,
	langID char(2),
	langName varchar(100),
	enName varchar(100),
	status smallint default 0
);

-- ------------------------------------------------------
-- TABLE: silkProject
-- ------------------------------------------------------
create table silkProject (
	silkProjectID int primary key generated always as identity,
	projectUUID varchar(36),
	silkSystemID int,
	parentID int,
	projectLevel smallint default 0,
	projectName varchar(100),
	nodeType varchar(10),
	content text,
	lastSyncID int,
	status smallint default 0,
	operationAction varchar(20),
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
	nodeType varchar(10) primary key,
	name varchar(50),
	fileName varchar(50),
	extension varchar(10),
	nodeLevel smallint default 0,
	parent smallint,
	editor smallint,
	saveMode smallint,
	import smallint,
	parentFilter varchar(20),
	iconName varchar(30),
	iconColor varchar(20),
	template text,
	recordOrder smallint default 0,
	sync smallint default 0
);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int primary key generated always as identity,
	silkSystemID int,
	parentID int,
	tagLevel smallint default 0,
	tagName varchar(50),
	tagType smallint default 0,
	tagIntValue smallint,
	content text,
	contentType smallint default 0,
	folderOnly smallint default 0,
	position smallint default 0,
	syncDate timestamp,
	operationAction varchar(20),
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
	silkTargetID int primary key generated always as identity,
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
	syncDate timestamp,
	operationAction varchar(20),
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
	silkTestingID int primary key generated always as identity,
	silkDeveloperID int,
	silkSystemID int,
	testName varchar(50),
	silkUserID varchar(50),
	variableList varchar(500),
	roleList varchar(500),
	position smallint default 0,
	foreign key (silkSystemID) references silkSystem (silkSystemID) on delete Cascade 
);

create index silkTesting_silkDeveloperID on silkTesting(silkDeveloperID);
create index silkTesting_silkSystemID on silkTesting(silkSystemID);

-- ------------------------------------------------------
-- TABLE: silkCodeHistory
-- ------------------------------------------------------
create table silkCodeHistory (
	silkCodeHistoryID int primary key generated always as identity,
	silkProjectID int,
	content text,
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
	silkSessionID int primary key generated always as identity,
	silkAccessID int,
	silkUserID int,
	ipAddress varchar(50),
	httpSession varchar(255),
	sessionToken varchar(500),
	sessionType smallint default 0,
	sessionDate timestamp,
	lastTransactionDate timestamp,
	deviceType varchar(20),
	userAgent varchar(255),
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
create or replace function readLanguage(dataText text, lang char(2))
   returns text
   language plpgsql
  as
$$
declare
	startTag varchar(20);
	endTag varchar(20);
	startPos smallint;
	endPos smallint;
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
	if position('<lang-' in dataText)=0 then
		return dataText;
	end if;

	-- 
	-- Creates received lang tag
	--
	startTag = concat('<lang-',lang,'>');
	endTag = concat('</lang-',lang,'>');

	--
	-- Search tag in dataText
	--
	startPos = position(startTag in dataText);
	
	if startPos=0 then
		--
		-- If lang does not exist search for english as base language
		--
		startTag = '<lang-en>';
		endTag = '</lang-en>';

		--
		-- Search tag in dataText
		--
		startPos = position(startTag in dataText);
	end if;

	if startPos=0 then
		--
		-- If lang does not exist search for any existing language
		--
		startPos = position('<lang-' in dataText);
		
		if startPos=0 then
			return '';
		end if;
		
		lang = substring(dataText,startPos+6,2);
		startTag = concat('<lang-',lang,'>');
		endTag = concat('</lang-',lang,'>');
		
	end if;	

	startPos = startPos+length(startTag);
	endPos = position(endTag in dataText)-startPos;
	
	return substring(dataText,startPos,endPos);
end;
$$;

--
-- Create writeLanguage Function
--
create or replace function writeLanguage(oldText text, dataText text, lang char(2))
   returns text
   language plpgsql
  as
$$
declare
	startTag varchar(20);
	endTag varchar(20);
	startPos smallint;
	endPos smallint;
begin

	-- -----------
	-- If old text is null it is set to empty.
	-- -----------
	oldText = coalesce(oldText,'');
	
	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if position('<lang-' in oldText)=0 then
		return oldText;
	end if;

	-- -----------
	-- Initializes the tag limits.
	-- -----------
	startTag = concat('<lang-',lang,'>');
	endTag = concat('</lang-',lang,'>');

	-- -----------
	-- Finds the position of the open lang tag.
	-- -----------
	startPos = position(startTag in oldText);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if startPos=0 then
		return concat(oldText,startTag,dataText,endTag);
	end if;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	startPos = startPos+length(startTag)-1;
	endPos = length(oldText) - position(endTag in oldText)+1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	return concat(left(oldText,startPos),dataText,right(oldText,endPos));

end;
$$;

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
	('APP','Private App',NULL,'.jsp',3,1,1,2,1,'SRV','fa-solid fa-rocket','#81dafc',E'<%@ taglib uri=\"/WEB-INF/silk.tld\" prefix=\"silk\" %>\n<%@page contentType=\"text/html;charset=UTF-8\" %>\n<silk:App title=\"\">\n\n	<silk:Screen>\n		<%@ include file=\"\" %>\n	</silk:Screen>\n\n</silk:App>',8,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CMF','Conceptual Model',NULL,NULL,2,1,0,0,0,'PRJ','fa-solid fa-book','#bc7e49',NULL,13,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CSF','Private Service',NULL,'.jsp',3,1,1,2,1,'SRV','fa-solid fa-satellite-dish','#81dafc',E'<%@page contentType=\"text/html;charset=UTF-8\" import=\"com.oopsclick.silk.dbo.*,java.io.*\" trimDirectiveWhitespaces=\"true\" %>\n<%\n	\n%>',10,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('CSFP','Public Service',NULL,'.srv',3,1,1,2,1,'SRV','fa-solid fa-satellite-dish','#a0e7a0',E'<%@page contentType=\"text/html;charset=UTF-8\" import=\"com.oopsclick.silk.dbo.*,java.io.*\" trimDirectiveWhitespaces=\"true\" %>\n<%\n\n%>',13,1);

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
	('EMAIL','Email Template',NULL,NULL,3,0,7,4,0,'SRV','fa-solid fa-envelope','#d8d8cf',E'{\n  \"head\": {\n    \"silkEmaillID\": \"\",\n    \"wrapper\": \"default.eml\",\n    \"sentFrom\": \"\",\n    \"replyTo\": \"\",\n    \"copyTo\": \"\",\n    \"blindTo\": \"\",\n    \"emailUUID\": \"\"\n  },\n  \"body\": [\n    {\n      \"langID\": \"en\",\n      \"subject\": \"\",\n      \"message\": \"\"\n    }\n  ]\n}',15,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('HTML','Document',NULL,NULL,3,1,2,0,0,'CMF,HTML','fa-solid fa-file','#eeeeee',NULL,16,0);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('MOD','App Module',NULL,'.jsp',3,0,1,2,1,'APP,CSF,PUB,CSFP','fa-solid fa-code','#e4e3a4',E'<silk:Module >\n\n	<silk:Page id=\"xListPage\" stage=\"A1\"\n		smLayout=\"A1\"\n		mdLayout=\"A1\"\n		rgLayout=\"A1:500px,A2\"\n		lgLayout=\"A1:500px,A2\"\n		xlLayout=\"A1:500px,A2\"\n		xxLayout=\"A1:500px,A2\"\n	>\n		<silk:Head >\n			List Attribute Title\n		</silk:Head>\n		<silk:Content>\n			List content goes here...\n		</silk:Content>\n	</silk:Page>\n		\n	<silk:Page id=\"xFormPage\" stage=\"A2\"\n		smLayout=\"A2:*:b\"\n		mdLayout=\"A2:*:b\"\n		rgLayout=\"A1:500px,A2\"\n		lgLayout=\"A1:500px,A2\"\n		xlLayout=\"A1:500px,A2\"\n		xxLayout=\"A1:500px,A2\"\n	>\n		<silk:Head >\n			Form Attribute Title\n		</silk:Head>\n		<silk:Content>\n			Form content goes here...\n		</silk: Content>\n	</silk:Page>\n\n	<silk:JScode>\n	\n	</silk:JScode>\n	\n	<silk:JQcode>\n	\n	</silk:JQcode>\n\n</silk:Module >',9,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ORM','ORM Table Object',NULL,'.orm',3,1,4,1,1,'DMF','fa-solid fa-database','#ffc500',E'{\n  \"table\": {\n    \"tableName\": \"\",\n    \"pkMode\": \"Auto\",\n    \"insertAuthorization\": \"\",\n    \"updateAuthorization\": \"\",\n    \"deleteAuthorization\": \"\",\n    \"pkSql1\": \"\",\n    \"dbType\": \"0\",\n    \"description\": \"\"\n  },\n  \"column\": [],\n  \"select\": [],\n  \"operation\": [],\n  \"authorization\": [],\n  \"fk\": [],\n  \"queryType\": \"SQL\"\n}',5,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('ORMF','ORM Folder Object',NULL,'.orm',3,0,4,1,1,'DMF','fa-solid fa-database','#ffc500',E'{\n  \"table\": {\n    \"tableName\": \"\",\n    \"pkMode\": \"Auto\",\n    \"insertAuthorization\": \"\",\n    \"updateAuthorization\": \"\",\n    \"deleteAuthorization\": \"\",\n    \"pkSql1\": \"\",\n    \"dbType\": \"0\",\n    \"description\": \"\"\n  },\n  \"column\": [\n    {\n      \"columnName\": \"fileID\",\n      \"type\": \"S\",\n      \"columnTypeLabel\": \"String\",\n      \"pk\": 1,\n      \"id\": \"dbc9531a-5d90-4566-940d-e8ac1331c4fd\",\n      \"_recordIndex\": 0\n    },\n    {\n      \"columnName\": \"filePath\",\n      \"type\": \"S\",\n      \"columnTypeLabel\": \"String\",\n      \"id\": \"3ca1cb96-85a8-4eac-a245-24a91b0321f2\",\n      \"_recordIndex\": 1\n    },\n    {\n      \"columnName\": \"folderPath\",\n      \"type\": \"S\",\n      \"columnTypeLabel\": \"String\",\n      \"id\": \"d5b5033b-fb5c-4396-8598-849994ad0e05\",\n      \"_recordIndex\": 2\n    },\n    {\n      \"columnName\": \"fileName\",\n      \"type\": \"S\",\n      \"columnTypeLabel\": \"String\",\n      \"id\": \"3200d087-34ff-400f-9e53-ad1a214364ba\",\n      \"_recordIndex\": 3\n    },\n    {\n      \"columnName\": \"size\",\n      \"type\": \"I\",\n      \"columnTypeLabel\": \"Integer\",\n      \"id\": \"87b418d6-c94a-4f5f-a2d1-7ace4314b98a\",\n      \"_recordIndex\": 4\n    },\n    {\n      \"columnName\": \"type\",\n      \"type\": \"S\",\n      \"columnTypeLabel\": \"String\",\n      \"id\": \"d4ca8037-3b37-4c58-a27a-05374f428535\",\n      \"_recordIndex\": 5\n    },\n    {\n      \"columnName\": \"content\",\n      \"type\": \"S\",\n      \"columnTypeLabel\": \"String\",\n      \"id\": \"e97620de-4c48-427c-b624-0b5df329372c\",\n      \"_recordIndex\": 6\n    }\n  ],\n  \"select\": [\n    \n  ],\n  \"operation\": [\n    \n  ],\n  \"authorization\": [\n    \n  ],\n  \"fk\": [\n    \n  ],\n  \"queryType\": \"Folder\"\n}',5,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('OSL','Private Data Outlet',NULL,'.jsp',3,0,6,3,1,'SRV','fa-solid fa-plug','#81dafc',E'{\"ormPath\":\"\",\"selectName\":\"\",\"parameter\":\"\"}',11,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('OSLP','Public Data Outlet',NULL,'.srv',3,0,6,3,1,'SRV','fa-solid fa-plug','#a0e7a0',E'{\"ormPath\":\"\",\"selectName\":\"\",\"parameter\":\"\"}',14,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('PRJ','Project',NULL,NULL,1,1,0,0,0,'ROOT','fa-solid fa-box-open','#FABC3C',NULL,1,1);

INSERT INTO silkNode (nodeType, name, fileName, extension, nodeLevel, parent, editor, saveMode, import, parentFilter, iconName, iconColor, template, recordOrder, sync)
VALUES
	('PUB','Public App',NULL,'.srv',3,1,1,2,1,'SRV','fa-solid fa-rocket','#a0e7a0',E'<%@ taglib uri=\"/WEB-INF/silk.tld\" prefix=\"silk\" %>\n<%@page contentType=\"text/html;charset=UTF-8\" %>\n<silk:App title=\"\">\n\n    <silk:Screen>\n        <%@ include file=\"\" %>\n    </silk:Screen>\n\n</silk:App>',12,1);

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
	concat(sys.systemName,'/',pr2.projectName,'/',pr1.projectName) AS projectName
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