IF DB_ID('BDD_TAXEC') IS NULL
BEGIN
    CREATE DATABASE BDD_TAXEC;
END
GO

USE BDD_TAXEC;
GO


CREATE TABLE Contribuyentes (
    ContribuyenteID INT IDENTITY(1,1) PRIMARY KEY,
    TipoContribuyente VARCHAR(50) NOT NULL, -- Persona Natural, Jurídica
    ObligadoContabilidad BIT NOT NULL DEFAULT 0, -- 1 = Sí, 0 = No
    Identificacion VARCHAR(13) NOT NULL UNIQUE, -- RUC o Cédula
    NombreRazonSocial VARCHAR(150) NOT NULL,
    Domicilio VARCHAR(255),
    ActividadEconomica VARCHAR(100),
    RegimenTributario VARCHAR(50) NOT NULL, -- General, RIMPE, etc.
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1
);
GO

CREATE TABLE Ingresos (
    IngresoID INT IDENTITY(1,1) PRIMARY KEY,
    ContribuyenteID INT NOT NULL FOREIGN KEY REFERENCES Contribuyentes(ContribuyenteID),
    PeriodoFiscal INT NOT NULL, -- Cambiado de YEAR a INT para mayor compatibilidad
    Gravables DECIMAL(18,2) DEFAULT 0,
    Exentos DECIMAL(18,2) DEFAULT 0,
    ParticipacionLaboral DECIMAL(18,2) DEFAULT 0,
    Capital DECIMAL(18,2) DEFAULT 0, -- dividendos, arriendos, financieros
    FechaActualizacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_PeriodoFiscal CHECK (PeriodoFiscal BETWEEN 2000 AND 2100)
);
GO

CREATE TABLE Deducciones (
    DeduccionID INT IDENTITY(1,1) PRIMARY KEY,
    ContribuyenteID INT NOT NULL FOREIGN KEY REFERENCES Contribuyentes(ContribuyenteID),
    PeriodoFiscal INT NOT NULL,
    AporteIESS DECIMAL(18,2) DEFAULT 0,
    GastosVivienda DECIMAL(18,2) DEFAULT 0,
    GastosSalud DECIMAL(18,2) DEFAULT 0,
    GastosEducacion DECIMAL(18,2) DEFAULT 0,
    GastosAlimentacion DECIMAL(18,2) DEFAULT 0,
    GastosVestimenta DECIMAL(18,2) DEFAULT 0,
    NumeroCargasFamiliares INT DEFAULT 0,
    PorcentajeDiscapacidad DECIMAL(5,2) DEFAULT 0,
    TerceraEdad BIT DEFAULT 0,
    CONSTRAINT FK_Deducciones_Contribuyentes FOREIGN KEY (ContribuyenteID) REFERENCES Contribuyentes(ContribuyenteID),
    CONSTRAINT CK_PeriodoFiscal_Deducciones CHECK (PeriodoFiscal BETWEEN 2000 AND 2100)
);
GO


CREATE TABLE BaseImponible (
    CalculoID INT IDENTITY(1,1) PRIMARY KEY,
    ContribuyenteID INT NOT NULL FOREIGN KEY REFERENCES Contribuyentes(ContribuyenteID),
    PeriodoFiscal INT NOT NULL,
    TipoCalculo VARCHAR(50) NOT NULL, -- Ej: "PN sin contabilidad", "PJ", etc.
    Base DECIMAL(18,2) NOT NULL,
    FechaCalculo DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_BaseImponible_Contribuyentes FOREIGN KEY (ContribuyenteID) REFERENCES Contribuyentes(ContribuyenteID)
);
GO


