-- ============================================================
--  ARQUI-KIDS — Script DDL y DML para SQLite
-- ============================================================

PRAGMA foreign_keys = ON;

CREATE TABLE Usuario (
    id_usuario          INTEGER     NOT NULL,
    nickname            TEXT        NOT NULL UNIQUE,
    avatar              TEXT            NULL,
    puntosAcumulados    INTEGER     NOT NULL DEFAULT 0,
    mejorTiempo         INTEGER         NULL,
    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario AUTOINCREMENT)
);

CREATE TABLE Insignia (
    id_insignia     INTEGER     NOT NULL,
    nombre          TEXT        NOT NULL,
    descripcion     TEXT            NULL,
    categoria       TEXT            NULL,
    CONSTRAINT PK_Insignia PRIMARY KEY (id_insignia AUTOINCREMENT)
);

CREATE TABLE Componente (
    id_componente           INTEGER     NOT NULL,
    nombreTecnico           TEXT        NOT NULL,
    descripcionSencilla     TEXT        NOT NULL,
    analogiaCotidiana       TEXT        NOT NULL,
    modelo3D                TEXT            NULL,
    orden_ensamble          INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Componente PRIMARY KEY (id_componente AUTOINCREMENT)
);

CREATE TABLE Gabinete (
    id_gabinete         INTEGER     NOT NULL,
    modelo              TEXT        NOT NULL,
    imagen              TEXT            NULL,
    ensambleCompleto    INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Gabinete PRIMARY KEY (id_gabinete AUTOINCREMENT)
);

CREATE TABLE Usuario_Insignia (
    id_usuario      INTEGER     NOT NULL,
    id_insignia     INTEGER     NOT NULL,
    desbloqueada    INTEGER     NOT NULL DEFAULT 0,
    fechaObtencion  TEXT            NULL,
    CONSTRAINT PK_Usuario_Insignia  PRIMARY KEY (id_usuario, id_insignia),
    CONSTRAINT FK_UI_Usuario        FOREIGN KEY (id_usuario)  REFERENCES Usuario  (id_usuario) ON DELETE CASCADE,
    CONSTRAINT FK_UI_Insignia       FOREIGN KEY (id_insignia) REFERENCES Insignia (id_insignia)
);

CREATE TABLE Ranura (
    id_ranura       INTEGER     NOT NULL,
    id_gabinete     INTEGER     NOT NULL,
    tipoCompatible  TEXT            NULL,
    etiqueta        TEXT            NULL,
    estaOcupada     INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Ranura        PRIMARY KEY (id_ranura AUTOINCREMENT),
    CONSTRAINT FK_Ranura_Gabinete   FOREIGN KEY (id_gabinete) REFERENCES Gabinete (id_gabinete) ON DELETE CASCADE
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
    estaColocado    INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Ranura_Componente PRIMARY KEY (id_ranura, id_componente),
    CONSTRAINT FK_RC_Ranura         FOREIGN KEY (id_ranura)     REFERENCES Ranura     (id_ranura) ON DELETE CASCADE,
    CONSTRAINT FK_RC_Componente     FOREIGN KEY (id_componente) REFERENCES Componente (id_componente)
);

CREATE TABLE Simulador_Componente (
    id_simulador    INTEGER     NOT NULL,
    id_componente   INTEGER     NOT NULL,
    CONSTRAINT PK_Simulador_Componente  PRIMARY KEY (id_simulador, id_componente),
    CONSTRAINT FK_SC_Simulador          FOREIGN KEY (id_simulador)  REFERENCES Simulador  (id_simulador) ON DELETE CASCADE,
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
    CONSTRAINT FK_Cuest_Evaluacion  FOREIGN KEY (id_evaluacion) REFERENCES Evaluacion (id_evaluacion) ON DELETE CASCADE
);

CREATE TABLE Pregunta (
    id_pregunta             INTEGER     NOT NULL,
    id_cuestionario         INTEGER     NOT NULL,
    enunciado               TEXT        NOT NULL,
    opciones                TEXT        NOT NULL,
    respuestaCorrecta       TEXT        NOT NULL,
    analogiaRelacionada     TEXT            NULL,
    CONSTRAINT PK_Pregunta          PRIMARY KEY (id_pregunta AUTOINCREMENT),
    CONSTRAINT FK_Preg_Cuestionario FOREIGN KEY (id_cuestionario) REFERENCES Cuestionario (id_cuestionario) ON DELETE CASCADE
);

-- 2. DATOS INICIALES (DML)
-- ============================================================

