CREATE OR REPLACE PACKAGE API_PQLGN_1_0 AS 
gobj json;
 function INVOCA(pjsontxt VARCHAR2) return clob;
END API_PQLGN_1_0;
/


CREATE OR REPLACE PACKAGE BODY API_PQLGN_1_0 AS
/*  __________________________________________________________________________________________________  */

	FUNCTION VJSON (pjsontxt in varchar2) RETURN boolean IS
		scanner_exception exception;
		pragma exception_init(scanner_exception, -20100);
		parser_exception exception;
		pragma exception_init(parser_exception, -20101);
		jext_exception exception;
		pragma exception_init(jext_exception, -20110);
	BEGIN
		gobj:=json(pjsontxt);
		return true;
	EXCEPTION
		when scanner_exception or parser_exception or jext_exception then return false;
	END;
/*  __________________________________________________________________________________________________  */

	PROCEDURE DATAVARAPI (pvar in  LGN_VARIABLE.IDVARIABLE%TYPE,
					      pval out APP.LGN_VARIABLE.VALOR%TYPE,
						  pdes out APP.LGN_VARIABLE.DESCRIPCION%TYPE) IS
	BEGIN
		select trim(valor),trim(descripcion) into pval,pdes from APP.LGN_VARIABLE where IDVARIABLE=pvar;
	EXCEPTION
		when NO_DATA_FOUND then
			pval:=null;	pdes:=null;
		when OTHERS then
			pval:=null;	pdes:=null;
	END;
/*  __________________________________________________________________________________________________  */

	FUNCTION JMSGERR (pcgo in varchar2) RETURN varchar2 IS
		vmsg APP.LGN_VARIABLE.VALOR%TYPE;
		vdes APP.LGN_VARIABLE.DESCRIPCION%TYPE;
	BEGIN
		gobj:=json();
    gobj.put('status',0);
		gobj.put('code',pcgo);
		datavarapi(pcgo,vmsg,vdes);
		gobj.put('msg',nvl(vmsg,'null'));
		gobj.put('description',nvl(vdes,'null'));		
		RETURN '['||gobj.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */
--funciones de configuracion para el json
/*  __________________________________________________________________________________________________  */

	FUNCTION ValidaToken(token in varchar2)  RETURN boolean is
            --desdifrar VARCHAR2(4000);
            fecha varchar2(40);
            jsontoken json;
            BEGIN
            jsontoken:=json(token);
           
            --desdifrar:=UTILERIA_CIFRAR.DESCIFRAR(token);
          --if not vjson(desdifrar) then return false; end if;
        
		fecha:=json_ext.get_string(jsontoken,'timeNow');
     if fecha is null then return false; else
     
    if fecha=to_char(SYSDATE) then 
     return true;
     else return false; end if; 
     end if;
      --RETURN true;
    EXCEPTION
		when OTHERS then
			return false;    
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */

	FUNCTION ShowTable (vmin in number,vmax in number) RETURN clob is
   cadena long;
   cantidadPregunta number(8):=0;
        cont number(8):=0; cont2 number(8):=0;
  CURSOR c_servicio is
   /* SELECT 
            LGN_USER.ID_USER as id,
             LGN_USER.USER_EMAIL as email,
            LGN_USER.DISPLAY_NAME as username,
            LGN_USER.DISPLAY_NAME as cliente,
            LGN_USER.DISPLAY_NAME as factura,
            TO_CHAR(LGN_USER.USER_REGISTRADO,'DD/MM/YYYY') as fechaCreacion,
            TO_CHAR(LGN_USER.USER_LAST_CONEXION,'DD/MM/YYYY HH24:MI:SS') as fechaFin,
       
            LGN_USER.status  as edicion
     FROM
        LGN_USER 

        WHERE
        LGN_USER.status = 1;
        */
        
        
              select 
    * 
from 
    ( select 
          ROWNUM rn, a.*
      from 
        (    SELECT 
            LGN_USER.ID_USER as id,
             LGN_USER.USER_EMAIL as email,
            LGN_USER.DISPLAY_NAME as username,
            LGN_USER.DISPLAY_NAME as cliente,
            LGN_USER.DISPLAY_NAME as factura,
            TO_CHAR(LGN_USER.USER_REGISTRADO,'DD/MM/YYYY') as fechaCreacion,
            TO_CHAR(LGN_USER.USER_LAST_CONEXION,'DD/MM/YYYY HH24:MI:SS') as fechaFin,
       
            LGN_USER.status  as edicion
     FROM
        LGN_USER 

        WHERE
        LGN_USER.status = 1 ) a 
      where 
        ROWNUM <= vmax
    ) 
where 
    rn>= vmin;
        
        
        
	BEGIN

   FOR indice IN c_servicio LOOP
   cont:=cont+1;
   END LOOP;
         FOR indice IN c_servicio LOOP
         cont2:=cont2+1;
       gobj:=json();
           gobj.put('id',indice.id);
             gobj.put('email',indice.email);
      gobj.put('name',indice.username);
    
       SELECT COUNT (*) tot into cantidadPregunta
                  FROM LGN_PERMISO
                  JOIN LGN_USER ON LGN_USER.ID_USER=indice.id 
                 JOIN LGN_SERVICIO ON LGN_PERMISO.ID_SERVICIO=LGN_SERVICIO.ID_SERVICIO 
                   WHERE LGN_PERMISO.ID_USER=LGN_USER.ID_USER AND LGN_USER.STATUS=1 AND LGN_SERVICIO.STATUS=1  and  LGN_PERMISO.STATUS=1;
                                     
       gobj.put('cantidadServicio',cantidadPregunta);
        gobj.put('fechaCreacion',indice.fechaCreacion);
          gobj.put('fechaFin',indice.fechaFin);    
         if cont=cont2 then 
       cadena:=cadena||gobj.to_char()||'';
       else 
       cadena:=cadena||gobj.to_char()||',';
       end if;
   
          END LOOP;
		RETURN '['||cadena||']';
	END;
/*  __________________________________________________________________________________________________  */