CREATE TABLE TablaImpuestos (
    TablaID INT IDENTITY(1,1) PRIMARY KEY,
    Anio INT NOT NULL,
    FraccionBasica DECIMAL(18,2) NOT NULL,
    ExcesoHasta DECIMAL(18,2),
    ImpuestoFraccionBasica DECIMAL(18,2) NOT NULL,
    PorcentajeExcedente DECIMAL(5,2) NOT NULL, -- Ej: 0.15 para 15%
    Descripcion VARCHAR(100),
    CONSTRAINT CK_Anio_TablaImpuestos CHECK (Anio BETWEEN 2000 AND 2100),
    CONSTRAINT UQ_Anio_Fraccion UNIQUE (Anio, FraccionBasica)
);
GO


CREATE TABLE PeriodosFiscales (
    PeriodoFiscal INT PRIMARY KEY,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    Descripcion VARCHAR(100),
    CONSTRAINT CK_PeriodoFiscal_Rango CHECK (PeriodoFiscal BETWEEN 2000 AND 2100),
    CONSTRAINT CK_Fechas_Consistentes CHECK (FechaInicio < FechaFin)
);
GO

CREATE TABLE HistoricoCalculos (
    HistoricoID INT IDENTITY(1,1) PRIMARY KEY,
    ContribuyenteID INT NOT NULL FOREIGN KEY REFERENCES Contribuyentes(ContribuyenteID),
    PeriodoFiscal INT NOT NULL,
    FechaCalculo DATETIME DEFAULT GETDATE(),
    BaseImponible DECIMAL(18,2) NOT NULL,
    ImpuestoCalculado DECIMAL(18,2) NOT NULL,
    Rebajas DECIMAL(18,2) DEFAULT 0,
    Retenciones DECIMAL(18,2) DEFAULT 0,
    SaldoPagar DECIMAL(18,2) NOT NULL,
    Estado VARCHAR(20) DEFAULT 'Pendiente', -- Pagado, Pendiente, Anulado
    CONSTRAINT FK_Historico_Contribuyentes FOREIGN KEY (ContribuyenteID) REFERENCES Contribuyentes(ContribuyenteID)
);
GO

CREATE TABLE CalendarioPagos (
    CalendarioID INT IDENTITY(1,1) PRIMARY KEY,
    NovenoDigito CHAR(1) NOT NULL,
    FechaLimitePago DATE NOT NULL,
    PeriodoFiscal INT NOT NULL,
    TipoImpuesto VARCHAR(50) NOT NULL, -- Renta, IVA, etc.
    Descripcion VARCHAR(100),
    CONSTRAINT UQ_Calendario UNIQUE (NovenoDigito, PeriodoFiscal, TipoImpuesto)
);
GO


CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    NombreUsuario VARCHAR(50) NOT NULL UNIQUE,
    ContrasenaHash VARCHAR(255) NOT NULL, -- Almacenamiento seguro
    Email VARCHAR(100) NOT NULL UNIQUE,
    NombreCompleto VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    UltimoAcceso DATETIME,
    Activo BIT DEFAULT 1,
    CONSTRAINT UQ_Email UNIQUE (Email)
);
GO


CREATE TABLE Roles (
    RolID INT IDENTITY(1,1) PRIMARY KEY,
    NombreRol VARCHAR(30) NOT NULL UNIQUE,
    Descripcion VARCHAR(200)
);
GO


CREATE TABLE UsuarioRoles (
    UsuarioRolID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL FOREIGN KEY REFERENCES Usuarios(UsuarioID),
    RolID INT NOT NULL FOREIGN KEY REFERENCES Roles(RolID),
    FechaAsignacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_UsuarioRol UNIQUE (UsuarioID, RolID)
);
GO


CREATE TABLE PerfilesUsuario (
    PerfilID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL FOREIGN KEY REFERENCES Usuarios(UsuarioID),
    ContribuyenteID INT NULL FOREIGN KEY REFERENCES Contribuyentes(ContribuyenteID),
    FotoPerfil VARCHAR(255),
    Biografia TEXT,
    Especialidad VARCHAR(100), -- Para asesores
    CONSTRAINT UQ_PerfilUsuario UNIQUE (UsuarioID)
);
GO