-- 2.1 Insignias
INSERT INTO Insignia (nombre, descripcion, categoria) VALUES 
('Primer Ensamble', '¡Completaste tu primer ensamble de computadora!', 'Progreso'),
('Constructor Veloz', 'Ensamblaste la PC en tiempo récord', 'Tiempo'),
('Cerebrito Arquikids', 'Respondiste todas las preguntas del quiz correctamente', 'Conocimiento'),
('Cero Errores', 'Colocaste todas las piezas a la primera, sin equivocarte', 'Precisión'),
('Maestro Ensamblador', 'Completaste el reto final sin la guía paso a paso', 'Finalización');

-- 2.2 Componentes (8 componentes)
INSERT INTO Componente (nombreTecnico, descripcionSencilla, analogiaCotidiana, modelo3D, orden_ensamble) VALUES 
(
    'Procesador (CPU)', 
    'Es el cerebro de la computadora. Piensa y toma decisiones para hacer funcionar todo.', 
    'Es como tu cerebro, que piensa y decide qué hacer cuando juegas o haces tarea.',
    'cpu.glb', 1
),
(
    'Memoria RAM', 
    'Guarda la información que estás usando en este momento, como los juegos abiertos.', 
    'Es como tu mesa de trabajo. Entre más grande, más cosas puedes tener encima al mismo tiempo.',
    'ram.glb', 2
),
(
    'Tarjeta Gráfica (GPU)', 
    'Se encarga de dibujar todo lo que ves en la pantalla, como los personajes y colores.', 
    'Es como un artista que dibuja rapidísimo cada escena de tu videojuego favorito.',
    'gpu.glb', 3
),
(
    'Disco Duro (SSD/HDD)', 
    'Guarda todos tus archivos, juegos y fotos de forma permanente, aunque apagues la PC.', 
    'Es como tu mochila o un gran archivador donde guardas todo para usarlo otro día.',
    'disco_duro.glb', 4
),
(
    'Fuente de Poder (PSU)', 
    'Toma la electricidad del enchufe y se la da a cada componente con la fuerza justa.', 
    'Es como el corazón que bombea la energía (sangre) a todo el cuerpo para que se mueva.',
    'psu.glb', 5
),
(
    'Refrigeración', 
    'Mantiene frío al procesador y otros componentes para que no se calienten demasiado.', 
    'Es como tomar agua fría o sudar cuando haces mucho ejercicio para no tener calor.',
    'refrigeracion.glb', 6
),
(
    'Monitor', 
    'Es la pantalla donde ves todo lo que hace la computadora: juegos, videos y dibujos.', 
    'Es como la televisión de la computadora, te muestra todo lo que está pasando.',
    'monitor.glb', 7
),
(
    'Mouse', 
    'Te ayuda a mover el cursor y a hacer clic en la pantalla para elegir cosas.', 
    'Es como tu dedo mágico que puede señalar y tocar cualquier cosa en la pantalla.',
    'mouse.glb', 8
);

-- 2.3 Gabinetes
INSERT INTO Gabinete (modelo, imagen, ensambleCompleto) VALUES 
('Gabinete Genérico', 'gabinete.glb', 0),
('Gabinete Gamer RGB', 'gabinete_rgb.glb', 0);

-- 2.4 ESTRUCTURA BASE PARA EL BANCO DE PREGUNTAS
INSERT INTO Usuario (id_usuario, nickname, avatar, puntosAcumulados) VALUES (1, 'Profesor Arquikids', '/static/img/buho.png', 0);

INSERT INTO Simulador (id_simulador, id_gabinete, id_usuario) VALUES (1, 1, 1);

INSERT INTO Evaluacion (id_evaluacion, id_usuario, id_simulador, tipoReto) VALUES (1, 1, 1, 'banco_preguntas');

-- 2.5 Cuestionario con 15 preguntas
INSERT INTO Cuestionario (id_cuestionario, id_evaluacion, totalPreguntas, respuestasCorrectas) VALUES (1, 1, 15, 0);

-- Preguntas (15 en total)
INSERT INTO Pregunta (id_cuestionario, enunciado, opciones, respuestaCorrecta, analogiaRelacionada) VALUES 

(1, '¿Cuál es el componente conocido como el "cerebro" de la computadora?', 'Memoria RAM,Procesador (CPU),Tarjeta Gráfica,Fuente de Poder', 'Procesador (CPU)', 'Como tu cerebro que piensa y da órdenes a todo tu cuerpo.'),

(1, '¿Qué hace la Memoria RAM?', 'Guarda archivos permanentemente,Convierte electricidad en energía,Guarda temporalmente los programas abiertos,Muestra imágenes en pantalla', 'Guarda temporalmente los programas abiertos', 'Como tener muchos cuadernos y libros abiertos en tu mesa de trabajo al mismo tiempo.'),

