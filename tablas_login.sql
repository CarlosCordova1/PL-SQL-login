
  CREATE TABLE "demo"."LGN_CONF" 
   (	"ID_CONF" NUMBER(*,0) NOT NULL ENABLE, 
	"KEY" VARCHAR2(200 BYTE), 
	"VALUE_KEY" VARCHAR2(200 BYTE), 
	"DESCRIPTION" VARCHAR2(1000 BYTE), 
	"OPCIONAL" VARCHAR2(1000 BYTE), 
	"STATUS" NUMBER(*,0) DEFAULT 1 NOT NULL ENABLE, 
	 CONSTRAINT "LGN_CONFIGUACION_PK" PRIMARY KEY ("ID_CONF")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo" ;
  
 -------------------------------------------------------------------------------------------
 
  CREATE TABLE "demo"."LGN_PERMISO" 
   (	"ID_PERMISO" NUMBER(*,0) NOT NULL ENABLE, 
	"ID_USER" NUMBER(*,0) NOT NULL ENABLE, 
	"ID_SERVICIO" NUMBER(*,0) NOT NULL ENABLE, 
	"ADMINISTRADOR" NUMBER(*,0) DEFAULT 0 NOT NULL ENABLE, 
	"GERENTE" NUMBER(*,0) DEFAULT 0 NOT NULL ENABLE, 
	"OPERATIVO" NUMBER(*,0) DEFAULT 0 NOT NULL ENABLE, 
	"SUPERVISOR" NUMBER(*,0) DEFAULT 0 NOT NULL ENABLE, 
	"INVITADO" NUMBER(*,0) DEFAULT 0 NOT NULL ENABLE, 
	"KEY" VARCHAR2(200 BYTE) DEFAULT 0, 
	"KEY_VALUE" NUMBER(*,0) DEFAULT 0, 
	"KEY_DESCRIPTION" VARCHAR2(2000 BYTE), 
	"FECHA" DATE, 
	"STATUS" NUMBER(*,0) DEFAULT 1 NOT NULL ENABLE, 
	 CONSTRAINT "LGN_PERMISO_PK" PRIMARY KEY ("ID_PERMISO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo" ;
  -------------------------------------------------------------------------------------------
 
   CREATE TABLE "demo"."LGN_SERVICIO" 
   (	"ID_SERVICIO" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SERVICIO" VARCHAR2(200 BYTE) NOT NULL ENABLE, 
	"DESCRIPCION" LONG, 
	"FECHA" DATE NOT NULL ENABLE, 
	"STATUS" NUMBER(*,0) DEFAULT 1 NOT NULL ENABLE, 
	 CONSTRAINT "LGN_SERVICIO_PK" PRIMARY KEY ("ID_SERVICIO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo" ;
 
  -------------------------------------------------------------------------------------------
   CREATE TABLE "demo"."LGN_USER" 
   (	"ID_USER" NUMBER(*,0) NOT NULL ENABLE, 
	"USER_LOGIN" VARCHAR2(200 BYTE) NOT NULL ENABLE, 
	"USER_PASS" NVARCHAR2(2000), 
	"USER_NICKNAME" VARCHAR2(200 BYTE), 
	"DISPLAY_NAME" VARCHAR2(200 BYTE), 
	"USER_EMAIL" VARCHAR2(200 BYTE), 
	"USER_REGISTRADO" DATE NOT NULL ENABLE, 
	"USER_LAST_CONEXION" DATE, 
	"USER_ACTIVATION_KEY" NVARCHAR2(2000), 
	"STATUS" NUMBER(*,0) DEFAULT 1 NOT NULL ENABLE, 
	 CONSTRAINT "LGN_USER_PK" PRIMARY KEY ("ID_USER")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo" ;
 
   -------------------------------------------------------------------------------------------
  
  
  CREATE TABLE "demo"."LGN_VARIABLE" 
   (	"IDVARIABLE" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"TIPOVAR" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"VALOR" VARCHAR2(500 BYTE) NOT NULL ENABLE, 
	"DESCRIPCION" VARCHAR2(500 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "LGN_VARIABLE_PK" PRIMARY KEY ("IDVARIABLE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "demo" ;
 
  -------------------------------------------------------------------------------------------
  
 
   CREATE SEQUENCE  "demo"."LGN_SQPER"  MINVALUE 1 MAXVALUE 99999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
   CREATE SEQUENCE  "demo"."LGN_SQUSE"  MINVALUE 1 MAXVALUE 99999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

  
  
  