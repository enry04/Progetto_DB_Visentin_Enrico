-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Creato il: Mag 22, 2026 alle 16:34
-- Versione del server: 10.4.27-MariaDB
-- Versione PHP: 8.0.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `torneicalcistici`
--

DELIMITER $$
--
-- Procedure
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `getClassificaMarcatoriCompetizione` (IN `codiceTorneo` VARCHAR(50))   BEGIN
	SELECT g.numeroTesseramentoGiocatore, nome, cognome, SUM(gol) AS golSegnati FROM Giocatore g
	INNER JOIN Prestazione p ON g.numeroTesseramentoGiocatore = p.numeroTesseramentoGiocatore 
	INNER JOIN Partita m ON p.codiceGara = m.codiceGara
	WHERE m.codiceCompetizione = codiceTorneo
	GROUP BY p.numeroTesseramentoGiocatore, nome, cognome 
	HAVING golSegnati > 0 ORDER BY golSegnati DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_quintetto_arbitrale` (IN `codicePartita` VARCHAR(50), IN `codiceArbitro` VARCHAR(50), IN `codicePrimoGuardalinee` VARCHAR(50), IN `codiceSecondoGuardalinee` VARCHAR(50), IN `codiceQuartoUomo` VARCHAR(50), IN `codiceAssistenteVAR` VARCHAR(50))   BEGIN
	IF (codiceArbitro = codicePrimoGuardalinee OR 
		codiceArbitro = codiceSecondoGuardalinee OR 
		codiceArbitro = codiceQuartoUomo OR 
		codiceArbitro = codiceAssistenteVAR OR
		codicePrimoGuardalinee = codiceSecondoGuardalinee OR
		codicePrimoGuardalinee = codiceQuartoUomo OR
		codicePrimoGuardalinee = codiceAssistenteVAR OR
		codiceSecondoGuardalinee = codiceQuartoUomo OR 
		codiceSecondoGuardalinee = 	codiceAssistenteVAR OR
		codiceQuartoUomo = codiceAssistenteVAR) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Errore: Gli ufficiali di gara designati per i vari ruoli devono essere persone distinte.';
	ELSE
		INSERT INTO Designazione (numeroTesserinoArbitrale, codiceGara, ruolo) 
		VALUES (codiceArbitro, codicePartita, 'arbitro principale');		
		INSERT INTO Designazione (numeroTesserinoArbitrale, codiceGara, ruolo) 
		VALUES (codicePrimoGuardalinee, codicePartita, 'guardalinee');		
		INSERT INTO Designazione (numeroTesserinoArbitrale, codiceGara, ruolo) 
		VALUES (codiceSecondoGuardalinee, codicePartita, 'guardalinee');		
		INSERT INTO Designazione (numeroTesserinoArbitrale, codiceGara, ruolo) 
		VALUES (codiceQuartoUomo, codicePartita, 'quarto uomo');	
		INSERT INTO Designazione (numeroTesserinoArbitrale, codiceGara, ruolo) 
		VALUES (codiceAssistenteVAR, codicePartita, 'assistente VAR');
	END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `Arbitro`
--

CREATE TABLE `Arbitro` (
  `numeroTesserinoArbitrale` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `cognome` varchar(50) NOT NULL,
  `dataDiNascita` date NOT NULL,
  `sezione` varchar(50) NOT NULL,
  `anniEsperienza` int(11) NOT NULL,
  `livello` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Arbitro`
--

INSERT INTO `Arbitro` (`numeroTesserinoArbitrale`, `nome`, `cognome`, `dataDiNascita`, `sezione`, `anniEsperienza`, `livello`) VALUES
('A_001', 'Daniele', 'Orsato', '1975-11-23', 'Schio', 20, 'Internazionale'),
('A_002', 'Fabio', 'Maresca', '1981-04-12', 'Napoli', 12, 'Nazionale'),
('A_003', 'Simone', 'Sozza', '1987-08-19', 'Seregno', 6, 'Nazionale'),
('A_004', 'Massimiliano', 'Irrati', '1979-06-27', 'Pistoia', 15, 'Internazionale VMO'),
('A_005', 'Davide', 'Massa', '1981-07-15', 'Imperia', 13, 'Internazionale'),
('A_006', 'Marco', 'Guida', '1981-06-07', 'Torre Annunziata', 14, 'Internazionale'),
('A_007', 'Alessandro', 'Prontera', '1986-09-15', 'Bologna', 5, 'Nazionale');