CREATE TABLE ConversacionesChat (
    ConversacionID INT IDENTITY(1,1) PRIMARY KEY,
    Asunto VARCHAR(100) NOT NULL,
    Estado VARCHAR(20) DEFAULT 'Abierta',
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaCierre DATETIME NULL,
    ContribuyenteID INT NULL FOREIGN KEY REFERENCES Contribuyentes(ContribuyenteID),
    CONSTRAINT CK_Estado_Valido CHECK (Estado IN ('Abierta', 'Cerrada', 'En espera'))
);
GO


CREATE TABLE ParticipantesChat (
    ParticipanteID INT IDENTITY(1,1) PRIMARY KEY,
    ConversacionID INT NOT NULL FOREIGN KEY REFERENCES ConversacionesChat(ConversacionID),
    UsuarioID INT NOT NULL FOREIGN KEY REFERENCES Usuarios(UsuarioID),
    RolParticipante VARCHAR(20) NOT NULL, -- 'Asesor', 'Cliente', 'Soporte'
    FechaUnion DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_ParticipanteConversacion UNIQUE (ConversacionID, UsuarioID),
    CONSTRAINT CK_RolParticipante CHECK (RolParticipante IN ('Asesor', 'Cliente', 'Soporte'))
);
GO

CREATE TABLE MensajesChat (
    MensajeID INT IDENTITY(1,1) PRIMARY KEY,
    ConversacionID INT NOT NULL FOREIGN KEY REFERENCES ConversacionesChat(ConversacionID),
    UsuarioID INT NOT NULL FOREIGN KEY REFERENCES Usuarios(UsuarioID),
    Contenido TEXT NOT NULL,
    FechaEnvio DATETIME DEFAULT GETDATE(),
    Leido BIT DEFAULT 0,
    TipoContenido VARCHAR(20) DEFAULT 'Texto',
    AdjuntoURL VARCHAR(255) NULL,
    CONSTRAINT CK_TipoContenido CHECK (TipoContenido IN ('Texto', 'Documento', 'Imagen', 'Sistema'))
);
GO


INSERT INTO Roles (NombreRol, Descripcion) VALUES 
('Administrador', 'Acceso completo al sistema'),
('Asesor', 'Personal que brinda asesoría fiscal'),
('Cliente', 'Usuarios contribuyentes'),
('Soporte', 'Personal de soporte técnico');
GO


CREATE INDEX IX_UsuarioRoles_Usuario ON UsuarioRoles(UsuarioID);
CREATE INDEX IX_UsuarioRoles_Rol ON UsuarioRoles(RolID);
CREATE INDEX IX_ParticipantesChat_Usuario ON ParticipantesChat(UsuarioID);
CREATE INDEX IX_MensajesChat_ConversacionFecha ON MensajesChat(ConversacionID, FechaEnvio);

-- Inserta al usuario administrador
INSERT INTO Usuarios (
    NombreUsuario, ContrasenaHash, Email, NombreCompleto, Telefono
) VALUES (
    'moises', 
    '25f43b1486ad95a1398e3eeb3d83bc4010015fcc9bedb35b432e00298d5021f7', -- Hash SHA256 de "admin1"
    'moises.arequipa@epn.edu.ec', 
    'Moises Arequipa', 
    '0999999999'
);

-- Asignar rol de Administrador (ID = 1 si es el primero creado)
INSERT INTO UsuarioRoles (UsuarioID, RolID) 
VALUES (
    (SELECT UsuarioID FROM Usuarios WHERE NombreUsuario = 'moises'),
    (SELECT RolID FROM Roles WHERE NombreRol = 'Administrador')
);


USE BDD_TAXEC;
GO

INSERT INTO PerfilesUsuario (
    UsuarioID,
    ContribuyenteID,
    FotoPerfil,
    Biografia,
    Especialidad
)
VALUES (
    (SELECT UsuarioID FROM Usuarios WHERE NombreUsuario = 'moises'),
    NULL, -- No es contribuyente en este caso
    'https://example.com/fotos/moises.jpg',
    'Administrador del sistema con experiencia en gestión tributaria.',
    'Administración y Sistemas'
);