create database dbAlumnos2

use dbAlumnos2

create table Semestres(Id int primary key identity(1,1), NombreSemestre varchar(200) not null)

create table Carreras(Id int primary key identity(1,1), NombreCarrera varchar(200) not null, IdSemestre int not null, Pencion decimal(5,2))

create table Alumnos(Id int primary key identity(1,1), Cedula varchar(15) not null , Nombre1 varchar(50), Nombre2 varchar(50), Apellido1 varchar(50), Apellido2 varchar(50), Sexo char(1), Direccion varchar(100), IdCarrera int not null, FechaIngreso datetime, FechaUpdate datetime)

create table Requisitos(Id int primary key identity(1,1), IdAlumno int not null, CopiaTituloBachiller bit, CopiaCedula bit, NotasBachiller bit)

create table NuevoSemestre(Id int primary key identity(1,1), IdAlumno int not null, IdSemestre int not null, FechaIngreso datetime)

create table Facturas(Id int primary key identity(1,1), Descripcion varchar(200), precio decimal(5,2), IdAlumno int not null, FechaIngreso datetime)

create table RegistroDeActividades(Id int primary key identity(1,1), NombresAlumno varchar(200) ,Accion varchar(100), FechaIngreso datetime) 
go
-- REGISTRO DE SEMESTRE --
select * from Semestres
--SISTEMA
insert into Semestres values ('Primer semestre') 
insert into Semestres values ('Segundo semestre') 
insert into Semestres values ('Tercer semestre') 
insert into Semestres values ('Cuarto semestre') 
--ADMINISTRACION
insert into Semestres values ('Primer semestre') 
insert into Semestres values ('Segundo semestre') 
insert into Semestres values ('Tercer semestre')
--TEOLOGIA
insert into Semestres values ('Primer semestre') 
insert into Semestres values ('Segundo semestre') 

-- REGISTRO DE CARRERAS
Select * from Carreras
insert into Carreras values ('ANALISIS DE SISTEMAS',1,110)
insert into Carreras values ('ANALISIS DE SISTEMAS',2,110)
insert into Carreras values ('ANALISIS DE SISTEMAS',3,110)
insert into Carreras values ('ANALISIS DE SISTEMAS',4,110)

insert into Carreras values ('ADMINISTRACION DE EMPRESA',5,120)
insert into Carreras values ('ADMINISTRACION DE EMPRESA',6,120)
insert into Carreras values ('ADMINISTRACION DE EMPRESA',7,120)

insert into Carreras values ('TEOLOGIA',8,120)
insert into Carreras values ('TEOLOGIA',9,120)


-- TRIGER
CREATE TRIGGER insert_registro_alumno on Alumnos for insert
as
begin 
		declare @NombresAlumno varchar(200)
		set @NombresAlumno = (select Nombre1+' '+Nombre2+''+Apellido1 from inserted)
		insert into RegistroDeActividades values (@NombresAlumno,'NUEVO ALUMNO AGREGADO',SYSDATETIME())
end
go

CREATE TRIGGER eliminar_registro_alumno on Alumnos for delete
as
begin 
		declare @id_Alumno int
		set @id_Alumno = (select Id from inserted)   
		-- ELIMINAR TODO LO QUE TIENE QUE VER CON ESTE ALUMNO 
		delete from NuevoSemestre where IdAlumno = @id_Alumno
		delete from Requisitos where IdAlumno =@id_Alumno
		delete from Facturas where IdAlumno = @id_Alumno
		
		declare @NombresAlumno varchar(200)
		set @NombresAlumno = (select Nombre1+' '+Nombre2+''+Apellido1 from deleted)
		insert into RegistroDeActividades values (@NombresAlumno,'ELIMINADO ALUMNO',SYSDATETIME())
end
go

CREATE TRIGGER modificar_registro_alumno on Alumnos for update
as
begin 
		declare @NombresAlumno varchar(200)
		set @NombresAlumno = (select Nombre1+' '+Nombre2+''+Apellido1 from inserted)
		insert into RegistroDeActividades values (@NombresAlumno,'MODIFICADO ALUMNO',SYSDATETIME())
end
go

CREATE TRIGGER insert_registro_requisitos on Requisitos for insert
as
begin 
		declare @id_Alumno int
		set @id_Alumno = (select IdAlumno from inserted)
		
		declare @NombresAlumno varchar(200)
		set @NombresAlumno = (select a.Nombre1+' '+a.Nombre2+' '+a.Apellido1 from Alumnos a inner join Requisitos r on a.Id = r.IdAlumno where a.Id = @id_Alumno)
		insert into RegistroDeActividades values (@NombresAlumno,'NUEVO DOCUMENTOS REQUISITOS',SYSDATETIME())
end
go


CREATE TRIGGER insert_registro_nuevoSemestre on NuevoSemestre for insert
as
begin 
		declare @id_Alumno int
		set @id_Alumno = (select IdAlumno from inserted)
		
		declare @NombresAlumno varchar(200)
		set @NombresAlumno = (select a.Nombre1+' '+a.Nombre2+' '+a.Apellido1 from Alumnos a inner join NuevoSemestre n on a.Id = n.IdAlumno where a.Id = @id_Alumno)
		insert into RegistroDeActividades values (@NombresAlumno,'NUEVO iNGRESO DE SEMESTRE',SYSDATETIME())
end
go


create proc sp_insert_alumnos3(@cedula varchar(15), 
							@Nombre1 varchar(50),
							@Nombre2 varchar(50),
							@Apellido1 varchar(50),
							@Apellido2 varchar(50),
							@Sexo char(1),
							@Direccion varchar(100),
							@IdCarrera int
						)
