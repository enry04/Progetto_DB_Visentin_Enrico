-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mag 21, 2026 alle 18:44
-- Versione del server: 10.4.32-MariaDB
-- Versione PHP: 8.2.12

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_sestetto_arbitrale` (IN `codicePartita` VARCHAR(50), IN `codiceArbitro` VARCHAR(50), IN `codicePrimoGuardalinee` VARCHAR(50), IN `codiceSecondoGuardalinee` VARCHAR(50), IN `codiceQuartoUomo` VARCHAR(50), IN `codiceAssistenteVAR` VARCHAR(50))   BEGIN
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
-- Struttura della tabella `arbitro`
--

CREATE TABLE `arbitro` (
  `numeroTesserinoArbitrale` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `cognome` varchar(50) NOT NULL,
  `dataDiNascita` date NOT NULL,
  `sezione` varchar(50) NOT NULL,
  `anniEsperienza` int(11) NOT NULL,
  `livello` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `arbitro`
--

INSERT INTO `arbitro` (`numeroTesserinoArbitrale`, `nome`, `cognome`, `dataDiNascita`, `sezione`, `anniEsperienza`, `livello`) VALUES
('ARB01', 'Daniele', 'Orsato', '1975-11-23', 'Schio', 20, 'Internazionale'),
('ARB02', 'Fabio', 'Maresca', '1981-04-12', 'Napoli', 12, 'A e B'),
('ARB03', 'Elena', 'Tambini', '1988-01-01', 'Como', 8, 'A e B'),
('ARB04', 'Luca', 'Pairetto', '1984-04-14', 'Nichelino', 10, 'A e B'),
('ARB05', 'Paolo', 'Valeri', '1978-05-16', 'Roma 2', 15, 'Internazionale'),
('ARB06', 'Gianluca', 'Rocchi', '1973-08-25', 'Firenze', 18, 'Internazionale'),
('ARB07', 'Davide', 'Massa', '1981-07-15', 'Imperia', 11, 'A e B');

-- --------------------------------------------------------

--
-- Struttura della tabella `contratto`
--

CREATE TABLE `contratto` (
  `idContratto` int(11) NOT NULL,
  `numeroTesseramentoGiocatore` varchar(50) NOT NULL,
  `codiceClub` varchar(50) NOT NULL,
  `dataInizio` date NOT NULL,
  `dataFine` date NOT NULL,
  `stipendio` decimal(10,2) NOT NULL,
  `numeroMaglia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `contratto`
--

INSERT INTO `contratto` (`idContratto`, `numeroTesseramentoGiocatore`, `codiceClub`, `dataInizio`, `dataFine`, `stipendio`, `numeroMaglia`) VALUES
(1, 'GIO10', 'SQ01', '2025-07-01', '2026-06-30', 9000000.00, 10),
(2, 'GIO11', 'SQ02', '2025-07-01', '2026-06-30', 7000000.00, 10),
(3, 'GIO12', 'SQ03', '2025-07-01', '2026-06-30', 8000000.00, 9);