-- --------------------------------------------------------

--
-- Struttura della tabella `Contratto`
--

CREATE TABLE `Contratto` (
  `idContratto` int(11) NOT NULL,
  `numeroTesseramentoGiocatore` varchar(50) NOT NULL,
  `codiceClub` varchar(50) NOT NULL,
  `dataInizio` date NOT NULL,
  `dataFine` date NOT NULL,
  `stipendio` decimal(10,2) NOT NULL,
  `numeroMaglia` int(11) NOT NULL
) ;

--
-- Dump dei dati per la tabella `Contratto`
--

INSERT INTO `Contratto` (`idContratto`, `numeroTesseramentoGiocatore`, `codiceClub`, `dataInizio`, `dataFine`, `stipendio`, `numeroMaglia`) VALUES
(1, 'G_001', 'INTER', '2023-07-01', '2028-06-30', '9000000.00', 10),
(2, 'G_004', 'INTER', '2022-07-01', '2027-06-30', '6500000.00', 23),
(3, 'G_002', 'MILAN', '2024-07-01', '2028-06-30', '7000000.00', 10),
(4, 'G_003', 'JUVENTUS', '2022-01-01', '2026-06-30', '12000000.00', 9),
(5, 'G_004', 'MILAN', '2006-02-01', '2009-07-09', '134343.00', 22);

--
-- Trigger `Contratto`
--
DELIMITER $$
CREATE TRIGGER `before_insert_contratto` BEFORE INSERT ON `Contratto` FOR EACH ROW BEGIN
	DECLARE conflitti INT;			
	SELECT COUNT(*) INTO conflitti FROM contratto c
	WHERE NEW.numeroTesseramentoGiocatore = c.numeroTesseramentoGiocatore AND NEW.dataInizio <= c.dataFine  AND NEW.dataFine >= c.dataInizio;			
	IF conflitti > 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Il giocatore non può avere due contratti attivi contemporaneamente';
	END IF;			
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_numero_maglia` BEFORE INSERT ON `Contratto` FOR EACH ROW BEGIN
	DECLARE conflitti INT;	
	SELECT COUNT(*) INTO conflitti FROM Contratto c WHERE NEW.numeroMaglia = c.numeroMaglia AND NEW.codiceClub = c.codiceClub AND NEW.dataInizio <= c.dataFine AND NEW.dataFine >= c.dataInizio;	
	IF conflitti > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: numero di maglia gia assegnato nella squadra nel periodo indicato';
	END IF;	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `Designazione`
--

CREATE TABLE `Designazione` (
  `idDesignazione` int(11) NOT NULL,
  `numeroTesserinoArbitrale` varchar(50) NOT NULL,
  `codiceGara` varchar(50) NOT NULL,
  `ruolo` varchar(50) NOT NULL DEFAULT 'Primo Arbitro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Designazione`
--

INSERT INTO `Designazione` (`idDesignazione`, `numeroTesserinoArbitrale`, `codiceGara`, `ruolo`) VALUES
(1, 'A_005', 'GARA_002', 'arbitro principale'),
(2, 'A_006', 'GARA_002', 'guardalinee'),
(3, 'A_007', 'GARA_002', 'guardalinee'),
(4, 'A_002', 'GARA_002', 'quarto uomo'),
(5, 'A_004', 'GARA_002', 'assistente VAR'),
(6, 'A_006', 'GARA_003', 'guardalinee'),
(7, 'A_007', 'GARA_003', 'guardalinee'),
(8, 'A_004', 'GARA_003', 'quarto uomo'),
(9, 'A_001', 'GARA_001', 'arbitro principale'),
(10, 'A_002', 'GARA_001', 'guardalinee'),
(11, 'A_003', 'GARA_001', 'guardalinee'),
(12, 'A_004', 'GARA_001', 'quarto uomo'),
(13, 'A_005', 'GARA_001', 'assistente VAR');