as
if NOT EXISTS (select * from Alumnos where Cedula = @cedula)
	Begin
		insert into Alumnos values (@cedula, @Nombre1, @Nombre2, @Apellido1, @Apellido2, @Sexo, @Direccion, @IdCarrera, SYSDATETIME(), SYSDATETIME())
	select 'SE INGRESO CORRECTAMENTE EL REGISTRO' as mensaje , 1 as envio, CONVERT(INT, @@identity) - 1  as idAlumno
	End
else
	Begin
		select 'EL NUMERO DE CEDULA YA EXISTE' as mensaje , 0 as envio
	End
GO
select * from Alumnos
exec sp_insert_alumnos2 '097','s','m','a','p','M','Ver',1
-----------------------------------------------
-------  ELIMINAR UN ALUMNO -------------------
Alter proc sp_delete_alumnos(@Id int)
as
if EXISTS (select * from Alumnos where Id = @Id)
	Begin
		delete from Alumnos where Id = @Id
		select 'SE A ELIMINADO CORRECTAMENTE' as mensaje , 1 as envio
	End
else 
	begin
	select 'NO SE ENCONTRO UN REGISTRO PARA ELIMINAR' as mensaje , 0 as envio
	end
GO

 
------- END ELIMINAR UN ALUMNO -----------------

create proc sp_update_alumnos(@Id int,
							@cedula varchar(15), 
							@Nombre1 varchar(50),
							@Nombre2 varchar(50),
							@Apellido1 varchar(50),
							@Apellido2 varchar(50),
							@Sexo char(1),
							@Direccion varchar(100),
							@IdCarrera int
						)
as
if EXISTS (select * from Alumnos where ID = @Id)
	Begin
		update Alumnos set Cedula = @cedula,Nombre1 = @Nombre1,Nombre2 = @Nombre2,Apellido1 = @Apellido1,Apellido2 = @Apellido2, Sexo = @Sexo,Direccion = @Direccion,IdCarrera = @IdCarrera, FechaUpdate = SYSDATETIME() where Id = @Id
		select 'SE A ACTUALIZADO CORRECTAMNTE' as mensaje , 1 as envio
	End
else
	begin
		select 'NO SE ENCONTRO UN REGISTRO PARA MODIFICAR'as mensaje , 0 as envio
	end
GO


create proc sp_add_Requisitos(@id_alumno int,
							  @CopiaTitulo bit,
							  @CopiaCedula bit,
							  @NotasBachiller bit)
as
if exists (select * from Alumnos where Id = @id_alumno)
	begin 
		insert into Requisitos values (@id_alumno,@CopiaTitulo,@CopiaCedula,@NotasBachiller)
		select 'SE INGRSO CORRECTAMENTE LOS REQUISITOS' as mensaje , 1 as envio
	end
else 
	begin
	SELECT 'NO HAY REGISTRO PARA GUARDAR ESTOS REQUIRIMIENTOS' AS mensaje , 0 as envio
	end 
go

create proc sp_add_nuevo_semestre(@id_Alumno int,
							@IdSemestre int)
as
		insert into NuevoSemestre values (@id_Alumno, @IdSemestre, SYSDATETIME())
		
		declare @nombres varchar(100) , @carrera varchar(20)
		set @nombres = (select a.Nombre1+' '+a.Nombre2+' '+a.Apellido1 as nombres  from Alumnos a join NuevoSemestre n on a.Id = n.IdAlumno where a.Id = @id_Alumno )
		set @carrera = (select s.NombreSemestre from NuevoSemestre n join Semestres s on n.IdSemestre = s.Id where n.IdAlumno = @id_Alumno )
		select 'EL Alumno '+@nombres+' se ha registrado al '+@carrera+' de su carrera Acutal' as mensaje , 1 as envio
go

create proc sp_delete_semestre(@id int)
as
	if(@id is not null)
		begin
			delete from NuevoSemestre where Id = @id
		end
go

--Ver Vistas
create view view_AlumnosSemestre as
select a.Cedula as Cedula, a.Nombre1+' '+a.Nombre2+' '+a.Apellido1 as Nombres, s.NombreSemestre AS Semestre, n.FechaIngreso from Alumnos a inner join NuevoSemestre n on a.Id = n.IdAlumno inner join Semestres s on n.IdSemestre = s.Id
go

select * from view_AlumnosSemestre

select * from Alumnos


create proc sp_obtener_Alumnos(@idAlumno int) as
select * from view_Alumnos where Id = @idAlumno
go

exec sp_obtener_Alumnos 1

-- VISTA DE TODOS LOS ALUMNOS
create view view_Alumnos as
select a.Id, a.Cedula, a.Nombre1+' '+a.Nombre2+' '+a.Apellido1 AS Nombres,
      CASE a.Sexo  
         WHEN 'M' THEN 'Masculino'  
         WHEN 'F' THEN 'Femenino'    
      END as Sexo
from Alumnos a inner join Carreras c on a.IdCarrera = c.Id

select * from view_Alumnos where Id = 1

create proc view_Reporte @cedula varchar(15)
as
select a.Cedula as Cedula, a.Nombre1+' '+a.Nombre2+' '+a.Apellido1 as Nombres,f.Descripcion,f.precio,f.FechaIngreso from Alumnos a inner join Facturas f on a.Id = f.IdAlumno where a.Cedula like '%'+@cedula+'%' 
go