--
-- Trigger `contratto`
--
DELIMITER $$
CREATE TRIGGER `before_insert_contratto` BEFORE INSERT ON `contratto` FOR EACH ROW BEGIN
	DECLARE conflitti INT;			
	SELECT COUNT(*) INTO conflitti FROM contratto c
	WHERE NEW.numeroTesseramentoGiocatore = c.numeroTesseramentoGiocatore AND NEW.dataInizio <= c.dataFine  AND NEW.dataFine >= c.dataInizio;			
	IF conflitti > 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Giocatore gia presente in un contratto con un altra squadra';
	END IF;			
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_numero_maglia` BEFORE INSERT ON `contratto` FOR EACH ROW BEGIN
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
-- Struttura della tabella `designazione`
--

CREATE TABLE `designazione` (
  `idDesignazione` int(11) NOT NULL,
  `numeroTesserinoArbitrale` varchar(50) NOT NULL,
  `codiceGara` varchar(50) NOT NULL,
  `ruolo` varchar(50) NOT NULL DEFAULT 'Primo Arbitro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `designazione`
--

INSERT INTO `designazione` (`idDesignazione`, `numeroTesserinoArbitrale`, `codiceGara`, `ruolo`) VALUES
(1, 'ARB01', 'MATCH01', 'arbitro principale'),
(2, 'ARB02', 'MATCH01', 'guardalinee'),
(3, 'ARB03', 'MATCH01', 'guardalinee'),
(4, 'ARB04', 'MATCH01', 'quarto uomo'),
(5, 'ARB05', 'MATCH02', 'arbitro principale'),
(6, 'ARB06', 'MATCH02', 'guardalinee'),
(7, 'ARB07', 'MATCH02', 'guardalinee'),
(8, 'ARB01', 'MATCH03', 'arbitro principale'),
(9, 'ARB02', 'MATCH03', 'guardalinee'),
(10, 'ARB03', 'MATCH04', 'arbitro principale'),
(11, 'ARB04', 'MATCH04', 'guardalinee'),
(14, 'ARB01', 'MATCH05', 'arbitro principale'),
(15, 'ARB02', 'MATCH05', 'guardalinee'),
(16, 'ARB03', 'MATCH05', 'guardalinee'),
(17, 'ARB04', 'MATCH05', 'quarto uomo'),
(18, 'ARB05', 'MATCH05', 'assistente VAR');

--
-- Trigger `designazione`
--
DELIMITER $$
CREATE TRIGGER `before_insert_designazione` BEFORE INSERT ON `designazione` FOR EACH ROW BEGIN
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
-- Struttura della tabella `giocatore`
--

CREATE TABLE `giocatore` (
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
-- Dump dei dati per la tabella `giocatore`
--

INSERT INTO `giocatore` (`numeroTesseramentoGiocatore`, `nome`, `cognome`, `nazionalita`, `dataDiNascita`, `altezza`, `peso`, `ruolo`) VALUES
('GIO10', 'Lautaro', 'Martinez', 'Argentina', '1997-08-22', 174, 72, 'Attaccante'),
('GIO11', 'Rafael', 'Leao', 'Portogallo', '1999-06-10', 188, 81, 'Attaccante'),
('GIO12', 'Dusan', 'Vlahovic', 'Serbia', '2000-01-28', 190, 88, 'Attaccante');

-- --------------------------------------------------------

--
-- Struttura della tabella `partecipazione`
--

CREATE TABLE `partecipazione` (
  `codiceClub` varchar(50) NOT NULL,
  `codiceCompetizione` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `partecipazione`
--

INSERT INTO `partecipazione` (`codiceClub`, `codiceCompetizione`) VALUES
('SQ01', 'TOR26'),
('SQ02', 'TOR26'),
('SQ03', 'TOR26');

-- --------------------------------------------------------

--
-- Struttura della tabella `partita`
--

CREATE TABLE `partita` (
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
-- Dump dei dati per la tabella `partita`
--

INSERT INTO `partita` (`codiceGara`, `data`, `orario`, `risultato`, `numeroSpettatori`, `stato`, `codiceCompetizione`, `codiceSquadraCasa`, `codiceSquadraTrasferta`, `codiceImpianto`) VALUES
('MATCH01', '2026-05-24', '20:45:00', NULL, 75000, 'programmata', 'TOR26', 'SQ01', 'SQ02', 'ST01'),
('MATCH02', '2026-05-24', '15:00:00', NULL, 40000, 'programmata', 'TOR26', 'SQ03', 'SQ01', 'ST02'),
('MATCH03', '2026-05-28', '20:45:00', '1-2', 68000, 'conclusa', 'TOR26', 'SQ02', 'SQ03', 'ST01'),
('MATCH04', '2026-05-31', '18:00:00', '0-2', 41000, 'conclusa', 'TOR26', 'SQ03', 'SQ01', 'ST02'),
('MATCH05', '2026-06-05', '20:45:00', NULL, NULL, 'programmata', 'TOR26', 'SQ01', 'SQ03', 'ST01'),
('MATCH06', '2026-06-12', '18:00:00', '0-0', NULL, 'conclusa', 'TOR26', 'SQ02', 'SQ01', 'ST01');

--
-- Trigger `partita`
--
DELIMITER $$
CREATE TRIGGER `before_insert_numero_spettatori` BEFORE INSERT ON `partita` FOR EACH ROW BEGIN
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
CREATE TRIGGER `before_update_numero_spettatori` BEFORE UPDATE ON `partita` FOR EACH ROW BEGIN
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
CREATE TRIGGER `before_update_risultato_partita` BEFORE UPDATE ON `partita` FOR EACH ROW BEGIN
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
-- Struttura della tabella `prestazione`
--

CREATE TABLE `prestazione` (
  `idPrestazione` int(11) NOT NULL,
  `numeroTesseramentoGiocatore` varchar(50) NOT NULL,
  `codiceGara` varchar(50) NOT NULL,
  `gol` int(11) NOT NULL DEFAULT 0,
  `assist` int(11) NOT NULL DEFAULT 0,
  `cartelliniGialli` int(11) NOT NULL DEFAULT 0,
  `cartelliniRossi` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `prestazione`
--

INSERT INTO `prestazione` (`idPrestazione`, `numeroTesseramentoGiocatore`, `codiceGara`, `gol`, `assist`, `cartelliniGialli`, `cartelliniRossi`) VALUES
(1, 'GIO10', 'MATCH01', 2, 0, 0, 0),
(2, 'GIO11', 'MATCH01', 1, 1, 0, 0),
(3, 'GIO12', 'MATCH02', 1, 0, 1, 0),
(4, 'GIO11', 'MATCH03', 1, 0, 0, 0),
(5, 'GIO12', 'MATCH03', 2, 0, 1, 0),
(6, 'GIO10', 'MATCH04', 2, 0, 0, 0);

--
-- Trigger `prestazione`
--
DELIMITER $$
CREATE TRIGGER `before_insert_prestazione` BEFORE INSERT ON `prestazione` FOR EACH ROW BEGIN
	DECLARE conflitti INT;
	DECLARE dataNuovaGara DATE;		
	SELECT data INTO dataNuovaGara FROM Partita 
	WHERE codiceGara = NEW.codiceGara; 	
	SELECT COUNT(*) INTO conflitti FROM Prestazione p
	INNER JOIN Partita m ON p.codiceGara = m.codiceGara
	WHERE p.numeroTesseramentoGiocatore = NEW.numeroTesseramentoGiocatore AND m.data = dataNuovaGara;	
	IF conflitti > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Giocatore gia partecipe ad una partita che si svolge nella stessa giornata';
	END IF;	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `societa`
--

CREATE TABLE `societa` (
  `codiceFederale` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `dataFondazione` date NOT NULL,
  `numeroTelefono` varchar(20) NOT NULL,
  `email` varchar(50) NOT NULL,
  `cognomePresidente` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `societa`
--

INSERT INTO `societa` (`codiceFederale`, `nome`, `dataFondazione`, `numeroTelefono`, `email`, `cognomePresidente`) VALUES
('SOC01', 'F.C. Internazionale', '1908-03-09', '021234567', 'info@inter.it', 'Marotta'),
('SOC02', 'Milan A.C.', '1899-12-16', '027654321', 'info@milan.it', 'Scaroni'),
('SOC03', 'Juventus F.C.', '1897-11-01', '011987654', 'info@juventus.it', 'Ferrero');

-- --------------------------------------------------------

--
-- Struttura della tabella `squadra`
--

CREATE TABLE `squadra` (
  `codiceClub` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `annoFondazione` int(11) DEFAULT NULL,
  `tipologia` varchar(50) NOT NULL,
  `codiceSocieta` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `squadra`
--

INSERT INTO `squadra` (`codiceClub`, `nome`, `annoFondazione`, `tipologia`, `codiceSocieta`) VALUES
('SQ01', 'Inter Prima Squadra', 1908, 'Professionistica', 'SOC01'),
('SQ02', 'Milan Prima Squadra', 1899, 'Professionistica', 'SOC02'),
('SQ03', 'Juventus Prima Squadra', 1897, 'Professionistica', 'SOC03');

-- --------------------------------------------------------

--
-- Struttura della tabella `stadio`
--

CREATE TABLE `stadio` (
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
-- Dump dei dati per la tabella `stadio`
--

INSERT INTO `stadio` (`codiceImpianto`, `nome`, `citta`, `via`, `numeroCivico`, `cap`, `capienzaMassima`, `annoCostruzione`, `tipologiaTerreno`) VALUES
('ST01', 'Giuseppe Meazza', 'Milano', 'Via dei Piccolomini', '5', '20151', 80000, 1926, 'Erba Naturale'),
('ST02', 'Allianz Stadium', 'Torino', 'Corso Gaetano Scirea', '50', '10151', 41500, 2011, 'Erba Ibrida');

-- --------------------------------------------------------

--
-- Struttura della tabella `torneo`
--

CREATE TABLE `torneo` (
  `codiceCompetizione` varchar(50) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `stagioneSportiva` varchar(50) NOT NULL,
  `dataInizio` date NOT NULL,
  `dataFine` date NOT NULL,
  `formato` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `torneo`
--

INSERT INTO `torneo` (`codiceCompetizione`, `nome`, `stagioneSportiva`, `dataInizio`, `dataFine`, `formato`) VALUES
('TOR26', 'Serie A Enilive', '2025/2026', '2025-08-23', '2026-05-31', 'Girone all\'italiana');

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

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaaffluenzamediastadi`  AS SELECT `s`.`codiceImpianto` AS `codiceImpianto`, `s`.`nome` AS `nome`, avg(`p`.`numeroSpettatori`) AS `mediaSpettatori` FROM (`stadio` `s` join `partita` `p` on(`s`.`codiceImpianto` = `p`.`codiceImpianto`)) GROUP BY `s`.`codiceImpianto`, `s`.`nome` ORDER BY avg(`p`.`numeroSpettatori`) DESC ;