/*  __________________________________________________________________________________________________  */

	FUNCTION ShowTableServicio  RETURN clob is
  
	cadena			clob;
	temp			json;
	temp2			json;
	respuesta		json;
	datacliente		json;
    CURSOR C_uso IS
  SELECT * FROM LGN_SERVICIO  ORDER BY TO_NUMBER(ID_SERVICIO) DESC;
			BEGIN
        temp2 :=json();
   FOR ind IN C_uso LOOP
          temp :=json();
             temp.put('ID',ind.ID_SERVICIO);
              temp.put('SERVICIO',ind.SERVICIO);
              temp.put('DESCRIPCION',ind.DESCRIPCION);

                temp.put('STATUS',ind.STATUS );
           
           
              temp2.put(ind.ID_SERVICIO,temp);

         END LOOP;

	respuesta :=json();
	respuesta.put('SERVICIOS',temp2);
	--respuesta.put('datacliente',datacliente);
	respuesta.put('status',1);
	respuesta.put('msg','todo ok');

	cadena := empty_clob();
	dbms_lob.createtemporary(cadena, true);
	respuesta.to_clob(cadena, true);
	--dbms_output.put_line(cadena);
	--dbms_lob.freetemporary(cadena);
	RETURN '['||cadena||']';
EXCEPTION
	when NO_DATA_FOUND then
		respuesta:=json();
		respuesta.put('status',0);
		respuesta.put('msg','No se encontro datos');
		return '['||respuesta.to_char()||']';
	when OTHERS then
		respuesta:=json();
		respuesta.put('msg','ocurrio un error.'|| ' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace );
		respuesta.put('error',SQLERRM);
		respuesta.put('lineaError',' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace);
		respuesta.put('status',0);
		return '['||respuesta.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */

	FUNCTION ShowTableServicioBYCliente(Vusuario in number)  RETURN clob is
  
	cadena			clob;
	temp			json;
	temp2			json;
	respuesta		json;
	datacliente		json;
    CURSOR C_uso IS
 SELECT B.*,(SELECT A.STATUS FROM LGN_PERMISO A WHERE A.ID_USER=Vusuario AND A.ID_SERVICIO =B.ID_SERVICIO) PERMISO,
 (SELECT A.ADMINISTRADOR FROM LGN_PERMISO A WHERE A.ID_USER=Vusuario AND A.ID_SERVICIO =B.ID_SERVICIO) ADMINISTRADOR,
      (SELECT A.GERENTE FROM LGN_PERMISO A WHERE A.ID_USER=Vusuario AND A.ID_SERVICIO =B.ID_SERVICIO) GERENTE,
       (SELECT A.OPERATIVO FROM LGN_PERMISO A WHERE A.ID_USER=Vusuario AND A.ID_SERVICIO =B.ID_SERVICIO) OPERATIVO,
        (SELECT A.SUPERVISOR FROM LGN_PERMISO A WHERE A.ID_USER=Vusuario AND A.ID_SERVICIO =B.ID_SERVICIO) SUPERVISOR,
        (SELECT A.INVITADO FROM LGN_PERMISO A WHERE A.ID_USER=Vusuario AND A.ID_SERVICIO =B.ID_SERVICIO) INVITADO
 FROM LGN_SERVICIO B;
			BEGIN
        temp2 :=json();
   FOR ind IN C_uso LOOP
          temp :=json();
             temp.put('ID',ind.ID_SERVICIO);
              temp.put('SERVICIO',ind.SERVICIO);
              temp.put('DESCRIPCION',ind.DESCRIPCION);
                temp.put('STATUS',ind.STATUS );
                 temp.put('permiso',ind.PERMISO );
                 temp.put('ADMINISTRADOR',ind.ADMINISTRADOR );
                 temp.put('GERENTE',ind.GERENTE );
                 temp.put('OPERATIVO',ind.OPERATIVO );
                  temp.put('SUPERVISOR',ind.SUPERVISOR );
                   temp.put('INVITADO',ind.INVITADO );
           
           
              temp2.put(ind.ID_SERVICIO,temp);

         END LOOP;

	respuesta :=json();
	respuesta.put('SERVICIOSbyUSER',temp2);
	--respuesta.put('datacliente',datacliente);
	respuesta.put('status',1);
	respuesta.put('msg','todo ok');

	cadena := empty_clob();
	dbms_lob.createtemporary(cadena, true);
	respuesta.to_clob(cadena, true);
	--dbms_output.put_line(cadena);
	--dbms_lob.freetemporary(cadena);
	RETURN '['||cadena||']';
EXCEPTION
	when NO_DATA_FOUND then
		respuesta:=json();
		respuesta.put('status',0);
		respuesta.put('msg','No se encontro datos');
		return '['||respuesta.to_char()||']';
	when OTHERS then
		respuesta:=json();
		respuesta.put('msg','ocurrio un error.'|| ' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace );
		respuesta.put('error',SQLERRM);
		respuesta.put('lineaError',' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace);
		respuesta.put('status',0);
		return '['||respuesta.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */
	FUNCTION agregarServicioLGN(nombre in varchar2,descripcion in varchar2)  RETURN varchar2 is
  
	cadena			clob;
	temp			json;
	temp2			json;
	respuesta		json;
	datacliente		json;
  total number(10):=0;
    			BEGIN
        temp2 :=json();
        	respuesta :=json();
SELECT count(*) into total  FROM LGN_SERVICIO where SERVICIO IN (LOWER(nombre)) ;
IF total=0 THEN
insert into LGN_SERVICIO (ID_SERVICIO,SERVICIO,DESCRIPCION,FECHA,STATUS)
values ((SELECT max(TO_NUMBER(ID_SERVICIO))+1 FROM LGN_SERVICIO),LOWER(nombre),LOWER(descripcion),SYSDATE,1);
COMMIT;
respuesta.put('status',1);
	respuesta.put('msg','todo ok');
ELSE
respuesta.put('status',0);
	respuesta.put('msg','YA EXISTE SERVICIO');
END IF;



	respuesta.put('SERVICIOS',temp2);
	respuesta.put('nombre',nombre);
  respuesta.put('descripcion',descripcion);
	

	cadena := empty_clob();
	dbms_lob.createtemporary(cadena, true);
	respuesta.to_clob(cadena, true);
	--dbms_output.put_line(cadena);
	--dbms_lob.freetemporary(cadena);
	RETURN '['||cadena||']';
EXCEPTION
	when NO_DATA_FOUND then
		respuesta:=json();
		respuesta.put('status',0);
		respuesta.put('msg','No se encontro datos');
		return '['||respuesta.to_char()||']';
	when OTHERS then
		respuesta:=json();
		respuesta.put('msg','ocurrio un error.'|| ' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace );
		respuesta.put('error',SQLERRM);
		respuesta.put('lineaError',' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace);
		respuesta.put('status',0);
		return '['||respuesta.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */
	FUNCTION agregarServicioto_user( Vusuario in number,  Vservicio in number,  	Vcheked in VARCHAR2)  RETURN clob is
  
	cadena			clob;
	temp			json;
	temp2			json;
	respuesta		json;
	datacliente		json;
  total number(10):=0;
  total2 number(10):=0;
    			BEGIN
        temp2 :=json();
        	respuesta :=json();
          
SELECT count(*) total into total  FROM LGN_PERMISO where ID_USER =Vusuario and ID_SERVICIO =Vservicio;

 if total =0 then 
 INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,FECHA,STATUS) 
       VALUES (LGN_SQPER.NEXTVAL,Vusuario,Vservicio,SYSDATE,1);
           COMMIT;
           respuesta.put('accion','agregado');
    else
    SELECT count(*) total2 into total2 FROM LGN_PERMISO where ID_USER =Vusuario and ID_SERVICIO =Vservicio and STATUS in (1,0);
    if total2 !=0 then 
    if Vcheked='true' then    
    update LGN_PERMISO set STATUS=1  where ID_USER =Vusuario and ID_SERVICIO =Vservicio ;
     COMMIT;
    else
     update LGN_PERMISO set STATUS=0  where ID_USER =Vusuario and ID_SERVICIO =Vservicio ;
     respuesta.put('accion','cambio de estatus a 0');
     COMMIT;
      end if;
    end if;
    end if;
 
 

respuesta.put('status',1);
	respuesta.put('msg','todo ok');
  
  respuesta.put('servicio','agregaservicioPermisostouser');
 



	respuesta.put('AgregarServicio',temp2);
	respuesta.put('Vservicio',Vservicio);
  respuesta.put('Vusuario',Vusuario);
  respuesta.put('Vcheked',Vcheked);
	

	cadena := empty_clob();
	dbms_lob.createtemporary(cadena, true);
	respuesta.to_clob(cadena, true);
	--dbms_output.put_line(cadena);
	--dbms_lob.freetemporary(cadena);
	RETURN '['||cadena||']';
EXCEPTION
	when NO_DATA_FOUND then
		respuesta:=json();
		respuesta.put('status',0);
		respuesta.put('msg','No se encontro datos');
		return '['||respuesta.to_char()||']';
	when OTHERS then
		respuesta:=json();
		respuesta.put('msg','ocurrio un error.'|| ' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace );
		respuesta.put('error',SQLERRM);
		respuesta.put('lineaError',' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace);
		respuesta.put('status',0);
		return '['||respuesta.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */
	FUNCTION agregarServicioto_user_rol( Vusuario in number,  Vservicio in number,  	Vcheked in VARCHAR2,Vroles in VARCHAR2)  RETURN clob is
  
	cadena			clob;
	temp			json;
	temp2			json;
	respuesta		json;
	datacliente		json;
  total number(10):=0;
  total2 number(10):=0;
    			BEGIN
        temp2 :=json();
        	respuesta :=json();
          
SELECT count(*) total into total  FROM LGN_PERMISO where ID_USER =Vusuario and ID_SERVICIO =Vservicio;

 if total =0 then 
        /* INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,FECHA,STATUS) 
       VALUES (LGN_SQPER.NEXTVAL,Vusuario,Vservicio,SYSDATE,1);
           COMMIT;
           */
           respuesta.put('accion','usuario o servicio no existe');
    else
    SELECT count(*) total2 into total2 FROM LGN_PERMISO where ID_USER =Vusuario and ID_SERVICIO =Vservicio and STATUS in (1,0);
    if total2 !=0 then 
    if Vcheked='true' then   
    
    if Vroles='ADMINISTRADOR' then
    update LGN_PERMISO set ADMINISTRADOR=1 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
      if Vroles='GERENTE' then
    update LGN_PERMISO set GERENTE=1 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
       if Vroles='OPERATIVO' then
    update LGN_PERMISO set OPERATIVO=1 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
       if Vroles='SUPERVISOR' then
    update LGN_PERMISO set SUPERVISOR=1 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
     if Vroles='INVITADO' then
    update LGN_PERMISO set INVITADO=1 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;   
    
     respuesta.put('accion','cambio de estatus a 1 el rol de > ' || Vroles);
  
  
    else
      if Vroles='ADMINISTRADOR' then
    update LGN_PERMISO set ADMINISTRADOR=0 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
      if Vroles='GERENTE' then
    update LGN_PERMISO set GERENTE=0 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
       if Vroles='OPERATIVO' then
    update LGN_PERMISO set OPERATIVO=0 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
       if Vroles='SUPERVISOR' then
    update LGN_PERMISO set SUPERVISOR=0 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
     if Vroles='INVITADO' then
    update LGN_PERMISO set INVITADO=0 where  ID_USER =Vusuario and ID_SERVICIO =Vservicio;
     COMMIT;
    end if;
    respuesta.put('accion','cambio de estatus a 0 el rol de > ' || Vroles);
     COMMIT;
      end if;
    end if;
    end if;
 
 

respuesta.put('status',1);
	respuesta.put('msg','todo ok');
  
  respuesta.put('servicio','agregaservicioPermisostouser');
 



	respuesta.put('AgregarServicio',temp2);
	respuesta.put('Vservicio',Vservicio);
  respuesta.put('Vusuario',Vusuario);
  respuesta.put('Vcheked',Vcheked);
	

	cadena := empty_clob();
	dbms_lob.createtemporary(cadena, true);
	respuesta.to_clob(cadena, true);
	--dbms_output.put_line(cadena);
	--dbms_lob.freetemporary(cadena);
	RETURN '['||cadena||']';
EXCEPTION
	when NO_DATA_FOUND then
		respuesta:=json();
		respuesta.put('status',0);
		respuesta.put('msg','No se encontro datos');
		return '['||respuesta.to_char()||']';
	when OTHERS then
		respuesta:=json();
		respuesta.put('msg','ocurrio un error.'|| ' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace );
		respuesta.put('error',SQLERRM);
		respuesta.put('lineaError',' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace);
		respuesta.put('status',0);
		return '['||respuesta.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */

/*  __________________________________________________________________________________________________  */

	FUNCTION ShowServicios(idusuario in number)  RETURN varchar2 is
   cadena long;
        cont number(8):=0; cont2 number(8):=0;
  CURSOR c_Servicio is
  --SELECT Servicio,descripcion FROM LGN_SERVICIO where ID_SERVICIO=idusuario and status=1;
                  SELECT LGN_SERVICIO.Servicio,LGN_SERVICIO.descripcion
                  FROM LGN_SERVICIO
                  JOIN LGN_PERMISO ON LGN_PERMISO.ID_USER=idusuario 
                  WHERE LGN_SERVICIO.ID_SERVICIO=LGN_PERMISO.ID_SERVICIO AND LGN_SERVICIO.STATUS=1  and  LGN_PERMISO.STATUS=1;
        
	BEGIN
   FOR indice IN c_Servicio LOOP
   cont:=cont+1;
   END LOOP;
         FOR indice IN c_Servicio LOOP
        gobj:=json();
        cont2:=cont2+1;
           gobj.put('servicio',indice.Servicio);   
            gobj.put('descripcion',indice.descripcion);   
         if cont=cont2 then 
       cadena:=cadena||gobj.to_char()||'';
       else 
       cadena:=cadena||gobj.to_char()||',';
       end if;
   
          END LOOP;
		RETURN '['||cadena||']';
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */

	FUNCTION agregar (token IN VARCHAR2,datosusuario json,datoinfo IN VARCHAR2,
   Dnombre in varchar2,Dlogin in varchar2,Demail in varchar2,cifrarPassword in varchar2,
    LGNservico in VARCHAR2,LGNroles in VARCHAR2,Demail2 in varchar2
  
  
  ) RETURN varchar2 IS
		 PRAGMA AUTONOMOUS_TRANSACTION;
     total number(10);
           descifrar VARCHAR2(4000);
          
            iduser number(10);
            Jdescifrar json_list;
            Jd json;
            /*Demail VARCHAR2(200);
             Dlogin VARCHAR2(200);
              cifrarPassword VARCHAR2(2000);
              Dnombre VARCHAR2(2000);
              Dpass VARCHAR2(2000);
              LGNservico VARCHAR2(10);
              LGNroles VARCHAR2(50);*/
	BEGIN
  descifrar:=UTILERIA_CIFRAR.DESCIFRAR(token);
  if ValidaToken(descifrar) then
  case	
	-----------------------------------------------------------------------
			when datoinfo='usuario'	then 
      --Jd:= json(datosusuario);
    --Jdescifrar:= json_list(datosusuario);
      /*	Dnombre:=json_ext.get_string(datosusuario,'lgnNombre');
        Dlogin:=json_ext.get_string(datosusuario,'lgnUsuario');
         Dpass:=json_ext.get_string(datosusuario,'lgnPassw');
     	Demail:=json_ext.get_string(datosusuario,'lgnEmail');
      cifrarPassword:=UTILERIA_CIFRAR.CIFRAR(Dpass);*/
      gobj:=json();
    
    gobj.put('usuario',datoinfo);
	  
      DECLARE
      TOTAL number (10):=0;      
      BEGIN
      SELECT COUNT(*) AS TOT INTO TOTAL FROM  LGN_USER WHERE USER_LOGIN=Dlogin OR USER_EMAIL=Demail;
      IF TOTAL !=0 THEN 
      gobj.put('status',0);
       gobj.put('msg','El usuario o Email ya existe.');
       ELSE
       
        INSERT INTO LGN_USER (ID_USER,USER_LOGIN,USER_PASS,DISPLAY_NAME,USER_EMAIL,USER_REGISTRADO) 
        VALUES (LGN_SQUSE.NEXTVAL,Dlogin,cifrarPassword,dnombre,Demail,SYSDATE);
           COMMIT;
       gobj.put('msg','El E-mail '||Demail||' se ha agregado.');
        gobj.put('mail',Demail);
        gobj.put('status',1);
       END IF;
      END;
      
     			
		RETURN '['||gobj.to_char()||']';
    -----------------------------------------------------------------------
    	-----------------------------------------------------------------------
			when datoinfo='permisos'	then 
      --Jd:= json(datosusuario);
    --Jdescifrar:= json_list(datosusuario);
      /*	LGNservico:=json_ext.get_string(datosusuario,'LGNservico');
        LGNroles:=json_ext.get_string(datosusuario,'LGNroles');
         --Dpass:=json_ext.get_string(datosusuario,'lgnPassw');
     	Demail:=json_ext.get_string(datosusuario,'mail');*/
      --cifrarPassword:=UTILERIA_CIFRAR.CIFRAR(Dpass);
      gobj:=json();
    
    gobj.put('usuario',datoinfo);
	  
      DECLARE
      TOTAL number (10):=0;
       USERID  APP.LGN_USER.ID_USER%TYPE;
      BEGIN
      --SELECT ID_USER  INTO USERID FROM  LGN_USER WHERE USER_EMAIL=Demail2;
       SELECT ID_USER  INTO USERID FROM  LGN_USER WHERE USER_LOGIN=Demail2;
      --SELECT COUNT(*) AS TOT INTO TOTAL FROM  LGN_USER WHERE USER_EMAIL=Demail2;
      SELECT  COUNT(*) AS TOT INTO TOTAL   FROM  LGN_PERMISO 
WHERE ID_USER=USERID AND ID_SERVICIO=TO_NUMBER(LGNservico);
      IF TOTAL =0 THEN 
      CASE
      --------------------------------------------------------------------------------
      WHEN  LGNroles='ADMINISTRADOR' THEN
       INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,ADMINISTRADOR,INVITADO,FECHA) 
       VALUES (LGN_SQPER.NEXTVAL,USERID,TO_NUMBER(LGNservico),1,0,SYSDATE);
           COMMIT;
     --------------------------------------------------------------------------------
      WHEN  LGNroles='GERENTE' THEN
       INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,GERENTE,INVITADO,FECHA) 
       VALUES (LGN_SQPER.NEXTVAL,USERID,TO_NUMBER(LGNservico),1,0,SYSDATE);
           COMMIT;
      --------------------------------------------------------------------------------
      WHEN  LGNroles='OPERATIVO' THEN
       INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,OPERATIVO,INVITADO,FECHA) 
       VALUES (LGN_SQPER.NEXTVAL,USERID,TO_NUMBER(LGNservico),1,0,SYSDATE);
           COMMIT;
       --------------------------------------------------------------------------------
      WHEN  LGNroles='INVITADO' THEN
       INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,INVITADO,FECHA) 
       VALUES (LGN_SQPER.NEXTVAL,USERID,TO_NUMBER(LGNservico),1,SYSDATE);
           COMMIT;
             --------------------------------------------------------------------------------
      WHEN  LGNroles='KEY' THEN
       INSERT INTO LGN_PERMISO (ID_PERMISO,ID_USER,ID_SERVICIO,KEY_VALUE,INVITADO,FECHA) 
       VALUES (LGN_SQPER.NEXTVAL,USERID,TO_NUMBER(LGNservico),1,0,SYSDATE);
           COMMIT;
      END CASE;
     
      
      gobj.put('status',1);
       gobj.put('msg','El permiso se agrego');
       gobj.put('permisoagrgado',LGNroles);
       ELSE
       
       -- INSERT INTO LGN_USER (ID_USER,USER_LOGIN,USER_PASS,DISPLAY_NAME,USER_EMAIL,USER_REGISTRADO) 
       -- VALUES (20,Dlogin,cifrarPassword,dnombre,Demail,SYSDATE);
         --  COMMIT;
       --gobj.put('msg','El permiso para  '||Demail||' se ha actualizado.');
        gobj.put('msg','Ya se ha agreado un permiso para '||Demail2||'...');
        gobj.put('mail',Demail);
        gobj.put('status',0);
       END IF;
      END;
      
     			
		RETURN '['||gobj.to_char()||']';
    -----------------------------------------------------------------------
      else
      gobj:=json();
    gobj.put('status',0);
	   gobj.put('msg','no se encontro info');			
		RETURN '['||gobj.to_char()||']';
		end case;
  -----------------------------------------------------------------------
		else
    gobj:=json();
    gobj.put('status',0);
		 gobj.put('msg','token Expirado');
    	
		RETURN '['||gobj.to_char()||']';
    END IF;
    EXCEPTION
    	when NO_DATA_FOUND then
        gobj:=json();
        	gobj.put('msg','No se encontro datos');
			--gobj.put('error',SQLERRM);
    gobj.put('status',0);
    RETURN '['||gobj.to_char()||']';
		when OTHERS then
			gobj:=json();
    gobj.put('status',0);
      gobj.put('datosPermisos',datosusuario);
		 gobj.put('msg','Ocurrio EXCEPTION ');
     gobj.put('error',SQLERRM);
    			
		RETURN '['||gobj.to_char()||']';
	END;
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */

	FUNCTION buscar_usuario (usuario in varchar2, passw in varchar2) RETURN varchar2 IS
	     PRAGMA AUTONOMOUS_TRANSACTION;
      identificador    LGN_USER.ID_USER%TYPE;
     mail    LGN_USER.USER_EMAIL%TYPE;
      nameusuario    LGN_USER.DISPLAY_NAME%TYPE;
      F_resgistro    LGN_USER.USER_REGISTRADO%TYPE;
       Serv    LGN_SERVICIO.SERVICIO%TYPE;
           cadena long;    lista json_list;
       
       -- CURSOR c_x7 is
       -- SELECT trim(NOM) n FROM  X7.AGT where IDTAGT='2158';
        --SELECT USER_EMAIL as n from  APP.LGN_USER;
        --select * from webx7.www_infoclient_view where CLIENTE='231231';
        --select * from x7.agt where nomcnx='MCALAN';
        -- select * from x7.fct;
        --SELECT * FROM  X7.AGT 
--select * from x7.fct;
--select * from x7.prf;
--select * from x7.hbl;
	permisosjson json ;  serviciosjson json ;
	BEGIN
    	gobj:=json();  serviciosjson:=json();
      ----------------------------busco usuario
     SELECT id_user,USER_EMAIL,DISPLAY_NAME,TO_CHAR(USER_REGISTRADO,'DD/MM/YYYY') 
      into identificador,mail,nameusuario,F_resgistro 
      from APP.LGN_USER  
      WHERE (USER_EMAIL=usuario OR USER_LOGIN=usuario) and (USER_PASS=passw OR USER_PASS=UTILERIA_CIFRAR.CIFRAR(passw));
      
      IF identificador  IS NOT NULL THEN
      UPDATE LGN_USER SET USER_LAST_CONEXION=SYSDATE WHERE ID_USER=identificador;
      COMMIT;
      END IF;
      
     DECLARE 
       ----------------------------busco PERMISOS
    CURSOR C_permisos IS SELECT ID_SERVICIO,ADMINISTRADOR,OPERATIVO,SUPERVISOR,INVITADO,KEY,KEY_VALUE,KEY_DESCRIPTION
      --into lgn_Admin,lgn_Operativo,lgn_Supervis,lgn_Invitado,lgn_Key,lgn_Key_value,lgn_Key_descrip
      from APP.LGN_PERMISO  
      WHERE ID_USER=identificador;
     -- contar NUMBER(10):=0;
           BEGIN         
        FOR indice IN C_permisos LOOP
       -- contar:=contar+1;
        permisosjson:=json();
      
        permisosjson.put('admin',indice.ADMINISTRADOR);
        permisosjson.put('supervisor',indice.SUPERVISOR);
      permisosjson.put('operativo',indice.OPERATIVO);
       permisosjson.put('invitado',indice.INVITADO);
        permisosjson.put('key',indice.KEY);
         permisosjson.put('key_value',indice.KEY_VALUE);
          permisosjson.put('key_description',indice.KEY_DESCRIPTION);
                
               DECLARE 
                SERV    LGN_SERVICIO.SERVICIO%TYPE;
                begin
                  SELECT SERVICIO  INTO SERV   from APP.LGN_SERVICIO   WHERE ID_SERVICIO=indice.ID_SERVICIO;
                   serviciosjson.put(SERV,permisosjson);   
                 END;
                    
   END LOOP;
      END;  
      
               DECLARE 
                IDTAGT_ID    X7.AGT.IDTAGT%TYPE;
                begin
                  SELECT IDTAGT INTO IDTAGT_ID FROM X7.AGT WHERE nomcnx=upper(usuario) OR EMAIL=usuario OR EMAIL=upper(usuario) ;
                   gobj.put('IDTAGT',IDTAGT_ID);   
                   EXCEPTION 
                	when NO_DATA_FOUND then
                  gobj.put('IDTAGT',IDTAGT_ID); 
                 END;
      
      
      gobj.put('status',1);   
       --lista.append(''||gobj.to_char()||'');
        gobj.put('iduser',identificador);
       gobj.put('mail',mail);
       gobj.put('display_name',nameusuario);
        gobj.put('fechaRegistro',F_resgistro);
         gobj.put('servicios',serviciosjson);
          gobj.put('timeNow',sysdate);
          --gobj:=json();
          -- lista.append(Permi);
         --gobj.put('oratkn descifrado',UTILERIA_CIFRAR.DESCIFRAR('B6874EA7027FFA533F8A9D8004174B85'));
         gobj.put('oratkn',UTILERIA_CIFRAR.CIFRAR(gobj.to_char()));
         cadena:='['||gobj.to_char()||']';
      --cadena:='['||gobj.to_char()||','||gobj.to_char()||']';
		RETURN cadena;
	EXCEPTION 
		when NO_DATA_FOUND then
    return jmsgerr('LGN0004');
    /*gobj:=json();
        	gobj.put('msg','Por favor reporte este error al adminitrador de la aplicacion');
				gobj.put('usuario',usuario);
      gobj.put('pass',passw);
    gobj.put('status','0');
     RETURN '['||gobj.to_char()||']';
     */
     	when OTHERS then
		gobj:=json();
        	gobj.put('msg','Por favor reporte este error al adminitrador de la aplicacion');
			gobj.put('error',SQLERRM);
    gobj.put('status','0');
     RETURN '['||gobj.to_char()||']';
	END;  
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */

	FUNCTION buscar_usuariox7 (usuario in varchar2, passw in varchar2) RETURN varchar2 IS
	     PRAGMA AUTONOMOUS_TRANSACTION;
      identificador    LGN_USER.ID_USER%TYPE;
     mail    LGN_USER.USER_EMAIL%TYPE;
      nameusuario    LGN_USER.DISPLAY_NAME%TYPE;
      F_resgistro    LGN_USER.USER_REGISTRADO%TYPE;
       Serv    LGN_SERVICIO.SERVICIO%TYPE;
           cadena long;    lista json_list;
       
       -- CURSOR c_x7 is
       -- SELECT trim(NOM) n FROM  X7.AGT where IDTAGT='2158';
        --SELECT USER_EMAIL as n from  APP.LGN_USER;
        --select * from webx7.www_infoclient_view where CLIENTE='231231';
        --select * from x7.agt where nomcnx='MCALAN';
        -- select * from x7.fct;
        --SELECT * FROM  X7.AGT 
--select * from x7.fct;
--select * from x7.prf;
--select * from x7.hbl;
	permisosjson json ;  serviciosjson json ;
	BEGIN
    	gobj:=json();  serviciosjson:=json();
      ----------------------------busco usuario
     SELECT id_user,USER_EMAIL,DISPLAY_NAME,TO_CHAR(USER_REGISTRADO,'DD/MM/YYYY') 
      into identificador,mail,nameusuario,F_resgistro 
      from APP.LGN_USER  
      WHERE (USER_EMAIL=usuario OR USER_LOGIN=usuario) and USER_PASS=passw;
       IF identificador  IS NOT NULL THEN
      UPDATE LGN_USER SET USER_LAST_CONEXION=SYSDATE WHERE ID_USER=identificador;
      COMMIT;
      END IF;
     DECLARE 
       ----------------------------busco PERMISOS
    CURSOR C_permisos IS SELECT ID_SERVICIO,ADMINISTRADOR,OPERATIVO,SUPERVISOR,INVITADO,KEY,KEY_VALUE,KEY_DESCRIPTION
      --into lgn_Admin,lgn_Operativo,lgn_Supervis,lgn_Invitado,lgn_Key,lgn_Key_value,lgn_Key_descrip
      from APP.LGN_PERMISO  
      WHERE ID_USER=identificador;
     -- contar NUMBER(10):=0;
           BEGIN         
        FOR indice IN C_permisos LOOP
       -- contar:=contar+1;
        permisosjson:=json();
      
        permisosjson.put('admin',indice.ADMINISTRADOR);
        permisosjson.put('supervisor',indice.SUPERVISOR);
      permisosjson.put('operativo',indice.OPERATIVO);
       permisosjson.put('invitado',indice.INVITADO);
        permisosjson.put('key',indice.KEY);
         permisosjson.put('key_value',indice.KEY_VALUE);
          permisosjson.put('key_description',indice.KEY_DESCRIPTION);
                
               DECLARE 
                SERV    LGN_SERVICIO.SERVICIO%TYPE;
                begin
                  SELECT SERVICIO  INTO SERV   from APP.LGN_SERVICIO   WHERE ID_SERVICIO=indice.ID_SERVICIO;
                   serviciosjson.put(SERV,permisosjson);   
                 END;
          
          
   END LOOP;
      END;
      
                 DECLARE 
                IDTAGT_ID    X7.AGT.IDTAGT%TYPE;
                begin
                  SELECT IDTAGT INTO IDTAGT_ID FROM X7.AGT WHERE nomcnx=upper(usuario);
                   gobj.put('IDTAGT',IDTAGT_ID);   
                 END;
              
      gobj.put('status',1);
     
      
       --lista.append(''||gobj.to_char()||'');
        gobj.put('iduser',identificador);
       gobj.put('mail',mail);
       gobj.put('display_name',nameusuario);
        gobj.put('fechaRegistro',F_resgistro);
         gobj.put('servicios',serviciosjson);
          gobj.put('timeNow',sysdate);
          --gobj:=json();
          -- lista.append(Permi);
         --gobj.put('oratkn descifrado',UTILERIA_CIFRAR.DESCIFRAR('B6874EA7027FFA533F8A9D8004174B85'));
         gobj.put('oratkn',UTILERIA_CIFRAR.CIFRAR(gobj.to_char()));
         cadena:='['||gobj.to_char()||']';
      --cadena:='['||gobj.to_char()||','||gobj.to_char()||']';
		RETURN cadena;
	EXCEPTION 
		when NO_DATA_FOUND then
    return jmsgerr('LGN0004');
    /*gobj:=json();
        	gobj.put('msg','Por favor reporte este error al adminitrador de la aplicacion');
				gobj.put('usuario',usuario);
      gobj.put('pass',passw);
    gobj.put('status','0');
     RETURN '['||gobj.to_char()||']';
     */
     	when OTHERS then
		gobj:=json();
        	gobj.put('msg','Por favor reporte este error al adminitrador de la aplicacion');
			gobj.put('error',SQLERRM);
    gobj.put('status','0');
     RETURN '['||gobj.to_char()||']';
	END;  
/*  __________________________________________________________________________________________________  */

/*  __________________________________________________________________________________________________  */

	FUNCTION login (pobj json) RETURN clob IS
	    aplic    APP.LGN_VARIABLE.VALOR%TYPE;
     metodoJson     VARCHAR2(50);
     action VARCHAR2(100);
     loginjs VARCHAR2(200);
     serviciojs VARCHAR2(200);
     passjs VARCHAR2(100);
     idusuario number(10);
      VuserServicio number(10);
     --datosJSON json;
       datostoken VARCHAR2(4000);
        datosusuario json;
        datoinfo VARCHAR2(100);
        
        Vroles  VARCHAR2(100);
         Demail VARCHAR2(200);
          Demail2 VARCHAR2(200);
             Dlogin VARCHAR2(200);
              cifrarPassword VARCHAR2(2000);
              Dnombre VARCHAR2(2000);
              Dpass VARCHAR2(2000);
              LGNservico VARCHAR2(10);
              LGNroles VARCHAR2(50);
        
        Vusuario  number(10);
        Vservicio  number(10);
     	Vcheked VARCHAR2(50);
   
    vmax number (10):=0;
         vmin number (10):=0;
         
         Vnombre VARCHAR2(100);
          Vdescripcion VARCHAR2(100);
	
	BEGIN
   --datosJSON :=pobj;
		metodoJson:=json_ext.get_string(pobj,'action');
    loginjs:=json_ext.get_string(pobj,'login');--se tiene que enviar por post
    passjs:=json_ext.get_string(pobj,'pass');--se tiene que enviar por post
    serviciojs:=json_ext.get_string(pobj,'servicio');--se tiene que enviar por post
     datostoken:=json_ext.get_string(pobj,'oratkn');--se tiene que enviar por post
     
     
      datoinfo:=json_ext.get_string(pobj,'info');--se tiene que enviar por post
      Dnombre:=json_ext.get_string(pobj,'lgnNombre');
        Dlogin:=json_ext.get_string(pobj,'lgnUsuario');
         Dpass:=json_ext.get_string(pobj,'lgnPassw');
     	Demail:=json_ext.get_string(pobj,'lgnEmail');
      
       Vusuario:=to_number(json_ext.get_string(pobj,'idusuario'));
        Vservicio:=to_number(json_ext.get_string(pobj,'ideServicio'));
     	Vcheked:=json_ext.get_string(pobj,'ischeked');
       Vroles:=json_ext.get_string(pobj,'rol');
      
      
      LGNservico:=json_ext.get_string(pobj,'LGNservico');
        LGNroles:=json_ext.get_string(pobj,'LGNroles');
         --Dpass:=json_ext.get_string(datosusuario,'lgnPassw');
     	Demail2:=json_ext.get_string(pobj,'mail');
      
      
       datosusuario:=json_ext.get_json(pobj,'datos');--se tiene que enviar por post
 idusuario:=TO_NUMBER(json_ext.get_string(pobj,'idusuario'));--se tiene que enviar por post
 
  Vnombre:=json_ext.get_string(pobj,'servicioname');--se tiene que enviar por post
   Vdescripcion:=json_ext.get_string(pobj,'serviciodescripcion');--se tiene que enviar por post
   
 vmax :=TO_NUMBER(json_ext.get_string(pobj,'max'));
         vmin :=TO_NUMBER(json_ext.get_string(pobj,'min'));
 
 VuserServicio:=TO_NUMBER(json_ext.get_string(pobj,'user'));--se tiene que enviar por post
    	gobj:=json();
      -- gobj.put('agregarsssss',pobj);
     action:=metodoJson;
      --gobj.put('action',action);
     case		-----------------------------------------------------------------------------	
	        -------------------------------------------------------------------------------------  
         when action='login'	then--muestra concentrado de respuesta segun su encuesta      	
          if loginjs is null then return jmsgerr('LGN0003'); end if;
          --if serviciojs is null then return jmsgerr('LGN0003'); end if;
           if passjs is null then return jmsgerr('LGN0003');
            else 
         return buscar_usuario(loginjs,passjs);
        end if;
         -------------------------------------------------------------------------------------  
         when action='accesox7'	then     	
        
       gobj.put('LGN','conexion a x7');
    gobj.put('msg','accion no encontrada');
    gobj.put('status',1);
     gobj.put('action',action);
     return '['||gobj.to_char()||']';
     --------------------------------------------------------------------------------------------
    when action='verstatus'	then--muestra el status de la aplicacion
       SELECT VALOR into aplic from APP.LGN_VARIABLE  WHERE IDVARIABLE='status';
       --gobj.put('estatsssusAplicacion1','ss');
	  gobj.put('estatusAplicacion',aplic);
    return '['||gobj.to_char()||']';
    	-------------------------------------------------------------------------------------
      	-------------------------------------------------------------------------------------
      when action='showTable'	then--muestra los datos de la tabla
      return ShowTable(vmin,vmax);
      -------------------------------------------------------------------------------------
      	-------------------------------------------------------------------------------------
      when action='showTableServicios'	then--muestra los datos de la tabla
      return ShowTableServicio();
      -------------------------------------------------------------------------------------
      	-------------------------------------------------------------------------------------
      when action='showTableServiciosbyCliente'	then--muestra los datos de la tabla
      return ShowTableServicioBYCliente(VuserServicio);
      -------------------------------------------------------------------------------------
      	-------------------------------------------------------------------------------------
      when action='ServiciosAgregarLGN'	then--muestra los datos de la tabla
       return agregarServicioLGN(Vnombre,Vdescripcion);
      -------------------------------------------------------------------------------------
      	-------------------------------------------------------------------------------------
      when action='agregaservicioPermisostouser'	then--muestra los datos de la tabla
       return agregarServicioto_user( Vusuario ,    Vservicio,   	Vcheked );
      -------------------------------------------------------------------------------------
      	-------------------------------------------------------------------------------------
      when action='agregaservicioPermisostouser_rol'	then--muestra los datos de la tabla
       return agregarServicioto_user_rol( Vusuario ,    Vservicio,   	Vcheked,Vroles );
      -------------------------------------------------------------------------------------
      
       	-------------------------------------------------------------------------------------
      when action='Agregar'	then
       if datostoken is null then return jmsgerr('LGN0003'); END IF;
      -- if datosusuario is null then 
      --return jmsgerr('2LGN0003');
         --   END IF;
      if datoinfo is null then return jmsgerr('LGN0003'); 
          else
          
          if datoinfo='usuario' then 
          cifrarPassword:=UTILERIA_CIFRAR.CIFRAR(Dpass);
          end if;
          
         return agregar(datostoken,datosusuario,datoinfo,Dnombre,Dlogin,Demail,cifrarPassword , LGNservico ,LGNroles,Demail2);
               end if;
     
      -------------------------------------------------------------------------------------
      when action='ShowServicios'	then--muestra preguntas segun su servicio      	
          if idusuario is null then return jmsgerr('LGN0003'); 
          else
         return ShowServicios(idusuario);
        end if;
    else--valor default
     gobj.put('LGN','default');
    gobj.put('msg','accion no encontrada');
    gobj.put('status',0);
     return '['||gobj.to_char()||']';
		end case;
     	
		
	EXCEPTION
		when NO_DATA_FOUND then
    return jmsgerr('LGN0001');
      -- return 'algun mensaje de error';
		when OTHERS then
			--return jmsgerr('AP1002');
     gobj:=json();
        	gobj.put('msg','Por favor reporte este error al adminitrador de la aplicacion');
        
			gobj.put('error',SQLERRM);
        gobj.put('lineaError',' lineaError -> '||DBMS_UTILITY.Format_Error_BackTrace);
    gobj.put('status',0);
      return '['||gobj.to_char()||']'; 
	END;  
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */

	FUNCTION loginx7 (pobj json) RETURN clob IS
	    aplic    APP.LGN_VARIABLE.VALOR%TYPE;
     metodoJson     VARCHAR2(50);
     action VARCHAR2(100);
     loginjs VARCHAR2(200);
     serviciojs VARCHAR2(200);
     passjs VARCHAR2(100);
	
	BEGIN
		metodoJson:=json_ext.get_string(pobj,'action');
    loginjs:=json_ext.get_string(pobj,'loginuser');--se tiene que enviar por post
    passjs:=json_ext.get_string(pobj,'loginpassword');--se tiene que enviar por post
    serviciojs:=json_ext.get_string(pobj,'servicio');--se tiene que enviar por post
		--if metodoJson is null then 
			--metodoJson:=json_ext.get_string(pobj,'prm_0');
			--if metodoJson is null then return jmsgerr('LGN0003'); end if;
		--end if;
    	gobj:=json();
     action:=metodoJson;
      --gobj.put('action',action);
     case		-----------------------------------------------------------------------------	
		/*	when action='verstatus'	then--muestra el status de la aplicacion
       SELECT VALOR into aplic from APP.LGN_VARIABLE  WHERE IDVARIABLE='status';
       --gobj.put('estatsssusAplicacion1','ss');
	  gobj.put('estatusAplicacion',aplic);
    return gobj.to_char(); 
  */
        -------------------------------------------------------------------------------------  
         when action='login'	then--muestra concentrado de respuesta segun su encuesta      	
          if loginjs is null then return jmsgerr('LGN0003'); end if;
          --if serviciojs is null then return jmsgerr('LGN0003'); end if;
           if passjs is null then return jmsgerr('LGN0003');
            else 
         return buscar_usuariox7(loginjs,passjs);
                 end if;
         -------------------------------------------------------------------------------------  
           
    else--valor default
     gobj.put('LGN','default');
    gobj.put('msg','accion no encontrada');
    gobj.put('status',0);
     return '['||gobj.to_char()||']';
		end case;
     	
		
	EXCEPTION
		when NO_DATA_FOUND then
    return jmsgerr('LGN0001');
      -- return 'algun mensaje de error';
		when OTHERS then
			--return jmsgerr('AP1002');
     gobj:=json();
        	gobj.put('msg','Por favor reporte este error al adminitrador de la aplicacion');
			gobj.put('error',SQLERRM);
    gobj.put('status',0);
      return '['||gobj.to_char()||']'; 
	END;  
/*  __________________________________________________________________________________________________  */
/*  __________________________________________________________________________________________________  */
FUNCTION INVOCA(pjsontxt in varchar2) return clob is
		vval APP.LGN_VARIABLE.VALOR%TYPE;
		vdes APP.LGN_VARIABLE.DESCRIPCION%TYPE;
		japi varchar2(6);
		jver varchar2(6);
		jmtd varchar2(40);
	BEGIN
		if not vjson(pjsontxt) then return jmsgerr('LGN0001'); end if;
		japi:=json_ext.get_string(gobj,'api');
		jver:=json_ext.get_string(gobj,'ver');
		jmtd:=json_ext.get_string(gobj,'mtd');	
		-- if (japi is null or jver is null or jmtd is null) then return jmsgerr('E0001'); end if;
		gobj.remove('api');
		gobj.remove('ver');
		gobj.remove('mtd');
		datavarapi('status',vval,vdes);
		if vval<>'1' then return jmsgerr('LGN0002'); end if;			
		--las invocaciones de versión estan primeramente filtradas por el APIAGK o APIWWW 
		--según el caso y comienzan con la versión 1.0
		case	
			--when jmtd='loginrnx'	then return loginrnx(gobj);
			when jmtd='lgn'	then return login(gobj);
      when jmtd='lgnx7'	then return loginx7(gobj);
     -- when jmtd='lgn'	then return gobj.to_char();
		end case;
				
		return jmsgerr('LGN0003');
	EXCEPTION
		when OTHERS then
			return jmsgerr('LGN0003');
	END;
/*  __________________________________________________________________________________________________  */
END API_PQLGN_1_0;
/
