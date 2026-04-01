-- ============================================================
--  ARQUI-KIDS — Script DDL para SQLite
-- ============================================================

PRAGMA foreign_keys = ON;

CREATE TABLE Usuario (
    id_usuario          INTEGER     NOT NULL,
    nickname            TEXT        NOT NULL,
    avatar              TEXT            NULL,
    puntosAcumulados    INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario AUTOINCREMENT)
);

CREATE TABLE Insignia (
    id_insignia     INTEGER     NOT NULL,
    nombre          TEXT        NOT NULL,
    categoria       TEXT            NULL,
    CONSTRAINT PK_Insignia PRIMARY KEY (id_insignia AUTOINCREMENT)
);

CREATE TABLE Componente (
    id_componente           INTEGER     NOT NULL,
    nombreTecnico           TEXT        NOT NULL,
    descripcionSencilla     TEXT            NULL,
    analogiaCotidiana       TEXT            NULL,
    modelo3D                TEXT            NULL,
    CONSTRAINT PK_Componente PRIMARY KEY (id_componente AUTOINCREMENT)
);

CREATE TABLE Gabinete (
    id_gabinete         INTEGER     NOT NULL,
    modelo              TEXT        NOT NULL,
    imagen              TEXT            NULL,
    ensambleCompleto    INTEGER     NOT NULL DEFAULT 0,   -- 0=false | 1=true
    CONSTRAINT PK_Gabinete PRIMARY KEY (id_gabinete AUTOINCREMENT)
);

CREATE TABLE Usuario_Insignia (
    id_usuario      INTEGER     NOT NULL,
    id_insignia     INTEGER     NOT NULL,
    desbloqueada    INTEGER     NOT NULL DEFAULT 0,   -- 0=false | 1=true
    fechaObtencion  TEXT            NULL,             -- ISO-8601: 'YYYY-MM-DD'
    CONSTRAINT PK_Usuario_Insignia  PRIMARY KEY (id_usuario, id_insignia),
    CONSTRAINT FK_UI_Usuario        FOREIGN KEY (id_usuario)  REFERENCES Usuario  (id_usuario),
    CONSTRAINT FK_UI_Insignia       FOREIGN KEY (id_insignia) REFERENCES Insignia (id_insignia)
);

CREATE TABLE Ranura (
    id_ranura       INTEGER     NOT NULL,
    id_gabinete     INTEGER     NOT NULL,
    tipoCompatible  TEXT            NULL,
    etiqueta        TEXT            NULL,
    estaOcupada     INTEGER     NOT NULL DEFAULT 0,   -- 0=false | 1=true
    CONSTRAINT PK_Ranura        PRIMARY KEY (id_ranura AUTOINCREMENT),
    CONSTRAINT FK_Ranura_Gabinete   FOREIGN KEY (id_gabinete) REFERENCES Gabinete (id_gabinete)
);

CREATE TABLE Simulador (
    id_simulador    INTEGER     NOT NULL,
    id_gabinete     INTEGER     NOT NULL,
    id_usuario      INTEGER     NOT NULL,
    CONSTRAINT PK_Simulador         PRIMARY KEY (id_simulador AUTOINCREMENT),
    CONSTRAINT FK_Sim_Gabinete      FOREIGN KEY (id_gabinete) REFERENCES Gabinete (id_gabinete),
    CONSTRAINT FK_Sim_Usuario       FOREIGN KEY (id_usuario)  REFERENCES Usuario  (id_usuario)
);

CREATE TABLE Ranura_Componente (
    id_ranura       INTEGER     NOT NULL,
    id_componente   INTEGER     NOT NULL,
    estaColocado    INTEGER     NOT NULL DEFAULT 0,   -- 0=false | 1=true
    CONSTRAINT PK_Ranura_Componente PRIMARY KEY (id_ranura, id_componente),
    CONSTRAINT FK_RC_Ranura         FOREIGN KEY (id_ranura)     REFERENCES Ranura     (id_ranura),
    CONSTRAINT FK_RC_Componente     FOREIGN KEY (id_componente) REFERENCES Componente (id_componente)
);

CREATE TABLE Simulador_Componente (
    id_simulador    INTEGER     NOT NULL,
    id_componente   INTEGER     NOT NULL,
    CONSTRAINT PK_Simulador_Componente  PRIMARY KEY (id_simulador, id_componente),
    CONSTRAINT FK_SC_Simulador          FOREIGN KEY (id_simulador)  REFERENCES Simulador  (id_simulador),
    CONSTRAINT FK_SC_Componente         FOREIGN KEY (id_componente) REFERENCES Componente (id_componente)
);

CREATE TABLE Evaluacion (
    id_evaluacion       INTEGER     NOT NULL,
    id_usuario          INTEGER     NOT NULL,
    id_simulador        INTEGER     NOT NULL,
    tiempoTranscurrido  REAL            NULL,
    erroresCometidos    INTEGER     NOT NULL DEFAULT 0,
    puntajeFinal        INTEGER     NOT NULL DEFAULT 0,
    tipoReto            TEXT            NULL,
    CONSTRAINT PK_Evaluacion        PRIMARY KEY (id_evaluacion AUTOINCREMENT),
    CONSTRAINT FK_Eval_Usuario      FOREIGN KEY (id_usuario)   REFERENCES Usuario   (id_usuario),
    CONSTRAINT FK_Eval_Simulador    FOREIGN KEY (id_simulador) REFERENCES Simulador (id_simulador)
);

CREATE TABLE Retroalimentacion (
    id_retroalimentacion    INTEGER     NOT NULL,
    id_simulador            INTEGER     NOT NULL,
    id_evaluacion           INTEGER     NOT NULL,
    mensajeVisual           TEXT            NULL,
    sonido                  TEXT            NULL,
    CONSTRAINT PK_Retroalimentacion     PRIMARY KEY (id_retroalimentacion AUTOINCREMENT),
    CONSTRAINT FK_Retro_Simulador       FOREIGN KEY (id_simulador)  REFERENCES Simulador  (id_simulador),
    CONSTRAINT FK_Retro_Evaluacion      FOREIGN KEY (id_evaluacion) REFERENCES Evaluacion (id_evaluacion)
);

CREATE TABLE Cuestionario (
    id_cuestionario     INTEGER     NOT NULL,
    id_evaluacion       INTEGER     NOT NULL,
    totalPreguntas      INTEGER     NOT NULL DEFAULT 0,
    respuestasCorrectas INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Cuestionario      PRIMARY KEY (id_cuestionario AUTOINCREMENT),
    CONSTRAINT FK_Cuest_Evaluacion  FOREIGN KEY (id_evaluacion) REFERENCES Evaluacion (id_evaluacion)
);

CREATE TABLE Pregunta (
    id_pregunta             INTEGER     NOT NULL,
    id_cuestionario         INTEGER     NOT NULL,
    enunciado               TEXT        NOT NULL,
    opciones                TEXT            NULL,
    respuestaCorrecta       TEXT            NULL,
    analogiaRelacionada     TEXT            NULL,
    CONSTRAINT PK_Pregunta          PRIMARY KEY (id_pregunta AUTOINCREMENT),
    CONSTRAINT FK_Preg_Cuestionario FOREIGN KEY (id_cuestionario) REFERENCES Cuestionario (id_cuestionario)
);