-- --------------------------------------------------------

--
-- Struttura per vista `vistaclassificavittorie`
--
DROP TABLE IF EXISTS `vistaclassificavittorie`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaclassificavittorie`  AS SELECT `s`.`codiceClub` AS `codiceClub`, `s`.`nome` AS `nome`, count(0) AS `numeroVittorie` FROM (`squadra` `s` join (select `partita`.`codiceSquadraCasa` AS `codiceSquadra` from `partita` where cast(substring_index(`partita`.`risultato`,'-',1) as unsigned) > cast(substring_index(`partita`.`risultato`,'-',-1) as unsigned) union all select `partita`.`codiceSquadraTrasferta` AS `codiceSquadra` from `partita` where cast(substring_index(`partita`.`risultato`,'-',-1) as unsigned) > cast(substring_index(`partita`.`risultato`,'-',1) as unsigned)) `vittorie` on(`s`.`codiceClub` = `vittorie`.`codiceSquadra`)) GROUP BY `s`.`codiceClub`, `s`.`nome` ORDER BY count(0) DESC ;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `arbitro`
--
ALTER TABLE `arbitro`
  ADD PRIMARY KEY (`numeroTesserinoArbitrale`);

--
-- Indici per le tabelle `contratto`
--
ALTER TABLE `contratto`
  ADD PRIMARY KEY (`idContratto`),
  ADD KEY `numeroTesseramentoGiocatore` (`numeroTesseramentoGiocatore`),
  ADD KEY `codiceClub` (`codiceClub`);

--
-- Indici per le tabelle `designazione`
--
ALTER TABLE `designazione`
  ADD PRIMARY KEY (`idDesignazione`),
  ADD KEY `numeroTesserinoArbitrale` (`numeroTesserinoArbitrale`),
  ADD KEY `codiceGara` (`codiceGara`);

--
-- Indici per le tabelle `giocatore`
--
ALTER TABLE `giocatore`
  ADD PRIMARY KEY (`numeroTesseramentoGiocatore`);

--
-- Indici per le tabelle `partecipazione`
--
ALTER TABLE `partecipazione`
  ADD PRIMARY KEY (`codiceClub`,`codiceCompetizione`),
  ADD KEY `codiceCompetizione` (`codiceCompetizione`);

--
-- Indici per le tabelle `partita`
--
ALTER TABLE `partita`
  ADD PRIMARY KEY (`codiceGara`),
  ADD KEY `codiceCompetizione` (`codiceCompetizione`),
  ADD KEY `codiceSquadraCasa` (`codiceSquadraCasa`),
  ADD KEY `codiceSquadraTrasferta` (`codiceSquadraTrasferta`),
  ADD KEY `codiceImpianto` (`codiceImpianto`);

--
-- Indici per le tabelle `prestazione`
--
ALTER TABLE `prestazione`
  ADD PRIMARY KEY (`idPrestazione`),
  ADD UNIQUE KEY `numeroTesseramentoGiocatore` (`numeroTesseramentoGiocatore`,`codiceGara`),
  ADD KEY `codiceGara` (`codiceGara`);

--
-- Indici per le tabelle `societa`
--
ALTER TABLE `societa`
  ADD PRIMARY KEY (`codiceFederale`);

--
-- Indici per le tabelle `squadra`
--
ALTER TABLE `squadra`
  ADD PRIMARY KEY (`codiceClub`),
  ADD KEY `codiceSocieta` (`codiceSocieta`);

--
-- Indici per le tabelle `stadio`
--
ALTER TABLE `stadio`
  ADD PRIMARY KEY (`codiceImpianto`);

--
-- Indici per le tabelle `torneo`
--
ALTER TABLE `torneo`
  ADD PRIMARY KEY (`codiceCompetizione`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `contratto`
--
ALTER TABLE `contratto`
  MODIFY `idContratto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT per la tabella `designazione`