--
-- Trigger `Designazione`
--
DELIMITER $$
CREATE TRIGGER `before_insert_designazione` BEFORE INSERT ON `Designazione` FOR EACH ROW BEGIN
	DECLARE conflitti INT;
	DECLARE dataNuovaGara DATE;
	SELECT data INTO dataNuovaGara FROM Partita 
	WHERE codiceGara = NEW.codiceGara; 
	SELECT COUNT(*) INTO conflitti FROM Designazione d
	INNER JOIN Partita p ON d.codiceGara = p.codiceGara
	WHERE d.numeroTesserinoArbitrale = NEW.numeroTesserinoArbitrale AND p.data = dataNuovaGara;
	IF conflitti > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Arbitro gia designato per un altra partita in questa data';
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `Giocatore`
--

CREATE TABLE `Giocatore` (
  `numeroTesseramentoGiocatore` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `cognome` varchar(50) NOT NULL,
  `nazionalita` varchar(50) NOT NULL,
  `dataDiNascita` date NOT NULL,
  `altezza` int(11) NOT NULL,
  `peso` int(11) NOT NULL,
  `ruolo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Giocatore`
--

INSERT INTO `Giocatore` (`numeroTesseramentoGiocatore`, `nome`, `cognome`, `nazionalita`, `dataDiNascita`, `altezza`, `peso`, `ruolo`) VALUES
('G_001', 'Lautaro', 'Martinez', 'Argentina', '1997-08-22', 174, 72, 'Attaccante'),
('G_002', 'Rafael', 'Leao', 'Portogallo', '1999-06-10', 188, 81, 'Attaccante'),
('G_003', 'Dusan', 'Vlahovic', 'Serbia', '2000-01-28', 190, 78, 'Attaccante'),
('G_004', 'Nicolo', 'Barella', 'Italia', '1997-02-07', 172, 68, 'Centrocampista');

-- --------------------------------------------------------

--
-- Struttura della tabella `Partecipazione`
--

CREATE TABLE `Partecipazione` (
  `codiceClub` varchar(50) NOT NULL,
  `codiceCompetizione` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Partecipazione`
--

INSERT INTO `Partecipazione` (`codiceClub`, `codiceCompetizione`) VALUES
('FIORENTINA', 'SERIE_A_26'),
('INTER', 'SERIE_A_26'),
('JUVENTUS', 'SERIE_A_26'),
('MILAN', 'SERIE_A_26');

-- --------------------------------------------------------

--
-- Struttura della tabella `Partita`
--

CREATE TABLE `Partita` (
  `codiceGara` varchar(50) NOT NULL,
  `data` date NOT NULL,
  `orario` time NOT NULL,
  `risultato` varchar(10) DEFAULT NULL,
  `numeroSpettatori` int(11) DEFAULT NULL,
  `stato` varchar(50) NOT NULL DEFAULT 'programmata',
  `codiceCompetizione` varchar(50) NOT NULL,
  `codiceSquadraCasa` varchar(50) NOT NULL,
  `codiceSquadraTrasferta` varchar(50) NOT NULL,
  `codiceImpianto` varchar(50) NOT NULL
) ;

--
-- Dump dei dati per la tabella `Partita`
--

INSERT INTO `Partita` (`codiceGara`, `data`, `orario`, `risultato`, `numeroSpettatori`, `stato`, `codiceCompetizione`, `codiceSquadraCasa`, `codiceSquadraTrasferta`, `codiceImpianto`) VALUES
('GARA_001', '2026-05-10', '20:45:00', '2-0', 72000, 'conclusa', 'SERIE_A_26', 'INTER', 'MILAN', 'STADIO_MI'),
('GARA_002', '2026-05-17', '18:00:00', '0-0', 40000, 'conclusa', 'SERIE_A_26', 'JUVENTUS', 'INTER', 'STADIO_TO'),
('GARA_003', '2026-05-24', '15:00:00', '0-2', 32000, 'conclusa', 'SERIE_A_26', 'FIORENTINA', 'JUVENTUS', 'STADIO_FI');

--
-- Trigger `Partita`
--
DELIMITER $$
CREATE TRIGGER `before_insert_numero_spettatori` BEFORE INSERT ON `Partita` FOR EACH ROW BEGIN
	DECLARE capienzaMassimaStadio INT;	
	IF NEW.numeroSpettatori IS NOT NULL THEN		
		SELECT capienzaMassima INTO capienzaMassimaStadio FROM Stadio s 
		WHERE NEW.codiceImpianto = s.codiceImpianto;	
		IF(NEW.numeroSpettatori > capienzaMassimaStadio) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Il numero di spettatori inserito supera la capienza massima dello stadio.';
		END IF;
	END IF;	
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_numero_spettatori` BEFORE UPDATE ON `Partita` FOR EACH ROW BEGIN
	DECLARE capienzaMassimaStadio INT;	
	SELECT capienzaMassima INTO capienzaMassimaStadio FROM Stadio s 
	WHERE NEW.codiceImpianto = s.codiceImpianto;	
	IF(NEW.numeroSpettatori > capienzaMassimaStadio) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Il numero di spettatori inserito supera la capienza massima dell''impianto.';
	END IF;	
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_risultato_partita` BEFORE UPDATE ON `Partita` FOR EACH ROW BEGIN
	DECLARE golCasa INT DEFAULT 0;
	DECLARE golTrasferta INT DEFAULT 0;
	IF (NEW.risultato IS NOT NULL AND (OLD.risultato IS NULL OR NEW.risultato <> OLD.risultato)) THEN
		IF NOT (NEW.risultato REGEXP '^([0-9]+)-([0-9]+)$') THEN
			SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = 'Errore: Il formato del risultato deve essere del tipo "golCasa-golTrasferta" (es. "2-1").';
		END IF;
	END IF;
	IF (NEW.stato = 'conclusa') THEN
		SELECT IFNULL(SUM(p.gol), 0) INTO golCasa FROM Prestazione p 
		INNER JOIN Contratto c ON p.numeroTesseramentoGiocatore = c.numeroTesseramentoGiocatore
		WHERE p.codiceGara = NEW.codiceGara AND c.codiceClub = NEW.codiceSquadraCasa AND NEW.data BETWEEN c.dataInizio AND c.dataFine;
		SELECT IFNULL(SUM(p.gol), 0) INTO golTrasferta FROM Prestazione p 
		INNER JOIN Contratto c ON p.numeroTesseramentoGiocatore = c.numeroTesseramentoGiocatore
		WHERE p.codiceGara = NEW.codiceGara AND c.codiceClub = NEW.codiceSquadraTrasferta AND NEW.data BETWEEN c.dataInizio AND c.dataFine;
		IF NEW.risultato IS NULL OR NEW.risultato <> CONCAT(golCasa, '-', golTrasferta) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Errore: Risultato inserito non coerente con la somma dei gol dei singoli giocatori.';
		END IF;
	END IF; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `Prestazione`
--

CREATE TABLE `Prestazione` (
  `idPrestazione` int(11) NOT NULL,
  `numeroTesseramentoGiocatore` varchar(50) NOT NULL,
  `codiceGara` varchar(50) NOT NULL,
  `gol` int(11) NOT NULL DEFAULT 0,
  `assist` int(11) NOT NULL DEFAULT 0,
  `cartelliniGialli` int(11) NOT NULL DEFAULT 0,
  `cartelliniRossi` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Prestazione`
--

INSERT INTO `Prestazione` (`idPrestazione`, `numeroTesseramentoGiocatore`, `codiceGara`, `gol`, `assist`, `cartelliniGialli`, `cartelliniRossi`) VALUES
(1, 'G_003', 'GARA_003', 2, 1, 0, 0),
(2, 'G_004', 'GARA_003', 0, 0, 0, 0),
(3, 'G_002', 'GARA_002', 0, 0, 1, 0),
(4, 'G_004', 'GARA_002', 0, 0, 0, 0),
(6, 'G_001', 'GARA_001', 2, 0, 0, 0);

--
-- Trigger `Prestazione`
--
DELIMITER $$
CREATE TRIGGER `before_insert_prestazione` BEFORE INSERT ON `Prestazione` FOR EACH ROW BEGIN
	DECLARE conflitti INT;
	DECLARE dataNuovaGara DATE;		
	SELECT data INTO dataNuovaGara FROM Partita 
	WHERE codiceGara = NEW.codiceGara; 	
	SELECT COUNT(*) INTO conflitti FROM Prestazione p
	INNER JOIN Partita m ON p.codiceGara = m.codiceGara
	WHERE p.numeroTesseramentoGiocatore = NEW.numeroTesseramentoGiocatore AND m.data = dataNuovaGara;	
	IF conflitti > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Il giocatore non puo partecipare a due partite che si disputano nella stessa giornata';
	END IF;	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `Societa`
--

CREATE TABLE `Societa` (
  `codiceFederale` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `dataFondazione` date NOT NULL,
  `numeroTelefono` varchar(20) NOT NULL,
  `email` varchar(50) NOT NULL,
  `cognomePresidente` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Societa`
--

INSERT INTO `Societa` (`codiceFederale`, `nome`, `dataFondazione`, `numeroTelefono`, `email`, `cognomePresidente`) VALUES
('00470470014', 'Juventus Football Club S.p.A.', '1897-11-01', '011987654', 'info@juventus.com', 'Ferrero'),
('00793430158', 'Associazione Calcio Milan S.p.A.', '1899-12-16', '027654321', 'info@acmilan.com', 'Scaroni'),
('01234560151', 'Inter Football Club S.p.A.', '1908-03-09', '021234567', 'info@inter.it', 'Marotta'),
('01452410486', 'ACF Fiorentina S.r.l.', '1926-08-29', '055543210', 'info@acffiorentina.it', 'Commisso');

-- --------------------------------------------------------

--
-- Struttura della tabella `Squadra`
--

CREATE TABLE `Squadra` (
  `codiceClub` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `annoFondazione` int(11) DEFAULT NULL,
  `tipologia` varchar(50) NOT NULL,
  `codiceSocieta` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Squadra`
--

INSERT INTO `Squadra` (`codiceClub`, `nome`, `annoFondazione`, `tipologia`, `codiceSocieta`) VALUES
('FIORENTINA', 'Fiorentina', 1926, 'Professionistica', '01452410486'),
('INTER', 'Inter', 1908, 'Professionistica', '01234560151'),
('JUVENTUS', 'Juventus', 1897, 'Professionistica', '00470470014'),
('MILAN', 'Milan', 1899, 'Professionistica', '00793430158');

-- --------------------------------------------------------

--
-- Struttura della tabella `Stadio`
--

CREATE TABLE `Stadio` (
  `codiceImpianto` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `citta` varchar(50) NOT NULL,
  `via` varchar(50) NOT NULL,
  `numeroCivico` varchar(20) NOT NULL,
  `cap` varchar(10) NOT NULL,
  `capienzaMassima` int(11) NOT NULL,
  `annoCostruzione` int(11) NOT NULL,
  `tipologiaTerreno` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Stadio`
--

INSERT INTO `Stadio` (`codiceImpianto`, `nome`, `citta`, `via`, `numeroCivico`, `cap`, `capienzaMassima`, `annoCostruzione`, `tipologiaTerreno`) VALUES
('STADIO_FI', 'Artemio Franchi', 'Firenze', 'Viale Manfredo Fanti', '4', '50137', 43147, 1931, 'Erba Naturale'),
('STADIO_MI', 'Giuseppe Meazza', 'Milano', 'Via Piccolomini', '5', '20151', 75817, 1926, 'Ibrido'),
('STADIO_TO', 'Allianz Stadium', 'Torino', 'Corso Gaetano Scirea', '50', '10151', 41507, 2011, 'Erba Naturale');

-- --------------------------------------------------------

--
-- Struttura della tabella `Torneo`
--

CREATE TABLE `Torneo` (
  `codiceCompetizione` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `stagioneSportiva` varchar(50) NOT NULL,
  `dataInizio` date NOT NULL,
  `dataFine` date NOT NULL,
  `formato` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `Torneo`
--

INSERT INTO `Torneo` (`codiceCompetizione`, `nome`, `stagioneSportiva`, `dataInizio`, `dataFine`, `formato`) VALUES
('SERIE_A_26', 'Serie A Enilive', '2025/2026', '2025-08-18', '2026-05-24', 'Girone all\'italiana');

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `vistaaffluenzamediastadi`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `vistaaffluenzamediastadi` (
`codiceImpianto` varchar(50)
,`nome` varchar(50)
,`mediaSpettatori` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `vistaclassificavittorie`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `vistaclassificavittorie` (
`codiceClub` varchar(50)
,`nome` varchar(50)
,`numeroVittorie` bigint(21)
);

-- --------------------------------------------------------

--
-- Struttura per vista `vistaaffluenzamediastadi`
--
DROP TABLE IF EXISTS `vistaaffluenzamediastadi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaaffluenzamediastadi`  AS SELECT `s`.`codiceImpianto` AS `codiceImpianto`, `s`.`nome` AS `nome`, avg(`p`.`numeroSpettatori`) AS `mediaSpettatori` FROM (`stadio` `s` join `partita` `p` on(`s`.`codiceImpianto` = `p`.`codiceImpianto`)) GROUP BY `s`.`codiceImpianto`, `s`.`nome` ORDER BY avg(`p`.`numeroSpettatori`) AS `DESCdesc` ASC  ;

-- --------------------------------------------------------

--
-- Struttura per vista `vistaclassificavittorie`
--
DROP TABLE IF EXISTS `vistaclassificavittorie`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaclassificavittorie`  AS SELECT `s`.`codiceClub` AS `codiceClub`, `s`.`nome` AS `nome`, count(0) AS `numeroVittorie` FROM (`squadra` `s` join (select `partita`.`codiceSquadraCasa` AS `codiceSquadra` from `partita` where cast(substring_index(`partita`.`risultato`,'-',1) as unsigned) > cast(substring_index(`partita`.`risultato`,'-',-1) as unsigned) union all select `partita`.`codiceSquadraTrasferta` AS `codiceSquadra` from `partita` where cast(substring_index(`partita`.`risultato`,'-',-1) as unsigned) > cast(substring_index(`partita`.`risultato`,'-',1) as unsigned)) `Vittorie` on(`s`.`codiceClub` = `vittorie`.`codiceSquadra`)) GROUP BY `s`.`codiceClub`, `s`.`nome` ORDER BY count(0) AS `DESCdesc` ASC  ;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `Arbitro`
--
ALTER TABLE `Arbitro`
  ADD PRIMARY KEY (`numeroTesserinoArbitrale`);

--
-- Indici per le tabelle `Contratto`
--
ALTER TABLE `Contratto`
  ADD PRIMARY KEY (`idContratto`),
  ADD KEY `numeroTesseramentoGiocatore` (`numeroTesseramentoGiocatore`),
  ADD KEY `codiceClub` (`codiceClub`);

--
-- Indici per le tabelle `Designazione`
--
ALTER TABLE `Designazione`
  ADD PRIMARY KEY (`idDesignazione`),
  ADD KEY `numeroTesserinoArbitrale` (`numeroTesserinoArbitrale`),
  ADD KEY `codiceGara` (`codiceGara`);

--
-- Indici per le tabelle `Giocatore`
--
ALTER TABLE `Giocatore`
  ADD PRIMARY KEY (`numeroTesseramentoGiocatore`);

--
-- Indici per le tabelle `Partecipazione`
--
ALTER TABLE `Partecipazione`
  ADD PRIMARY KEY (`codiceClub`,`codiceCompetizione`),
  ADD KEY `codiceCompetizione` (`codiceCompetizione`);

--
-- Indici per le tabelle `Partita`
--
ALTER TABLE `Partita`
  ADD PRIMARY KEY (`codiceGara`),
  ADD KEY `codiceCompetizione` (`codiceCompetizione`),
  ADD KEY `codiceSquadraCasa` (`codiceSquadraCasa`),
  ADD KEY `codiceSquadraTrasferta` (`codiceSquadraTrasferta`),
  ADD KEY `codiceImpianto` (`codiceImpianto`);

--
-- Indici per le tabelle `Prestazione`
--
ALTER TABLE `Prestazione`
  ADD PRIMARY KEY (`idPrestazione`),
  ADD UNIQUE KEY `numeroTesseramentoGiocatore` (`numeroTesseramentoGiocatore`,`codiceGara`),
  ADD KEY `codiceGara` (`codiceGara`);

--
-- Indici per le tabelle `Societa`
--
ALTER TABLE `Societa`
  ADD PRIMARY KEY (`codiceFederale`);

--
-- Indici per le tabelle `Squadra`
--
ALTER TABLE `Squadra`
  ADD PRIMARY KEY (`codiceClub`),
  ADD KEY `codiceSocieta` (`codiceSocieta`);

--
-- Indici per le tabelle `Stadio`
--
ALTER TABLE `Stadio`
  ADD PRIMARY KEY (`codiceImpianto`);

--
-- Indici per le tabelle `Torneo`
--
ALTER TABLE `Torneo`
  ADD PRIMARY KEY (`codiceCompetizione`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `Contratto`
--
ALTER TABLE `Contratto`
  MODIFY `idContratto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `Designazione`
--
ALTER TABLE `Designazione`
  MODIFY `idDesignazione` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT per la tabella `Prestazione`
--
ALTER TABLE `Prestazione`
  MODIFY `idPrestazione` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `Contratto`
--
ALTER TABLE `Contratto`
  ADD CONSTRAINT `contratto_ibfk_1` FOREIGN KEY (`numeroTesseramentoGiocatore`) REFERENCES `Giocatore` (`numeroTesseramentoGiocatore`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `contratto_ibfk_2` FOREIGN KEY (`codiceClub`) REFERENCES `Squadra` (`codiceClub`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `Designazione`
--
ALTER TABLE `Designazione`
  ADD CONSTRAINT `designazione_ibfk_1` FOREIGN KEY (`numeroTesserinoArbitrale`) REFERENCES `Arbitro` (`numeroTesserinoArbitrale`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `designazione_ibfk_2` FOREIGN KEY (`codiceGara`) REFERENCES `Partita` (`codiceGara`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `Partecipazione`
--
ALTER TABLE `Partecipazione`
  ADD CONSTRAINT `partecipazione_ibfk_1` FOREIGN KEY (`codiceClub`) REFERENCES `Squadra` (`codiceClub`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `partecipazione_ibfk_2` FOREIGN KEY (`codiceCompetizione`) REFERENCES `Torneo` (`codiceCompetizione`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `Partita`
--
ALTER TABLE `Partita`
  ADD CONSTRAINT `partita_ibfk_1` FOREIGN KEY (`codiceCompetizione`) REFERENCES `Torneo` (`codiceCompetizione`) ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_ibfk_2` FOREIGN KEY (`codiceSquadraCasa`) REFERENCES `Squadra` (`codiceClub`) ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_ibfk_3` FOREIGN KEY (`codiceSquadraTrasferta`) REFERENCES `Squadra` (`codiceClub`) ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_ibfk_4` FOREIGN KEY (`codiceImpianto`) REFERENCES `Stadio` (`codiceImpianto`) ON UPDATE CASCADE;

--
-- Limiti per la tabella `Prestazione`
--
ALTER TABLE `Prestazione`
  ADD CONSTRAINT `prestazione_ibfk_1` FOREIGN KEY (`numeroTesseramentoGiocatore`) REFERENCES `Giocatore` (`numeroTesseramentoGiocatore`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prestazione_ibfk_2` FOREIGN KEY (`codiceGara`) REFERENCES `Partita` (`codiceGara`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `Squadra`
--
ALTER TABLE `Squadra`
  ADD CONSTRAINT `squadra_ibfk_1` FOREIGN KEY (`codiceSocieta`) REFERENCES `Societa` (`codiceFederale`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