(1, '¿Qué componente convierte la electricidad del enchufe en energía para la PC?', 'Tarjeta Gráfica,Disco Duro,Refrigeración,Fuente de Poder', 'Fuente de Poder', 'Es como el corazón que bombea la energía (sangre) a todo el cuerpo.'),

(1, '¿Cuál componente guarda todos tus archivos, juegos y fotos de forma PERMANENTE?', 'Memoria RAM,Procesador (CPU),Disco Duro (SSD/HDD),Monitor', 'Disco Duro (SSD/HDD)', 'Es como tu mochila o un gran archivador donde guardas todo para usarlo después.'),

(1, '¿Para qué sirve la Tarjeta Gráfica (GPU)?', 'Enfriar los componentes,Procesar y mostrar imágenes en pantalla,Guardar archivos,Conectar el mouse y teclado', 'Procesar y mostrar imágenes en pantalla', 'Es como un artista súper rápido que dibuja cada escena de tu videojuego favorito.'),

(1, '¿Cuál es la placa principal que conecta a TODOS los componentes de la computadora?', 'Procesador (CPU),Tarjeta Madre (Placa Base),Memoria RAM,Refrigeración', 'Tarjeta Madre (Placa Base)', 'Es como el esqueleto humano o el sistema nervioso: une y conecta todas las partes del cuerpo.'),

(1, '¿Qué componente evita que la computadora se caliente demasiado?', 'Tarjeta Gráfica,Disco Duro,Refrigeración (ventiladores/disipador),Fuente de Poder', 'Refrigeración (ventiladores/disipador)', 'Es como tomar agua fría o sudar cuando haces mucho ejercicio para enfriarte.'),

(1, '¿Qué parte de la computadora te permite VER los juegos, videos y dibujos?', 'Mouse,Teclado,Monitor,Gabinete', 'Monitor', 'Es como la pantalla de tu televisión, pero para la computadora.'),

(1, '¿Qué dispositivo usas para mover el cursor y hacer clic en la pantalla?', 'Teclado,Mouse,Monitor,Procesador', 'Mouse', 'Es como tu dedo mágico que puede señalar y tocar cualquier cosa en la pantalla.'),

(1, '¿Cuál es la diferencia entre la Memoria RAM y el Disco Duro?', 'La RAM es más grande que el Disco Duro,La RAM es temporal y el Disco Duro es permanente,El Disco Duro es el cerebro y la RAM la pantalla,No hay diferencia', 'La RAM es temporal y el Disco Duro es permanente', 'La RAM es como tu mesa de trabajo (lo que usas ahora) y el Disco Duro es como tu mochila (donde guardas todo).'),

(1, '¿Qué podría pasar si una computadora no tiene un buen sistema de refrigeración?', 'Funcionaría más rápido,Se apagaría sola o se dañaría por el calor,La pantalla se vería más bonita,El mouse dejaría de funcionar', 'Se apagaría sola o se dañaría por el calor', 'Como si hicieras ejercicio sin tomar agua: tu cuerpo se calienta y puede enfermarse.'),

(1, '¿Qué componente es MÁS importante para que los videojuegos se vean fluidos y bonitos?', 'Memoria RAM,Disco Duro,Tarjeta Gráfica (GPU),Fuente de Poder', 'Tarjeta Gráfica (GPU)', 'Es el artista que dibuja cada personaje, escenario y explosión en tiempo real.'),

(1, 'El procesador (CPU) es muy importante porque...', 'Guarda todos tus archivos,Muestra las imágenes en la pantalla,Realiza todos los cálculos y decisiones,Conecta todos los componentes', 'Realiza todos los cálculos y decisiones', 'Es como el director de una orquesta: dice a cada músico (componente) qué hacer y cuándo hacerlo.'),

(1, '¿Qué componente es INDISPENSABLE para que la computadora reciba electricidad y pueda encenderse?', 'Tarjeta Gráfica,Disco Duro,Fuente de Poder (PSU),Refrigeración', 'Fuente de Poder (PSU)', 'Sin el corazón (fuente de poder) no llega la energía, igual que sin comida no tienes energía para jugar.'),

(1, 'Si quisieras ARMAR una computadora desde cero, ¿cuál sería el PRIMER componente que deberías instalar en el gabinete?', 'La Tarjeta Gráfica,El Disco Duro,La Tarjeta Madre (Placa Base),La Memoria RAM', 'La Tarjeta Madre (Placa Base)', 'Primero pones el esqueleto (tarjeta madre), luego le agregas los órganos (CPU, RAM, GPU, etc.).');