--
ALTER TABLE `designazione`
  MODIFY `idDesignazione` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT per la tabella `prestazione`
--
ALTER TABLE `prestazione`
  MODIFY `idPrestazione` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `contratto`
--
ALTER TABLE `contratto`
  ADD CONSTRAINT `contratto_ibfk_1` FOREIGN KEY (`numeroTesseramentoGiocatore`) REFERENCES `giocatore` (`numeroTesseramentoGiocatore`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `contratto_ibfk_2` FOREIGN KEY (`codiceClub`) REFERENCES `squadra` (`codiceClub`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `designazione`
--
ALTER TABLE `designazione`
  ADD CONSTRAINT `designazione_ibfk_1` FOREIGN KEY (`numeroTesserinoArbitrale`) REFERENCES `arbitro` (`numeroTesserinoArbitrale`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `designazione_ibfk_2` FOREIGN KEY (`codiceGara`) REFERENCES `partita` (`codiceGara`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `partecipazione`
--
ALTER TABLE `partecipazione`
  ADD CONSTRAINT `partecipazione_ibfk_1` FOREIGN KEY (`codiceClub`) REFERENCES `squadra` (`codiceClub`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `partecipazione_ibfk_2` FOREIGN KEY (`codiceCompetizione`) REFERENCES `torneo` (`codiceCompetizione`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `partita`
--
ALTER TABLE `partita`
  ADD CONSTRAINT `partita_ibfk_1` FOREIGN KEY (`codiceCompetizione`) REFERENCES `torneo` (`codiceCompetizione`) ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_ibfk_2` FOREIGN KEY (`codiceSquadraCasa`) REFERENCES `squadra` (`codiceClub`) ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_ibfk_3` FOREIGN KEY (`codiceSquadraTrasferta`) REFERENCES `squadra` (`codiceClub`) ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_ibfk_4` FOREIGN KEY (`codiceImpianto`) REFERENCES `stadio` (`codiceImpianto`) ON UPDATE CASCADE;

--
-- Limiti per la tabella `prestazione`
--
ALTER TABLE `prestazione`
  ADD CONSTRAINT `prestazione_ibfk_1` FOREIGN KEY (`numeroTesseramentoGiocatore`) REFERENCES `giocatore` (`numeroTesseramentoGiocatore`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prestazione_ibfk_2` FOREIGN KEY (`codiceGara`) REFERENCES `partita` (`codiceGara`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `squadra`
--
ALTER TABLE `squadra`
  ADD CONSTRAINT `squadra_ibfk_1` FOREIGN KEY (`codiceSocieta`) REFERENCES `societa` (`codiceFederale`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
