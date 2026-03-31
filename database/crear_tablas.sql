
CREATE DATABASE ArquiKids;
GO

USE ArquiKidsDB;
GO


CREATE TABLE Usuario (
    id_usuario          INT             NOT NULL IDENTITY(1,1),
    nickname            VARCHAR(30)     NOT NULL,
    avatar              VARCHAR(100)        NULL,
    puntosAcumulados    INT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario)
);
GO

CREATE TABLE Insignia (
    id_insignia     INT             NOT NULL IDENTITY(1,1),
    nombre          VARCHAR(50)     NOT NULL,
    categoria       VARCHAR(30)         NULL,
    CONSTRAINT PK_Insignia PRIMARY KEY (id_insignia)
);
GO

CREATE TABLE Componente (
    id_componente           INT             NOT NULL IDENTITY(1,1),
    nombreTecnico           VARCHAR(50)     NOT NULL,
    descripcionSencilla     VARCHAR(200)        NULL,
    analogiaCotidiana       VARCHAR(200)        NULL,
    modelo3D                VARCHAR(100)        NULL,
    CONSTRAINT PK_Componente PRIMARY KEY (id_componente)
);
GO

CREATE TABLE Gabinete (
    id_gabinete         INT             NOT NULL IDENTITY(1,1),
    modelo              VARCHAR(50)     NOT NULL,
    imagen              VARCHAR(100)        NULL,
    ensambleCompleto    BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_Gabinete PRIMARY KEY (id_gabinete)
);
GO


CREATE TABLE Usuario_Insignia (
    id_usuario      INT     NOT NULL,
    id_insignia     INT     NOT NULL,
    desbloqueada    BIT     NOT NULL DEFAULT 0,
    fechaObtencion  DATE        NULL,
    CONSTRAINT PK_Usuario_Insignia  PRIMARY KEY (id_usuario, id_insignia),
    CONSTRAINT FK_UI_Usuario        FOREIGN KEY (id_usuario)  REFERENCES Usuario  (id_usuario),
    CONSTRAINT FK_UI_Insignia       FOREIGN KEY (id_insignia) REFERENCES Insignia (id_insignia)
);
GO

CREATE TABLE Ranura (
    id_ranura       INT             NOT NULL IDENTITY(1,1),
    id_gabinete     INT             NOT NULL,
    tipoCompatible  VARCHAR(30)         NULL,
    etiqueta        VARCHAR(30)         NULL,
    estaOcupada     BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_Ranura        PRIMARY KEY (id_ranura),
    CONSTRAINT FK_Ranura_Gabinete   FOREIGN KEY (id_gabinete) REFERENCES Gabinete (id_gabinete)
);
GO

CREATE TABLE Simulador (
    id_simulador    INT     NOT NULL IDENTITY(1,1),
    id_gabinete     INT     NOT NULL,
    id_usuario      INT     NOT NULL,
    CONSTRAINT PK_Simulador         PRIMARY KEY (id_simulador),
    CONSTRAINT FK_Sim_Gabinete      FOREIGN KEY (id_gabinete) REFERENCES Gabinete (id_gabinete),
    CONSTRAINT FK_Sim_Usuario       FOREIGN KEY (id_usuario)  REFERENCES Usuario  (id_usuario)
);
GO


CREATE TABLE Ranura_Componente (
    id_ranura       INT     NOT NULL,
    id_componente   INT     NOT NULL,
    estaColocado    BIT     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Ranura_Componente     PRIMARY KEY (id_ranura, id_componente),
    CONSTRAINT FK_RC_Ranura             FOREIGN KEY (id_ranura)     REFERENCES Ranura     (id_ranura),
    CONSTRAINT FK_RC_Componente         FOREIGN KEY (id_componente) REFERENCES Componente (id_componente)
);
GO

CREATE TABLE Simulador_Componente (
    id_simulador    INT     NOT NULL,
    id_componente   INT     NOT NULL,
    CONSTRAINT PK_Simulador_Componente  PRIMARY KEY (id_simulador, id_componente),
    CONSTRAINT FK_SC_Simulador          FOREIGN KEY (id_simulador)  REFERENCES Simulador  (id_simulador),
    CONSTRAINT FK_SC_Componente         FOREIGN KEY (id_componente) REFERENCES Componente (id_componente)
);
GO

CREATE TABLE Evaluacion (
    id_evaluacion       INT             NOT NULL IDENTITY(1,1),
    id_usuario          INT             NOT NULL,
    id_simulador        INT             NOT NULL,
    tiempoTranscurrido  FLOAT               NULL,
    erroresCometidos    INT             NOT NULL DEFAULT 0,
    puntajeFinal        INT             NOT NULL DEFAULT 0,
    tipoReto            VARCHAR(30)         NULL,
    CONSTRAINT PK_Evaluacion        PRIMARY KEY (id_evaluacion),
    CONSTRAINT FK_Eval_Usuario      FOREIGN KEY (id_usuario)    REFERENCES Usuario   (id_usuario),
    CONSTRAINT FK_Eval_Simulador    FOREIGN KEY (id_simulador)  REFERENCES Simulador (id_simulador)
);
GO


CREATE TABLE Retroalimentacion (
    id_retroalimentacion    INT             NOT NULL IDENTITY(1,1),
    id_simulador            INT             NOT NULL,
    id_evaluacion           INT             NOT NULL,
    mensajeVisual           VARCHAR(200)        NULL,
    sonido                  VARCHAR(100)        NULL,
    CONSTRAINT PK_Retroalimentacion     PRIMARY KEY (id_retroalimentacion),
    CONSTRAINT FK_Retro_Simulador       FOREIGN KEY (id_simulador)  REFERENCES Simulador  (id_simulador),
    CONSTRAINT FK_Retro_Evaluacion      FOREIGN KEY (id_evaluacion) REFERENCES Evaluacion (id_evaluacion)
);
GO

CREATE TABLE Cuestionario (
    id_cuestionario     INT     NOT NULL IDENTITY(1,1),
    id_evaluacion       INT     NOT NULL,
    totalPreguntas      INT     NOT NULL DEFAULT 0,
    respuestasCorrectas INT     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Cuestionario      PRIMARY KEY (id_cuestionario),
    CONSTRAINT FK_Cuest_Evaluacion  FOREIGN KEY (id_evaluacion) REFERENCES Evaluacion (id_evaluacion)
);
GO

CREATE TABLE Pregunta (
    id_pregunta             INT             NOT NULL IDENTITY(1,1),
    id_cuestionario         INT             NOT NULL,
    enunciado               VARCHAR(300)    NOT NULL,
    opciones                VARCHAR(500)        NULL,
    respuestaCorrecta       VARCHAR(100)        NULL,
    analogiaRelacionada     VARCHAR(200)        NULL,
    CONSTRAINT PK_Pregunta          PRIMARY KEY (id_pregunta),
    CONSTRAINT FK_Preg_Cuestionario FOREIGN KEY (id_cuestionario) REFERENCES Cuestionario (id_cuestionario)
);
GO